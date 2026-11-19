<%if session("username")="" then%>
<script language="javascript">
	alert("Bạn vui lòng đăng nhập để vào hệ thống quản trị!");
	window.location="../gpdh/";
</script>
<%end if%>
<% 
if request("action")="submit" then
	id = replace(request("id"),"'","''")
	hoten = replace(request("hoten"),"'","''")
	email = replace(request("email"),"'","''")
	dienthoai = replace(request("dienthoai"),"'","''")
	username = replace(request("username"),"'","''")
    
    ' Lấy thông tin phân quyền từ Checkbox và Dropdown
    If request("is_super") = "1" Then is_super = 1 Else is_super = 0
    If request("is_content") = "1" Then is_content = 1 Else is_content = 0
    If request("is_genealogy") = "1" Then is_genealogy = 1 Else is_genealogy = 0
    
    allowed_start_idgiapha = request("allowed_start_idgiapha")
    If allowed_start_idgiapha = "" Then allowed_start_idgiapha = 0

	openconn
    ' Nếu có nhập mật khẩu mới thì cập nhật mật khẩu, không thì giữ nguyên mật khẩu cũ
    If request("password") <> "" Then
        password = sha256(replace(request("password"),"'","''"))
        sql = "UPDATE tbladmin SET hoten=N'"&hoten&"', email='"&email&"', dienthoai=N'"&dienthoai&"', username='"&username&"', password='"&password&"', is_super="&is_super&", is_content="&is_content&", is_genealogy="&is_genealogy&", allowed_start_idgiapha="&allowed_start_idgiapha&" WHERE idadmin="&CInt(id)
    Else
        sql = "UPDATE tbladmin SET hoten=N'"&hoten&"', email='"&email&"', dienthoai=N'"&dienthoai&"', username='"&username&"', is_super="&is_super&", is_content="&is_content&", is_genealogy="&is_genealogy&", allowed_start_idgiapha="&allowed_start_idgiapha&" WHERE idadmin="&CInt(id)
    End If
    
	conn.execute(sql)
	destroyconn
	response.Redirect("?gpdh=30&Quan-ly-nguoi-dung.html")
end if
%>
<script language="javascript">
function CheckForm() {
    if(frmAddNews.username.value == "") {
        alert("Mời bạn nhập vào tên truy cập");
        frmAddNews.username.focus();
        return false;
    }
    if(frmAddNews.password.value != "" && frmAddNews.password.value != frmAddNews.password1.value) {
        alert("Mật khẩu mới của bạn không khớp");
        frmAddNews.password1.focus();
        return false;
    }
    if(frmAddNews.hoten.value == "") {
        alert("Mời bạn nhập vào họ tên");
        frmAddNews.hoten.focus();
        return false;
    }
    return true;
}

function togglePermissionFields() {
    var isSuper = document.getElementById('is_super').checked;
    var isGenealogy = document.getElementById('is_genealogy').checked;
    
    // Nếu chọn toàn quyền, khóa các quyền lẻ lại
    document.getElementById('is_content').disabled = isSuper;
    document.getElementById('is_genealogy').disabled = isSuper;
    
    // Hiển thị khung chọn phạm vi phả hệ nếu có quyền quản lý phả hệ hoặc toàn quyền
    var branchBox = document.getElementById('branch_selection_box');
    if (isSuper || isGenealogy) {
        branchBox.style.display = 'block';
    } else {
        branchBox.style.display = 'none';
    }
}
window.onload = function() { togglePermissionFields(); };
</script>

<form name="frmAddNews" method="post" onSubmit="return CheckForm()">
<input type="hidden" name="action" value="submit">
<table border="0" cellpadding="7" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="700">
  <tr>
    <td width="100%" align="center" class="title1">SỬA THÔNG TIN & PHÂN QUYỀN NGƯỜI DÙNG</td>
  </tr>
  <tr>
    <td width="100%">
   	<% 	
	  		 openconn	
	  		 set rs1 = server.CreateObject("adodb.recordset")
	 		 rs1.open "Select * from tbladmin where idadmin = " & CInt(request.QueryString("id")), conn
	 %>
	 <table border="0" cellpadding="5" cellspacing="0" style="border-collapse: collapse" width="100%">
		  <tr>
			<td width="180" class="tintuc1">Tên truy cập</td>
			<td width="520">
			<input name="username" class="tintuc1" type="text" value="<%=rs1("username")%>" size="50"></td>
		  </tr>
		   <tr>
			<td width="180" class="tintuc1">Mật khẩu mới</td>
			<td width="520">
			<input name="password" class="tintuc1" type="password" value="" size="50" placeholder="Bỏ trống nếu không đổi mật khẩu"></td>
		  </tr>
		   <tr>
			<td width="180" class="tintuc1">Nhập lại mật khẩu</td>
			<td width="520">
			<input name="password1" class="tintuc1" type="password" value="" size="50"></td>
		  </tr>
		   <tr>
			<td width="180" class="tintuc1">Họ và tên</td>
			<td width="520">
			<input name="hoten" class="tintuc1" type="text" value="<%=rs1("hoten")%>" size="50"></td>
		  </tr>
		  <tr>
			<td width="180" class="tintuc1">Email</td>
			<td width="520">
			<input name="email" class="tintuc1" type="text" value="<%=rs1("email")%>" size="50"></td>
		  </tr>
		  <tr>
			<td width="180" class="tintuc1">Điện thoại</td>
			<td width="520">
			<input name="dienthoai" class="tintuc1" type="text" value="<%=rs1("dienthoai")%>" size="50"></td>
		  </tr>

          <!-- CẤU HÌNH PHÂN QUYỀN -->
          <tr>
              <td colspan="2" style="background:#f4f4f4; padding:10px; font-weight:bold; color:#0a69db;">PHÂN QUYỀN HỆ THỐNG</td>
          </tr>
          <tr>
              <td colspan="2" class="tintuc1">
                  <label><input type="checkbox" id="is_super" name="is_super" value="1" <%If rs1("is_super")=1 Then Response.Write "checked"%> onclick="togglePermissionFields()"> <b>Toàn quyền quản lý</b> (Full quyền hệ thống)</label>
              </td>
          </tr>
          <tr>
              <td colspan="2" class="tintuc1">
                  <label><input type="checkbox" id="is_content" name="is_content" value="1" <%If rs1("is_content")=1 Then Response.Write "checked"%>> <b>Quản lý nội dung</b> (Tin tức, Hình ảnh, Video)</label>
              </td>
          </tr>
          <tr>
              <td colspan="2" class="tintuc1">
                  <label><input type="checkbox" id="is_genealogy" name="is_genealogy" value="1" <%If rs1("is_genealogy")=1 Then Response.Write "checked"%> onclick="togglePermissionFields()"> <b>Quản lý phả hệ</b></label>
              </td>
          </tr>

          <!-- PHẠM VI QUẢN LÝ PHẢ HỆ -->
          <tr id="branch_selection_box" style="display:none;">
              <td colspan="2" style="padding-left:20px; background:#fafafa; border-left:3px solid #0a69db;">
                  <p class="tintuc1" style="margin:5px 0; font-weight:bold;">Giới hạn phạm vi quản lý phả hệ:</p>
                  <span class="tintuc1">Chỉ cho phép quản lý từ nhân vật này trở xuống (Hậu duệ):</span>
                  <select name="allowed_start_idgiapha" class="tintuc1" style="padding:4px; width:100%; margin-top:5px;">
                      <option value="0">-- Quản lý toàn bộ phả hệ (Không giới hạn) --</option>
                      <%
                          Set rsM = conn.Execute("SELECT g.idgiapha, g.hoten, d.tieude FROM tblgiapha g LEFT JOIN tbldoi d ON g.iddoi = d.iddoi ORDER BY g.iddoi ASC, g.thutu ASC")
                          Do While Not rsM.EOF
                              If CStr(rs1("allowed_start_idgiapha")) = CStr(rsM("idgiapha")) Then selectedStr = " selected" Else selectedStr = ""
                              Response.Write "<option value='" & rsM("idgiapha") & "'" & selectedStr & ">Đời " & rsM("tieude") & " - " & rsM("hoten") & "</option>"
                              rsM.MoveNext
                          Loop
                          rsM.Close
                      %>
                  </select>
              </td>
          </tr>

        <tr align="center">
          	<td width="100%" colspan="2" style="padding-top:15px;">
				<input type="submit" class="tintuc2" name="submit" value="Lưu thay đổi" style="padding:6px 20px; cursor:pointer; background:#0a69db; color:#fff; border:none; border-radius:3px;">
            </td>
        </tr>
	</table>
	</td>
	</tr>
</table>
</form>
<% 
rs1.Close
Set rs1 = Nothing
destroyconn() 
%>