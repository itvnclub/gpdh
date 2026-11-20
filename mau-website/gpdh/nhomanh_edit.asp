<%session.CodePage=65001%>
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

Function ValInt(v)
    If IsNull(v) Or Trim(v & "") = "" Then ValInt = 0 Else If IsNumeric(v) Then ValInt = CInt(v) Else ValInt = 0
End Function

Function GetSafeInt(paramName, defaultVal)
    Dim val
    val = Request.QueryString(paramName)
    If val = "" Then val = Request.Form(paramName)
    If val = "" Then GetSafeInt = defaultVal : Exit Function
    If InStr(val, ",") > 0 Then
        Dim arr : arr = Split(val, ",") : val = Trim(arr(0))
    End If
    GetSafeInt = ValInt(val)
End Function

Function GetCleanFileName(ByVal rawPath)
    rawPath = Trim(rawPath & "")
    If rawPath = "" Then GetCleanFileName = "" : Exit Function
    rawPath = Replace(rawPath, "\", "/")
    If InStr(rawPath, "/") > 0 Then
        Dim arrP : arrP = Split(rawPath, "/")
        GetCleanFileName = arrP(UBound(arrP))
    Else
        GetCleanFileName = rawPath
    End If
End Function

Function GetImgUrl(ByVal rawPath)
    rawPath = Trim(rawPath & "")
    If rawPath = "" Then GetImgUrl = "" : Exit Function
    If Left(LCase(rawPath), 4) = "http" Then GetImgUrl = rawPath : Exit Function
    GetImgUrl = "/images/hinhanh/" & GetCleanFileName(rawPath)
End Function

Dim action, id_nhom, tieude
action = Request.Form("action")
id_nhom = GetSafeInt("id_nhom", 0)
If id_nhom = 0 Then id_nhom = GetSafeInt("id", 0)

If action = "submit" Then
    tieude = Replace(Request.Form("tieude"),"'","''")
    openconn
    If id_nhom = 0 Then
        conn.Execute("INSERT INTO tblnhomanh(tieude) VALUES(N'"&tieude&"')")
        Set rsNew = conn.Execute("SELECT @@IDENTITY AS NewID")
        id_nhom = ValInt(rsNew("NewID"))
        rsNew.Close : Set rsNew = Nothing
    Else
        conn.Execute("UPDATE tblnhomanh SET tieude=N'"&tieude&"' WHERE idnhomanh=" & id_nhom)
        Set rsCover = conn.Execute("SELECT TOP 1 hinhanh FROM tblanh WHERE idnhomanh=" & id_nhom & " ORDER BY thutu ASC, idanh DESC")
        If Not rsCover.EOF Then
            Dim coverFile
            coverFile = Replace(GetCleanFileName(rsCover("hinhanh")), "'", "''")
            conn.Execute("UPDATE tblnhomanh SET hinhanh='" & coverFile & "' WHERE idnhomanh=" & id_nhom)
        Else
            conn.Execute("UPDATE tblnhomanh SET hinhanh='' WHERE idnhomanh=" & id_nhom)
        End If
        rsCover.Close : Set rsCover = Nothing
    End If
    destroyconn
    Response.Redirect("/gpdh/thu-vien-anh/")
End If

edit_tieude = ""
If id_nhom > 0 Then
    openconn
    Set rs1 = conn.Execute("SELECT * FROM tblnhomanh WHERE idnhomanh=" & id_nhom)
    If Not rs1.EOF Then
        edit_tieude  = rs1("tieude")
    End If
    rs1.Close : Set rs1 = Nothing
    destroyconn
End If

Response.Expires = -1
Response.AddHeader "Pragma", "no-cache"
Response.AddHeader "cache-control", "no-store"
%>
<style>
    body, html, input, select, textarea, button {
        font-family: <%=currentFont%> !important;
        font-size: <%=currentFontSize%> !important;
    }
.admin-card { background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 25px; border: 1px solid #e2e8f0; }
.admin-card-header { background: #f8fafc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0; font-weight: bold; color: #0f172a; font-size: 1.1em; display: flex; align-items: center; gap: 10px; text-transform: uppercase; }
.admin-card-header i { color: #0a69db; font-size: 1.2em; }
.admin-card-body { padding: 20px; }
.row-grid { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 15px; }
.col-flex { flex: 1; min-width: 250px; }
.form-label { display: block; font-weight: 600; margin-bottom: 8px; font-size: 0.95em; color: #475569; }
.form-input { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 1em; box-sizing: border-box; }
.btn-primary { background: #0a69db; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-weight: bold; cursor: pointer; transition: 0.2s; }
.btn-primary:hover { background: #0056b3; }
.btn-secondary { background: #64748b; color: #fff; border: none; padding: 10px 15px; border-radius: 4px; font-weight: bold; text-decoration: none; display: inline-block; }
.btn-secondary:hover { background: #475569; }
.dropzone-area { border: 2px dashed #cbd5e1; border-radius: 6px; background: #f8fafc; padding: 40px 20px; text-align: center; color: #64748b; cursor: pointer; transition: 0.3s; position: relative; margin-bottom: 20px; }
.dropzone-area.dragover { background: #e0f2fe; border-color: #0a69db; color: #0a69db; }
.dropzone-area i { font-size: 40px; margin-bottom: 10px; color: #94a3b8; }
.dropzone-area input[type="file"] { position: absolute; top: 0; left: 0; width: 100%; height: 100%; opacity: 0; cursor: pointer; }
.gallery-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 15px; }
.gallery-item { position: relative; border: 1px solid #e2e8f0; border-radius: 4px; overflow: hidden; background: #fff; cursor: grab; padding: 5px; box-shadow: 0 1px 2px rgba(0,0,0,0.05); transition: transform 0.2s; }
.gallery-item:active { cursor: grabbing; transform: scale(1.05); z-index: 10; box-shadow: 0 10px 15px rgba(0,0,0,0.1); }
.gallery-item img { width: 100%; height: 120px; object-fit: cover; border-radius: 3px; pointer-events: none; }
.gallery-item .cover-badge { position: absolute; top: 10px; left: 10px; background: #ef4444; color: #fff; font-size: 11px; padding: 2px 6px; border-radius: 3px; font-weight: bold; display: none; pointer-events: none; z-index: 2; }
.gallery-item:first-child .cover-badge { display: block; } 
.btn-delete-img { position: absolute; top: 10px; right: 10px; background: rgba(0,0,0,0.6); color: #fff; border: none; border-radius: 50%; width: 26px; height: 26px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s; z-index: 2; }
.btn-delete-img:hover { background: #ef4444; }
.sortable-ghost { opacity: 0.4; background: #e0f2fe; border: 2px dashed #0a69db; }
</style>

<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-folder-open"></i> THÔNG TIN NHÓM ẢNH</div>
    <div class="admin-card-body">
        <form method="post" action="">
            <input type="hidden" name="action" value="submit">
            <input type="hidden" name="id_nhom" value="<%=id_nhom%>">
            <div class="row-grid">
                <div class="col-flex" style="flex: 2;">
                    <label class="form-label">Tên nhóm ảnh (Sự kiện) <span style="color:red">*</span></label>
                    <input type="text" name="tieude" class="form-input" value="<%=edit_tieude%>" required>
                </div>
            </div>
            <div style="display: flex; gap: 10px; align-items: center;">
                <button type="submit" class="btn-primary"><i class="fa fa-save"></i> LƯU THÔNG TIN</button>
                <a href="/gpdh/thu-vien-anh/" class="btn-secondary">QUAY LẠI DANH SÁCH</a>
            </div>
        </form>
    </div>
</div>

<% If id_nhom > 0 Then %>
<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-picture-o"></i> QUẢN LÝ THƯ VIỆN ẢNH (Kéo thả để sắp xếp)</div>
    <div class="admin-card-body">
        <div class="dropzone-area" id="dropzone">
            <i class="fa fa-cloud-upload"></i>
            <h3>Kéo thả ảnh vào đây hoặc Click để chọn ảnh tải lên</h3>
            <p style="font-size: 12px; margin-top: 5px;">Hỗ trợ upload nhiều ảnh cùng lúc (.jpg, .png). Ảnh đầu tiên sẽ tự động làm ảnh đại diện.</p>
            <input type="file" id="fileInput" multiple accept="image/*">
        </div>
        <div class="gallery-grid" id="galleryGrid">
            <%
            openconn
            Set rsA = conn.Execute("SELECT * FROM tblanh WHERE idnhomanh=" & id_nhom & " ORDER BY thutu ASC, idanh DESC")
            If rsA.EOF Then
                Response.Write "<div id='emptyGalleryMsg' style='grid-column: 1 / -1; text-align: center; padding: 20px; color: #94a3b8;'>Chưa có hình ảnh nào trong thư viện.</div>"
            End If
            Do While Not rsA.EOF
                imgPath = GetImgUrl(rsA("hinhanh"))
                cleanFile = GetCleanFileName(rsA("hinhanh"))
            %>
            <div class="gallery-item" data-id="<%=rsA("idanh")%>" data-path="<%=cleanFile%>">
                <span class="cover-badge"><i class="fa fa-star"></i> Ảnh đại diện</span>
                <button type="button" class="btn-delete-img" onclick="deleteImage(<%=rsA("idanh")%>, <%=id_nhom%>, this)"><i class="fa fa-times"></i></button>
                <img src="<%=imgPath%>">
            </div>
            <%
                rsA.MoveNext
            Loop
            rsA.Close : Set rsA = Nothing
            destroyconn
            %>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/sortablejs@latest/Sortable.min.js"></script>
<script>
async function compressImage(file, targetSizeKB = 200) {
    if (file.size / 1024 <= targetSizeKB) return file;
    return new Promise((resolve) => {
        const reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = function (event) {
            const img = new Image();
            img.src = event.target.result;
            img.onload = function () {
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');
                const MAX_DIMENSION = 1600;
                let width = img.width;
                let height = img.height;
                if (width > MAX_DIMENSION || height > MAX_DIMENSION) {
                    if (width > height) {
                        height = Math.round((height * MAX_DIMENSION) / width);
                        width = MAX_DIMENSION;
                    } else {
                        width = Math.round((width * MAX_DIMENSION) / height);
                        height = MAX_DIMENSION;
                    }
                }
                canvas.width = width;
                canvas.height = height;
                ctx.fillStyle = "#FFFFFF";
                ctx.fillRect(0, 0, width, height);
                ctx.drawImage(img, 0, 0, width, height);
                let quality = 0.9; 
                const attemptCompress = () => {
                    canvas.toBlob((blob) => {
                        if (blob.size / 1024 > targetSizeKB && quality > 0.3) {
                            quality -= 0.1; 
                            attemptCompress(); 
                        } else {
                            const newFileName = file.name.replace(/\.[^/.]+$/, "") + ".jpg";
                            const compressedFile = new File([blob], newFileName, {
                                type: 'image/jpeg',
                                lastModified: Date.now()
                            });
                            resolve(compressedFile);
                        }
                    }, 'image/jpeg', quality);
                };
                attemptCompress();
            };
        };
    });
}

const dropzone = document.getElementById('dropzone');
const fileInput = document.getElementById('fileInput');
const galleryGrid = document.getElementById('galleryGrid');
const idNhom = "<%=id_nhom%>";

dropzone.addEventListener('dragover', (e) => { e.preventDefault(); dropzone.classList.add('dragover'); });
dropzone.addEventListener('dragleave', () => dropzone.classList.remove('dragover'));
dropzone.addEventListener('drop', (e) => {
    e.preventDefault();
    dropzone.classList.remove('dragover');
    processFilesSequentially(e.dataTransfer.files);
});
fileInput.addEventListener('change', function(e) {
    processFilesSequentially(e.target.files);
});

async function processFilesSequentially(files) {
    if (files.length === 0) return;
    let total = files.length;
    let successCount = 0;
    dropzone.style.pointerEvents = "none"; 
    for (let i = 0; i < total; i++) {
        dropzone.innerHTML = `<i class='fa fa-spinner fa-spin'></i> <h3>Đang nén & tải lên ${i + 1} / ${total} ảnh...</h3>`;
        try {
            let optimizedFile = await compressImage(files[i], 200);
            let fileData = new FormData();
            fileData.append('file', optimizedFile); 
            let uploadResponse = await fetch('/gpdh/ajax_upload_ha.asp', { method: 'POST', body: fileData });
            let fileName = await uploadResponse.text();
            fileName = fileName.trim();
            if (fileName !== "" && fileName.indexOf("Lỗi") === -1) {
                let dbParams = new URLSearchParams();
                dbParams.append("action", "upload");
                dbParams.append("id_nhom", idNhom);
                dbParams.append("hinhanh", fileName);
                let dbResponse = await fetch('/gpdh/ajax_gallery.asp', { 
                    method: 'POST', 
                    body: dbParams 
                });
                let dbResult = await dbResponse.text();
                if (!dbResponse.ok || dbResult.indexOf("error") > -1 || dbResult.indexOf("Lỗi") > -1) {
                    alert("LỖI DATABASE:\n" + dbResult);
                } else {
                    successCount++;
                }
            } else {
                alert("LỖI LƯU FILE VẬT LÝ:\n" + fileName);
            }
        } catch (error) {
            console.error("Lỗi quá trình tải ảnh:", error);
            alert("LỖI MẠNG: " + error.message);
        }
    }
    dropzone.innerHTML = `<i class='fa fa-check-circle' style='color:#10b981;'></i> <h3 style='color:#10b981;'>Đã tải xong ${successCount} ảnh! Đang đồng bộ...</h3>`;
    await updateSortOrder();
    setTimeout(() => { window.location.reload(); }, 1200);
}

new Sortable(galleryGrid, {
    animation: 150, 
    ghostClass: 'sortable-ghost', 
    onEnd: function () {
        updateSortOrder(); 
    }
});

async function updateSortOrder() {
    const items = [...galleryGrid.querySelectorAll('.gallery-item')];
    if (items.length === 0) {
        galleryGrid.innerHTML = "<div id='emptyGalleryMsg' style='grid-column: 1 / -1; text-align: center; padding: 20px; color: #94a3b8;'>Chưa có hình ảnh nào trong thư viện.</div>";
        return;
    }
    let ids = items.map(item => item.getAttribute('data-id')).join(',');
    let coverPath = items[0].getAttribute('data-path'); 
    
    // Sử dụng URLSearchParams thay vì FormData để Classic ASP đọc được Request.Form
    let params = new URLSearchParams();
    params.append("action", "sort");
    params.append("id_nhom", idNhom);
    params.append("sorted_ids", ids);
    params.append("cover_path", coverPath);

    try {
        await fetch('/gpdh/ajax_gallery.asp', { method: 'POST', body: params });
        document.querySelectorAll('.cover-badge').forEach(badge => badge.style.display = 'none');
        if (items[0].querySelector('.cover-badge')) {
            items[0].querySelector('.cover-badge').style.display = 'block';
        }
    } catch (err) {
        console.error("Lỗi cập nhật thứ tự:", err);
    }
}

async function deleteImage(idAnh, idNhomVal, btn) {
    if (!confirm("Chắc chắn xóa ảnh này?")) return;
    
    // Sử dụng URLSearchParams thay vì FormData để Classic ASP đọc được Request.Form
    let params = new URLSearchParams();
    params.append("action", "delete");
    params.append("id_anh", idAnh);
    params.append("id_nhom", idNhomVal);

    try {
        let response = await fetch('/gpdh/ajax_gallery.asp', { method: 'POST', body: params });
        let result = (await response.text()).trim();
        if (response.ok && result === "Deleted") {
            btn.parentElement.remove();
            await updateSortOrder();
        } else {
            alert("Không thể xóa ảnh: " + result);
        }
    } catch (err) {
        alert("Lỗi kết nối khi xóa ảnh: " + err.message);
    }
}
</script>
<% End If %>