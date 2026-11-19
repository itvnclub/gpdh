<%session.CodePage=65001%>
<%
' ====================================================
' 0. KIỂM TRA QUYỀN TRUY CẬP (BẢO MẬT & URL REWRITE)
' ====================================================
If Session("username") = "" Then
%>
<script language="javascript">
    alert("Phiên đăng nhập đã hết hạn. Bạn vui lòng đăng nhập lại!");
    window.parent.location = "bang-dieu-khien/";
</script>
<% 
    Response.End
End If

If is_super = 0 And is_genealogy = 0 Then
%>
<script language="javascript">
    alert("Bạn không có quyền truy cập vào chức năng Quản lý Phả hệ!");
    window.parent.$.fancybox.close();
</script>
<% 
    Response.End
End If
%>

<style>
/* Ẩn Header, Sidebar và các khoảng trắng thừa của Default.asp khi mở bên trong Iframe Popup */
.topbar, .sidebar, .top-header { display: none !important; }
.admin-layout, .admin-wrapper { min-height: auto !important; }
.main-content { padding: 5px !important; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}

/* Cấu trúc Card Layout đồng bộ */
.form-container { background: #fff; padding: 25px; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.form-title { font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important; font-weight: bold; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 20px; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
.form-title i { font-size: 1.2em; }

/* Bảng danh sách tối giản, kế thừa font hệ thống */
.table-custom { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 0.95em; }
.table-custom th { background-color: #f1f5f9; color: #0f172a; padding: 12px 10px; border: 1px solid #cbd5e1; text-align: center; font-weight: bold; text-transform: uppercase; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-custom td { border: 1px solid #e2e8f0; padding: 10px 12px; vertical-align: middle; color: #334155; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.row-item { transition: 0.2s; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.row-item:hover { background-color: #f8fafc; }

/* Định dạng Icon Thao tác */
.btn-action { margin: 0 6px; text-decoration: none; display: inline-block; font-size: 1.2em; transition: 0.2s; }
.btn-edit { color: #f59e0b; } 
.btn-delete { color: #dc2626; } 
.btn-action:hover { transform: scale(1.25); }

.empty-notice { text-align: center; padding: 30px; color: #64748b; font-style: italic; font-size: 0.95em; }
</style>

<% 
' ====================================================
' 1. KHỐI XỬ LÝ XÓA DỮ LIỆU
' ====================================================
If Request.QueryString("action") = "del_one" Then
    openconn
    Dim nidDel
    nidDel = Replace(Request.QueryString("nid"),"'","''")
    conn.execute("DELETE FROM tblgiapha WHERE idgiapha=" & CInt(nidDel))
    destroyconn
%>
<script language="javascript">
    alert("Đã xóa nhân vật thành công!");
    if (window.parent && window.parent.location) {
        window.parent.location.reload();
    }
    if (window.parent && window.parent.$.fancybox) {
        window.parent.$.fancybox.close();
    }
</script>
<%
    Response.End
End If
%>

<%
    ' ====================================================
    ' 2. KHAI BÁO BIẾN VÀ LẤY THÔNG TIN NHÂN VẬT CHÍNH
    ' ====================================================
    openconn
    sessionpage = Replace(Request.QueryString("sessionpage"),"'","''")
    
    Set rskieu = Server.CreateObject("ADODB.Recordset")
    rskieu.Open "SELECT hoten, gioitinh FROM tblgiapha WHERE idgiapha=" & CInt(sessionpage), conn 
    
    titleColor = "#0a69db"
    titleIcon = "fa-info-circle"

    If Not rskieu.EOF Then
        mainName = rskieu("hoten")
        mainGender = CInt("0" & rskieu("gioitinh"))
        If mainGender = 1 Then
            labelTitle = "DANH SÁCH VỢ CỦA ÔNG " & UCase(mainName)
            titleColor = "#e11d48" ' Màu hồng/đỏ cho form Vợ
            titleIcon = "fa-female"
        Else
            labelTitle = "DANH SÁCH CHỒNG CỦA BÀ " & UCase(mainName)
            titleColor = "#0a69db" ' Màu xanh cho form Chồng
            titleIcon = "fa-male"
        End If
    Else
        labelTitle = "DANH SÁCH VỢ / CHỒNG"
    End If
    rskieu.Close
    Set rskieu = Nothing
%>

<script>
// Hàm xóa được cập nhật để chạy chuẩn với URL Rewrite
function del_one(nid) {
  if (confirm("Bạn có chắc chắn muốn xóa nhân vật này không?")) {
    document.location.href = "?sessionpage=<%=sessionpage%>&action=del_one&nid=" + nid;
  }
}
</script>

<div class="form-container">
    <div class="form-title" style="color: <%=titleColor%>;"><i class="fa <%=titleIcon%>"></i> <%=labelTitle%></div>
    
    <table class="table-custom">
      <tr>
        <th width="10%">TT</th>
        <th width="65%">HỌ VÀ TÊN</th>
        <th width="25%">QUẢN LÝ</th>
      </tr>
      
      <%    
          Dim rsSpouse
          Set rsSpouse = Server.CreateObject("ADODB.Recordset")
          rsSpouse.Open "SELECT * FROM tblgiapha WHERE loai_quanhe = 2 AND id_vochong=" & CInt(sessionpage) & " ORDER BY thutu ASC, idgiapha ASC", conn, 3, 1
          
          If rsSpouse.EOF Then
      %>
      <tr>
          <td colspan="3" class="empty-notice">Chưa có thông tin vợ/chồng nào được cập nhật.</td>
      </tr>
      <% 
          Else
              stt = 0
              Do While Not rsSpouse.EOF
                  stt = stt + 1
      %>
      <tr class="row-item">
        <td align="center" class="font14"><%= stt %></td>
        <td  class="font14"><%= rsSpouse("hoten") %></td>
        <td  class="font14" align="center" style="white-space: nowrap;">
            <!-- URL Tối ưu Rewrite: sua-nhan-vat/?id=... -->
            <a href="javascript:void(0);" onclick="if(typeof parent !== 'undefined' && parent.$.fancybox) { parent.$.fancybox.open({src: 'sua-nhan-vat/?id=<%=rsSpouse("idgiapha")%>', type: 'iframe', opts: {iframe: {css: {width: '800px', height: '90%'}}}}); } else { $.fancybox.open({src: 'sua-nhan-vat/?id=<%=rsSpouse("idgiapha")%>', type: 'iframe', opts: {iframe: {css: {width: '800px', height: '90%'}}}}); }" title="Sửa thông tin" class="btn-action btn-edit">
                <i class="fa fa-pencil-square-o"></i>
            </a>
            
            <a href="javascript:void(0);" onclick="del_one('<%= rsSpouse("idgiapha") %>');" title="Xóa thông tin" class="btn-action btn-delete">
                <i class="fa fa-trash-o"></i>
            </a>
        </td>
      </tr>
      <% 
                  rsSpouse.MoveNext
              Loop
          End If
          rsSpouse.Close
          Set rsSpouse = Nothing
          destroyconn
      %>
    </table>
</div>