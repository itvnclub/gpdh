<%
' ====================================================
' 0. KIỂM TRA QUYỀN TRUY CẬP TRANG QUẢN LÝ NHÓM TIN
' ====================================================
If Session("username") = "" Then
%>
<script language="javascript">
    alert("Bạn vui lòng đăng nhập để vào hệ thống quản trị!");
    window.location.href = "/gpdh/";
</script>
<% 
    Response.End
End If

' Kiểm tra phân quyền: Yêu cầu quyền Quản trị tối cao hoặc Quản lý nội dung
If CInt("0" & Session("is_super")) = 0 And CInt("0" & Session("is_content")) = 0 Then
%>
<script language="javascript">
    alert("Bạn không có quyền truy cập vào chức năng Quản lý Nhóm tin!");
    window.location.href = "/gpdh/bang-dieu-khien/";
</script>
<% 
    Response.End
End If
%>

<%
' ====================================================
' 1. XỬ LÝ LƯU DỮ LIỆU (THÊM MỚI VÀ CẬP NHẬT)
' ====================================================
If Request.Form("action_submit") = "save" Then
    edit_id = Replace(Request.Form("edit_id"), "'", "''")
    tieude  = Replace(Request.Form("tieude"), "'", "''")
    thutu   = Replace(Request.Form("thutu"), "'", "''")
    If thutu = "" Or Not IsNumeric(thutu) Then thutu = 0

    If tieude <> "" Then
        openconn
        If edit_id = "" Then
            ' Thêm mới
            conn.Execute "INSERT INTO tblnhomtin(tieude, thutu) VALUES(N'" & tieude & "', " & CInt(thutu) & ")"
        Else
            ' Cập nhật
            conn.Execute "UPDATE tblnhomtin SET tieude=N'" & tieude & "', thutu=" & CInt(thutu) & " WHERE idnhomtin=" & CInt(edit_id)
        End If
        destroyconn
        
        ' Điều hướng về URL Rewrite sạch sẽ
        Response.Redirect("/gpdh/nhom-tin/")
    End If
End If

' ====================================================
' 2. XỬ LÝ XÓA VÀ SẮP XẾP THỨ TỰ
' ====================================================
action_req = Request.QueryString("action")
id_nhomtin = Request.QueryString("id")

If action_req <> "" And IsNumeric(id_nhomtin) Then
    openconn
    If action_req = "del" Then
        ' -- TRIGGER / KIỂM TRA TRƯỚC KHI XÓA --
        Set rsCheck = conn.Execute("SELECT COUNT(*) AS totalTin FROM tbltintuc WHERE idnhomtin=" & CInt(id_nhomtin))
        countTin = CInt(rsCheck("totalTin"))
        rsCheck.Close : Set rsCheck = Nothing
        
        If countTin > 0 Then
            ' Đang có bài viết -> Không cho xóa và báo lỗi bằng JS
            destroyconn
            %>
            <script language="javascript">
                alert("CẢNH BÁO: Không thể xóa!\nNhóm tin này đang chứa <%=countTin%> bài viết. Vui lòng chuyển các bài viết sang nhóm khác hoặc xóa bài viết trước.");
                window.location.href = window.location.pathname;
            </script>
            <%
            Response.End
        Else
            ' Không có bài viết -> Tiến hành xóa an toàn
            conn.Execute "DELETE FROM tblnhomtin WHERE idnhomtin=" & CInt(id_nhomtin)
            destroyconn
            Response.Write "<script>window.location.href = window.location.pathname;</script>"
            Response.End
        End If
        
    ElseIf action_req = "up" Or action_req = "down" Then
        Set rsCur = conn.Execute("SELECT ISNULL(thutu, 0) AS thutu FROM tblnhomtin WHERE idnhomtin=" & CInt(id_nhomtin))
        If Not rsCur.EOF Then
            curOrder = CInt(rsCur("thutu"))
            If action_req = "up" Then
                sqlTarget = "SELECT TOP 1 idnhomtin, ISNULL(thutu, 0) AS thutu FROM tblnhomtin WHERE ISNULL(thutu, 0) < " & curOrder & " ORDER BY ISNULL(thutu, 0) DESC"
            Else
                sqlTarget = "SELECT TOP 1 idnhomtin, ISNULL(thutu, 0) AS thutu FROM tblnhomtin WHERE ISNULL(thutu, 0) > " & curOrder & " ORDER BY ISNULL(thutu, 0) ASC"
            End If
            
            Set rsTarget = conn.Execute(sqlTarget)
            If Not rsTarget.EOF Then
                tarID = CInt(rsTarget("idnhomtin"))
                tarOrder = CInt(rsTarget("thutu"))
                ' Hoán đổi vị trí
                conn.Execute "UPDATE tblnhomtin SET thutu=" & tarOrder & " WHERE idnhomtin=" & CInt(id_nhomtin)
                conn.Execute "UPDATE tblnhomtin SET thutu=" & curOrder & " WHERE idnhomtin=" & tarID
            End If
            rsTarget.Close : Set rsTarget = Nothing
        End If
        rsCur.Close : Set rsCur = Nothing
        destroyconn
        
        Response.Write "<script>window.location.href = window.location.pathname;</script>"
        Response.End
    End If
End If

' ====================================================
' 3. LẤY DỮ LIỆU ĐỂ HIỂN THỊ FORM SỬA (NẾU CÓ)
' ====================================================
val_tieude = "" : val_thutu = "0"
form_title = "THÊM NHÓM TIN MỚI"
btn_text = "THÊM MỚI"
btn_icon = "fa-plus-circle"

If Request.QueryString("edit") <> "" And IsNumeric(Request.QueryString("edit")) Then
    openconn
    Set rsEdit = conn.Execute("SELECT * FROM tblnhomtin WHERE idnhomtin=" & CInt(Request.QueryString("edit")))
    If Not rsEdit.EOF Then
        val_tieude = rsEdit("tieude")
        val_thutu = rsEdit("thutu")
        form_title = "CẬP NHẬT NHÓM TIN"
        btn_text = "LƯU THAY ĐỔI"
        btn_icon = "fa-save"
    End If
    rsEdit.Close : Set rsEdit = Nothing
    destroyconn
End If
%>

<style>
.row-grid { display: flex; flex-wrap: wrap; gap: 15px; margin-bottom: 15px; }
.col-flex { flex: 1; min-width: 200px; display: flex; flex-direction: column; }

.form-label { font-weight: 600; margin-bottom: 6px; color: #475569; font-size: 0.9em; }
.form-input { padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; color: #334155; transition: 0.2s; font-family: inherit; font-size: 1em; box-sizing: border-box; }
.form-input:focus { border-color: #e11d48; outline: none; box-shadow: 0 0 0 3px rgba(225,29,72,0.1); }

.btn-primary { background: #e11d48; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-weight: bold; cursor: pointer; transition: 0.2s; }
.btn-primary:hover { background: #be123c; }
.btn-secondary { background: #64748b; color: #fff; border: none; padding: 10px 15px; border-radius: 4px; font-weight: bold; text-decoration: none; display: inline-block; }
.btn-secondary:hover { background: #475569; }

.table-modern { width: 100%; border-collapse: collapse; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-modern th { background: #f1f5f9; color: #0f172a; font-weight: bold; padding: 12px; text-align: left; border-bottom: 2px solid #cbd5e1; text-transform: uppercase; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-modern td { padding: 10px 12px; border-bottom: 1px solid #e2e8f0; vertical-align: middle; color: #334155; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-modern tr:hover { background-color: #f8fafc; }

.btn-move { display: inline-flex; align-items: center; justify-content: center; width: 24px; height: 24px; background: #f1f5f9; color: #475569; border-radius: 4px; text-decoration: none; margin: 0 2px; border: 1px solid #cbd5e1; transition: 0.2s; }
.btn-move:hover { background: #0a69db; color: #fff; border-color: #0a69db; }
.action-icon { font-size: 1.5em; margin: 0 5px; cursor: pointer; transition: 0.2s; color: #64748b; }
.action-icon:hover { color: #0a69db; transform: scale(1.15); }
.action-delete:hover { color: #dc2626; }
</style>

<script>
function check_input() {
    var frm = document.frmNhomTin;
    if (frm.tieude.value === "") { alert("Vui lòng nhập tên nhóm tin!"); frm.tieude.focus(); return false; }
    return true;        
}
function del_one(id) {
    if (confirm("Bạn có chắc chắn muốn xóa nhóm tin này không?\nHệ thống sẽ kiểm tra xem nhóm có chứa bài viết hay không trước khi xóa.")) {
        document.location.href = "?action=del&id=" + id;
    }
}
</script>

<!-- KHỐI 1: FORM THÊM / CẬP NHẬT -->
<div class="admin-card" style="border-top: 3px solid #e11d48; margin-bottom: 20px; background: #fff; padding: 15px; border-radius: 5px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
    <div class="admin-card-header" style="font-size: 1.1em; font-weight: bold; margin-bottom: 15px; color: #0f172a;"><i class="fa fa-folder-open"></i> <%=form_title%></div>
    <div class="admin-card-body">
        <form name="frmNhomTin" method="post" action="" onSubmit="return check_input();" style="margin:0;">
            <input type="hidden" name="action_submit" value="save">
            <input type="hidden" name="edit_id" value="<%=Request.QueryString("edit")%>">
            
            <div class="row-grid">
                <div class="col-flex" style="flex: 2;">
                    <label class="form-label">Tên nhóm tin <span style="color:red">*</span></label>
                    <input name="tieude" type="text" class="form-input" value="<%=val_tieude%>" placeholder="Nhập tên nhóm tin...">
                </div>
                <div class="col-flex" style="flex: 0.5;">
                    <label class="form-label">Thứ tự ưu tiên</label>
                    <input name="thutu" type="number" class="form-input" value="<%=val_thutu%>">
                </div>
            </div>
            <div style="margin-top: 10px;">
                <button type="submit" class="btn-primary"><i class="fa <%=btn_icon%>"></i> <%=btn_text%></button>
                <% If Request.QueryString("edit") <> "" Then %>
                    <a href="/gpdh/nhom-tin/" class="btn-secondary" style="margin-left: 10px;">Hủy bỏ / Quay lại</a>
                <% End If %>
            </div>
        </form>
    </div>
</div>

<!-- KHỐI 2: DANH SÁCH NHÓM TIN -->
<div class="admin-card" style="background: #fff; border-radius: 5px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden;">
    <div class="admin-card-header" style="padding: 15px; background: #f8fafc; border-bottom: 1px solid #e2e8f0; font-size: 1.1em; font-weight: bold; color: #0f172a;"><i class="fa fa-list"></i> DANH SÁCH NHÓM TIN DÒNG HỌ</div>
    <div class="admin-card-body" style="padding: 0;">
        <div style="overflow-x: auto;">
            <table class="table-modern">
                <tr>
                    <th style="width: 80px; text-align:center;">ID</th>
                    <th>TÊN NHÓM TIN</th>
                    <th style="width: 150px; text-align:center;">BÀI VIẾT</th>
                    <th style="width: 120px; text-align:center;">SẮP XẾP</th>
                    <th style="width: 120px; text-align:center;">QUẢN LÝ</th>
                </tr>
                <%  
                    openconn    
                    Dim rs, rsCount
                    Set rs = Server.CreateObject("ADODB.Recordset")
                    rs.Open "SELECT * FROM tblnhomtin ORDER BY ISNULL(thutu, 0) ASC, idnhomtin DESC", conn, 3, 1
                    
                    If rs.EOF Then
                        Response.Write "<tr><td colspan='5' style='text-align:center; padding:30px; color:#64748b;'>Chưa có nhóm tin nào được tạo.</td></tr>"
                    End If
                    
                    Do While Not rs.EOF
                        Dim countPost
                        Set rsCount = conn.Execute("SELECT COUNT(idtintuc) AS total FROM tbltintuc WHERE idnhomtin=" & rs("idnhomtin"))
                        countPost = rsCount("total")
                        rsCount.Close : Set rsCount = Nothing
                %>
                <tr>
                    <td align="center"><strong>#<%=rs("idnhomtin")%></strong></td>
                    <td>
                        <span style="font-size: 15px; font-weight: 600; color: #0f172a;"><%= rs("tieude") %></span>
                    </td>
                    <td align="center">
                        <% If countPost > 0 Then %>
                            <span style="background: #e0f2fe; color: #0284c7; padding: 3px 8px; border-radius: 12px; font-size: 13px; font-weight: bold;"><%=countPost%> bài</span>
                        <% Else %>
                            <span style="color: #94a3b8; font-size: 13px;">Trống</span>
                        <% End If %>
                    </td>
                    <td align="center">
                        <span style="display:inline-block; width:20px; font-size: 14px"><%=rs("thutu")%></span>
                        <a href="?action=up&id=<%=rs("idnhomtin")%>" class="btn-move" title="Lên"><i class="fa fa-arrow-up"></i></a>
                        <a href="?action=down&id=<%=rs("idnhomtin")%>" class="btn-move" title="Xuống"><i class="fa fa-arrow-down"></i></a>
                    </td>
                    <td align="center">
                        <a href="?edit=<%=rs("idnhomtin")%>" title="Sửa nhóm tin"><i class="fa fa-pencil-square-o action-icon" style="color: #f59e0b;"></i></a>
                        <i class="fa fa-trash-o action-icon action-delete" title="Xóa nhóm tin" onClick="del_one('<%= rs("idnhomtin") %>');"></i>
                    </td>
                </tr>
                <%  
                        rs.MoveNext
                    Loop
                    rs.Close : Set rs = Nothing
                    destroyconn
                %>
            </table>    
        </div>
    </div>
</div>