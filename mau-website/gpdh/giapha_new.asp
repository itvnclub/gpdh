<%
' (Session đã được kiểm tra ở default.asp nên không cần kiểm tra lại ở đây)
' Hàm tự động chuyển đổi số sang định dạng La Mã (Hàm này có tính chất nội bộ - Local Scope)
Function ToRoman(ByVal num)
    Dim vals, roms, res, i ' Biến i ở đây là nội bộ của Function, không xung đột với biến i toàn cục
    vals = Array(1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1)
    roms = Array("M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I")
    res = ""
    For i = 0 To UBound(vals)
        Do While num >= vals(i)
            res = res & roms(i)
            num = num - vals(i)
        Loop
    Next
    ToRoman = res
End Function
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
/* Ẩn Header, Sidebar và padding thừa của Default.asp khi load bên trong Iframe Popup */
.top-header, .topbar, .sidebar { display: none !important; }
.admin-layout, .admin-wrapper { min-height: auto !important; }
.main-content { padding: 5px !important; }

/* Hệ thống Lưới CSS Flexbox Responsive chuẩn */
body { background-color: #f8fafc; margin: 0; font-family: inherit; }
.form-container { background: #fff; padding: 25px; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; }
.form-title { font-size: 16px; font-weight: bold; color: #0f172a; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px; margin-bottom: 20px; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
.form-title i { color: #0a69db; font-size: 18px; }

.form-row { display: flex; flex-wrap: wrap; margin-bottom: 15px; gap: 15px; width: 100%; }
.form-col { flex: 1; min-width: calc(50% - 15px); display: flex; flex-direction: column; }
.form-col.full { min-width: 100%; }

.form-label { font-weight: 600; margin-bottom: 6px; font-size: 13px; color: #475569; }
.form-control { width: 100%; box-sizing: border-box; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 14px; color: #334155; transition: 0.2s; font-family: inherit; }
.form-control:focus { border-color: #0a69db; outline: none; box-shadow: 0 0 0 3px rgba(10,105,219,0.1); }
.readonly-field { background: #f1f5f9; pointer-events: none; color: #64748b; font-weight: 600; border-color: #e2e8f0; }
.required { color: #e11d48; }

/* Nhóm Input + Nút Tải ảnh */
.input-group { display: flex; }
.input-group .form-control { flex: 1; border-top-right-radius: 0; border-bottom-right-radius: 0; border-right: none; }
.btn-upload { background: #f1f5f9; padding: 10px 15px; text-decoration: none; border-radius: 0 4px 4px 0; border: 1px solid #cbd5e1; color: #475569; font-size: 13px; font-weight: 600; white-space: nowrap; transition: 0.2s; display: inline-flex; align-items: center; gap: 5px; margin: 0; cursor: pointer; }
.btn-upload:hover { background: #e2e8f0; color: #0f172a; }

/* Nút Radio Tình trạng */
.radio-group { display: flex; gap: 20px; align-items: center; padding: 8px 0; }
.radio-group label { display: flex; align-items: center; gap: 6px; cursor: pointer; font-size: 14px; font-weight: 600; color: #334155; }
.radio-group input { width: 16px; height: 16px; cursor: pointer; margin: 0; }

/* Khung Editor */
.editor-wrapper { border: 1px solid #cbd5e1; border-radius: 4px; overflow: hidden; background: #fff; }

/* Nút Submit */
.btn-primary { background: #0a69db; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s; text-transform: uppercase; }
.btn-primary:hover { background: #0056b3; }

@media (max-width: 600px) {
    .form-col { min-width: 100% !important; }
}
</style>

<% 
' ĐỔI TÊN ACTION ĐỂ KHÔNG XUNG ĐỘT VỚI LOGIN HAY FORM KHÁC
If Request.Form("action_add")="submit" Then
    idcha      = Replace(Request.Form("idcha"), "'", "''")
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
    
    ' Chỉ khai báo cục bộ các biến Đời và Phả đồ xử lý riêng biệt
    Dim targetIdDoi, romanTitle
    Dim rsParentCheck, rsCheckDoi1, rsNewDoi1, rsDoiCha, rsCheckDoi, rsNewDoi
    
    ' TRƯỜNG HỢP 1: THÊM THỦY TỔ (idcha = 0 hoặc rỗng)
    If idcha = "" Or idcha = "0" Or CInt("0" & idcha) = 0 Then
        idcha = 0
        loai_quanhe = 1
        
        ' Kiểm tra xem hệ thống đã có Đời I chưa, nếu chưa có thì tự tạo
        Set rsCheckDoi1 = conn.Execute("SELECT iddoi FROM tbldoi WHERE thutu = 1")
        If rsCheckDoi1.EOF Then
            conn.Execute("INSERT INTO tbldoi (tieude, thutu) VALUES (N'I', 1)")
            Set rsNewDoi1 = conn.Execute("SELECT @@IDENTITY AS NewID")
            targetIdDoi = rsNewDoi1("NewID")
            rsNewDoi1.Close
            Set rsNewDoi1 = Nothing
        Else
            targetIdDoi = rsCheckDoi1("iddoi")
        End If
        rsCheckDoi1.Close
        Set rsCheckDoi1 = Nothing
        
    ' TRƯỜNG HỢP 2: THÊM CON CHO NHÂN VẬT ĐÃ CÓ
    Else
        Dim iddoi_cha, currentDoiThutu, targetDoiThutu
        
        Set rsParentCheck = conn.Execute("SELECT gioitinh, iddoi FROM tblgiapha WHERE idgiapha=" & CInt(idcha))
        If Not rsParentCheck.EOF Then
            If CInt(rsParentCheck("gioitinh")) = 1 Then
                loai_quanhe = 1 
            Else
                loai_quanhe = 3 
            End If
            iddoi_cha = rsParentCheck("iddoi")
        Else
            loai_quanhe = 1
            iddoi_cha = 0
        End If
        rsParentCheck.Close
        Set rsParentCheck = Nothing
        
        ' Lấy số thứ tự đời của Cha để tính đời con (+1)
        Set rsDoiCha = conn.Execute("SELECT thutu FROM tbldoi WHERE iddoi=" & CInt(iddoi_cha))
        If Not rsDoiCha.EOF Then
            currentDoiThutu = CInt(rsDoiCha("thutu"))
        Else
            currentDoiThutu = 0
        End If
        rsDoiCha.Close
        Set rsDoiCha = Nothing
        
        targetDoiThutu = currentDoiThutu + 1
        
        ' Kiểm tra Đời của Con đã tồn tại chưa, chưa có thì tự sinh
        Set rsCheckDoi = conn.Execute("SELECT iddoi FROM tbldoi WHERE thutu=" & targetDoiThutu)
        If rsCheckDoi.EOF Then
            rsCheckDoi.Close
            Set rsCheckDoi = Nothing
            
            romanTitle = ToRoman(targetDoiThutu)
            conn.Execute("INSERT INTO tbldoi (tieude, thutu) VALUES (N'" & romanTitle & "', " & targetDoiThutu & ")")
            
            Set rsNewDoi = conn.Execute("SELECT @@IDENTITY AS NewID")
            targetIdDoi = rsNewDoi("NewID")
            rsNewDoi.Close
            Set rsNewDoi = Nothing
        Else
            targetIdDoi = rsCheckDoi("iddoi")
            rsCheckDoi.Close
            Set rsCheckDoi = Nothing
        End If
    End If
    ' ====================================================
    ' TỰ ĐỘNG DỒN SỐ THỨ TỰ (TRÁNH TRÙNG LẶP)
    ' ====================================================
    Dim rsCheckThuTu
    Set rsCheckThuTu = conn.Execute("SELECT idgiapha FROM tblgiapha WHERE idcha=" & CInt(idcha) & " AND thutu=" & CInt(thutu))
    If Not rsCheckThuTu.EOF Then
        conn.Execute("UPDATE tblgiapha SET thutu = thutu + 1 WHERE idcha=" & CInt(idcha) & " AND thutu >= " & CInt(thutu))
    End If
    rsCheckThuTu.Close
    Set rsCheckThuTu = Nothing
    
    ' 3. THỰC THI INSERT NHÂN VẬT VÀO DATABASE
    sql = "INSERT INTO tblgiapha(idcha,iddoi,hoten,hinhanh,thutu,tentu,gioitinh,diachi,namsinh,tinhtrang,nammat,huongtho,noiantang,tieusu,nghenghiep,dienthoai,email,loai_quanhe) VALUES(" & CInt(idcha) & "," & CInt(targetIdDoi) & ",N'"&hoten&"','"&hinhanh&"'," & CInt(thutu) & ",N'"&tentu&"'," & CInt(gioitinh) & ",N'"&diachi&"',N'"&namsinh&"'," & CInt(tinhtrang) & ",N'"&nammat&"','"&huongtho&"',N'"&noiantang&"',N'"&tieusu&"',N'"&nghenghiep&"',N'"&dienthoai&"',N'"&email&"'," & loai_quanhe & ")"
    conn.execute(sql)
    destroyconn
%>
<script language="javascript">
    alert("Chúc mừng anh đã thêm thông tin nhân vật thành công!");
    window.parent.location.reload();
    window.parent.$.fancybox.close();
</script>
<%
    Response.End
End If
%>

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

    // Hiển thị trạng thái đang tải
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
            targetInput.value = originalVal; // Trả lại giá trị cũ nếu lỗi
        } else {
            // Tự động gán đường dẫn chuẩn cho CSDL
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
    Dim sessionpage, isThuyTo
    sessionpage = request.QueryString("sessionpage")
    
    isThuyTo = False
    If sessionpage = "" Or sessionpage = "0" Or CInt("0" & sessionpage) = 0 Then
        isThuyTo = True
    End If
    
    Set rs2 = Server.CreateObject("adodb.recordset")
    If Not isThuyTo Then
        rs2.open "select * from tblgiapha where idgiapha=" & CInt(sessionpage), conn 
    End If
%>

<div class="form-container">
    <div class="form-title"><i class="fa fa-user-plus"></i> THÊM MỚI NHÂN VẬT</div>
    
    <form name="frmAddNews" method="post" action="">
    <input type="hidden" name="action_add" value="submit">

    <!-- DÒNG 1: Là con của / Thủy tổ -->
    <div class="form-row">
        <% If isThuyTo Then %>
        <div class="form-col full">
            <label class="form-label" style="color: #0a69db; font-size: 14px;"><i class="fa fa-star"></i> KHỞI TẠO THỦY TỔ DÒNG HỌ</label>
            <input type="hidden" name="idcha" value="0">
            <input type="text" class="form-control readonly-field" value="[Là gốc Thủy Tổ - Tự động định danh Đời I]" readonly>
        </div>
        <% ElseIf Not rs2.eof Then %>
        <div class="form-col full">
            <label class="form-label">Là con của ông/bà</label>
            <input type="hidden" name="idcha" value="<%=rs2("idgiapha")%>">
            <input type="text" class="form-control readonly-field" value="<%=rs2("hoten")%>" readonly>
        </div>
        <div style="width:100%; font-size: 12px; color: #64748b; margin-top:-8px; font-style: italic;">
            * Đời của nhân vật này sẽ được hệ thống tự động kế thừa và tính toán dựa trên đời của người Cha/Mẹ.
        </div>
        <% End If %>
    </div>

    <!-- DÒNG 2: Họ và tên | Tên tự -->
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

    <!-- DÒNG 3: Hình ảnh (Đã chuyển sang AJAX Upload) -->
    <div class="form-row">
        <div class="form-col full">
            <label class="form-label">Hình ảnh đại diện (300 x 400)</label>
            <div class="input-group">
                <input name="hinhanh" id="hinhanh" type="text" class="form-control" placeholder="Tải ảnh lên hoặc dán đường dẫn ảnh vào đây...">
                <label class="btn-upload">
                    <i class="fa fa-upload"></i> Tải ảnh
                    <input type="file" accept="image/*" style="display:none;" onchange="uploadCharacterImage(this, 'hinhanh')">
                </label>
            </div>
        </div>
    </div>

    <!-- DÒNG 4: Giới tính | Con thứ -->
    <div class="form-row">
        <div class="form-col">
            <label class="form-label">Giới tính</label>
            <select name="gioitinh" class="form-control">
                <option value='1'>Nam</option>
                <option value='2'>Nữ</option>
            </select>
        </div>
        <div class="form-col">
            <label class="form-label">Là con thứ <span class="required">*</span></label>
            <input name="thutu" type="number" class="form-control" required placeholder="Nhập số thứ tự (1, 2, 3...)">
        </div>
    </div>

    <!-- DÒNG 5: Địa chỉ -->
    <div class="form-row">
        <div class="form-col full">
            <label class="form-label">Địa chỉ / Thường trú</label>
            <input name="diachi" type="text" class="form-control" placeholder="Nhập địa chỉ hiện tại...">
        </div>
    </div>

    <!-- DÒNG 6: Tình trạng -->
    <div class="form-row">
        <div class="form-col full">
            <label class="form-label">Tình trạng</label>
            <div class="radio-group">
                <label><input type="radio" name="tinhtrang" value="1" checked onchange="toggleTinhTrang()"> Còn sống</label>
                <label><input type="radio" name="tinhtrang" value="2" onchange="toggleTinhTrang()"> Đã mất</label>
            </div>
        </div>
    </div>

    <!-- DÒNG 7: NĂM SINH / NĂM MẤT (Hiển thị động) -->
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

    <!-- DÒNG 8: KHU VỰC ĐÃ MẤT (Hưởng thọ + An táng) -->
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

    <!-- DÒNG 9: Tiểu sử -->
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

    <!-- DÒNG 10: Nghề nghiệp -->
    <div class="form-row">
        <div class="form-col full">
            <label class="form-label">Nghề nghiệp, Chức vụ</label>
            <input name="nghenghiep" type="text" class="form-control" placeholder="Công việc hiện tại hoặc chức vụ...">
        </div>
    </div>

    <!-- DÒNG 11: Điện thoại | Email -->
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
' ĐÓNG RECORDSET VÀ CONNECTION AN TOÀN TRÁNH LỖI ĐỐI TƯỢNG ĐÃ ĐÓNG
On Error Resume Next
If Not isThuyTo Then
    If rs2.State = 1 Then 
        rs2.Close()
    End If
End If
Set rs2 = Nothing
destroyconn()
On Error GoTo 0
%>