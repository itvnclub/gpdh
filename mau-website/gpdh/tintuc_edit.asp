<%
' ====================================================
' 0. KIỂM TRA QUYỀN TRUY CẬP TRANG
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
  alert("Bạn không có quyền truy cập vào chức năng này!");
  window.location.href = "/gpdh/bang-dieu-khien/";
</script>
<% 
    Response.End
End If
%>

<% 
' ====================================================
' 1. XỬ LÝ CẬP NHẬT DỮ LIỆU
' ====================================================
If Request.Form("action_edit") = "submit" Then
  id         = replace(request("id"),"'","''")
  idnhomtin  = replace(request("idnhomtin"),"'","''")
  tieude     = replace(request("tieude"),"'","''")
  hinhanh    = replace(request("hinhanh"),"'","''")
  trichdan   = replace(request("trichdan"),"'","''")
  noidung      = replace(request("noidung"),"'","''")
  ngaycapnhat  = replace(request("ngaycapnhat"),"'","''")
  top1         = replace(request("top1"),"'","''")
    
  If top1 = "" Then top1 = 0
  If idnhomtin = "" Or Not IsNumeric(idnhomtin) Then idnhomtin = 0

  openconn
  sql = "UPDATE tbltintuc SET idnhomtin="&CInt(idnhomtin)&", tieude=N'"&tieude&"', trichdan=N'"&trichdan&"', noidung=N'"&noidung&"', hinhanh='"&hinhanh&"', ngaycapnhat='"&ngaycapnhat&"', top1='"&top1&"' WHERE idtintuc="&CInt(id)
  conn.execute(sql)
  destroyconn
  
  ' Điều hướng về trang danh sách tin tức bằng URL thân thiện
  Response.Redirect("/gpdh/tin-tuc/")
End If
%>

<style>
.admin-card { background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 25px; border: 1px solid #e2e8f0; overflow: hidden; }
.admin-card-header { background: #f8fafc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0; font-weight: bold; color: #0f172a; font-size: 15px; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
.admin-card-header i { color: #f59e0b; font-size: 18px; }
.admin-card-body { padding: 20px; }

.row-grid { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 15px; }
.col-flex { flex: 1; min-width: 250px; }
.col-full { flex: 1 1 100%; }

.form-label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #475569; }
.form-input { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; color: #334155; transition: 0.2s; box-sizing: border-box; font-family: inherit; }
.form-input:focus { border-color: #f59e0b; outline: none; box-shadow: 0 0 0 3px rgba(245,158,11,0.1); }
.form-textarea { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; color: #334155; resize: vertical; min-height: 100px; font-family: inherit; }

.input-group { display: flex; }
.input-group .form-input { border-top-right-radius: 0; border-bottom-right-radius: 0; border-right: none; }
.btn-upload { background: #f1f5f9; padding: 10px 15px; text-decoration: none; border-radius: 0 4px 4px 0; border: 1px solid #cbd5e1; color: #475569; font-size: 13px; font-weight: 600; white-space: nowrap; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; margin: 0; box-sizing: border-box; }
.btn-upload:hover { background: #e2e8f0; color: #0f172a; }

.btn-warning { background: #f59e0b; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; text-transform: uppercase; }
.btn-warning:hover { background: #d97706; }
.checkbox-group { display: flex; align-items: center; gap: 8px; font-weight: 600; font-size: 14px; color: #334155; cursor: pointer; }
.editor-wrapper { border: 1px solid #cbd5e1; border-radius: 4px; overflow: hidden; background: #fff; }

select.form-input { appearance: auto; -webkit-appearance: auto; -moz-appearance: auto; cursor: pointer; }
</style>

<script language="javascript1.2" type="text/javascript">
function check_input() {
  var NCategory = document.frmEditNews.idnhomtin.value;
  var NTitle = document.frmEditNews.tieude.value;
  var NContent = document.frmEditNews.noidung.value;
  
  if (NCategory === "") { alert("Vui lòng chọn nhóm tin cho bài viết!"); document.frmEditNews.idnhomtin.focus(); return false; }
  if (NTitle === "") { alert("Bạn chưa nhập tiêu đề cho tin!"); document.frmEditNews.tieude.focus(); return false; }
  if (NContent === "") { alert("Bạn chưa nhập nội dung của tin!"); document.frmEditNews.noidung.focus(); return false; }
  return true;    
}

// XỬ LÝ UPLOAD ẢNH BẰNG AJAX
async function uploadNewsImage(fileInput, targetInputId) {
    if(fileInput.files.length === 0) return;
    var file = fileInput.files[0];
    var targetInput = document.getElementById(targetInputId);
    var originalVal = targetInput.value;

    targetInput.value = "Đang tải ảnh lên...";

    var formData = new FormData();
    formData.append('file', file);

    try {
        // [QUAN TRỌNG] Dùng đường dẫn tuyệt đối để tránh lỗi 404
        let response = await fetch('/gpdh/ajax_upload_ha.asp', {
            method: 'POST',
            body: formData
        });
        let fileName = await response.text();
        fileName = fileName.trim();

        if(fileName.indexOf("Lỗi") !== -1 || fileName === "") {
            alert(fileName === "" ? "Lỗi không xác định khi tải ảnh." : fileName);
            targetInput.value = originalVal; 
        } else {
            targetInput.value = "Images/Hinhanh/" + fileName;
        }
    } catch (error) {
        alert('Lỗi hệ thống khi tải ảnh!');
        targetInput.value = originalVal;
    }
    
    fileInput.value = "";
}
</script>

<%  
    ' Bắt lỗi an toàn nếu truyền sai ID
    edit_id = Request.QueryString("id")
    If edit_id = "" Or Not IsNumeric(edit_id) Then
        Response.Write "<div class='admin-card'><div class='admin-card-body' style='text-align:center; color:red; font-weight:bold;'><i class='fa fa-exclamation-triangle'></i> Mã tin tức không hợp lệ!</div></div>"
        Response.End
    End If

    openconn  
    Set rsEditNews = Server.CreateObject("ADODB.Recordset")
    rsEditNews.Open "SELECT * FROM tbltintuc WHERE idtintuc = " & CInt(edit_id), conn
    
    If rsEditNews.EOF Then
        Response.Write "<div class='admin-card'><div class='admin-card-body' style='text-align:center; color:red; font-weight:bold;'><i class='fa fa-exclamation-triangle'></i> Không tìm thấy tin tức cần sửa!</div></div>"
        Response.End
    End If
%>

<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-pencil-square-o"></i> SỬA THÔNG TIN TIN TỨC</div>
    <div class="admin-card-body">
        <form name="frmEditNews" method="post" action="" onSubmit="return check_input();">
        <input type="hidden" name="action_edit" value="submit">
        <input type="hidden" name="id" value="<%= rsEditNews("idtintuc") %>">

        <!-- KIỂM TRA NHÓM TIN TRƯỚC KHI HIỂN THỊ FORM -->
        <%
        Set rsCat = conn.Execute("SELECT idnhomtin, tieude FROM tblnhomtin ORDER BY thutu ASC, idnhomtin DESC")
        
        If Not rsCat.EOF Then
            hasCategory = True
        Else
            hasCategory = False
        End If
        %>

        <div class="row-grid">
            <% If hasCategory Then %>
                <!-- CÓ NHÓM TIN -->
                <div class="col-flex" style="flex: 1;">
                    <label class="form-label">Thuộc nhóm tin <span style="color:red">*</span></label>
                    <select name="idnhomtin" id="idnhomtin" class="form-input">
                        <option value="">-- Chọn nhóm tin --</option>
                        <%
                        Do While Not rsCat.EOF
                            ' So khớp ID nhóm tin để tự động chọn đúng Option cũ của bài viết
                            If CInt("0" & rsEditNews("idnhomtin")) = CInt(rsCat("idnhomtin")) Then
                                isSelected = "selected"
                            Else
                                isSelected = ""
                            End If
                        %>
                        <option value="<%=rsCat("idnhomtin")%>" <%=isSelected%>><%=rsCat("tieude")%></option>
                        <%
                            rsCat.MoveNext
                        Loop
                        %>
                    </select>
                </div>
                <div class="col-flex" style="flex: 2.5;">
                    <label class="form-label">Tiêu đề tin tức <span style="color:red">*</span></label>
                    <input name="tieude" type="text" class="form-input" value="<%= rsEditNews("tieude") %>">
                </div>
            <% Else %>
                <!-- KHÔNG CÓ NHÓM TIN -->
                <input type="hidden" name="idnhomtin" id="idnhomtin" value="0">
                <div class="col-full">
                    <label class="form-label">Tiêu đề tin tức <span style="color:red">*</span></label>
                    <input name="tieude" type="text" class="form-input" value="<%= rsEditNews("tieude") %>">
                </div>
            <% End If %>
            <%
            ' Đóng Recordset rsCat
            rsCat.Close : Set rsCat = Nothing
            %>
        </div>

        <div class="row-grid">
            <div class="col-full">
                <label class="form-label">Ảnh đại diện (800 x 600)</label>
                <div class="input-group">
                    <input name="hinhanh" id="hinhanh" type="text" class="form-input" value="<%= rsEditNews("hinhanh") %>">
                    <label class="btn-upload">
                        <i class="fa fa-upload" style="margin-right: 5px;"></i> Tải ảnh
                        <input type="file" accept="image/*" style="display:none;" onchange="uploadNewsImage(this, 'hinhanh')">
                    </label>
                </div>
            </div>
        </div>

        <div class="row-grid">
            <div class="col-flex">
                <label class="form-label">Ngày cập nhật</label>
                <div class="input-group">
<input name="ngaycapnhat" id="ngaycapnhat" type="date" class="form-input" value="<%=defaultDate%>">                </div>
            </div>
            <div class="col-flex" style="display: flex; align-items: flex-end;">
                <label class="checkbox-group" style="padding-bottom: 10px;">
                    <input type="checkbox" name="top1" value="1" style="width: 18px; height: 18px; cursor: pointer;" <%If CInt("0" & rsEditNews("top1")) = 1 Then Response.Write "checked"%>> Đánh dấu Tin tức nổi bật
                </label>
            </div>
        </div>

        <div class="row-grid">
            <div class="col-full">
                <label class="form-label">Tóm tắt / Trích dẫn</label>
                <textarea name="trichdan" class="form-textarea"><%= rsEditNews("trichdan") %></textarea>
            </div>
        </div>

        <div class="row-grid">
            <div class="col-full">
                <label class="form-label">Nội dung chi tiết <span style="color:red">*</span></label>
                <div class="editor-wrapper">
                    <textarea id="noidung" name="noidung" rows="4" style="width:100%;">
                      <%
                      function encodeHTML(sHTML)
                        sHTML = replace(sHTML,"&","&amp;")
                        sHTML = replace(sHTML,"<","&lt;")
                        sHTML = replace(sHTML,">","&gt;")
                        encodeHTML = sHTML
                      end function
                      Response.Write encodeHTML(rsEditNews("noidung") & "")
                      %>
                    </textarea>
                    <script>
                        var oEdit2 = new InnovaEditor("oEdit2");
                        oEdit2.width = "100%";
                        oEdit2.height = 400;
                        oEdit2.features = ["Save","FullScreen","Preview","Print","Search","SpellCheck","Superscript","Subscript","LTR","RTL","Table","Guidelines","Absolute","Flash","Media","InternalLink","CustomObject","Form","Characters","ClearAll","XHTMLFullSource","XHTMLSource","BRK","Cut","Copy","Paste","PasteWord","PasteText","Undo","Redo","Hyperlink","Bookmark","Image","JustifyLeft","JustifyCenter","JustifyRight","JustifyFull","Numbering","Bullets","Indent","Outdent","Line","RemoveFormat","BRK","StyleAndFormatting","TextFormatting","ListFormatting","BoxFormatting","ParagraphFormatting","CssText","Styles","CustomTag","Paragraph","FontName","FontSize","Bold","Italic","Underline","Strikethrough","ForeColor","BackColor"];
                        
                        // [QUAN TRỌNG] Gắn lại file css giao diện soạn thảo nếu có
                        oEdit2.css = "/gpdh/css/cms.css"; 
                        
                        oEdit2.cmdAssetManager = "modalDialogShow('/Editor/assetmanager/assetmanager.asp',640,465)"; 
                        oEdit2.mode = "XHTMLBody"; 
                        oEdit2.REPLACE("noidung");
                    </script>
                </div>
            </div>
        </div>

        <div style="text-align: center; margin-top: 20px;">
            <button type="submit" name="submit" class="btn-warning"><i class="fa fa-save"></i> Cập nhật tin tức</button>
        </div>
        </form>
    </div>
</div>

<% 
rsEditNews.Close
Set rsEditNews = Nothing
destroyconn()
%>