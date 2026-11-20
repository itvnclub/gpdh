    <%
' (Session đã được kiểm tra ở default.asp)
' KHAI BÁO CÁC BIẾN ĐẶC THÙ CỦA RIÊNG FORM NÀY (Không trùng với default.asp)
Dim tentu, namsinh, tinhtrang, nammat, huongtho, noiantang, tieusu, nghenghiep, tenCha, tsData

' ====================================================
' 1. XỬ LÝ LƯU DỮ LIỆU
' ====================================================
If Request.Form("action_edit") = "submit" Then
    id         = Replace(Request.Form("id"), "'", "''")
    idcha      = Replace(Request.Form("idcha"), "'", "''")
    iddoi      = Replace(Request.Form("iddoi"), "'", "''")
    hoten      = Replace(Request.Form("hoten"), "'", "''")
    hinhanh    = Replace(Request.Form("hinhanh"), "'", "''")
    thutu      = Replace(Request.Form("thutu"), "'", "''")
    tentu      = Replace(Request.Form("tentu"), "'", "''")
    gioitinh   = Replace(Request.Form("gioitinh"), "'", "''")
    diachi     = Replace(Request.Form("diachi"), "'", "''")
    namsinh    = Replace(Request.Form("namsinh"), "'", "''")
    tinhtrang  = Replace(Request.Form("tinhtrang"), "'", "''")
    nammat     = Replace(Request.Form("nammat"), "'", "''")
    huongtho   = Replace(Request.Form("huongtho"), "'", "''")
    noiantang  = Replace(Request.Form("noiantang"), "'", "''")
    tieusu     = Replace(Request.Form("tieusu"), "'", "''")
    nghenghiep = Replace(Request.Form("nghenghiep"), "'", "''")
    dienthoai  = Replace(Request.Form("dienthoai"), "'", "''")
    email      = Replace(Request.Form("email"), "'", "''")
    
    openconn
    ' ====================================================
    ' THUẬT TOÁN TỐI ƯU SỐ THỨ TỰ (KÉO LÊN / KÉO XUỐNG)
    ' ====================================================
    Dim old_thutu, new_thutu
    new_thutu = CInt(thutu)

    ' 1. Lấy số thứ tự cũ của nhân vật trước khi sửa
    Dim rsOld
    Set rsOld = conn.Execute("SELECT thutu FROM tblgiapha WHERE idgiapha=" & CInt(id))
    If Not rsOld.EOF Then 
        old_thutu = CInt(rsOld("thutu"))
    Else
        old_thutu = new_thutu ' Fallback an toàn nếu lỗi
    End If
    rsOld.Close
    Set rsOld = Nothing

    ' 2. Xử lý dồn chỗ nếu có sự thay đổi vị trí
    If old_thutu <> new_thutu Then
        If old_thutu < new_thutu Then
            ' Trường hợp KÉO XUỐNG (VD: sửa từ 1 -> 2)
            ' -> Các nhân vật đang ở vị trí 2 sẽ bị đẩy ngược LÊN vị trí 1
            conn.Execute("UPDATE tblgiapha SET thutu = thutu - 1 WHERE idcha=" & CInt(idcha) & " AND thutu > " & old_thutu & " AND thutu <= " & new_thutu & " AND idgiapha <> " & CInt(id))
        Else
            ' Trường hợp KÉO LÊN (VD: sửa từ 2 -> 1)
            ' -> Các nhân vật đang ở vị trí 1 sẽ bị đẩy XUỐNG vị trí 2
            conn.Execute("UPDATE tblgiapha SET thutu = thutu + 1 WHERE idcha=" & CInt(idcha) & " AND thutu >= " & new_thutu & " AND thutu < " & old_thutu & " AND idgiapha <> " & CInt(id))
        End If
    End If
    sql = "UPDATE tblgiapha SET idcha='"&idcha&"', iddoi='"&iddoi&"', hoten=N'"&hoten&"', hinhanh=N'"&hinhanh&"', thutu='"&thutu&"', tentu=N'"&tentu&"', gioitinh='"&gioitinh&"', diachi=N'"&diachi&"', namsinh=N'"&namsinh&"', tinhtrang='"&tinhtrang&"', nammat=N'"&nammat&"', huongtho='"&huongtho&"', noiantang=N'"&noiantang&"', tieusu=N'"&tieusu&"', nghenghiep=N'"&nghenghiep&"', dienthoai=N'"&dienthoai&"', email=N'"&email&"' WHERE idgiapha=" & CInt(id)
    conn.execute(sql)
    destroyconn
%>
<script language="javascript">
    alert("Chúc mừng anh đã SỬA thông tin thành công!");
    window.parent.location.reload();
    window.parent.$.fancybox.close();
</script>
<%
    Response.End
End If
%>

<style>
/* Ẩn Header, Sidebar và padding thừa của Default.asp khi load bên trong Iframe Popup */
.top-header, .topbar, .sidebar { display: none !important; }
.admin-layout, .admin-wrapper { min-height: auto !important; }
.main-content { padding: 5px !important; }

/* Hệ thống Lưới CSS Flexbox Responsive chuẩn */
body { background-color: #f8fafc; margin: 0; font-family: inherit; }
.form-container { background: #fff; padding: 25px; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; }
.form-title { font-size: 16px; font-weight: bold; color: #f59e0b; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 20px; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
.form-title i { color: #f59e0b; font-size: 18px; }

.form-row { display: flex; flex-wrap: wrap; margin-bottom: 15px; gap: 15px; width: 100%; }
.form-col { flex: 1; min-width: calc(50% - 15px); display: flex; flex-direction: column; }
.form-col.full { min-width: 100%; }

.form-label { font-weight: 600; margin-bottom: 6px; font-size: 13px; color: #475569; }
.form-control { width: 100%; box-sizing: border-box; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; color: #334155; transition: 0.2s; font-family: inherit; }
.form-control:focus { border-color: #f59e0b; outline: none; box-shadow: 0 0 0 3px rgba(245,158,11,0.1); }
.readonly-field { background: #f1f5f9; pointer-events: none; color: #64748b; font-weight: 600; border-color: #e2e8f0; }
.required { color: #e11d48; }

/* Nhóm Input + Nút Tải ảnh */
.input-group { display: flex; }
.input-group .form-control { flex: 1; border-top-right-radius: 0; border-bottom-right-radius: 0; border-right: none; }
.btn-upload { background: #f1f5f9; padding: 10px 15px; text-decoration: none; border-radius: 0 4px 4px 0; border: 1px solid #cbd5e1; color: #475569; font-size: 13px; font-weight: 600; white-space: nowrap; transition: 0.2s; display: inline-flex; align-items: center; justify-content: center; margin: 0; box-sizing: border-box; cursor: pointer; }
.btn-upload:hover { background: #e2e8f0; color: #0f172a; }

/* Nút Radio Tình trạng */
.radio-group { display: flex; gap: 20px; align-items: center; padding: 8px 0; }
.radio-group label { display: flex; align-items: center; gap: 6px; cursor: pointer; font-size: 14px; font-weight: 600; color: #334155; }
.radio-group input { width: 16px; height: 16px; cursor: pointer; margin: 0; }

/* Khung Editor */
.editor-wrapper { border: 1px solid #cbd5e1; border-radius: 4px; overflow: hidden; background: #fff; }

/* Nút Submit */
.btn-primary { background: #f59e0b; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; text-transform: uppercase; }
.btn-primary:hover { background: #d97706; }

@media (max-width: 600px) {
    .form-col { min-width: 100% !important; }
}
</style>

<script language="javascript1.2" type="text/javascript">
// Logic Ẩn/Hiện khu vực Đã mất
function toggleTinhTrang() {
    var radios = document.getElementsByName('tinhtrang');
    var val = '1';
    for(var i=0; i<radios.length; i++) {
        if(radios[i].checked) val = radios[i].value;
    }
    
    var colNamMat = document.getElementById('col_nammat');
    var colNamSinh = document.getElementById('col_namsinh');
    var khuMat = document.getElementById('khu_vuc_da_mat');
    
    if (val === '2') { // Đã mất
        colNamMat.style.display = 'flex';
        khuMat.style.display = 'flex';
        colNamSinh.style.minWidth = 'calc(50% - 15px)'; 
    } else { // Còn sống
        colNamMat.style.display = 'none';
        khuMat.style.display = 'none';
        colNamSinh.style.minWidth = '100%'; 
    }
}
window.onload = function() { toggleTinhTrang(); };

// XỬ LÝ UPLOAD ẢNH BẰNG AJAX (Chạy ngầm)
async function uploadCharacterImage(fileInput, targetInputId) {
    if(fileInput.files.length === 0) return;
    var file = fileInput.files[0];
    var targetInput = document.getElementById(targetInputId);
    var originalVal = targetInput.value;

    targetInput.value = "Đang tải ảnh lên...";

    var formData = new FormData();
    formData.append('file', file);

    try {
        let response = await fetch('ajax_upload_ha.asp', {
            method: 'POST',
            body: formData
        });
        let fileName = await response.text();
        fileName = fileName.trim();

        if(fileName.indexOf("Lỗi") !== -1 || fileName === "") {
            alert(fileName === "" ? "Lỗi không xác định khi tải ảnh." : fileName);
            targetInput.value = originalVal; // Trả lại giá trị cũ nếu lỗi
        } else {
            // Tự động gán đường dẫn chuẩn theo yêu cầu
            targetInput.value = "Images/Hinhanh/" + fileName;
        }
    } catch (error) {
        alert('Lỗi hệ thống khi tải ảnh!');
        targetInput.value = originalVal;
    }
    
    // Reset file input
    fileInput.value = "";
}
</script>

<%
    openconn
    edit_id = replace(request.QueryString("id"), "'", "''")
    Set rsEdit = Server.CreateObject("ADODB.Recordset")
    rsEdit.Open "SELECT * FROM tblgiapha WHERE idgiapha=" & CInt(edit_id), conn 
    
    If rsEdit.EOF Then
        Response.Write "<div style='padding:20px; text-align:center; color:#e11d48; font-weight:bold;'>Không tìm thấy thông tin nhân vật!</div>"
        Response.End
    End If
%>

<div class="form-container">
    <div class="form-title"><i class="fa fa-pencil-square-o"></i> SỬA THÔNG TIN NHÂN VẬT</div>
    
    <form name="frmAddNews" method="post" action="">
    <input type="hidden" name="action_edit" value="submit">
    <input type="hidden" name="id" value="<%=edit_id%>">

    <div class="form-row">
        <div class="form-col">
            <label class="form-label">Là con của ông/bà (hoặc Quan hệ)</label>
            <%
            If CInt(rsEdit("idcha")) = 0 Then
                If (rsEdit("loai_quanhe") & "") = "2" Then
                    tenCha = "Vợ/Chồng (Không thuộc nhánh huyết thống)"
                Else
                    tenCha = "Thủy tổ - Đời thứ I"
                End If
            Else
                Set rs2 = conn.Execute("SELECT hoten FROM tblgiapha WHERE idgiapha=" & rsEdit("idcha"))
                If Not rs2.EOF Then tenCha = rs2("hoten") Else tenCha = "Không xác định"
                rs2.Close
                Set rs2 = Nothing
            End If
            %>
            <input type="text" class="form-control readonly-field" value="<%=tenCha%>" readonly>
            <input type="hidden" name="idcha" value="<%=rsEdit("idcha")%>">
        </div>
        <div class="form-col">
            <label class="form-label">Thuộc đời thứ</label>
            <select name="iddoi" class="form-control">
                <%  
                     Set rsd = server.CreateObject("ADODB.Recordset")
                     rsd.Open "SELECT * FROM tbldoi ORDER BY iddoi ASC", conn
                     Do While Not rsd.EOF
                 %> 
                <option value="<%=rsd("iddoi")%>" <%If CInt(rsEdit("iddoi")) = CInt(rsd("iddoi")) Then Response.Write "selected"%>><%=rsd("tieude")%> - (Đời thứ <%=rsd("thutu")%>)</option>
                 <%
                     rsd.MoveNext
                     Loop
                     rsd.Close
                     Set rsd = Nothing
                 %>
            </select>
        </div>
    </div>

    <div class="form-row">
        <div class="form-col">
            <label class="form-label">Họ và tên <span class="required">*</span></label>
            <input name="hoten" type="text" class="form-control" value="<%=rsEdit("hoten")&""%>" required>
        </div>
        <div class="form-col">
            <label class="form-label">Tên tự (Hiệu/Thụy)</label>
            <input name="tentu" type="text" class="form-control" value="<%=rsEdit("tentu")&""%>">
        </div>
    </div>

    <div class="form-row">
        <div class="form-col full">
            <label class="form-label">Hình ảnh đại diện (300 x 400)</label>
            <div class="input-group">
                <input name="hinhanh" id="hinhanh" type="text" class="form-control" value="<%=rsEdit("hinhanh")&""%>">
                <label class="btn-upload">
                    <i class="fa fa-upload" style="margin-right: 5px;"></i> Tải ảnh
                    <input type="file" accept="image/*" style="display:none;" onchange="uploadCharacterImage(this, 'hinhanh')">
                </label>
            </div>
        </div>
    </div>

    <div class="form-row">
        <div class="form-col">
            <label class="form-label">Giới tính</label>
            <select name="gioitinh" class="form-control">
                <option value='1' <%If (rsEdit("gioitinh")&"")="1" Then Response.Write "selected"%>>Nam</option>
                <option value='2' <%If (rsEdit("gioitinh")&"")="2" Then Response.Write "selected"%>>Nữ</option>
            </select>
        </div>
        <div class="form-col">
            <label class="form-label">Là con / người thứ <span class="required">*</span></label>
            <input name="thutu" type="number" class="form-control" value="<%=rsEdit("thutu")&""%>" required>
        </div>
    </div>

    <div class="form-row">
        <div class="form-col full">
            <label class="form-label">Địa chỉ / Thường trú</label>
            <input name="diachi" type="text" class="form-control" value="<%=rsEdit("diachi")&""%>">
        </div>
    </div>

    <div class="form-row">
        <div class="form-col full">
            <label class="form-label">Tình trạng</label>
            <div class="radio-group">
                <label><input type="radio" name="tinhtrang" value="1" <%If (rsEdit("tinhtrang")&"")="1" Then Response.Write "checked"%> onchange="toggleTinhTrang()"> Còn sống</label>
                <label><input type="radio" name="tinhtrang" value="2" <%If (rsEdit("tinhtrang")&"")="2" Then Response.Write "checked"%> onchange="toggleTinhTrang()"> Đã mất</label>
            </div>
        </div>
    </div>

    <div class="form-row">
        <div class="form-col" id="col_namsinh" style="min-width: 100%;">
            <label class="form-label">Năm sinh / Ngày sinh</label>
            <input name="namsinh" type="text" class="form-control" value="<%=rsEdit("namsinh")&""%>">
        </div>
        <div class="form-col" id="col_nammat" style="display: none;">
            <label class="form-label">Năm mất / Ngày mất</label>
            <input name="nammat" type="text" class="form-control" value="<%=rsEdit("nammat")&""%>">
        </div>
    </div>

    <div class="form-row" id="khu_vuc_da_mat" style="display: none; width: 100%;">
        <div class="form-col">
            <label class="form-label">Hưởng thọ / dương (Tuổi)</label>
            <input name="huongtho" type="number" class="form-control" value="<%=rsEdit("huongtho")&""%>">
        </div>
        <div class="form-col">
            <label class="form-label">An táng tại</label>
            <input name="noiantang" type="text" class="form-control" value="<%=rsEdit("noiantang")&""%>">
        </div>
    </div>

    <div class="form-row">
        <div class="form-col full">
            <label class="form-label">Tiểu sử, Sự nghiệp, Công đức, Ghi chú</label>
            <div class="editor-wrapper">
                <textarea id="tieusu" name="tieusu" rows="4" style="width:100%;">
                  <%
                  function encodeHTML(sHTML)
                    sHTML=replace(sHTML,"&","&amp;")
                    sHTML=replace(sHTML,"<","&lt;")
                    sHTML=replace(sHTML,">","&gt;")
                    encodeHTML=sHTML
                  end function
                  
                  If Request("tieusu") <> "" Then
                      tsData = Request("tieusu")
                  Else
                      tsData = rsEdit("tieusu") & ""
                  End If
                  Response.Write encodeHTML(tsData)
                  %>
                </textarea>
                <script>
                    var oEdit2 = new InnovaEditor("oEdit2");
                    oEdit2.width="100%"; 
                    oEdit2.height=300;
                    oEdit2.features=["Save","FullScreen","Preview","Print",
                      "Search","SpellCheck",
                      "Superscript","Subscript","LTR","RTL",
                      "Table","Guidelines","Absolute",
                      "Flash","Media","InternalLink","CustomObject",
                      "Form","Characters","ClearAll","XHTMLFullSource","XHTMLSource","BRK",
                      "Cut","Copy","Paste","PasteWord","PasteText",
                      "Undo","Redo","Hyperlink","Bookmark","Image",
                      "JustifyLeft","JustifyCenter","JustifyRight","JustifyFull",
                      "Numbering","Bullets","Indent","Outdent",
                      "Line","RemoveFormat","BRK",
                      "StyleAndFormatting","TextFormatting","ListFormatting",
                      "BoxFormatting","ParagraphFormatting","CssText","Styles",
                      "CustomTag","Paragraph","FontName","FontSize",
                      "Bold","Italic","Underline","Strikethrough",
                      "ForeColor","BackColor"];
                    oEdit2.css="style/test.css";
                    oEdit2.cmdAssetManager = "modalDialogShow('/Editor/assetmanager/assetmanager.asp',640,465)"; 
                    oEdit2.cmdInternalLink = "modelessDialogShow('links.htm',365,270)"; 
                    oEdit2.cmdCustomObject = "modelessDialogShow('objects.htm',365,270)"; 
                    oEdit2.mode="XHTMLBody"; 
                    oEdit2.REPLACE("tieusu");
                </script>
            </div>
        </div>
    </div>

    <div class="form-row">
        <div class="form-col full">
            <label class="form-label">Nghề nghiệp, Chức vụ</label>
            <input name="nghenghiep" type="text" class="form-control" value="<%=rsEdit("nghenghiep")&""%>">
        </div>
    </div>

    <div class="form-row">
        <div class="form-col">
            <label class="form-label">Điện thoại liên hệ</label>
            <input name="dienthoai" type="text" class="form-control" value="<%=rsEdit("dienthoai")&""%>">
        </div>
        <div class="form-col">
            <label class="form-label">Email</label>
            <input name="email" type="email" class="form-control" value="<%=rsEdit("email")&""%>">
        </div>
    </div>

    <div style="text-align: center; margin-top: 15px; padding-top: 20px; border-top: 1px solid #e2e8f0;">
        <button type="submit" name="submit" class="btn-primary"><i class="fa fa-save"></i> LƯU SỬA ĐỔI</button>
    </div>

    </form>
</div>

<% 
On Error Resume Next
If rsEdit.State = 1 Then rsEdit.Close()
Set rsEdit = Nothing
destroyconn()
On Error GoTo 0
%>