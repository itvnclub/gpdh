<%session.CodePage=65001%>
<%
' ====================================================
' 1. KIỂM TRA ĐĂNG NHẬP & PHÂN QUYỀN TRUY CẬP
' ====================================================
If Session("username") = "" Then
    Response.Write "<script>alert('Bạn vui lòng đăng nhập để vào hệ thống quản trị!'); window.location='../gpdh/';</script>"
    Response.End
End If

' Kiểm tra quyền Phả hệ (is_genealogy) hoặc Toàn quyền (is_super)
Dim is_super_doi, is_genealogy_doi
is_super_doi     = CInt("0" & Session("is_super"))
is_genealogy_doi = CInt("0" & Session("is_genealogy"))

If is_super_doi = 0 And is_genealogy_doi = 0 Then
    Response.Write "<script>alert('Lỗi bảo mật: Bạn không có quyền truy cập vào chức năng Quản lý Đời phả hệ!'); window.location='default.asp';</script>"
    Response.End
End If

' --- FIX LỖI ĐƯỜNG DẪN URL REWRITE ---
' Lấy đường dẫn gốc của thư mục quản trị (ví dụ: /gpdh/) để làm mỏ neo cho các link
Dim adminBasePath
adminBasePath = Left(Request.ServerVariables("SCRIPT_NAME"), InStrRev(Request.ServerVariables("SCRIPT_NAME"), "/"))

' ====================================================
' 2. XỬ LÝ CẬP NHẬT TÊN ĐỜI (KHI SUBMIT FORM SỬA)
' ====================================================
Dim edit_id_doi, update_tieude
If Request.Form("action_doi") = "submit" Then
    edit_id_doi   = Replace(Request.Form("id"), "'", "''")
    update_tieude = Trim(Replace(Request.Form("tieude"), "'", "''"))
    
    If IsNumeric(edit_id_doi) And update_tieude <> "" Then
        openconn
        conn.execute("UPDATE tbldoi SET tieude=N'" & update_tieude & "' WHERE iddoi=" & CInt(edit_id_doi))
        destroyconn
        
        ' Đã sửa đổi window.location.href kết hợp với adminBasePath
        Response.Write "<script>alert('Cập nhật tên đời thành công!'); window.location.href='" & adminBasePath & "quan-ly-doi';</script>"
        Response.End
    End If
End If

' ====================================================
' 3. LẤY DỮ LIỆU ĐỂ SỬA (NẾU CÓ THAM SỐ id TRÊN URL)
' ====================================================
Dim current_edit_id, edit_tieude, edit_thutu
current_edit_id = Request.QueryString("id")
edit_tieude = ""
edit_thutu = ""

If current_edit_id <> "" And IsNumeric(current_edit_id) Then
    openconn
    Dim rsEditDoi
    Set rsEditDoi = Server.CreateObject("ADODB.Recordset")
    rsEditDoi.Open "SELECT * FROM tbldoi WHERE iddoi = " & CInt(current_edit_id), conn
    If Not rsEditDoi.EOF Then
        edit_tieude = rsEditDoi("tieude")
        edit_thutu  = rsEditDoi("thutu")
    Else
        current_edit_id = "" ' Reset nếu nhập ID không hợp lệ lên URL
    End If
    rsEditDoi.Close : Set rsEditDoi = Nothing
    destroyconn
End If
%>

<!-- ==================================================== -->
<!-- CSS GIAO DIỆN CHUẨN CARD LAYOUT & FLEXBOX            -->
<!-- ==================================================== -->
<style>
.row-grid { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 15px; }
.col-flex { flex: 1; min-width: 250px; }
.col-full { flex: 1 1 100%; }

.form-label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #475569; }
.form-input { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; color: #334155; transition: 0.2s; box-sizing: border-box; font-family: inherit; }
.form-input:focus { border-color: #0a69db; outline: none; box-shadow: 0 0 0 3px rgba(10,105,219,0.1); }

.btn-primary { background: #0a69db; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; }
.btn-primary:hover { background: #0056b3; }
.btn-secondary { background: #64748b; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; text-decoration: none; display: inline-block; }
.btn-secondary:hover { background: #475569; }

/* CSS Table Danh sách */
.table-modern { width: 100%; border-collapse: collapse; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-modern th { background: #f1f5f9; color: #334155; font-weight: bold; padding: 12px; text-align: left; border-bottom: 2px solid #cbd5e1; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-modern td { padding: 12px; border-bottom: 1px solid #e2e8f0; vertical-align: middle; color: #475569; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-modern tr:hover { background-color: #f8fafc; }

/* Dòng đang được chọn để sửa sẽ có màu nền nổi bật */
.row-active { background-color: #fffbeb !important; }
.row-active td { border-bottom: 1px solid #fde68a !important; }

.action-icon { color: #64748b; font-size: 18px; margin: 0 5px; cursor: pointer; transition: 0.2s; }
.action-icon:hover { color: #0a69db; transform: scale(1.1); }
</style>

<script>
function checkDoiForm() {
    var tieude = document.frmDoi.tieude.value.trim();
    if(tieude == "") {
        alert("Tên đời không được để trống!");
        document.frmDoi.tieude.focus();
        return false;
    }
    return true;
}
</script>

<!-- KHỐI 1: FORM SỬA TÊN ĐỜI (CHỈ HIỆN KHI BẤM SỬA TRÊN BẢNG) -->
<% If current_edit_id <> "" Then %>
<div class="admin-card" style="border-top: 3px solid #f59e0b; margin-bottom: 25px;">
    <div class="admin-card-header"><i class="fa fa-pencil-square-o" style="color: #f59e0b;"></i> SỬA TÊN ĐỜI (ĐỜI THỨ <%= edit_thutu %>)</div>
    <div class="admin-card-body">
        <form name="frmDoi" method="post" action="" onSubmit="return checkDoiForm()">
            <input type="hidden" name="action_doi" value="submit">
            <input type="hidden" name="id" value="<%= current_edit_id %>">
            
            <div class="row-grid">
                <div class="col-flex" style="flex: 2;">
                    <label class="form-label">Tên đời (Ký tự hiển thị, ví dụ: I, II, III) <span style="color:red">*</span></label>
                    <input name="tieude" type="text" class="form-input" value="<%= edit_tieude %>" autocomplete="off" style="border-color: #f59e0b;">
                </div>
                <div class="col-flex" style="flex: 1;">
                    <label class="form-label">Thứ tự định danh</label>
                    <input type="text" class="form-input" style="background:#f1f5f9; color:#94a3b8; cursor: not-allowed;" value="Đời thứ <%= edit_thutu %>" readonly title="Thứ tự được quản lý tự động bởi phả hệ">
                </div>
            </div>

            <div style="margin-top: 15px;">
                <button type="submit" class="btn-primary" style="background: #f59e0b;"><i class="fa fa-save"></i> LƯU THAY ĐỔI</button>
                <!-- Đã cập nhật href bằng biến adminBasePath cho nút Hủy Bỏ -->
                <a href="<%= adminBasePath %>quan-ly-doi" class="btn-secondary"><i class="fa fa-times"></i> HỦY BỎ</a>
            </div>
        </form>
    </div>
</div>
<% End If %>

<!-- KHỐI 2: DANH SÁCH ĐỜI GIA PHẢ -->
<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-list-ol"></i> DANH SÁCH CÁC ĐỜI TRONG PHẢ HỆ</div>
    <div class="admin-card-body">
        <p style="color:#dc3545; font-style:italic; margin-bottom: 15px; font-size: 13px;">
            <i class="fa fa-info-circle"></i> Hệ thống tự động tính toán và khởi tạo Đời dựa trên dữ liệu thành viên thêm vào phả đồ. Bạn chỉ có thể sửa Tên đời.
        </p>
        
        <div style="overflow-x: auto;">
            <table class="table-modern">
              <tr>
                <th style="width: 150px; text-align:center;">THỨ TỰ</th>
                <th>TÊN ĐỜI HIỂN THỊ</th>
                <th style="width: 120px; text-align:center;">QUẢN LÝ</th>
              </tr>
              <%  
                     openconn 
                     Dim rsDoiList, trClass
                     Set rsDoiList = Server.CreateObject("adodb.recordset")
                     rsDoiList.open "SELECT * FROM tbldoi ORDER BY thutu ASC", conn, 1, 1
                     
                     If rsDoiList.EOF Then
                         Response.Write "<tr><td colspan='3' align='center' style='padding: 30px;'>Chưa có dữ liệu đời nào trong hệ thống.</td></tr>"
                     End If
                     
                     Do While Not rsDoiList.EOF
                         ' Đánh dấu highlight dòng đang được chọn sửa
                         If current_edit_id <> "" And CInt(current_edit_id) = CInt(rsDoiList("iddoi")) Then
                             trClass = "class='row-active'"
                         Else
                             trClass = ""
                         End If
              %>
              <tr <%=trClass%>>
                <td align="center" style="font-size: 14px">Đời thứ <strong><%= rsDoiList("thutu") %></strong></td>
                <td><span style="font-size: 16px; font-weight: bold; color: #0a69db;"><%= rsDoiList("tieude") %></span></td>
                <td align="center">
                    <!-- Đã cập nhật href bằng biến adminBasePath cho liên kết Sửa -->
                    <a href="<%= adminBasePath %>quan-ly-doi/sua/<%= rsDoiList("iddoi") %>" title="Sửa tên đời">
                        <i class="fa fa-pencil-square-o action-icon" <%If trClass<>"" Then%>style="color: #f59e0b;"<%End If%>></i>
                    </a>
                </td>
              </tr>
              <% 
                         rsDoiList.MoveNext
                     Loop
                     rsDoiList.Close : Set rsDoiList = Nothing
                     destroyconn
              %>
            </table>    
        </div>
    </div>
</div>