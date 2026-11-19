<%session.CodePage=65001%>
<%
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
' XỬ LÝ LƯU DỮ LIỆU
If Request.Form("action_edit") = "submit" Then
  gioithieu = Replace(Request.Form("gioithieu"),"'","''")
  hinhanh   = Replace(Request.Form("hinhanh"),"'","''")
  
    openconn
  sql = "UPDATE tblconfig SET gioithieu=N'"&gioithieu&"', hinhanh='"&hinhanh&"' WHERE idconfig=1"
  conn.execute(sql)
    destroyconn
%>
<script language="javascript">
    alert("Cập nhật thông tin Giới thiệu Trang chủ thành công!");
    window.location.href="gioi-thieu";
</script>
<%
    Response.End
End If

' LẤY DỮ LIỆU HIỆN TẠI
openconn  
Set rs1 = Server.CreateObject("ADODB.Recordset")
rs1.open "SELECT hinhanh, gioithieu FROM tblconfig WHERE idconfig = 1", conn
If rs1.EOF Then
    Response.Write "Không tìm thấy cấu hình!"
    Response.End
End If
%>

<style>
.admin-card { background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 25px; border: 1px solid #e2e8f0; overflow: hidden; font-family: inherit; font-size: inherit; }
.admin-card-header { background: #f8fafc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0; font-weight: bold; color: #0f172a; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
.admin-card-header i { color: #0a69db; font-size: 1.2em; }
.admin-card-body { padding: 20px; }

.row-grid { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 20px; width: 100%; }
.col-full { flex: 1 1 100%; }

.form-label { display: block; font-weight: 600; margin-bottom: 8px; color: #475569; font-size: 0.95em; }
.form-input { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; color: #334155; transition: 0.2s; box-sizing: border-box; font-family: inherit; font-size: 1em; }
.form-input:focus { border-color: #0a69db; outline: none; box-shadow: 0 0 0 3px rgba(10,105,219,0.1); }
.readonly-field { background: #f1f5f9; color: #64748b; pointer-events: none; border-color: #e2e8f0; }

.btn-primary { background: #0a69db; color: #fff; border: none; padding: 12px 24px; border-radius: 4px; font-weight: bold; cursor: pointer; transition: 0.2s; text-transform: uppercase; font-size: 1em; display: inline-flex; align-items: center; gap: 8px; }
.btn-primary:hover { background: #0056b3; }
.btn-upload-ajax { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; padding: 8px 15px; border-radius: 4px; cursor: pointer; font-weight: 600; transition: 0.2s; display: inline-flex; align-items: center; gap: 6px; font-size: 0.9em; }
.btn-upload-ajax:hover { background: #e2e8f0; color: #0f172a; border-color: #94a3b8; }

.editor-wrapper { border: 1px solid #cbd5e1; border-radius: 4px; overflow: hidden; background: #fff; }

/* Khu vực hiển thị ảnh đại diện */
.img-preview-box { border: 1px dashed #cbd5e1; padding: 10px; border-radius: 6px; display: inline-block; background: #f8fafc; text-align: center; min-width: 150px; min-height: 100px; display: flex; align-items: center; justify-content: center; flex-direction: column; }
.img-preview-box img { max-width: 250px; max-height: 200px; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); display: none; }
</style>

<script>
function check_input() {
    var content = document.frmIntro.gioithieu.value;
    if (content === "") { alert("Nội dung giới thiệu không được để trống!"); return false; }
    return true;    
}

// Xử lý upload ảnh ngầm bằng AJAX gọi tới file ajax_upload_ha.asp của bạn
function triggerUpload() {
    document.getElementById('fileAjaxUpload').click();
}

document.addEventListener("DOMContentLoaded", function() {
    var fileInput = document.getElementById('fileAjaxUpload');
    var statusText = document.getElementById('uploadStatus');
    var imgPreview = document.getElementById('imgPreview');
    var txtHinhanh = document.getElementById('hinhanh');

    // Nếu đã có ảnh từ trước, hiển thị lên
    if(txtHinhanh.value !== "") {
        imgPreview.src = (txtHinhanh.value.indexOf("http") === 0 || txtHinhanh.value.indexOf("../") === 0) ? txtHinhanh.value : "../Images/Hinhanh/" + txtHinhanh.value;
        imgPreview.style.display = "block";
    }

    fileInput.addEventListener('change', function(e) {
        var file = e.target.files[0];
        if (!file) return;

        var formData = new FormData();
        formData.append('file', file); 

        statusText.innerHTML = "<i class='fa fa-spinner fa-spin'></i> Đang tải lên...";
        statusText.style.color = "#0a69db";

        fetch('ajax_upload_ha.asp', {
            method: 'POST',
            body: formData
        })
        .then(response => response.text())
        .then(fileName => {
            fileName = fileName.trim();
            if(fileName.indexOf("Lỗi") !== -1) {
                alert(fileName);
                statusText.innerHTML = "<span style='color:red;'><i class='fa fa-exclamation-triangle'></i> Tải thất bại</span>";
            } else {
                // Tùy theo logic frontend của bạn, thường thẻ img cần ../Images/Hinhanh/
                var fullPath = "Images/Hinhanh/" + fileName; 
                txtHinhanh.value = fullPath;
                imgPreview.src = "../" + fullPath;
                imgPreview.style.display = "block";
                statusText.innerHTML = "<span style='color:#10b981;'><i class='fa fa-check-circle'></i> Tải ảnh thành công!</span>";
            }
        })
        .catch(error => {
            alert('Có lỗi xảy ra khi kết nối máy chủ tải ảnh!');
            statusText.innerHTML = "";
        });
    });
});
</script>

<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-info-circle"></i> GIỚI THIỆU NGẮN TRANG CHỦ</div>
    <div class="admin-card-body">
        
        <form name="frmIntro" method="post" onSubmit="return check_input();">
        <input type="hidden" name="action_edit" value="submit">

        <!-- Upload Hình ảnh bằng AJAX -->
        <div class="row-grid">
            <div class="col-full">
                <label class="form-label">Hình ảnh đại diện (Kích thước khuyên dùng: 900 x 900)</label>
                <div style="display: flex; gap: 20px; align-items: flex-start;">
                    
                    <div class="img-preview-box">
                        <img id="imgPreview" src="">
                    </div>
                    
                    <div style="flex: 1;">
                        <input name="hinhanh" id="hinhanh" type="text" class="form-input readonly-field" value="<%=rs1("hinhanh")%>" readonly style="margin-bottom: 10px;" placeholder="Đường dẫn ảnh sẽ tự động xuất hiện tại đây sau khi tải lên...">
                        
                        <input type="file" id="fileAjaxUpload" accept="image/*" style="display: none;">
                        <button type="button" class="btn-upload-ajax" onclick="triggerUpload()">
                            <i class="fa fa-cloud-upload"></i> Chọn ảnh từ máy tính
                        </button>
                        <span id="uploadStatus" style="margin-left: 10px; font-weight: bold; font-size: 13px;"></span>
                    </div>

                </div>
            </div>
        </div>

        <!-- Khung soạn thảo bài viết -->
        <div class="row-grid">
            <div class="col-full">
                <label class="form-label">Nội dung giới thiệu dòng họ</label>
                <div class="editor-wrapper">
                    <textarea id="gioithieu" name="gioithieu" rows="4" style="width:100%;">
                      <%
                      function encodeHTML(sHTML)
                        If IsNull(sHTML) Then sHTML = ""
                        sHTML=replace(sHTML,"&","&amp;")
                        sHTML=replace(sHTML,"<","&lt;")
                        sHTML=replace(sHTML,">","&gt;")
                        encodeHTML=sHTML
                      end function

                      Response.Write encodeHTML(rs1("gioithieu"))
                      %>
                    </textarea>

                    <script>
                        var oEdit2 = new InnovaEditor("oEdit2");
                        oEdit2.width="100%";
                        oEdit2.height=450;
                        oEdit2.features=["Save","FullScreen","Preview","Print",
                          "Search","SpellCheck","Superscript","Subscript","LTR","RTL",
                          "Table","Guidelines","Absolute","Flash","Media","InternalLink","CustomObject",
                          "Form","Characters","ClearAll","XHTMLFullSource","XHTMLSource","BRK",
                          "Cut","Copy","Paste","PasteWord","PasteText","Undo","Redo","Hyperlink","Bookmark","Image",
                          "JustifyLeft","JustifyCenter","JustifyRight","JustifyFull",
                          "Numbering","Bullets","Indent","Outdent","Line","RemoveFormat","BRK",
                          "StyleAndFormatting","TextFormatting","ListFormatting","BoxFormatting",
                          "ParagraphFormatting","CssText","Styles","CustomTag","Paragraph",
                          "FontName","FontSize","Bold","Italic","Underline","Strikethrough",
                          "ForeColor","BackColor"];
                        oEdit2.css="style/test.css";
                        oEdit2.cmdAssetManager = "modalDialogShow('/Editor/assetmanager/assetmanager.asp',640,465)"; 
                        oEdit2.cmdInternalLink = "modelessDialogShow('links.htm',365,270)"; 
                        oEdit2.cmdCustomObject = "modelessDialogShow('objects.htm',365,270)"; 
                        oEdit2.mode="XHTMLBody"; 
                        oEdit2.REPLACE("gioithieu");
                    </script>
                </div>
            </div>
        </div>

        <div style="text-align: center; margin-top: 30px; border-top: 1px solid #e2e8f0; padding-top: 20px;">
            <button type="submit" name="submit" class="btn-primary"><i class="fa fa-save"></i> LƯU THAY ĐỔI</button>
        </div>

        </form>
    </div>
</div>

<% 
rs1.Close
Set rs1 = Nothing
destroyconn()
%>