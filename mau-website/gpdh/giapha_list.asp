<%
' ====================================================
' 0. KIỂM TRA QUYỀN TRUY CẬP TRANG QUẢN LÝ PHẢ HỆ
' ====================================================
If is_super = 0 And is_genealogy = 0 Then
    Response.Write "<script>alert('Bạn không có quyền truy cập vào chức năng Quản lý Phả hệ!'); window.history.back();</script>"
    Response.End
End If

' Khởi tạo biến phân quyền nhánh từ Session của hệ thống
Dim allowed_root
allowed_root = CInt("0" & Session("allowed_start_idgiapha"))

' ====================================================
' KHAI BÁO BIẾN TOÀN CỤC CHO MẢNG DỮ LIỆU TỐI ƯU
' ====================================================
Dim allMembersArray, allSpousesArray
Dim numMembers, numSpouses
numMembers = -1
numSpouses = -1

' HÀM TẢI TOÀN BỘ GIA PHẢ VÀO MẢNG RAM
Sub LoadGenealogyArrays()
    Dim rsAll, rsSpouses
    
    ' 1. Lấy tất cả nhân vật chính (Không phải vợ/chồng)
    Set rsAll = conn.Execute("SELECT g.idgiapha, g.idcha, g.iddoi, g.hoten, g.thutu, g.gioitinh, g.loai_quanhe, d.tieude AS doi_tieude FROM tblgiapha g LEFT JOIN tbldoi d ON g.iddoi = d.iddoi WHERE (g.loai_quanhe IS NULL OR g.loai_quanhe <> 2) ORDER BY g.thutu ASC")
    If Not rsAll.EOF Then
        allMembersArray = rsAll.GetRows()
        numMembers = UBound(allMembersArray, 2)
    End If
    rsAll.Close
    Set rsAll = Nothing

    ' 2. Lấy tất cả thông tin vợ/chồng
    Set rsSpouses = conn.Execute("SELECT id_vochong, idgiapha, hoten FROM tblgiapha WHERE loai_quanhe = 2 ORDER BY thutu ASC, idgiapha ASC")
    If Not rsSpouses.EOF Then
        allSpousesArray = rsSpouses.GetRows()
        numSpouses = UBound(allSpousesArray, 2)
    End If
    rsSpouses.Close
    Set rsSpouses = Nothing
End Sub

' ====================================================
' 1. XỬ LÝ NÚT LÊN / XUỐNG THỨ TỰ (CÓ BẢO MẬT NHÁNH)
' ====================================================
action_req = Request.QueryString("action")
id_move = Request.QueryString("id")
idcha_move = Request.QueryString("idcha")

If action_req = "moveup" Or action_req = "movedown" Then
    If Not CheckGenealogyPermission(Session("idadmin"), id_move) Then
        Response.Write "<script>alert('Lỗi bảo mật: Bạn không có quyền di chuyển nhân vật này do không thuộc nhánh quản lý!'); window.location.href = window.location.pathname;</script>"
        Response.End
    End If

    openconn
    Set rs1 = conn.Execute("SELECT thutu, idcha FROM tblgiapha WHERE idgiapha=" & CInt(id_move))
    If Not rs1.EOF Then 
        thutu = CInt(rs1("thutu"))
        idcha_move = CInt(rs1("idcha"))
    End If
    rs1.Close
    
    If action_req = "moveup" Then
        sql = "SELECT TOP 1 idgiapha, thutu FROM tblgiapha WHERE idcha=" & idcha_move & " AND thutu < " & thutu & " ORDER BY thutu DESC"
    Else
        sql = "SELECT TOP 1 idgiapha, thutu FROM tblgiapha WHERE idcha=" & idcha_move & " AND thutu > " & thutu & " ORDER BY thutu ASC"
    End If
    
    Set rs2 = conn.Execute(sql)
    If Not rs2.EOF Then
        id_action = CInt(rs2("idgiapha"))
        j = CInt(rs2("thutu"))
        
        Conn.Execute("UPDATE tblgiapha SET thutu=" & j & " WHERE idgiapha=" & CInt(id_move))
        Conn.Execute("UPDATE tblgiapha SET thutu=" & thutu & " WHERE idgiapha=" & id_action)
    End If
    rs2.Close
    destroyconn
    Response.Write "<script>window.location.href = window.location.pathname;</script>"
    Response.End
End If

' ====================================================
' 2. XỬ LÝ XÓA BẢN GHI (CÓ BẢO MẬT, CHẶN PHỤ THUỘC & DỒN SỐ)
' ====================================================
If action_req = "del_one" Then
    nid_del = Replace(Request.QueryString("nid"), "'", "''")
    
    If Not CheckGenealogyPermission(Session("idadmin"), nid_del) Then
        Response.Write "<script>alert('Lỗi bảo mật: Bạn không có quyền xóa nhân vật này!'); window.location.href = window.location.pathname;</script>"
        Response.End
    End If

    openconn
    
    ' 2.1 KIỂM TRA RÀNG BUỘC PHỤ THUỘC (CON CÁI, VỢ/CHỒNG)
    Dim rsCheckDep, countDep
    countDep = 0
    Set rsCheckDep = Conn.Execute("SELECT COUNT(idgiapha) AS totalDep FROM tblgiapha WHERE idcha=" & CInt(nid_del) & " OR (id_vochong=" & CInt(nid_del) & " AND loai_quanhe = 2)")
    If Not rsCheckDep.EOF Then
        countDep = CInt(rsCheckDep("totalDep"))
    End If
    rsCheckDep.Close
    Set rsCheckDep = Nothing

    ' Nếu có người phụ thuộc, hủy thao tác xóa và giữ nguyên trang
    If countDep > 0 Then
        destroyconn
        Response.Write "<script language='javascript'>alert('TỪ CHỐI XÓA: Nhân vật này đang có " & countDep & " người phụ thuộc (vợ, chồng hoặc con cái).\n\nVui lòng xóa các nhân vật phụ thuộc trước khi xóa nhân vật này để đảm bảo tính toàn vẹn của phả đồ!'); window.location.href = window.location.pathname;</script>"
        Response.End
    End If
    
    ' 2.2 NẾU HỢP LỆ, LẤY THÔNG TIN ĐỂ DỒN SỐ
    Dim rsDelInfo, parentID, spouseID, isSpouse
    Set rsDelInfo = Conn.Execute("SELECT idcha, id_vochong, loai_quanhe FROM tblgiapha WHERE idgiapha=" & CInt(nid_del))
    If Not rsDelInfo.EOF Then
        parentID = rsDelInfo("idcha")
        spouseID = rsDelInfo("id_vochong")
        isSpouse = rsDelInfo("loai_quanhe")
    End If
    rsDelInfo.Close
    Set rsDelInfo = Nothing

    ' 2.3 THỰC THI XÓA
    Conn.execute("DELETE FROM tblgiapha WHERE idgiapha=" & CInt(nid_del))

    ' 2.4 DỒN SỐ THỨ TỰ
    Dim rsResequence, newOrder, sqlSelect
    newOrder = 1
    
    If isSpouse = "2" Then
        sqlSelect = "SELECT idgiapha, thutu FROM tblgiapha WHERE id_vochong=" & CInt(spouseID) & " AND loai_quanhe = 2 ORDER BY thutu ASC, idgiapha ASC"
    Else
        sqlSelect = "SELECT idgiapha, thutu FROM tblgiapha WHERE idcha=" & CInt(parentID) & " AND (loai_quanhe IS NULL OR loai_quanhe <> 2) ORDER BY thutu ASC, idgiapha ASC"
    End If

    Set rsResequence = Conn.Execute(sqlSelect)
    Do While Not rsResequence.EOF
        If CInt(rsResequence("thutu")) <> newOrder Then
            Conn.Execute("UPDATE tblgiapha SET thutu=" & newOrder & " WHERE idgiapha=" & rsResequence("idgiapha"))
        End If
        newOrder = newOrder + 1
        rsResequence.MoveNext
    Loop
    rsResequence.Close
    Set rsResequence = Nothing

    destroyconn
%>
<script language="javascript">
    alert("Đã xóa nhân vật và tự động chuẩn hóa lại số thứ tự thành công!");
    window.location.href = window.location.pathname;
</script>
<%
    Response.End
End If
%>

<script>
function del_one(nid, hoten, danhXung) {
  if (confirm("Bạn chắc chắn muốn xóa " + danhXung + " " + hoten + " khỏi gia phả?")) {
    document.location.href = "?action=del_one&nid=" + nid;
  }
}
</script>

<style>
    body, html, input, select, textarea, button {
        font-family: <%=currentFont%> !important;
        font-size: <%=currentFontSize%> !important;
    }

    h1 { font-size: calc(<%=currentFontSize%> * 1.8); }
    h2 { font-size: calc(<%=currentFontSize%> * 1.5); }
    h3 { font-size: calc(<%=currentFontSize%> * 1.25); }

    .table-responsive { 
        width: 100%; 
        overflow-x: auto; 
        margin-top: 15px; 
        border: 1px solid #cbd5e1; 
        border-radius: 6px; 
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        background: #fff;
    }

    .table-matrix { 
        width: 100%; 
        border-collapse: collapse; 
        font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;
    }
    
    /* Cố định tiêu đề khi cuộn */
    .table-matrix th { 
        background-color: #f1f5f9; 
        padding: 12px 10px; 
        border: 1px solid #cbd5e1; 
        font-weight: bold; 
        white-space: nowrap; 
        text-align: center; 
        color: #0f172a; 
        text-transform: uppercase; 
        letter-spacing: 0.5px;
        position: sticky;
        top: 0;
        z-index: 10;
    }
    .table-matrix td { 
        border: 1px solid #e2e8f0; 
        padding: 10px 14px; 
        vertical-align: middle; 
        white-space: nowrap; 
        color: #334155; 
    }

    .row-male { background-color: #ffffff; }
    .row-female { background-color: #fff1f2; } 
    .row-ngoai { background-color: #fefce8; } 
    .table-matrix tr:hover td { background-color: #f8fafc; }

    .btn-action { 
        margin: 0 5px; 
        text-decoration: none; 
        display: inline-block; 
        vertical-align: middle; 
        font-size: 1.5em; 
        transition: transform 0.2s ease, color 0.2s ease; 
    }
    .btn-add-child { color: #10b981; } 
    .btn-add-spouse { color: #e11d48; } 
    .btn-view { color: #0ea5e9; } 
    .btn-edit { color: #f59e0b; } 
    .btn-delete { color: #dc2626; } 
    .btn-action:hover { transform: scale(1.25); }

    .btn-move { 
        display: inline-flex; 
        align-items: center; 
        justify-content: center; 
        width: 24px; 
        height: 24px; 
        background: #f1f5f9; 
        color: #475569; 
        text-align: center; 
        border-radius: 4px; 
        font-size: 0.85em; 
        text-decoration: none; 
        margin: 0 2px; 
        border: 1px solid #cbd5e1;
        transition: all 0.2s; 
    }
    .btn-move:hover { background: #0a69db; color: #fff; border-color: #0a69db; }

    .member-link {
        cursor: pointer;
        color: #0a69db;
        text-decoration: none !important;
        font-family: <%=currentFont%> !important; font-size: 15px;
        transition: color 0.2s;
    }
    .member-link:hover {
        color: #0284c7;
        text-decoration: none !important;
    }

    .spouse-name { color: #64748b; font-weight: normal;}
    .spouse-separator { color: #e11d48; margin: 0 4px; font-weight: bold; }
    .highlight-name { background-color: #fef08a; color: #000; padding: 2px 6px; border-radius: 4px; font-weight: bold; box-shadow: 0 1px 2px rgba(0,0,0,0.1); }

    #contextMenu { 
        display: none; 
        position: absolute; 
        background: #fff; 
        border: 1px solid #cbd5e1; 
        box-shadow: 0 10px 25px -5px rgba(0,0,0,0.15); 
        border-radius: 8px; 
        z-index: 99999; 
        min-width: 260px; 
        padding: 6px 0; 
        font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;
    }
    #contextMenu .menu-header { 
        padding: 10px 15px; 
        background: #f8fafc; 
        font-weight: bold; 
        border-bottom: 1px solid #e2e8f0; 
        color: #0f172a; 
    }
    #contextMenu a { 
        display: flex; 
        align-items: center; 
        gap: 10px; 
        padding: 10px 15px; 
        color: #334155; 
        text-decoration: none; 
        transition: 0.2s; 
    }
    #contextMenu a:hover { background: #f1f5f9; color: #0a69db; }
    #contextMenu a i { width: 16px; text-align: center; }

    #filterForm {
        background: #f8fafc; 
        padding: 18px; 
        border: 1px solid #e2e8f0; 
        border-radius: 8px; 
        margin-bottom: 20px; 
        display: flex; 
        flex-wrap: wrap; 
        gap: 15px; 
        align-items: flex-end;
    }
    #filterForm .form-input, #filterForm .form-select {
        padding: 9px 12px;
        border: 1px solid #cbd5e1;
        border-radius: 4px;
        font-size: 14px;
        background: #fff;
        font-family: inherit;
    }
    
    /* CSS cho cụm lọc */
    .filter-group { display: flex; flex-direction: column; gap: 5px; }
    .filter-label { font-size: 0.9em; font-weight: bold; color: #64748b; }
    .filter-actions { display: flex; gap: 8px; align-items: flex-end; }
    .filter-exports { margin-left: auto; display: flex; gap: 8px; }

    @media print {
        .no-print, form, .btn-action, .btn-move { display: none !important; }
        .table-responsive { border: none; overflow: visible; box-shadow: none; }
        .table-matrix th { background-color: #f1f5f9 !important; -webkit-print-color-adjust: exact; position: static; }
        .admin-card { border: none; box-shadow: none; }
        .admin-card-header { display: none; }
    }
</style>

<div class="admin-card">
    <div class="admin-card-header no-print">
        <i class="fa fa-sitemap"></i> QUẢN LÝ PHẢ ĐỒ DÒNG HỌ
    </div>
    <div class="admin-card-body">
      
      <!-- BỘ LỌC TÌM KIẾM TỐI ƯU URL -->
      <%
          tu_doi = Request.QueryString("tu_doi")
          den_doi = Request.QueryString("den_doi")
          gioitinh_loc = Request.QueryString("gioitinh")
          tukhoa_loc = Trim(Request.QueryString("tukhoa"))
      %>
      <form id="filterForm" class="no-print" method="get" action="">
          <div class="filter-group">
              <label class="filter-label">TÌM KIẾM</label>
              <input type="text" name="tukhoa" value="<%=tukhoa_loc%>" class="form-input" style="width:200px;" placeholder="Nhập tên nhân vật...">
          </div>
          
          <div class="filter-group">
              <label class="filter-label">TỪ ĐỜI</label>
              <select name="tu_doi" class="form-select" style="width:120px;">
                  <option value="">-- Chọn --</option>
                  <%
                      openconn
                      Set rsd = conn.Execute("SELECT * FROM tbldoi ORDER BY iddoi ASC")
                      Do While Not rsd.EOF
                          Response.Write "<option value='" & rsd("iddoi") & "'"
                          If tu_doi = CStr(rsd("iddoi")) Then Response.Write " selected"
                          Response.Write ">Đời " & rsd("tieude") & "</option>"
                          rsd.MoveNext
                      Loop
                      rsd.Close
                  %>
              </select>
          </div>
          
          <div class="filter-group">
              <label class="filter-label">ĐẾN ĐỜI</label>
              <select name="den_doi" class="form-select" style="width:120px;">
                  <option value="">-- Chọn --</option>
                  <%
                      Set rsd = conn.Execute("SELECT * FROM tbldoi ORDER BY iddoi ASC")
                      Do While Not rsd.EOF
                          Response.Write "<option value='" & rsd("iddoi") & "'"
                          If den_doi = CStr(rsd("iddoi")) Then Response.Write " selected"
                          Response.Write ">Đời " & rsd("tieude") & "</option>"
                          rsd.MoveNext
                      Loop
                      rsd.Close
                  %>
              </select>
          </div>
          
          <div class="filter-group">
              <label class="filter-label">GIỚI TÍNH</label>
              <select name="gioitinh" class="form-select" style="width:120px;">
                  <option value="">-- Tất cả --</option>
                  <option value="1" <%If gioitinh_loc="1" Then Response.Write "selected"%>>Nam</option>
                  <option value="2" <%If gioitinh_loc="2" Then Response.Write "selected"%>>Nữ</option>
              </select>
          </div>
          
          <div class="filter-actions">
              <button type="submit" class="btn-primary" style="padding:10px 20px;"><i class="fa fa-search"></i> Lọc</button>
              <button type="button" onclick="window.location.href=window.location.pathname;" class="btn-secondary" style="padding:10px 20px;"><i class="fa fa-refresh"></i></button>
          </div>
          
          <div class="filter-exports">
              <button type="button" onclick="exportData('excel')" class="btn-primary" style="background:#cccccc; padding:10px 15px;"><i class="fa fa-file-excel-o"></i> Xuất Excel</button>
              <button type="button" onclick="exportData('word')" class="btn-primary" style="background:#cccccc; padding:10px 15px;"><i class="fa fa-file-word-o"></i> Phả Đồ Cuốn</button>
          </div>
      </form>

      <script>
      function exportData(type) {
          var form = document.getElementById('filterForm');
          var oldAction = form.action;
          if(type === 'excel') form.action = 'giapha_excel.asp';
          if(type === 'word') form.action = 'giapha_word.asp';
          form.target = '_blank';
          form.submit();
          form.action = oldAction;
          form.target = '';
      }
      </script>

      <!-- BẢNG PHẢ HỆ -->
      <div class="table-responsive">
      <table class="table-matrix">
        <tr>
            <%
                Dim arrDoiID(), arrDoiTieuDe()
                totalRecord = 0
                
                Set rs1 = conn.Execute("SELECT iddoi, tieude FROM tbldoi ORDER BY iddoi ASC")
                Do While Not rs1.EOF
                    totalRecord = totalRecord + 1
                    ReDim Preserve arrDoiID(totalRecord)
                    ReDim Preserve arrDoiTieuDe(totalRecord)
                    arrDoiID(totalRecord) = CInt(rs1("iddoi"))
                    arrDoiTieuDe(totalRecord) = rs1("tieude") & ""
                    rs1.MoveNext
                Loop
                rs1.Close

                If totalRecord = 0 Then
                    conn.Execute("INSERT INTO tbldoi (tieude, thutu) VALUES (N'I', 1)")
                    Set rs2 = conn.Execute("SELECT @@IDENTITY AS NewID")
                    totalRecord = 1
                    ReDim arrDoiID(1)
                    ReDim arrDoiTieuDe(1)
                    arrDoiID(1) = CInt(rs2("NewID"))
                    arrDoiTieuDe(1) = "I"
                    rs2.Close
                End If

                Dim startIndex, endIndex
                startIndex = 1
                endIndex = totalRecord
                
                If tu_doi <> "" Then
                    For i = 1 To totalRecord
                        If arrDoiID(i) = CInt(tu_doi) Then startIndex = i
                    Next
                End If
                
                If den_doi <> "" Then
                    For i = 1 To totalRecord
                        If arrDoiID(i) = CInt(den_doi) Then endIndex = i
                    Next
                End If
                
                If startIndex > endIndex Then
                    j = startIndex: startIndex = endIndex: endIndex = j
                End If

                For i = startIndex To endIndex
                    Response.Write "<th>ĐỜI " & UCase(arrDoiTieuDe(i)) & "</th>"
                Next
            %>
            <th style="width: 80px; min-width: 80px;">CON THỨ</th>
            <th style="width: 140px; min-width: 140px;" class="no-print">QUẢN LÝ</th>
        </tr>
<%
    ' ====================================================
    ' XỬ LÝ PHÂN QUYỀN VÀ DUYỆT CÂY BẰNG MẢNG RAM
    ' ====================================================
    If is_super = 1 Or allowed_root = 0 Then
        Set rs3 = conn.Execute("SELECT TOP 1 idgiapha FROM tblgiapha WHERE (loai_quanhe IS NULL OR loai_quanhe <> 2)")
        If rs3.EOF Then
            Response.Write "<tr><td colspan='" & (endIndex - startIndex + 3) & "' align='center' style='padding:40px; white-space:normal; background:#f8fafc; color:#64748b;'><i class='fa fa-folder-open-o' style='font-size:30px; margin-bottom:10px; display:block;'></i>Hệ thống gia phả chưa có dữ liệu.<br><br><a href='javascript:void(0);' onclick='$.fancybox.open({src: ""../them-nhan-vat/?sessionpage=0"", type: ""iframe"", opts: {iframe: {css: {width: ""800px"", height: ""90%""}}}});' class='btn-primary' style='text-decoration:none;'><i class='fa fa-user-plus'></i> Khởi tạo Thủy Tổ</a></td></tr>"
        Else
            Call LoadGenealogyArrays()
            Call RenderMatrixTree_Array(0, arrDoiID, arrDoiTieuDe, startIndex, endIndex, totalRecord, tu_doi, den_doi, gioitinh_loc, tukhoa_loc)
        End If
        rs3.Close
        destroyconn
    Else
        Call LoadGenealogyArrays()
        
        Dim rootIdx, foundRoot
        foundRoot = False
        
        If numMembers >= 0 Then
            For rootIdx = 0 To numMembers
                If CInt(allMembersArray(0, rootIdx)) = CInt(allowed_root) Then
                    foundRoot = True
                    Exit For
                End If
            Next
        End If
        
        If foundRoot Then
            Call PrintMemberRow_Array(rootIdx, arrDoiID, arrDoiTieuDe, startIndex, endIndex, totalRecord, tukhoa_loc)
            Call RenderMatrixTree_Array(allowed_root, arrDoiID, arrDoiTieuDe, startIndex, endIndex, totalRecord, tu_doi, den_doi, gioitinh_loc, tukhoa_loc)
        Else
            Response.Write "<tr><td colspan='" & (endIndex - startIndex + 3) & "' align='center' style='padding:30px; color:#e11d48;'>Hệ thống không tìm thấy dữ liệu nhánh được phân quyền của bạn. Vui lòng liên hệ Quản trị viên.</td></tr>"
        End If
        destroyconn
    End If

    ' ====================================================
    ' HÀM DUYỆT CÂY ĐỆ QUY TRÊN MẢNG RAM
    ' ====================================================
    Sub RenderMatrixTree_Array(parentID, arrDoiID, arrDoiTieuDe, startIndex, endIndex, totalRecord, loc_tu, loc_den, loc_gt, loc_key)
        If numMembers < 0 Then Exit Sub
        
        Dim i, isMatch, doiLocal
        
        For i = 0 To numMembers
            If CInt("0" & allMembersArray(1, i)) = CInt(parentID) Then
                isMatch = True
                doiLocal = CInt("0" & allMembersArray(2, i))
                
                If loc_tu <> "" Then
                    If doiLocal < CInt(loc_tu) Then isMatch = False
                End If
                If loc_den <> "" Then
                    If doiLocal > CInt(loc_den) Then isMatch = False
                End If
                
                If loc_gt <> "" Then
                    If CInt("0" & allMembersArray(5, i)) <> CInt(loc_gt) Then 
                        isMatch = False
                    ElseIf CInt(loc_gt) = 1 And (allMembersArray(6, i) & "" = "3") Then
                        isMatch = False
                    End If
                End If
                
                If isMatch Then
                    Call PrintMemberRow_Array(i, arrDoiID, arrDoiTieuDe, startIndex, endIndex, totalRecord, loc_key)
                End If
                
                Call RenderMatrixTree_Array(allMembersArray(0, i), arrDoiID, arrDoiTieuDe, startIndex, endIndex, totalRecord, loc_tu, loc_den, loc_gt, loc_key)
            End If
        Next
    End Sub

    ' ====================================================
    ' HÀM IN HTML TỪ MẢNG RAM
    ' ====================================================
    Sub PrintMemberRow_Array(idx, arrDoiID, arrDoiTieuDe, startIndex, endIndex, totalRecord, loc_key)
        Dim localRowClass, currentDoiId, doiText, localThuTu, localDisplayName, gioitinhNum, loopK, loaiQH
        Dim strSpouses, rawName, hasSpouse, localCleanName, localDanhXung
        Dim emptyCols, nameCols, found, loopI
        
        Dim t_idgiapha, t_idcha, t_iddoi, t_hoten, t_thutu, t_gioitinh, t_loaiqh, t_doitieude
        t_idgiapha = allMembersArray(0, idx)
        t_idcha = allMembersArray(1, idx)
        t_iddoi = allMembersArray(2, idx)
        t_hoten = allMembersArray(3, idx)
        t_thutu = allMembersArray(4, idx)
        t_gioitinh = allMembersArray(5, idx)
        t_loaiqh = allMembersArray(6, idx)
        t_doitieude = allMembersArray(7, idx)

        gioitinhNum = CInt("0" & t_gioitinh)
        loaiQH = t_loaiqh & ""
        
        If gioitinhNum = 2 Then 
            localDanhXung = "bà"
            localRowClass = "row-female" 
        Else 
            localDanhXung = "ông"
            localRowClass = "row-male" 
        End If
        
        If loaiQH = "3" Then localRowClass = "row-ngoai"
        
        currentDoiId = CInt("0" & t_iddoi)
        
        doiText = ""
        For loopK = 1 To totalRecord
            If CInt(arrDoiID(loopK)) = currentDoiId Then
                doiText = CStr(arrDoiTieuDe(loopK))
                Exit For
            End If
        Next
        
        strSpouses = ""
        hasSpouse = False
        
        If numSpouses >= 0 Then
            Dim s_idx
            For s_idx = 0 To numSpouses
                If CInt("0" & allSpousesArray(0, s_idx)) = CInt(t_idgiapha) Then
                    hasSpouse = True
                    strSpouses = strSpouses & "<span class='spouse-separator'> - </span><span class='spouse-name'>" & allSpousesArray(2, s_idx) & "</span>"
                End If
            Next
        End If

        localThuTu = t_thutu & ""
        rawName = t_hoten & ""
        localCleanName = Replace(rawName, """", "&quot;")
        
        If loc_key <> "" And InStr(1, rawName, loc_key, 1) > 0 Then
            rawName = "<span class='highlight-name'>" & rawName & "</span>"
        End If
        
        localDisplayName = doiText & "." & localThuTu & ". " & rawName
%>
        <tr class="<%=localRowClass%>">
            <% 
            emptyCols = 0
            nameCols = 1
            found = False
            
            For loopI = startIndex To endIndex 
                If currentDoiId = CInt(arrDoiID(loopI)) Then 
                    emptyCols = loopI - startIndex
                    nameCols = endIndex - loopI + 1
                    found = True
                    Exit For
                End If
            Next 
            
            If found Then
                If emptyCols > 0 Then
                    Response.Write "<td colspan='" & emptyCols & "'></td>"
                End If
                %>
                <td align="left" colspan="<%=nameCols%>">
        <% If (t_idgiapha & "") = "1" Then %>
            <span class="member-link" style="color:#e11d48;" onclick="showContextMenu(event, '<%=t_idgiapha%>', '<%=localCleanName%>', '<%=gioitinhNum%>', '<%=hasSpouse%>', '<%=loaiQH%>', '<%=localDanhXung%>')"><%= localDisplayName %></span>
            <%=strSpouses%>
        <% Else %>
            <span class="member-link" onclick="showContextMenu(event, '<%=t_idgiapha%>', '<%=localCleanName%>', '<%=gioitinhNum%>', '<%=hasSpouse%>', '<%=loaiQH%>', '<%=localDanhXung%>')"><%= localDisplayName %></span>
            <% If loaiQH = "3" Then Response.Write " <span style='font-size:1em; color:#94a3b8; font-style:italic;'>(Cháu ngoại)</span>" %>
            <%=strSpouses%>
        <% End If %>
    </td>
            <% End If %>

            <td align="center">
                <span style="display:inline-block; width:20px; font-size: 14px;font-family: <%=currentFont%> !important; color:#0f172a;"><%=localThuTu%></span>
                <a href="?action=moveup&id=<%=t_idgiapha%>&idcha=<%=t_idcha%>" title="Chuyển lên" class="btn-move"><i class="fa fa-arrow-up"></i></a>
                <a href="?action=movedown&id=<%=t_idgiapha%>&idcha=<%=t_idcha%>" title="Chuyển xuống" class="btn-move"><i class="fa fa-arrow-down"></i></a>
            </td>

            <td align="center" style="white-space: nowrap;" class="no-print">
    <% If loaiQH <> "3" Then %>
        <a href="javascript:void(0);" onclick="$.fancybox.open({src: '/gpdh/them-nhan-vat/?sessionpage=<%=t_idgiapha%>', type: 'iframe', opts: {iframe: {css: {width: '800px', height: '90%'}}}});" title="Thêm con" class="btn-action btn-add-child">
            <i class="fa fa-user-plus"></i>
        </a>
        
        <a href="javascript:void(0);" onclick="$.fancybox.open({src: '/gpdh/them-nhan-vat-ngoai/?sessionpage=<%=t_idgiapha%>', type: 'iframe', opts: {iframe: {css: {width: '800px', height: '90%'}}}});" title="Thêm <% If gioitinhNum = 2 Then Response.Write "chồng" Else Response.Write "vợ" End If %>" class="btn-action btn-add-spouse">
            <i class="fa fa-venus-mars"></i>
        </a>
        
        <% If hasSpouse Then %>
        <a href="javascript:void(0);" onclick="$.fancybox.open({src: '/gpdh/nhan-vat-ngoai/?sessionpage=<%=t_idgiapha%>', type: 'iframe', opts: {iframe: {css: {width: '800px', height: '90%'}}}});" title="Xem thông tin vợ/chồng" class="btn-action btn-view">
            <i class="fa fa-info-circle"></i>
        </a>
        <% End If %>
    <% End If %>
    
    <a href="javascript:void(0);" onclick="$.fancybox.open({src: '/gpdh/sua-nhan-vat/?id=<%=t_idgiapha%>', type: 'iframe', opts: {iframe: {css: {width: '800px', height: '90%'}}}});" title="Sửa thông tin" class="btn-action btn-edit">
        <i class="fa fa-pencil-square-o"></i>
    </a>
    
    <% If (t_idgiapha & "") <> "1" Then %>
    <a href="javascript:void(0);" onclick="del_one('<%= t_idgiapha %>', '<%= localCleanName %>', '<%= localDanhXung %>');" title="Xóa bản ghi" class="btn-action btn-delete">
        <i class="fa fa-trash-o"></i>
    </a>
    <% End If %>
</td>
        </tr>
<%
    End Sub
%>
      </table>
      </div>
    </div>
</div>

<!-- KHUNG MENU NGỮ CẢNH ĐƯỢC CHUẨN HÓA URL -->
<div id="contextMenu">
    <div class="menu-header" id="menuMemberName">Quản lý nhân vật</div>
    <div id="menuActionList"></div>
</div>

<script>
function showContextMenu(event, id, hoten, gioitinh, hasSpouse, loaiQH, danhXung) {
    event.stopPropagation();
    var menu = document.getElementById('contextMenu');
    document.getElementById('menuMemberName').innerText = "Quản lý: " + hoten;
    
    var spouseText = (gioitinh === "2") ? "chồng" : "vợ";
    var html = "";
    
    if (loaiQH !== "3") {
        html += '<a href="javascript:void(0);" onclick="openPopup(\'/gpdh/them-nhan-vat/?sessionpage=' + id + '\')"><i class="fa fa-user-plus text-success" style="color:#10b981;"></i> Thêm con của ' + danhXung + ' ' + hoten + '</a>';
        html += '<a href="javascript:void(0);" onclick="openPopup(\'/gpdh/them-nhan-vat-ngoai/?sessionpage=' + id + '\')"><i class="fa fa-venus-mars text-pink" style="color:#e11d48;"></i> Thêm ' + spouseText + ' của ' + danhXung + ' ' + hoten + '</a>';
        
        if (hasSpouse === "True") {
            html += '<a href="javascript:void(0);" onclick="openPopup(\'/gpdh/nhan-vat-ngoai/?sessionpage=' + id + '\')"><i class="fa fa-info-circle text-info" style="color:#0ea5e9;"></i> Xem thông tin ' + spouseText + ' của ' + danhXung + ' ' + hoten + '</a>';
        }
    }
    
    html += '<a href="javascript:void(0);" onclick="openPopup(\'/gpdh/sua-nhan-vat/?id=' + id + '\')"><i class="fa fa-pencil text-warning" style="color:#f59e0b;"></i> Sửa thông tin ' + danhXung + ' ' + hoten + '</a>';
    
    if (id !== "1") {
        html += '<a href="javascript:void(0);" onclick="del_one(\'' + id + '\', \'' + hoten + '\', \'' + danhXung + '\')"><i class="fa fa-trash text-danger" style="color:#dc2626;"></i> Xóa ' + danhXung + ' ' + hoten + '</a>';
    }
    
    document.getElementById('menuActionList').innerHTML = html;
    
    menu.style.display = 'block';
    menu.style.left = event.pageX + 'px';
    menu.style.top = event.pageY + 'px';
}

function openPopup(url) {
    $.fancybox.open({
        src: url,
        type: 'iframe',
        opts: {
            iframe: {
                css: { width: '800px', height: '90%' }
            }
        }
    });
    hideContextMenu();
}

function hideContextMenu() {
    var menu = document.getElementById('contextMenu');
    if (menu) menu.style.display = 'none';
}

$(document).click(function() {
    hideContextMenu();
});

$(document).ready(function() {
    $('[data-fancybox]').fancybox({
        iframe : {
            css : {
                width : '800px',
                height : '90%'
            }
        }
    });
});
</script>