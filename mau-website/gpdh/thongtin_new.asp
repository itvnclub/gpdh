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
  tieude     = replace(request("tieude"),"'","''")
  noidung    = replace(request("noidung"),"'","''")
  openconn
  sql = "INSERT INTO tblthongtin(tieude, noidung, thutu) VALUES(N'"&tieude&"', N'"&noidung&"', 0)"
  conn.execute(sql)
  destroyconn
  Response.Redirect("/gpdh/thong-tin-dong-ho/")
End If
%>

<style>
.admin-card { background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 25px; border: 1px solid #e2e8f0; overflow: hidden; }
.admin-card-header { background: #f8fafc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0; font-weight: bold; color: #0f172a; font-size: 15px; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
.admin-card-header i { color: #0a69db; font-size: 18px; }
.admin-card-body { padding: 20px; }

.row-grid { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 15px; }
.col-full { flex: 1 1 100%; }

.form-label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #475569; }
.form-input { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; color: #334155; transition: 0.2s; box-sizing: border-box; font-family: inherit; }
.form-input:focus { border-color: #0a69db; outline: none; box-shadow: 0 0 0 3px rgba(10,105,219,0.1); }

.btn-primary { background: #0a69db; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; text-transform: uppercase; }
.btn-primary:hover { background: #0056b3; }
.editor-wrapper { border: 1px solid #cbd5e1; border-radius: 4px; overflow: hidden; background: #fff; }
</style>

<script language="javascript1.2" type="text/javascript">
function check_input() {
  var NTitle = document.frmAddNews.tieude.value;
  var NContent = document.frmAddNews.noidung.value;
  if (NTitle == "") { alert("Bạn chưa nhập tiêu đề!"); document.frmAddNews.tieude.focus(); return false; }
  if (NContent == "") { alert("Bạn chưa nhập nội dung!"); document.frmAddNews.noidung.focus(); return false; }
  return true;    
}
</script>

<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-plus-square"></i> THÊM MỚI THÔNG TIN DÒNG HỌ</div>
    <div class="admin-card-body">
        <form name="frmAddNews" method="post" action="" onSubmit="return check_input();">
        <input type="hidden" name="action_new" value="submit">

        <div class="row-grid">
            <div class="col-full">
                <label class="form-label">Tiêu đề <span style="color:red">*</span></label>
                <input name="tieude" type="text" class="form-input" placeholder="Nhập tiêu đề thông tin...">
            </div>
        </div>

        <div class="row-grid">
            <div class="col-full">
                <label class="form-label">Nội dung chi tiết <span style="color:red">*</span></label>
                <div class="editor-wrapper">
                    <textarea id="noidung" name="noidung" rows="4" style="width:100%;"></textarea>
                    <script>
                        var oEdit2 = new InnovaEditor("oEdit2");
                        oEdit2.width = "100%";
                        oEdit2.height = 400;
                        oEdit2.features = ["Save","FullScreen","Preview","Print","Search","SpellCheck","Superscript","Subscript","LTR","RTL","Table","Guidelines","Absolute","Flash","Media","InternalLink","CustomObject","Form","Characters","ClearAll","XHTMLFullSource","XHTMLSource","BRK","Cut","Copy","Paste","PasteWord","PasteText","Undo","Redo","Hyperlink","Bookmark","Image","JustifyLeft","JustifyCenter","JustifyRight","JustifyFull","Numbering","Bullets","Indent","Outdent","Line","RemoveFormat","BRK","StyleAndFormatting","TextFormatting","ListFormatting","BoxFormatting","ParagraphFormatting","CssText","Styles","CustomTag","Paragraph","FontName","FontSize","Bold","Italic","Underline","Strikethrough","ForeColor","BackColor"];
                        oEdit2.css = "/gpdh/css/cms.css";
                        oEdit2.cmdAssetManager = "modalDialogShow('/Editor/assetmanager/assetmanager.asp',640,465)"; 
                        oEdit2.mode = "XHTMLBody"; 
                        oEdit2.REPLACE("noidung");
                    </script>
                </div>
            </div>
        </div>

        <div style="text-align: center; margin-top: 20px;">
            <button type="submit" name="submit" class="btn-primary"><i class="fa fa-save"></i> Thêm mới</button>
        </div>
        </form>
    </div>
</div>