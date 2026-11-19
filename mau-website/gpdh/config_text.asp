<%
' ====================================================
' 1. KIỂM TRA SESSION ĐĂNG NHẬP
' ====================================================
If Session("username") = "" Then
%>
<script language="javascript">
    alert("Bạn vui lòng đăng nhập để vào hệ thống quản trị!");
    window.location="../gpdh/";
</script>
<% 
    Response.End
End If
%>

<%
' ====================================================
' 2. XỬ LÝ LƯU DỮ LIỆU CẬP NHẬT
' ====================================================
Dim action_text, item, fldKey, fldVal
action_text = Request.Form("action_text")

If action_text = "submit" Then
    openconn
    ' Tự động lặp qua tất cả các input được gửi lên có tiền tố "txt_"
    For Each item In Request.Form
        If Left(item, 4) = "txt_" Then
            fldKey = Mid(item, 5) ' Cắt bỏ chữ "txt_" để lấy TextKey gốc
            fldVal = Replace(Request.Form(item), "'", "''") ' Xử lý chống lỗi nháy đơn SQL
            
            ' Cập nhật vào database
            conn.Execute("UPDATE tblUI_Text SET TextValue=N'" & fldVal & "' WHERE TextKey='" & fldKey & "'")
        End If
    Next
    destroyconn
%>
    <script language="javascript">
        alert("Cập nhật các nội dung văn bản thành công!");
        window.location="cau-hinh-text"; // THAY ĐỔI SỐ NÀY THÀNH ID MENU CỦA TRANG NÀY
    </script>
<%
    Response.End
End If
%>

<!-- ==================================================== -->
<!-- 3. GIAO DIỆN HIỂN THỊ FORM                           -->
<!-- ==================================================== -->
<style>
/* Kế thừa CSS từ trang config */
.admin-card { background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 25px; border: 1px solid #e2e8f0; font-family: Arial, sans-serif; font-size: 14px; overflow: hidden; }
.admin-card-header { background: #f8fafc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0; font-weight: bold; color: #0f172a; font-size: 15px; text-transform: uppercase; }
.admin-card-body { padding: 20px; }
.row-grid { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 15px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 15px; }
.row-grid:last-child { border-bottom: none; padding-bottom: 0; margin-bottom: 0; }
.col-flex { flex: 1; min-width: 300px; }
.form-label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #0a69db; }
.form-note { display: inline-block; color: #64748b; font-weight: normal; font-size: 12px; margin-left: 5px; }
.form-input, .form-textarea { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; transition: 0.2s; box-sizing: border-box; }
.form-input:focus, .form-textarea:focus { border-color: #0a69db; outline: none; box-shadow: 0 0 0 3px rgba(10,105,219,0.1); }
.form-textarea { resize: vertical; min-height: 60px; }
.btn-primary { background: #0a69db; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; }
.btn-primary:hover { background: #0056b3; }
</style>

<form name="frmText" method="post" action="">
    <input type="hidden" name="action_text" value="submit">

    <div class="admin-card">
        <div class="admin-card-header"><i class="fa fa-language"></i> QUẢN LÝ TIÊU ĐỀ & VĂN BẢN GIAO DIỆN</div>
        <div class="admin-card-body">
            
            <%
            openconn
            Dim rsText, tKey, tVal, tNote
            Set rsText = Server.CreateObject("ADODB.Recordset")
            ' Load danh sách từ database, có thể dùng thuộc tính GhiChu để phân nhóm nếu cần
            rsText.Open "SELECT * FROM tblUI_Text ORDER BY TextKey ASC", conn, 1, 1

            If Not rsText.EOF Then
                Do While Not rsText.EOF
                    tKey = rsText("TextKey")
                    tVal = rsText("TextValue") & ""
                    tNote = rsText("GhiChu") & ""
            %>
            <div class="row-grid">
                <div class="col-flex">
                    <label class="form-label">
                        <%=tKey%> <span class="form-note">(<%=tNote%>)</span>
                    </label>
                    <!-- Tự động dùng textarea cho các trường có chữ "Desc" hoặc nội dung dài, còn lại dùng input -->
                    <% If InStr(LCase(tKey), "desc") > 0 Or Len(tVal) > 60 Then %>
                        <textarea name="txt_<%=tKey%>" class="form-textarea"><%=tVal%></textarea>
                    <% Else %>
                        <input type="text" name="txt_<%=tKey%>" value="<%=tVal%>" class="form-input">
                    <% End If %>
                </div>
            </div>
            <%
                    rsText.MoveNext
                Loop
            Else
                Response.Write "<p style='color:red;'>Chưa có dữ liệu trong bảng tblUI_Text. Vui lòng chạy lệnh SQL Insert trước.</p>"
            End If
            
            rsText.Close
            Set rsText = Nothing
            destroyconn
            %>

        </div>
    </div>

    <div style="text-align: center; margin-bottom: 40px;">
        <button type="submit" class="btn-primary"><i class="fa fa-save"></i> LƯU TOÀN BỘ THAY ĐỔI</button>
    </div>
</form>