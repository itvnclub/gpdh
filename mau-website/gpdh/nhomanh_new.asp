<%
If Session("username") = "" Then
%>
<script language="javascript">
  alert("Bạn vui lòng đăng nhập để vào hệ thống quản trị!");
  window.location.href = "/gpdh/";
</script>
<% 
    Response.End
End If

If CInt("0" & Session("is_super")) = 0 And CInt("0" & Session("is_content")) = 0 Then
%>
<script language="javascript">
  alert("Bạn không có quyền truy cập vào chức năng này!");
  window.location.href = "/gpdh/bang-dieu-khien/";
</script>
<% 
    Response.End
End If

If Request("action_new") = "submit" Then
    tieude = Replace(Request.Form("tieude"),"'","''")
    openconn
    conn.execute("INSERT INTO tblnhomanh(tieude, thutu) VALUES(N'"&tieude&"', 0)")
    
    Set rsNew = conn.Execute("SELECT @@IDENTITY AS NewID")
    new_id = rsNew("NewID")
    rsNew.Close : Set rsNew = Nothing
    destroyconn
    
    Response.Redirect("/gpdh/sua-thu-vien-anh/?id=" & new_id)
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

.form-label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #475569; }
.form-input { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; color: #334155; transition: 0.2s; box-sizing: border-box; }
.form-input:focus { border-color: #0a69db; outline: none; box-shadow: 0 0 0 3px rgba(10,105,219,0.1); }

.btn-primary { background: #0a69db; color: #fff; border: none; padding: 12px 24px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; text-transform: uppercase; }
.btn-primary:hover { background: #0056b3; }
</style>

<script language="javascript1.2" type="text/javascript">
function check_input() {
    var NTitle = document.frmAddNhom.tieude.value;
    if (NTitle == "") { alert("Bạn chưa nhập tên sự kiện / nhóm ảnh!"); document.frmAddNhom.tieude.focus(); return false; }
    return true;        
}
</script>

<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-folder-plus"></i> KHỞI TẠO NHÓM ẢNH MỚI</div>
    <div class="admin-card-body">
        
        <div style="background: #eff6ff; border-left: 4px solid #3b82f6; padding: 15px; border-radius: 4px; margin-bottom: 20px; font-size: 14px; color: #1e3a8a;">
            <b>Hướng dẫn:</b> Bạn hãy nhập Tên nhóm ảnh và bấm Khởi tạo. Ngay sau đó, hệ thống sẽ mở ra giao diện để bạn kéo thả hàng loạt hình ảnh vào nhóm này.
        </div>

        <form name="frmAddNhom" method="post" action="" onSubmit="return check_input();">
        <input type="hidden" name="action_new" value="submit">

        <div class="row-grid">
            <div class="col-flex" style="flex: 2;">
                <label class="form-label">Tên nhóm ảnh (Tên sự kiện) <span style="color:red">*</span></label>
                <input name="tieude" type="text" class="form-input" placeholder="Ví dụ: Lễ tế tổ mùa xuân năm 2026...">
            </div>
        </div>

        <div style="text-align: center; margin-top: 25px;">
            <button type="submit" name="submit" class="btn-primary"><i class="fa fa-arrow-right"></i> Khởi tạo & Chuyển tới Tải ảnh</button>
        </div>
        </form>
    </div>
</div>