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

If Request.Form("action_edit") = "submit" Then
    id         = replace(request("id"),"'","''")
    tieude     = replace(request("tieude"),"'","''")
    noidung    = replace(request("noidung"),"'","''")
    openconn
    sql = "UPDATE tblthongtin SET tieude=N'"&tieude&"', noidung=N'"&noidung&"' WHERE idthongtin="&CInt(id)
    conn.execute(sql)
    destroyconn
    Response.Redirect("/gpdh/thong-tin-dong-ho/")
End If
%>

<style>
.admin-card { background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 25px; border: 1px solid #e2e8f0; overflow: hidden; }
.admin-card-header { background: #f8fafc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0; font-weight: bold; color: #0f172a; font-size: 15px; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
.admin-card-header i { color: #f59e0b; font-size: 18px; }
.admin-card-body { padding: 20px; }

.row-grid { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 15px; }
.col-full { flex: 1 1 100%; }

.form-label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #475569; }
.form-input { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; color: #334155; transition: 0.2s; box-sizing: border-box; font-family: inherit; }
.form-input:focus { border-color: #f59e0b; outline: none; box-shadow: 0 0 0 3px rgba(245,158,11,0.1); }

.btn-warning { background: #f59e0b; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; text-transform: uppercase; }
.btn-warning:hover { background: #d97706; }
.editor-wrapper { border: 1px solid #cbd5e1; border-radius: 4px; overflow: hidden; background: #fff; }
</style>

<script language="javascript1.2" type="text/javascript">
function check_input() {
  var NTitle = document.frmEditNews.tieude.value;
  var NContent = document.frmEditNews.noidung.value;
  if (NTitle == "") { alert("Bạn chưa nhập tiêu đề!"); document.frmEditNews.tieude.focus(); return false; }
  if (NContent == "") { alert("Bạn chưa nhập nội dung!"); document.frmEditNews.noidung.focus(); return false; }
  return true;    
}
</script>

<%  
    Dim edit_id
    edit_id = Request.QueryString("id")
    If edit_id = "" Or Not IsNumeric(edit_id) Then
        Response.Write "<div class='admin-card'><div class='admin-card-body' style='text-align:center; color:red; font-weight:bold;'><i class='fa fa-exclamation-triangle'></i> Mã thông tin không hợp lệ!</div></div>"
        Response.End
    End If

    openconn  
    Set rsEditNews = Server.CreateObject("ADODB.Recordset")
    rsEditNews.Open "SELECT * FROM tblthongtin WHERE idthongtin = " & CInt(edit_id), conn
    
    If rsEditNews.EOF Then
        Response.Write "<div class='admin-card'><div class='admin-card-body' style='text-align:center; color:red; font-weight:bold;'><i class='fa fa-exclamation-triangle'></i> Không tìm thấy thông tin cần sửa!</div></div>"
        Response.End
    End If
%>

<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-pencil-square-o"></i> SỬA THÔNG TIN DÒNG HỌ</div>
    <div class="admin-card-body">
        <form name="frmEditNews" method="post" action="" onSubmit="return check_input();">
        <input type="hidden" name="action_edit" value="submit">
        <input type="hidden" name="id" value="<%= rsEditNews("idthongtin") %>">

        <div class="row-grid">
            <div class="col-full">
                <label class="form-label">Tiêu đề <span style="color:red">*</span></label>
                <input name="tieude" type="text" class="form-input" value="<%= rsEditNews("tieude") %>">
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
                        oEdit2.css = "/gpdh/css/cms.css";
                        oEdit2.cmdAssetManager = "modalDialogShow('/Editor/assetmanager/assetmanager.asp',640,465)"; 
                        oEdit2.mode = "XHTMLBody"; 
                        oEdit2.REPLACE("noidung");
                    </script>
                </div>
            </div>
        </div>

        <div style="text-align: center; margin-top: 20px;">
            <button type="submit" name="submit" class="btn-warning"><i class="fa fa-save"></i> Cập nhật</button>
        </div>
        </form>
    </div>
</div>

<% 
rsEditNews.Close
Set rsEditNews = Nothing
destroyconn()
%>