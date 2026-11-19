<%session.CodePage=65001%>
<%
If Session("username") = "" Then
%>
<script language="javascript">
    alert("Bạn vui lòng đăng nhập để vào hệ thống quản trị!");
    window.parent.location="../gpdh/";
</script>
<% 
    Response.End
End If
%>
<%
If Not KiemTraHanMucGiaPha(totalNow, maxDinh) Then
%>
    <div style="max-width: 650px; margin: 60px auto; background: #fff; border: 1px solid #e0e0e0; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.08); overflow: hidden; font-family: Arial, sans-serif;">
        <div style="background: #e74c3c; color: #fff; padding: 18px 24px; font-size: 18px; font-weight: bold;">
            ⚠️ THÔNG BÁO HẠN MỨC GIA TỘC
        </div>
        <div style="padding: 25px; color: #333; line-height: 1.6;">
            <p style="font-size: 15px;">Hệ thống ghi nhận dòng họ đã sử dụng hết số lượng nhân khẩu cho phép: 
               <b style="color: #c0392b; font-size: 17px;"><%=totalNow%> / <%=maxDinh%></b> người.</p>
            <p>Để tiếp tục cập nhật thêm danh sách con cháu vào phả hệ, vui lòng liên hệ bộ phận kỹ thuật để kích hoạt mở rộng gói dung lượng lớn hơn.</p>
            <div style="background: #f8f9fa; border-left: 4px solid #046c52; padding: 12px 15px; margin: 20px 0;">
                Hotline hỗ trợ kỹ thuật: <b>0915.555.977</b> (Bùi Chí Nhân)
            </div>
            <div style="text-align: right; margin-top: 20px;">
                <a href="/pha-do" style="display: inline-block; padding: 9px 20px; background: #046c52; color: #fff; text-decoration: none; border-radius: 4px; font-weight: bold;">Quay lại danh sách</a>
            </div>
        </div>
    </div>
<%
    Response.End
End If
%>
<style>
/* Ẩn Header, Sidebar và các khoảng trắng thừa của Default.asp khi mở bên trong Iframe Popup */
.top-header, .topbar, .sidebar { display: none !important; }
.admin-layout, .admin-wrapper { min-height: auto !important; }
.main-content { padding: 5px !important; }

/* Hệ thống Lưới CSS Flexbox Responsive chuẩn */
body { background-color: #f8fafc; margin: 0; font-family: inherit; font-size: inherit; }
.form-container { background: #fff; padding: 25px; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; }
.form-title { font-size: 1.1em; font-weight: bold; color: #e11d48; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 20px; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
.form-title i { color: #e11d48; font-size: 1.2em; }

.form-row { display: flex; flex-wrap: wrap; margin-bottom: 15px; gap: 15px; width: 100%; }
.form-col { flex: 1; min-width: calc(50% - 15px); display: flex; flex-direction: column; }
.form-col.full { min-width: 100%; }

.form-label { font-weight: 600; margin-bottom: 6px; font-size: 0.9em; color: #475569; }
.form-control { width: 100%; box-sizing: border-box; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 1em; color: #334155; transition: 0.2s; font-family: inherit; }
.form-control:focus { border-color: #e11d48; outline: none; box-shadow: 0 0 0 3px rgba(225,29,72,0.1); }
.readonly-field { background: #f1f5f9; pointer-events: none; color: #64748b; font-weight: 600; border-color: #e2e8f0; }
.required { color: #e11d48; }

/* Nhóm Input + Nút Tải ảnh */
.input-group { display: flex; }
.input-group .form-control { flex: 1; border-top-right-radius: 0; border-bottom-right-radius: 0; border-right: none; }
.btn-upload { background: #f1f5f9; padding: 10px 15px; text-decoration: none; border-radius: 0 4px 4px 0; border: 1px solid #cbd5e1; color: #475569; font-size: 0.95em; font-weight: 600; white-space: nowrap; transition: 0.2s; display: inline-flex; align-items: center; justify-content: center; margin: 0; cursor: pointer; box-sizing: border-box; }
.btn-upload:hover { background: #e2e8f0; color: #0f172a; }

/* Nút Radio Tình trạng */
.radio-group { display: flex; gap: 20px; align-items: center; padding: 8px 0; }
.radio-group label { display: flex; align-items: center; gap: 6px; cursor: pointer; font-size: 0.95em; font-weight: 600; color: #334155; }
.radio-group input { width: 16px; height: 16px; cursor: pointer; margin: 0; }

/* Khung Editor */
.editor-wrapper { border: 1px solid #cbd5e1; border-radius: 4px; overflow: hidden; background: #fff; }

/* Nút Submit */
.btn-primary { background: #e11d48; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-size: 1em; font-weight: bold; cursor: pointer; transition: 0.2s; text-transform: uppercase; }
.btn-primary:hover { background: #be123c; }

@media (max-width: 600px) {
    .form-col { min-width: 100% !important; }
}
</style>

<script language="javascript1.2" type="text/javascript">
function toggleTinhTrang() {
    var radios = document.getElementsByName('tinhtrang');
    var val = '1';
    for(var i=0; i<radios.length; i++) {
        if(radios[i].checked) val = radios[i].value;
    }
    
    var colNamMat = document.getElementById('col_nammat');
    var colNamSinh = document.getElementById('col_namsinh');
    var khuMat = document.getElementById('khu_vuc_da_mat');
    
    if (val === '2') { 
        colNamMat.style.display = 'flex';
        khuMat.style.display = 'flex';
        colNamSinh.style.minWidth = 'calc(50% - 15px)'; 
    } else { 
        colNamMat.style.display = 'none';
        khuMat.style.display = 'none';
        colNamSinh.style.minWidth = '100%'; 
    }
}
window.onload = function() { toggleTinhTrang(); };

// XỬ LÝ UPLOAD ẢNH BẰNG AJAX (Chạy ngầm)
async function uploadSpouseImage(fileInput, targetInputId) {
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
' XỬ LÝ LƯU THÊM MỚI VỢ/CHỒNG
If Request.Form("action_add")="submit" Then

    id_vochong = Replace(Request.Form("id_vochong"),"'","''") 
    iddoi      = Replace(Request.Form("iddoi"),"'","''")
    hoten      = Replace(Request.Form("hoten"),"'","''")
    hinhanh    = Replace(Request.Form("hinhanh"),"'","''")
    thutu      = Replace(Request.Form("thutu"),"'","''")
    tentu      = Replace(Request.Form("tentu"),"'","''")
    gioitinh   = Replace(Request.Form("gioitinh"),"'","''")
    diachi     = Replace(Request.Form("diachi"),"'","''")
    namsinh    = Replace(Request.Form("namsinh"),"'","''")
    tinhtrang  = Replace(Request.Form("tinhtrang"),"'","''")
    nammat     = Replace(Request.Form("nammat"),"'","''")
    huongtho   = Replace(Request.Form("huongtho"),"'","''")
    noiantang  = Replace(Request.Form("noiantang"),"'","''")
    tieusu     = Replace(Request.Form("tieusu"),"'","''")
    nghenghiep = Replace(Request.Form("nghenghiep"),"'","''")
    dienthoai  = Replace(Request.Form("dienthoai"),"'","''")
    email      = Replace(Request.Form("email"),"'","''")
    
    openconn
    ' Thực hiện Insert: idcha = 0 (Không cùng huyết thống), id_vochong = ID nhân vật gốc, loai_quanhe = 2 (Định danh vợ chồng)
    sql = "INSERT INTO tblgiapha(idcha, id_vochong, iddoi, hoten, hinhanh, thutu, tentu, gioitinh, diachi, namsinh, tinhtrang, nammat, huongtho, noiantang, tieusu, nghenghiep, dienthoai, email, loai_quanhe) " & _
          "VALUES(0, " & CInt(id_vochong) & ", " & CInt(iddoi) & ", N'"&hoten&"', '"&hinhanh&"', " & CInt(thutu) & ", N'"&tentu&"', " & CInt(gioitinh) & ", N'"&diachi&"', N'"&namsinh&"', " & CInt(tinhtrang) & ", N'"&nammat&"', '"&huongtho&"', N'"&noiantang&"', N'"&tieusu&"', N'"&nghenghiep&"', N'"&dienthoai&"', N'"&email&"', 2)"
    
    conn.execute(sql)
    destroyconn
%>
<script language="javascript">
    alert("Chúc mừng anh đã thêm Vợ/Chồng thành công!");
    window.parent.location.reload();
    window.parent.$.fancybox.close();
</script>
<%
    Response.End
End If

' LẤY THÔNG TIN NHÂN VẬT GỐC (NGƯỜI ĐƯỢC THÊM VỢ/CHỒNG)
openconn
sessionpage = replace(request.QueryString("sessionpage"),"'","''")
set rsMain = server.CreateObject("adodb.recordset")
rsMain.open "select * from tblgiapha where idgiapha=" & CInt(sessionpage), conn 

If Not rsMain.EOF Then
    mainName = rsMain("hoten")
    mainGender = CInt(rsMain("gioitinh"))
    mainDoi = CInt(rsMain("iddoi"))

    If mainGender = 1 Then
        labelQuanHe = "VỢ"
        labelNguoiDoi = "ông"
        spouseGender = 2 ' Nếu người gốc là Nam -> Thêm vợ (Nữ)
    Else
        labelQuanHe = "CHỒNG"
        labelNguoiDoi = "bà"
        spouseGender = 1 ' Nếu người gốc là Nữ -> Thêm chồng (Nam)
    End If
End If
%>

<div class="form-container">
    <div class="form-title"><i class="fa fa-heart"></i> THÊM MỚI <%=labelQuanHe%></div>
    
    <form name="frmAddNews" method="post" action="">
    <input type="hidden" name="action_add" value="submit">
    <input type="hidden" name="id_vochong" value="<%=sessionpage%>"> 
    <input type="hidden" name="iddoi" value="<%=mainDoi%>"> 
    <input type="hidden" name="gioitinh" value="<%=spouseGender%>">

    <div class="form-row">
        <div class="form-col">
            <label class="form-label">Là <%=LCase(labelQuanHe)%> của <%=labelNguoiDoi%></label>
            <input type="text" class="form-control readonly-field" value="<%=mainName%>" readonly>
        </div>
        <div class="form-col">
            <label class="form-label">Thuộc đời thứ</label>
            <select class="form-control readonly-field" disabled>
                <%  
                     Dim rs3
                     set rs3=server.CreateObject("adodb.recordset")
                     rs3.open "Select * from tbldoi where iddoi=" & mainDoi, conn
                     if not rs3.eof then
                 %> 
                <option value='<%=rs3("iddoi")%>'><%=rs3("tieude")%> - (Đời thứ <%=rs3("thutu")%>)</option>
                 <%
                     end if
                     rs3.close
                     set rs3 = Nothing
                 %>
            </select>
        </div>
    </div>

    <div class="form-row">
        <div class="form-col">
            <label class="form-label">Họ và tên <span class="required">*</span></label>
            <input name="hoten" type="text" class="form-control" required placeholder="Nhập họ và tên đầy đủ...">
        </div>
        <div class="form-col">
            <label class="form-label">Tên tự (Hiệu/Thụy)</label>
            <input name="tentu" type="text" class="form-control" placeholder="Tên gọi khác nếu có...">
        </div>
    </div>

    <!-- HÌNH ẢNH DÙNG AJAX UPLOAD NGẦM -->
    <div class="form-row">
        <div class="form-col full">
            <label class="form-label">Hình ảnh đại diện (300 x 400)</label>
            <div class="input-group">
                <input name="hinhanh" id="hinhanh" type="text" class="form-control" placeholder="Tải ảnh lên hoặc dán đường dẫn ảnh vào đây...">
                <label class="btn-upload">
                    <i class="fa fa-upload" style="margin-right: 5px;"></i> Tải ảnh
                    <input type="file" accept="image/*" style="display:none;" onchange="uploadSpouseImage(this, 'hinhanh')">
                </label>
            </div>
        </div>
    </div>

    <div class="form-row">
        <div class="form-col">
            <label class="form-label">Giới tính</label>
            <select class="form-control readonly-field" disabled>
                <option value='1' <%If spouseGender=1 Then Response.Write "selected"%>>Nam</option>
                <option value='2' <%If spouseGender=2 Then Response.Write "selected"%>>Nữ</option>
            </select>
        </div>
        <div class="form-col">
            <label class="form-label">Là <%=LCase(labelQuanHe)%> thứ <span class="required">*</span></label>
            <input name="thutu" type="number" class="form-control" required placeholder="VD: 1, 2, 3...">
        </div>
    </div>

    <div class="form-row">
        <div class="form-col full">
            <label class="form-label">Quê quán / Địa chỉ</label>
            <input name="diachi" type="text" class="form-control" placeholder="Nhập địa chỉ hiện tại hoặc quê quán...">
        </div>
    </div>

    <div class="form-row">
        <div class="form-col full">
            <label class="form-label">Tình trạng</label>
            <div class="radio-group">
                <label><input type="radio" name="tinhtrang" value="1" checked onchange="toggleTinhTrang()"> Còn sống</label>
                <label><input type="radio" name="tinhtrang" value="2" onchange="toggleTinhTrang()"> Đã mất</label>
            </div>
        </div>
    </div>

    <div class="form-row">
        <div class="form-col" id="col_namsinh" style="min-width: 100%;">
            <label class="form-label">Năm sinh / Ngày sinh</label>
            <input name="namsinh" type="text" class="form-control" placeholder="VD: 1990 hoặc 12/05/1990">
        </div>
        <div class="form-col" id="col_nammat" style="display: none;">
            <label class="form-label">Năm mất / Ngày mất</label>
            <input name="nammat" type="text" class="form-control" placeholder="VD: 2020 hoặc 15/08/2020">
        </div>
    </div>

    <div class="form-row" id="khu_vuc_da_mat" style="display: none; width: 100%;">
        <div class="form-col">
            <label class="form-label">Hưởng thọ / dương (Tuổi)</label>
            <input name="huongtho" type="number" class="form-control" placeholder="Nhập số tuổi...">
        </div>
        <div class="form-col">
            <label class="form-label">An táng tại</label>
            <input name="noiantang" type="text" class="form-control" placeholder="Nơi an nghỉ...">
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
                  Response.Write encodeHTML(Request("tieusu"))
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
            <input name="nghenghiep" type="text" class="form-control" placeholder="Công việc hiện tại hoặc chức vụ...">
        </div>
    </div>

    <div class="form-row">
        <div class="form-col">
            <label class="form-label">Điện thoại liên hệ</label>
            <input name="dienthoai" type="text" class="form-control" placeholder="Nhập số điện thoại...">
        </div>
        <div class="form-col">
            <label class="form-label">Email</label>
            <input name="email" type="email" class="form-control" placeholder="Nhập địa chỉ email...">
        </div>
    </div>

    <div style="text-align: center; margin-top: 15px; padding-top: 20px; border-top: 1px solid #e2e8f0;">
        <button type="submit" name="submit" class="btn-primary"><i class="fa fa-save"></i> LƯU DỮ LIỆU</button>
    </div>

    </form>
</div>

<% 
rsMain.close() 
Set rsMain = Nothing
destroyconn()
%>