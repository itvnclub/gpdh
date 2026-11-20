<%
' 1. KIỂM TRA SESSION
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
' 2. KHAI BÁO BIẾN CÁCH LY
' ====================================================
Dim cfg_action, cfg_icon, cfg_logo, cfg_logof, cfg_dongho, cfg_diachi, cfg_dienthoai
Dim cfg_email, cfg_website, cfg_tukhoa, cfg_mota, cfg_bando, cfg_font, cfg_fontsize, cfg_mausac, cfg_sql
Dim cfg_bgchinh, cfg_bgtren, cfg_anhdaidien
Dim rsCfg, currentFont, currentFontSize, currentColor

cfg_action = Request.Form("action_config")

' ====================================================
' 3. XỬ LÝ LƯU DỮ LIỆU
' ====================================================
If cfg_action = "submit" Then
    cfg_icon       = Replace(Request.Form("icon"), "'", "''")
    cfg_logo       = Replace(Request.Form("logo"), "'", "''")
    cfg_logof      = Replace(Request.Form("logof"), "'", "''")
    cfg_dongho     = Replace(Request.Form("dongho"), "'", "''")
    cfg_diachi     = Replace(Request.Form("diachi"), "'", "''")
    cfg_dienthoai  = Replace(Request.Form("dienthoai"), "'", "''")
    cfg_toctruong      = Replace(Request.Form("toctruong"), "'", "''")
    cfg_website    = Replace(Request.Form("website"), "'", "''")
    cfg_tukhoa     = Replace(Request.Form("tukhoa"), "'", "''")
    cfg_mota       = Replace(Request.Form("mota"), "'", "''")
    cfg_bando      = Replace(Request.Form("bando"), "'", "''")
    cfg_font       = Replace(Request.Form("font_family"), "'", "''") 
    cfg_fontsize   = Replace(Request.Form("font_size"), "'", "''") 
    cfg_mausac     = Replace(Request.Form("mausac"), "'", "''") 
    cfg_bgchinh    = Replace(Request.Form("bgchinh"), "'", "''") 
    cfg_bgtren     = Replace(Request.Form("bgtren"), "'", "''")  
    cfg_anhdaidien = Replace(Request.Form("anhdaidien"), "'", "''")  

    openconn
    cfg_sql = "UPDATE tblconfig SET icon=N'"&cfg_icon&"', logo=N'"&cfg_logo&"', logof=N'"&cfg_logof&"', dongho=N'"&cfg_dongho&"', diachi=N'"&cfg_diachi&"', dienthoai=N'"&cfg_dienthoai&"', toctruong=N'"&cfg_toctruong&"', website=N'"&cfg_website&"', tukhoa=N'"&cfg_tukhoa&"', mota=N'"&cfg_mota&"', bando=N'"&cfg_bando&"', font_family=N'"&cfg_font&"', font_size=N'"&cfg_fontsize&"', mausac=N'"&cfg_mausac&"', bgchinh=N'"&cfg_bgchinh&"', bgtren=N'"&cfg_bgtren&"', anhdaidien=N'"&cfg_anhdaidien&"'"
    conn.execute(cfg_sql)
    destroyconn
%>
    <script language="javascript">
        alert("Cập nhật cấu hình website thành công!");
        window.location="cau-hinh";
    </script>
<%
    Response.End
End If

' ====================================================
' 4. LẤY DỮ LIỆU HIỂN THỊ
' ====================================================
openconn    
Set rsCfg = Server.CreateObject("ADODB.Recordset")
rsCfg.Open "SELECT TOP 1 * FROM tblconfig", conn

If rsCfg.EOF Then
    conn.execute("INSERT INTO tblconfig (dongho, font_family, font_size, mausac) VALUES (N'Gia phả Dòng họ', 'Arial, sans-serif', '14px', '#2B3A22')")
    rsCfg.Close
    rsCfg.Open "SELECT TOP 1 * FROM tblconfig", conn
End If

currentFont = rsCfg("font_family") & ""
If currentFont = "" Then currentFont = "Arial, sans-serif"

currentFontSize = rsCfg("font_size") & ""
If currentFontSize = "" Then currentFontSize = "14px"

currentColor = rsCfg("mausac") & ""
If currentColor = "" Then currentColor = "#2B3A22" 'Màu mặc định nếu rỗng
%>

<!-- ==================================================== -->
<!-- 5. GOOGLE FONTS & CSS GIAO DIỆN                      -->
<!-- ==================================================== -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Philosopher:ital,wght@0,400;0,700;1,400;1,700&family=Roboto:wght@400;700&family=Open+Sans:wght@400;700&family=Montserrat:wght@400;700&family=Lora:wght@400;700&family=Nunito:wght@400;700&family=Playfair+Display:wght@400;700&family=Merriweather:wght@400;700&family=Pattaya&family=Dancing+Script:wght@400;700&family=Quicksand:wght@400;700&family=Inter:wght@400;700&family=Mulish:wght@400;700&family=Oswald:wght@400;700&family=Poppins:wght@400;700&family=Raleway:wght@400;700&family=Ubuntu:wght@400;700&family=Cinzel:wght@400;700&family=EB+Garamond:wght@400;700&family=PT+Serif:wght@400;700&family=Be+Vietnam+Pro:wght@400;700&display=swap" rel="stylesheet">

<style>
.admin-card { background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 25px; border: 1px solid #e2e8f0; font-family: <%=currentFont%>; font-size: <%=currentFontSize%>; overflow: hidden; }
.admin-card-header { background: #f8fafc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0; font-weight: bold; color: #0f172a; font-size: 15px; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
.admin-card-header i { color: #0a69db; font-size: 18px; }
.admin-card-body { padding: 20px; }

.row-grid { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 15px; }
.col-flex { flex: 1; min-width: 250px; }
.col-full { flex: 1 1 100%; }

.form-label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #475569; }
.form-input, .form-select, .form-textarea { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; color: #334155; transition: 0.2s; font-family: inherit; box-sizing: border-box; }
.form-input:focus, .form-select:focus, .form-textarea:focus { border-color: #0a69db; outline: none; box-shadow: 0 0 0 3px rgba(10,105,219,0.1); }
.form-textarea { resize: vertical; min-height: 80px; }

.upload-group { display: flex; }
.upload-group .form-input { border-top-right-radius: 0; border-bottom-right-radius: 0; border-right: none; }
.btn-upload { background: #f1f5f9; color: #475569; padding: 10px 15px; border: 1px solid #cbd5e1; border-radius: 0 4px 4px 0; font-size: 13px; font-weight: 600; cursor: pointer; text-decoration: none; white-space: nowrap; transition: 0.2s; display: inline-block; margin: 0; }
.btn-upload:hover { background: #e2e8f0; color: #0f172a; }

.btn-primary { background: #0a69db; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; }
.btn-primary:hover { background: #0056b3; }

.font-preview-box { margin-top: 10px; padding: 15px; background: #f0fdf4; border: 1px dashed #22c55e; border-radius: 4px; color: #166534; text-align: center; }
input[type="color"].form-input { padding: 2px 5px; height: 40px; cursor: pointer; }
</style>

<script>
function check_config() {
    var nDongHo = document.frmConfig.dongho.value;
    if (nDongHo == "") {
        alert("Tên dòng họ không được để trống!"); 
        document.frmConfig.dongho.focus(); 
        return false;
    }
    return true;        
}

function updateFontPreview() {
    var selectedFont = document.getElementById("font_family").value;
    var selectedSize = document.getElementById("font_size").value;
    var selectedColor = document.getElementById("mausac").value;
    var previewBox = document.getElementById("font-preview-text");
    
    previewBox.style.fontFamily = selectedFont;
    previewBox.style.fontSize = selectedSize;
    previewBox.style.color = selectedColor;
}

// XỬ LÝ UPLOAD ẢNH BẰNG AJAX CÓ PREVIEW
async function uploadConfigImage(fileInput, targetInputId, previewImgId) {
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

        if(fileName.indexOf("Lỗi") !== -1) {
            alert(fileName);
            targetInput.value = originalVal;
        } else {
            targetInput.value = "Images/Hinhanh/" + fileName;
            if(previewImgId) {
                // Thêm ../ vào trước đường dẫn để hiển thị đúng trong thư mục /gpdh/
                document.getElementById(previewImgId).src = "../" + targetInput.value; 
            }
        }
    } catch (error) {
        alert('Lỗi hệ thống khi tải ảnh!');
        targetInput.value = originalVal;
    }
    
    fileInput.value = "";
}
</script>

<form name="frmConfig" method="post" onSubmit="return check_config();" id="config-container">
    <input type="hidden" name="action_config" value="submit">

    <!-- KHỐI 1: THÔNG TIN CHUNG -->
    <div class="admin-card">
        <div class="admin-card-header"><i class="fa fa-info-circle"></i> THÔNG TIN DÒNG HỌ</div>
        <div class="admin-card-body">
            <div class="row-grid">
                <div class="col-full">
                    <label class="form-label">Tên dòng họ / Website <span style="color:red">*</span></label>
                    <input name="dongho" type="text" value="<%=rsCfg("dongho")%>" class="form-input" placeholder="Ví dụ: Gia phả họ Bùi Xuân Bảng">
                </div>
            </div>
            <div class="row-grid">
                <div class="col-flex">
                    <label class="form-label">Đường dẫn Website</label>
                    <input name="website" type="text" value="<%=rsCfg("website")%>" class="form-input" placeholder="https://...">
                </div>
                <div class="col-flex">
                    <label class="form-label">Trưởng tộc</label>
                    <input name="toctruong" type="text" value="<%=rsCfg("toctruong")%>" class="form-input" placeholder="Họ tên trưởng tộc">
                </div>
                <div class="col-flex">
                    <label class="form-label">Điện thoại</label>
                    <input name="dienthoai" type="text" value="<%=rsCfg("dienthoai")%>" class="form-input" placeholder="09xx...">
                </div>
            </div>
            <div class="row-grid">
                <div class="col-full">
                    <label class="form-label">Địa chỉ Nhà thờ</label>
                    <input name="diachi" type="text" value="<%=rsCfg("diachi")%>" class="form-input">
                </div>
            </div>
        </div>
    </div>

    <!-- KHỐI 2: TÙY CHỈNH KIỂU CHỮ, KÍCH THƯỚC & MÀU SẮC -->
    <div class="admin-card">
        <div class="admin-card-header"><i class="fa fa-font"></i> ĐỊNH DẠNG GIAO DIỆN (CHỮ & MÀU SẮC)</div>
        <div class="admin-card-body">
            <div class="row-grid">
                <div class="col-flex">
                    <label class="form-label">Chọn Font chữ hệ thống</label>
                    <select name="font_family" id="font_family" class="form-select" onchange="updateFontPreview()">
                        <option value="'Philosopher', sans-serif" <%If InStr(currentFont, "Philosopher")>0 Then Response.Write "selected"%>>Philosopher (Cổ điển, Gia phả)</option>
                        <option value="Arial, sans-serif" <%If currentFont = "Arial, sans-serif" Then Response.Write "selected"%>>Arial (Cơ bản, Mặc định)</option>
                        <option value="'Be Vietnam Pro', sans-serif" <%If InStr(currentFont, "Be Vietnam Pro")>0 Then Response.Write "selected"%>>Be Vietnam Pro (Tiếng Việt chuẩn)</option>
                        <option value="'Roboto', sans-serif" <%If InStr(currentFont, "Roboto")>0 Then Response.Write "selected"%>>Roboto (Hiện đại, Chuẩn Google)</option>
                        <option value="'Open Sans', sans-serif" <%If InStr(currentFont, "Open Sans")>0 Then Response.Write "selected"%>>Open Sans (Chuẩn mực, Rõ nét)</option>
                        <option value="'Inter', sans-serif" <%If InStr(currentFont, "Inter")>0 Then Response.Write "selected"%>>Inter (Sạch sẽ, Giao diện phẳng)</option>
                        <option value="'Mulish', sans-serif" <%If InStr(currentFont, "Mulish")>0 Then Response.Write "selected"%>>Mulish (Thanh lịch, Mượt mà)</option>
                        <option value="'Poppins', sans-serif" <%If InStr(currentFont, "Poppins")>0 Then Response.Write "selected"%>>Poppins (Trẻ trung, Hình học)</option>
                        <option value="'Nunito', sans-serif" <%If InStr(currentFont, "Nunito")>0 Then Response.Write "selected"%>>Nunito (Tròn trịa, Thân thiện)</option>
                        <option value="'Montserrat', sans-serif" <%If InStr(currentFont, "Montserrat")>0 Then Response.Write "selected"%>>Montserrat (Sang trọng, Cứng cáp)</option>
                        <option value="'Raleway', sans-serif" <%If InStr(currentFont, "Raleway")>0 Then Response.Write "selected"%>>Raleway (Mỏng nhẹ, Tinh tế)</option>
                        <option value="'Ubuntu', sans-serif" <%If InStr(currentFont, "Ubuntu")>0 Then Response.Write "selected"%>>Ubuntu (Độc đáo, Rõ ràng)</option>
                        <option value="'Oswald', sans-serif" <%If InStr(currentFont, "Oswald")>0 Then Response.Write "selected"%>>Oswald (Tiêu đề mạnh mẽ, Gọn gàng)</option>
                        <option value="'Lora', serif" <%If InStr(currentFont, "Lora")>0 Then Response.Write "selected"%>>Lora (Có chân, Cổ điển, Hợp phả ký)</option>
                        <option value="'Merriweather', serif" <%If InStr(currentFont, "Merriweather")>0 Then Response.Write "selected"%>>Merriweather (Có chân, Hợp đọc sách)</option>
                        <option value="'PT Serif', serif" <%If InStr(currentFont, "PT Serif")>0 Then Response.Write "selected"%>>PT Serif (Truyền thống, Trang trọng)</option>
                        <option value="'EB Garamond', serif" <%If InStr(currentFont, "EB Garamond")>0 Then Response.Write "selected"%>>EB Garamond (Văn bản cổ, Sắc nét)</option>
                        <option value="'Playfair Display', serif" <%If InStr(currentFont, "Playfair")>0 Then Response.Write "selected"%>>Playfair Display (Nghệ thuật, Cổ kính)</option>
                        <option value="'Cinzel', serif" <%If InStr(currentFont, "Cinzel")>0 Then Response.Write "selected"%>>Cinzel (Phong cách sử thi, Dòng họ lớn)</option>
                        <option value="'Dancing Script', cursive" <%If InStr(currentFont, "Dancing Script")>0 Then Response.Write "selected"%>>Dancing Script (Chữ ký, Mềm mại)</option>
                        <option value="'Pattaya', sans-serif" <%If InStr(currentFont, "Pattaya")>0 Then Response.Write "selected"%>>Pattaya (Thư pháp Việt Nam)</option>
                    </select>
                </div>
                
                <div class="col-flex">
                    <label class="form-label">Kích thước chữ</label>
                    <select name="font_size" id="font_size" class="form-select" onchange="updateFontPreview()">
                        <option value="15px" <%If currentFontSize = "15px" Then Response.Write "selected"%>>15px (Nhỏ gọn)</option>
                        <option value="16px" <%If currentFontSize = "16px" Then Response.Write "selected"%>>16px (Tiêu chuẩn gốc - Khuyên dùng)</option>
                        <option value="17px" <%If currentFontSize = "17px" Then Response.Write "selected"%>>17px (Vừa phải)</option>
                        <option value="18px" <%If currentFontSize = "18px" Then Response.Write "selected"%>>18px (Lớn vừa)</option>
                        <option value="19px" <%If currentFontSize = "19px" Then Response.Write "selected"%>>19px (Lớn)</option>
                        <option value="20px" <%If currentFontSize = "20px" Then Response.Write "selected"%>>20px (Rất lớn, Dễ nhìn)</option>
                        <option value="21px" <%If currentFontSize = "21px" Then Response.Write "selected"%>>21px (Phù hợp người cao tuổi)</option>
                        <option value="22px" <%If currentFontSize = "22px" Then Response.Write "selected"%>>22px (To rõ ràng)</option>
                        <option value="23px" <%If currentFontSize = "23px" Then Response.Write "selected"%>>23px (Rất to)</option>
                        <option value="24px" <%If currentFontSize = "24px" Then Response.Write "selected"%>>24px (Cực lớn)</option>
                        <option value="25px" <%If currentFontSize = "25px" Then Response.Write "selected"%>>25px (Kích thước tối đa)</option>
                    </select>
                </div>

                <div class="col-flex">
                    <label class="form-label">Màu sắc chủ đạo (Header, Nút bấm)</label>
                    <input type="color" name="mausac" id="mausac" value="<%=currentColor%>" class="form-input" onchange="updateFontPreview()">
                </div>
            </div>
            
            <div class="row-grid">
                <div class="col-full">
                    <div class="font-preview-box" id="font-preview-text" style="font-family: <%=currentFont%>; font-size: <%=currentFontSize%>; color: <%=currentColor%>;">
                        <b>Mộc bản lưu truyền:</b> Cây có gốc mới nở ngành xanh ngọn, nước có nguồn mới bể rộng sông sâu.
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- KHỐI 3: HÌNH ẢNH HIỂN THỊ -->
    <div class="admin-card">
        <div class="admin-card-header"><i class="fa fa-picture-o"></i> HÌNH ẢNH LOGO, ICON & BACKGROUND</div>
        <div class="admin-card-body">
            
            <!-- DÒNG 1: LOGO VÀ ICON (3 Cột) -->
            <div class="row-grid">
                <div class="col-flex">
                    <label class="form-label">Logo website (Header)</label>
                    <div class="upload-group">
                        <input name="logo" id="inp_logo" type="text" class="form-input" value="<%=rsCfg("logo")%>" placeholder="File ảnh logo...">
                        <label class="btn-upload">
                            <i class="fa fa-upload"></i>
                            <input type="file" accept="image/*" style="display:none;" onchange="uploadConfigImage(this, 'inp_logo', 'preview_logo')">
                        </label>
                    </div>
                    <div style="margin-top: 10px; border: 1px dashed #cbd5e1; padding: 10px; border-radius: 4px; text-align: center; background: #f8fafc;">
                        <img id="preview_logo" src="../<%=rsCfg("logo")%>" onerror="this.onerror=null; this.src='../Images/noimages.jpg'" style="height: 60px; max-width: 100%; object-fit: contain;">
                    </div>
                </div>
                
                <div class="col-flex">
                    <label class="form-label">Logo chân trang (Footer)</label>
                    <div class="upload-group">
                        <input name="logof" id="inp_logof" type="text" class="form-input" value="<%=rsCfg("logof")%>" placeholder="File ảnh footer...">
                        <label class="btn-upload">
                            <i class="fa fa-upload"></i>
                            <input type="file" accept="image/*" style="display:none;" onchange="uploadConfigImage(this, 'inp_logof', 'preview_logof')">
                        </label>
                    </div>
                    <div style="margin-top: 10px; border: 1px dashed #cbd5e1; padding: 10px; border-radius: 4px; text-align: center; background: #f8fafc;">
                        <img id="preview_logof" src="../<%=rsCfg("logof")%>" onerror="this.onerror=null; this.src='../Images/noimages.jpg'" style="height: 60px; max-width: 100%; object-fit: contain;">
                    </div>
                </div>

                <div class="col-flex">
                    <label class="form-label">Favicon (Icon tab)</label>
                    <div class="upload-group">
                        <input name="icon" id="inp_icon" type="text" class="form-input" value="<%=rsCfg("icon")%>">
                        <label class="btn-upload">
                            <i class="fa fa-upload"></i>
                            <input type="file" accept="image/*" style="display:none;" onchange="uploadConfigImage(this, 'inp_icon', 'preview_icon')">
                        </label>
                    </div>
                    <div style="margin-top: 10px; border: 1px dashed #cbd5e1; padding: 10px; border-radius: 4px; text-align: center; background: #f8fafc;">
                        <img id="preview_icon" src="../<%=rsCfg("icon")%>" onerror="this.onerror=null; this.src='../Images/noimages.jpg'" style="width: 60px; height: 60px; object-fit: contain;">
                    </div>
                </div>
            </div>

            <!-- DÒNG 2: BACKGROUND CHÍNH, TRÊN & ẢNH ĐẠI DIỆN CHIA SẺ (3 Cột) -->
            <div class="row-grid">
                <div class="col-flex">
                    <label class="form-label">Background chính (Nền toàn trang)</label>
                    <div class="upload-group">
                        <input name="bgchinh" id="inp_bgchinh" type="text" class="form-input" value="<%=rsCfg("bgchinh")%>" placeholder="Đường dẫn ảnh nền chính...">
                        <label class="btn-upload">
                            <i class="fa fa-upload"></i>
                            <input type="file" accept="image/*" style="display:none;" onchange="uploadConfigImage(this, 'inp_bgchinh', 'preview_bgchinh')">
                        </label>
                    </div>
                    <div style="margin-top: 10px; border: 1px dashed #cbd5e1; padding: 10px; border-radius: 4px; text-align: center; background: #f8fafc;">
                        <span style="display: block; font-size: 11px; color: #64748b; margin-bottom: 5px; text-transform: uppercase;">Minh họa nền trang</span>
                        <img id="preview_bgchinh" src="../<%=rsCfg("bgchinh")%>" onerror="this.onerror=null; this.src='../Images/noimages.jpg'" style="width: 100%; height: 120px; object-fit: cover; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
                    </div>
                </div>

                <div class="col-flex">
                    <label class="form-label">Background trên (Nền khu vực Header)</label>
                    <div class="upload-group">
                        <input name="bgtren" id="inp_bgtren" type="text" class="form-input" value="<%=rsCfg("bgtren")%>" placeholder="Đường dẫn ảnh nền header...">
                        <label class="btn-upload">
                            <i class="fa fa-upload"></i>
                            <input type="file" accept="image/*" style="display:none;" onchange="uploadConfigImage(this, 'inp_bgtren', 'preview_bgtren')">
                        </label>
                    </div>
                    <div style="margin-top: 10px; border: 1px dashed #cbd5e1; padding: 10px; border-radius: 4px; text-align: center; background: #f8fafc;">
                        <span style="display: block; font-size: 11px; color: #64748b; margin-bottom: 5px; text-transform: uppercase;">Minh họa phần Header</span>
                        <img id="preview_bgtren" src="../<%=rsCfg("bgtren")%>" onerror="this.onerror=null; this.src='../Images/noimages.jpg'" style="width: 100%; height: 120px; object-fit: cover; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
                    </div>
                </div>
                
                <!-- BỔ SUNG TRƯỜNG ẢNH ĐẠI DIỆN CHIA SẺ -->
                <div class="col-flex">
                    <label class="form-label">Ảnh đại diện chia sẻ (Khi gửi link Zalo, FB)</label>
                    <div class="upload-group">
                        <input name="anhdaidien" id="inp_anhdaidien" type="text" class="form-input" value="<%=rsCfg("anhdaidien")%>" placeholder="Đường dẫn ảnh đại diện...">
                        <label class="btn-upload">
                            <i class="fa fa-upload"></i>
                            <input type="file" accept="image/*" style="display:none;" onchange="uploadConfigImage(this, 'inp_anhdaidien', 'preview_anhdaidien')">
                        </label>
                    </div>
                    <div style="margin-top: 10px; border: 1px dashed #cbd5e1; padding: 10px; border-radius: 4px; text-align: center; background: #f8fafc;">
                        <span style="display: block; font-size: 11px; color: #64748b; margin-bottom: 5px; text-transform: uppercase;">Minh họa khi chia sẻ liên kết</span>
                        <img id="preview_anhdaidien" src="../<%=rsCfg("anhdaidien")%>" onerror="this.onerror=null; this.src='../Images/noimages.jpg'" style="width: 100%; height: 120px; object-fit: cover; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- KHỐI 4: CẤU HÌNH KỸ THUẬT (SEO & MAPS) -->
    <div class="admin-card">
        <div class="admin-card-header"><i class="fa fa-cogs"></i> SEO & BẢN ĐỒ</div>
        <div class="admin-card-body">
            <div class="row-grid">
                <div class="col-full">
                    <label class="form-label">Từ khóa tìm kiếm (Meta Keywords - Phân cách bằng dấu phẩy)</label>
                    <textarea name="tukhoa" class="form-textarea"><%=rsCfg("tukhoa")%></textarea>
                </div>
            </div>
            <div class="row-grid">
                <div class="col-full">
                    <label class="form-label">Mô tả website (Meta Description - Hiển thị trên Google/Facebook)</label>
                    <textarea name="mota" class="form-textarea"><%=rsCfg("mota")%></textarea>
                </div>
            </div>
            <div class="row-grid">
                <div class="col-full">
                    <label class="form-label">Mã nhúng Bản đồ Google Maps (Thẻ iframe)</label>
                    <textarea name="bando" class="form-textarea" placeholder="<iframe src='...'></iframe>"><%=rsCfg("bando")%></textarea>
                </div>
            </div>
        </div>
    </div>

    <!-- NÚT LƯU THAY ĐỔI -->
    <div style="text-align: center; margin-bottom: 40px;">
        <button type="submit" class="btn-primary"><i class="fa fa-save"></i> CẬP NHẬT CẤU HÌNH</button>
    </div>
</form>

<% 
rsCfg.Close
Set rsCfg = Nothing
destroyconn()
%>