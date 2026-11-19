<%session.CodePage=65001%>
<%
' ====================================================
' 0. KIỂM TRA ĐĂNG NHẬP VÀ PHÂN QUYỀN
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

' Hàm chuyển đổi số nguyên an toàn
Function ValInt(v)
    If IsNull(v) Or Trim(v & "") = "" Then ValInt = 0 Else If IsNumeric(v) Then ValInt = CInt(v) Else ValInt = 0
End Function

' Hàm an toàn lấy QueryString/Form khi IIS URL Rewrite gộp tham số
Function GetSafeInt(paramName, defaultVal)
    Dim val
    val = Request.QueryString(paramName)
    If val = "" Then val = Request.Form(paramName)
    If val = "" Then GetSafeInt = defaultVal : Exit Function
    If InStr(val, ",") > 0 Then
        Dim arr : arr = Split(val, ",") : val = Trim(arr(0))
    End If
    GetSafeInt = ValInt(val)
End Function

' XÁC ĐỊNH QUYỀN HẠN CỦA NGƯỜI ĐANG ĐĂNG NHẬP
current_is_super = ValInt(Session("is_super"))
current_idadmin  = ValInt(Session("idadmin"))
edit_id          = GetSafeInt("id", 0)

' Nếu là user thường, ép buộc chỉ được sửa thông tin chính mình
If current_is_super <> 1 Then
    edit_id = current_idadmin
End If

action_req = Trim(Request.QueryString("action"))

' ====================================================
' 1. XỬ LÝ XÓA NGƯỜI DÙNG (CHỈ SUPER ADMIN)
' ====================================================
If action_req = "del_one" And current_is_super = 1 Then
    nid_del = GetSafeInt("nid", 0)
    If nid_del > 0 Then
        openconn
        ' Không cho phép tự xóa tài khoản đang đăng nhập
        If nid_del <> current_idadmin Then
            Conn.Execute("DELETE FROM tbladmin WHERE idadmin=" & nid_del)
        End If
        destroyconn
    End If
%>
<script language="javascript">
    alert("Đã xóa người dùng thành công!");
    window.location.href = "/gpdh/nguoi-dung/";
</script>
<%
    Response.End
End If

' ====================================================
' 2. XỬ LÝ THÊM MỚI HOẶC CẬP NHẬT (LƯU DỮ LIỆU)
' ====================================================
If Request.Form("action") = "submit" Then
    id_action = GetSafeInt("id", 0)
    hoten     = Replace(Request.Form("hoten"), "'", "''")
    email     = Replace(Request.Form("email"), "'", "''")
    dienthoai = Replace(Request.Form("dienthoai"), "'", "''")
    username  = Replace(Request.Form("username"), "'", "''")
    
    ' Bảo mật: Nếu không phải Super Admin, không cho phép đổi quyền hạn
    If current_is_super = 1 Then
        If Request.Form("is_super") = "1" Then is_super = 1 Else is_super = 0
        If Request.Form("is_content") = "1" Then is_content = 1 Else is_content = 0
        If Request.Form("is_genealogy") = "1" Then is_genealogy = 1 Else is_genealogy = 0
        allowed_start_idgiapha = GetSafeInt("allowed_start_idgiapha", 0)
    End If

    openconn
    
    ' --- KIỂM TRA TRÙNG LẶP TÊN TRUY CẬP ---
    If id_action > 0 Then
        check_sql = "SELECT idadmin FROM tbladmin WHERE username='" & username & "' AND idadmin <> " & id_action
    Else
        check_sql = "SELECT idadmin FROM tbladmin WHERE username='" & username & "'"
    End If
    Set rsCheck = Conn.Execute(check_sql)
    If Not rsCheck.EOF Then
        rsCheck.Close : Set rsCheck = Nothing
        destroyconn
        Response.Write "<script>alert('Tên truy cập [" & username & "] đã tồn tại! Vui lòng chọn tên khác.'); window.history.back();</script>"
        Response.End
    End If
    rsCheck.Close : Set rsCheck = Nothing

    If id_action > 0 Then
        ' --- TRƯỜNG HỢP SỬA ---
        If current_is_super = 1 Then
            If Request.Form("password") <> "" Then
                password = sha256(Replace(Request.Form("password"), "'", "''"))
                sql = "UPDATE tbladmin SET hoten=N'"&hoten&"', email='"&email&"', dienthoai=N'"&dienthoai&"', username='"&username&"', password='"&password&"', is_super="&is_super&", is_content="&is_content&", is_genealogy="&is_genealogy&", allowed_start_idgiapha="&allowed_start_idgiapha&" WHERE idadmin="&id_action
            Else
                sql = "UPDATE tbladmin SET hoten=N'"&hoten&"', email='"&email&"', dienthoai=N'"&dienthoai&"', username='"&username&"', is_super="&is_super&", is_content="&is_content&", is_genealogy="&is_genealogy&", allowed_start_idgiapha="&allowed_start_idgiapha&" WHERE idadmin="&id_action
            End If
        Else
            If id_action = current_idadmin Then
                If Request.Form("password") <> "" Then
                    password = sha256(Replace(Request.Form("password"), "'", "''"))
                    sql = "UPDATE tbladmin SET hoten=N'"&hoten&"', email='"&email&"', dienthoai=N'"&dienthoai&"', password='"&password&"' WHERE idadmin="&id_action
                Else
                    sql = "UPDATE tbladmin SET hoten=N'"&hoten&"', email='"&email&"', dienthoai=N'"&dienthoai&"' WHERE idadmin="&id_action
                End If
            End If
        End If
    ElseIf current_is_super = 1 Then
        ' --- TRƯỜNG HỢP THÊM MỚI ---
        password = sha256(Replace(Request.Form("password"), "'", "''"))
        sql = "INSERT INTO tbladmin(hoten, email, dienthoai, username, password, is_super, is_content, is_genealogy, allowed_start_idgiapha) VALUES(N'"&hoten&"', '"&email&"', N'"&dienthoai&"', '"&username&"', '"&password&"', "&is_super&", "&is_content&", "&is_genealogy&", "&allowed_start_idgiapha&")"
    End If
    
    If sql <> "" Then Conn.Execute(sql)
    destroyconn
    Response.Redirect("/gpdh/nguoi-dung/")
End If

' ====================================================
' 3. LẤY DỮ LIỆU ĐỂ SỬA
' ====================================================
edit_hoten = "" : edit_email = "" : edit_dienthoai = "" : edit_username = ""
edit_is_super = 0 : edit_is_content = 0 : edit_is_genealogy = 0 : edit_allowed_id = 0

If edit_id > 0 Then
    openconn
    Set rsEdit = Conn.Execute("SELECT * FROM tbladmin WHERE idadmin = " & edit_id)
    If Not rsEdit.EOF Then
        edit_hoten = rsEdit("hoten") & ""
        edit_email = rsEdit("email") & ""
        edit_dienthoai = rsEdit("dienthoai") & ""
        edit_username = rsEdit("username") & ""
        If Not IsNull(rsEdit("is_super")) Then edit_is_super = CInt(rsEdit("is_super"))
        If Not IsNull(rsEdit("is_content")) Then edit_is_content = CInt(rsEdit("is_content"))
        If Not IsNull(rsEdit("is_genealogy")) Then edit_is_genealogy = CInt(rsEdit("is_genealogy"))
        If Not IsNull(rsEdit("allowed_start_idgiapha")) Then edit_allowed_id = CInt(rsEdit("allowed_start_idgiapha"))
    End If
    rsEdit.Close : Set rsEdit = Nothing
    destroyconn
End If
%>

<style>
    body, html, input, select, textarea, button {
        font-family: <%=currentFont%> !important;
        font-size: <%=currentFontSize%> !important;
    }
.admin-card { background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 25px; border: 1px solid #e2e8f0; overflow: hidden; }
.admin-card-header { background: #f8fafc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0; font-weight: bold; color: #0f172a; font-size: 15px; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
.admin-card-header i { color: #0a69db; font-size: 18px; }
.admin-card-body { padding: 20px; }

.row-grid { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 15px; }
.col-flex { flex: 1; min-width: 250px; }
.col-full { flex: 1 1 100%; }

.form-label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #475569; }
.form-input, .form-select { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; color: #334155; transition: 0.2s; box-sizing: border-box; }
.form-input:focus, .form-select:focus { border-color: #0a69db; outline: none; box-shadow: 0 0 0 3px rgba(10,105,219,0.1); }

.checkbox-group { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; font-size: 14px; color: #334155; }
.checkbox-group input[type="checkbox"] { width: 16px; height: 16px; cursor: pointer; }

.btn-primary { background: #0a69db; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; }
.btn-primary:hover { background: #0056b3; }
.btn-secondary { background: #64748b; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; text-decoration: none; display: inline-block; }
.btn-secondary:hover { background: #475569; }

.table-modern { width: 100%; border-collapse: collapse; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-modern th { background: #f1f5f9; color: #334155; font-weight: bold; padding: 12px; text-align: left; border-bottom: 2px solid #cbd5e1; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-modern td { padding: 12px; border-bottom: 1px solid #e2e8f0; vertical-align: middle; color: #475569; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-modern tr:hover { background-color: #f8fafc; }
.action-icon { color: #64748b; font-size: 18px; margin: 0 5px; cursor: pointer; transition: 0.2s; }
.action-icon:hover { color: #0a69db; transform: scale(1.1); }
.action-delete:hover { color: #dc3545; }
</style>

<script>
function del_one(nid) {
  if (confirm("Bạn có chắc chắn muốn xóa người dùng này không?")) {
    document.location.href = "?action=del_one&nid=" + nid;
  }
}

function CheckForm() {
    var frm = document.frmUser;
    if(frm.username.value == "") {
        alert("Mời bạn nhập vào tên truy cập!"); frm.username.focus(); return false;
    }
    <% If edit_id = 0 Then %>
    if(frm.password.value == "") {
        alert("Mời bạn nhập vào mật khẩu!"); frm.password.focus(); return false;
    }
    <% End If %>
    if(frm.password.value != "" && frm.password.value != frm.password1.value) {
        alert("Mật khẩu nhập lại không khớp!"); frm.password1.focus(); return false;
    }
    if(frm.hoten.value == "") {
        alert("Mời bạn nhập vào họ tên!"); frm.hoten.focus(); return false;
    }
    return true;
}

function togglePermissionFields() {
    var isSuper = document.getElementById('is_super');
    if (!isSuper) return;
    
    var isGenealogy = document.getElementById('is_genealogy').checked;
    document.getElementById('is_content').disabled = isSuper.checked;
    document.getElementById('is_genealogy').disabled = isSuper.checked;
    
    var branchBox = document.getElementById('branch_selection_box');
    if (!isSuper.checked && isGenealogy) {
        branchBox.style.display = 'block';
    } else {
        branchBox.style.display = 'none';
        if(document.getElementsByName('allowed_start_idgiapha')[0]) {
            document.getElementsByName('allowed_start_idgiapha')[0].value = "0";
        }
    }
}
window.onload = function() { togglePermissionFields(); };
</script>

<!-- KHỐI 1: FORM THÊM / SỬA -->
<div class="admin-card">
    <div class="admin-card-header">
        <i class="fa fa-user-circle"></i> 
        <% If edit_id > 0 Then  
            If current_is_super = 1 And edit_id <> current_idadmin Then
                Response.Write "CẬP NHẬT TÀI KHOẢN NGƯỜI DÙNG"
            Else
                Response.Write "ĐỔI MẬT KHẨU & CẬP NHẬT THÔNG TIN CÁ NHÂN"
            End If
           Else  
                Response.Write "THÊM MỚI TÀI KHOẢN" 
           End If %>
    </div>
    <div class="admin-card-body">
        <form name="frmUser" method="post" action="" onSubmit="return CheckForm()">
        <input type="hidden" name="action" value="submit">
        <input type="hidden" name="id" value="<%=edit_id%>">

        <div class="row-grid">
            <div class="col-flex">
                <label class="form-label">Tên truy cập <span style="color:red">*</span></label>
                <input name="username" type="text" class="form-input" value="<%=edit_username%>" autocomplete="off" <%If current_is_super <> 1 Then Response.Write "readonly style='background:#f1f5f9; color:#64748b;'" End If%>>
            </div>
            <div class="col-flex">
                <label class="form-label">Mật khẩu <% If edit_id > 0 Then %>(Bỏ trống nếu không đổi)<% Else %><span style="color:red">*</span><% End If %></label>
                <input name="password" type="password" class="form-input" autocomplete="new-password">
            </div>
            <div class="col-flex">
                <label class="form-label">Nhập lại mật khẩu</label>
                <input name="password1" type="password" class="form-input">
            </div>
        </div>

        <div class="row-grid">
            <div class="col-flex">
                <label class="form-label">Họ và tên <span style="color:red">*</span></label>
                <input name="hoten" type="text" class="form-input" value="<%=edit_hoten%>">
            </div>
            <div class="col-flex">
                <label class="form-label">Điện thoại</label>
                <input name="dienthoai" type="text" class="form-input" value="<%=edit_dienthoai%>">
            </div>
            <div class="col-flex">
                <label class="form-label">Email</label>
                <input name="email" type="text" class="form-input" value="<%=edit_email%>">
            </div>
        </div>

        <!-- KHU VỰC PHÂN QUYỀN (CHỈ HIỆN THỊ NẾU LÀ SUPER ADMIN) -->
        <% If current_is_super = 1 Then %>
        <div style="background: #f8fafc; padding: 15px; border-radius: 4px; border: 1px solid #e2e8f0; margin-top: 10px;">
            <label class="form-label" style="color: #0a69db; font-size: 14px; text-transform: uppercase;">Phân quyền hệ thống</label>
            <div class="checkbox-group">
                <input type="checkbox" id="is_super" name="is_super" value="1" <%If edit_is_super=1 Then Response.Write "checked"%> onclick="togglePermissionFields()"> 
                <label for="is_super"><b>Toàn quyền quản lý</b> (Quản lý toàn bộ hệ thống)</label>
            </div>
            <div class="checkbox-group">
                <input type="checkbox" id="is_content" name="is_content" value="1" <%If edit_is_content=1 Then Response.Write "checked"%>> 
                <label for="is_content">Quản lý nội dung (Tin tức, Hình ảnh, Video)</label>
            </div>
            <div class="checkbox-group">
                <input type="checkbox" id="is_genealogy" name="is_genealogy" value="1" <%If edit_is_genealogy=1 Then Response.Write "checked"%> onclick="togglePermissionFields()"> 
                <label for="is_genealogy">Quản lý phả hệ</label>
            </div>

            <!-- PHẠM VI QUẢN LÝ PHẢ HỆ -->
            <div id="branch_selection_box" style="display:none; margin-top: 15px; padding-left: 15px; border-left: 3px solid #0a69db;">
                <label class="form-label">Giới hạn phạm vi quản lý phả hệ (Chỉ quản lý từ nhân vật này trở xuống):</label>
                <select name="allowed_start_idgiapha" class="form-select">
                    <option value="0">-- Quản lý toàn bộ phả đồ (Không giới hạn nhánh) --</option>
                    <%
                        openconn
                        sqlGoc = "SELECT g.idgiapha, g.hoten, d.tieude FROM tblgiapha g LEFT JOIN tbldoi d ON g.iddoi = d.iddoi WHERE g.gioitinh = 1 AND (g.loai_quanhe IS NULL OR g.loai_quanhe = 1) ORDER BY g.iddoi ASC, g.thutu ASC"
                        Set rsM = Conn.Execute(sqlGoc)
                        Do While Not rsM.EOF
                            If edit_allowed_id = ValInt(rsM("idgiapha")) Then selectedStr = " selected" Else selectedStr = ""
                            Response.Write "<option value='" & rsM("idgiapha") & "'" & selectedStr & ">Đời " & rsM("tieude") & " - Ông " & rsM("hoten") & "</option>"
                            rsM.MoveNext
                        Loop
                        rsM.Close : Set rsM = Nothing
                        destroyconn
                    %>
                </select>
            </div>
        </div>
        <% End If %>

        <div style="margin-top: 20px;">
            <button type="submit" class="btn-primary"><i class="fa fa-save"></i> <% If edit_id > 0 Then %>CẬP NHẬT THÔNG TIN<% Else %>THÊM MỚI<% End If %></button>
            <% If edit_id > 0 And current_is_super = 1 Then %>
            <a href="/gpdh/nguoi-dung/" class="btn-secondary"><i class="fa fa-times"></i> QUAY LẠI DANH SÁCH</a>
            <% End If %>
        </div>
        </form>
    </div>
</div>

<!-- KHỐI 2: DANH SÁCH TÀI KHOẢN (CHỈ HIỆN THỊ CHO SUPER ADMIN) -->
<% If current_is_super = 1 Then %>
<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-list-alt"></i> DANH SÁCH NGƯỜI DÙNG HỆ THỐNG</div>
    <div class="admin-card-body" style="overflow-x: auto;">
        <table class="table-modern">
            <tr>
                <th>HỌ TÊN</th>
                <th>TÊN TRUY CẬP</th>
                <th>ĐIỆN THOẠI</th>
                <th style="text-align:left;">QUYỀN HẠN</th>
                <th style="text-align:center; width: 100px;">QUẢN LÝ</th>
            </tr>
            <%  
                openconn    
                Set rs = Server.CreateObject("adodb.recordset")
                rs.open "SELECT * FROM tbladmin ORDER BY idadmin DESC", conn, 3, 1
                
                If Request.QueryString("page") = "" Then
                    intCurrentPage = 1
                Else
                    intCurrentPage = GetSafeInt("page", 1)
                End If
                RS.PageSize = 10
                If rs.PageCount > 0 then rs.AbsolutePage = intCurrentPage
                
                j = 1
                Do While Not rs.EOF
            %>
            <tr>
                <td><%= rs("hoten") %></td>
                <td><%= rs("username") %></td>
                <td><%= rs("dienthoai") %></td>
                <td align="left">
                    <%  
                        If ValInt(rs("is_super")) = 1 Then 
                            Response.Write "<span style='color:#dc3545; font-weight:bold; background:#ffeeba; padding:4px 8px; border-radius:4px; font-size:12px;'><i class='fa fa-star'></i> Toàn quyền</span>"
                        Else
                            qList = ""
                            If ValInt(rs("is_content")) = 1 Then qList = qList & "Nội dung<br>"
                            If ValInt(rs("is_genealogy")) = 1 Then 
                                Dim phamVi, rsPhamVi
                                phamVi = "Toàn bộ"
                                If ValInt(rs("allowed_start_idgiapha")) > 0 Then
                                    Set rsPhamVi = Conn.Execute("SELECT g.hoten, d.tieude FROM tblgiapha g LEFT JOIN tbldoi d ON g.iddoi = d.iddoi WHERE g.idgiapha = " & ValInt(rs("allowed_start_idgiapha")))
                                    If Not rsPhamVi.EOF Then
                                        phamVi = "Đời " & rsPhamVi("tieude") & " (" & rsPhamVi("hoten") & ")"
                                    End If
                                    rsPhamVi.Close : Set rsPhamVi = Nothing
                                End If
                                qList = qList & "Phả hệ: <span style='color:#64748b; font-weight:normal;'>" & phamVi & "</span>"
                            End If
                            If qList = "" Then qList = "<span style='color:#94a3b8; font-style:italic;'>Chưa cấp quyền</span>"
                            Response.Write "<span style='color:#0a69db; font-weight:bold; font-size:13px; display:block; line-height:1.5;'>" & qList & "</span>"
                        End If
                    %>
                </td>
                <td align="center">
                    <a href="/gpdh/nguoi-dung/?id=<%=rs("idadmin")%>" title="Sửa thông tin"><i class="fa fa-pencil-square-o action-icon"></i></a>
                    <% If CStr(rs("idadmin")) <> CStr(current_idadmin) Then %>
                    <i class="fa fa-trash-o action-icon action-delete" title="Xóa tài khoản" onClick="del_one('<%= rs("idadmin") %>');"></i>
                    <% End If %>
                </td>
            </tr>
            <%  
                    If j = RS.PageSize Then Exit Do
                    j = j + 1                   
                    rs.MoveNext
                Loop
                rs.Close : Set rs = Nothing
                destroyconn
            %>
        </table>    
    </div>
</div>
<% End If %>