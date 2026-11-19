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
Response.Expires = -1
Response.AddHeader "Pragma", "no-cache"
Response.AddHeader "cache-control", "no-store"
%>
<style>
.admin-card { background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 25px; border: 1px solid #e2e8f0; font-family: inherit; }
.admin-card-header { background: #f8fafc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0; font-weight: bold; color: #0f172a; font-size: 15px; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
.admin-card-header i { color: #0a69db; font-size: 18px; }
.admin-card-body { padding: 20px; }

/* Khu vực Upload Kéo Thả */
.dropzone-area { border: 2px dashed #cbd5e1; border-radius: 6px; background: #f8fafc; padding: 30px 20px; text-align: center; color: #64748b; cursor: pointer; transition: 0.3s; position: relative; margin-bottom: 25px; }
.dropzone-area:hover, .dropzone-area.dragover { background: #e0f2fe; border-color: #0a69db; color: #0a69db; }
.dropzone-area i { font-size: 40px; margin-bottom: 10px; color: #94a3b8; }
.dropzone-area input[type="file"] { position: absolute; top: 0; left: 0; width: 100%; height: 100%; opacity: 0; cursor: pointer; }

/* Grid hiển thị ảnh Slider */
.gallery-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 15px; }
.gallery-item { position: relative; border: 1px solid #e2e8f0; border-radius: 4px; overflow: hidden; background: #fff; cursor: grab; padding: 5px; box-shadow: 0 1px 2px rgba(0,0,0,0.05); transition: transform 0.2s; }
.gallery-item:active { cursor: grabbing; transform: scale(1.05); z-index: 10; box-shadow: 0 10px 15px rgba(0,0,0,0.15); }
.gallery-item img { width: 100%; height: 120px; object-fit: cover; border-radius: 3px; pointer-events: none; }

.btn-delete-img { position: absolute; top: 10px; right: 10px; background: rgba(0,0,0,0.6); color: #fff; border: none; border-radius: 50%; width: 28px; height: 28px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s; font-size: 14px; }
.btn-delete-img:hover { background: #e11d48; transform: scale(1.1); }
.drag-hint { position: absolute; bottom: 10px; left: 10px; background: rgba(0,0,0,0.6); color: #fff; font-size: 11px; padding: 4px 8px; border-radius: 3px; pointer-events: none; }
</style>

<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-picture-o"></i> QUẢN LÝ ẢNH SLIDER TRANG CHỦ</div>
    <div class="admin-card-body">
        
        <!-- Khu vực Tải ảnh lên -->
        <div class="dropzone-area" id="dropzone">
            <i class="fa fa-cloud-upload"></i>
            <h3 style="margin:0; font-size: 16px; color:#334155;">Click hoặc Kéo thả ảnh vào đây để tải lên</h3>
            <p style="font-size: 13px; margin-top: 5px;">Hỗ trợ up nhiều ảnh cùng lúc (Bôi đen nhiều ảnh hoặc giữ Ctrl khi chọn).</p>
            <input type="file" id="fileInput" accept="image/*" multiple>
        </div>
        
        <!-- Lưới hiển thị ảnh (Kéo thả để sắp xếp) -->
        <div class="gallery-grid" id="galleryGrid">
            <%
            openconn
            Set rsA = conn.Execute("SELECT * FROM tblloadanh ORDER BY ISNULL(thutu, 0) ASC, idloadanh DESC")
            
            If rsA.EOF Then
                Response.Write "<div style='grid-column: 1 / -1; text-align: center; padding: 20px; color: #94a3b8;'>Chưa có hình ảnh nào trong Slider.</div>"
            End If

            Do While Not rsA.EOF
                Dim imgPath
                imgPath = rsA("hinhanh")
                If InStr(imgPath, "../") = 0 And InStr(imgPath, "http") = 0 Then
                    imgPath = "../Images/Hinhanh/" & imgPath
                End If
            %>
            <div class="gallery-item" draggable="true" data-id="<%=rsA("idloadanh")%>">
                <button class="btn-delete-img" onclick="deleteSliderImage(<%=rsA("idloadanh")%>, this)" title="Xóa ảnh này"><i class="fa fa-trash"></i></button>
                <img src="<%=imgPath%>">
                <span class="drag-hint"><i class="fa fa-arrows"></i> Kéo để sắp xếp</span>
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

<script>
// ==========================================
// HÀM NÉN ẢNH BẰNG HTML5 CANVAS TRƯỚC KHI UPLOAD
// ==========================================
async function compressImage(file, targetSizeKB = 200) {
    // Nếu file đã nhỏ hơn targetSizeKB, không cần nén, giữ nguyên file gốc
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

                // 1. Tính toán lại kích thước (Tối đa chiều ngang/dọc là 1600px để giữ độ nét)
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

                // Tô nền trắng (phòng trường hợp ảnh PNG trong suốt bị lỗi nền đen khi ép sang JPG)
                ctx.fillStyle = "#FFFFFF";
                ctx.fillRect(0, 0, width, height);
                ctx.drawImage(img, 0, 0, width, height);

                // 2. Vòng lặp giảm chất lượng ảnh cho đến khi đạt ~200KB
                let quality = 0.9; 
                const attemptCompress = () => {
                    canvas.toBlob((blob) => {
                        // Kiểm tra nếu dung lượng vẫn lớn hơn mức yêu cầu và chất lượng chưa quá mờ (>0.3)
                        if (blob.size / 1024 > targetSizeKB && quality > 0.3) {
                            quality -= 0.1; // Giảm chất lượng đi 10%
                            attemptCompress(); // Thử lại
                        } else {
                            // Đổi đuôi file thành .jpg
                            const newFileName = file.name.replace(/\.[^/.]+$/, "") + ".jpg";
                            // Tạo file mới từ Blob
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

// ==========================================
// XỬ LÝ UPLOAD HÀNG ĐỢI (ĐÃ TÍCH HỢP NÉN ẢNH)
// ==========================================
const dropzone = document.getElementById('dropzone');
const fileInput = document.getElementById('fileInput');

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
        dropzone.innerHTML = `<i class='fa fa-spinner fa-spin'></i> 
            <h3 style='margin:0; font-size: 16px; color:#0a69db;'>
                Đang nén & tải lên ${i + 1} / ${total} ảnh...
            </h3>`;
        
        try {
            // [MỚI] Chạy hàm nén ảnh trước khi nạp vào FormData
            let optimizedFile = await compressImage(files[i], 200);

            let formData = new FormData();
            formData.append('file', optimizedFile); 

            let response = await fetch('ajax_upload_ha.asp', { method: 'POST', body: formData });
            let fileName = await response.text();
            fileName = fileName.trim();

            if (fileName !== "" && fileName.indexOf("Lỗi") === -1) {
                let dbResponse = await fetch('ajax_loadanh.asp', { 
                    method: 'POST', 
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                    body: 'action=add&hinhanh=' + encodeURIComponent(fileName)
                });
                
                let dbResult = await dbResponse.text();
                
                if (!dbResponse.ok || dbResult.indexOf("Lỗi") > -1 || dbResult.indexOf("error") > -1) {
                    console.error("LỖI GHI DATABASE:", dbResult);
                } else {
                    successCount++;
                }
            } else {
                console.error("LỖI LƯU FILE VẬT LÝ:", fileName);
            }
        } catch (error) {
            console.error("LỖI MẠNG:", error.message);
        }
    }
    
    dropzone.innerHTML = `<i class='fa fa-check-circle' style='color:#10b981;'></i> 
        <h3 style='margin:0; font-size: 16px; color:#10b981;'>Đã xử lý xong ${successCount} ảnh! Đang làm mới...</h3>`;
    setTimeout(() => { window.location.reload(); }, 1500);
}

// ==========================================
// CÁC HÀM XÓA VÀ KÉO THẢ GIỮ NGUYÊN BÊN DƯỚI...
// ==========================================
function deleteSliderImage(idLoadAnh, btn) {
    if(!confirm("Bạn có chắc chắn muốn xóa ảnh này khỏi Slider?")) return;
    fetch('ajax_loadanh.asp', { 
        method: 'POST', 
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: 'action=delete&id=' + idLoadAnh
    }).then(async (response) => {
        let result = await response.text();
        if (!response.ok || result.indexOf("Lỗi") > -1) {
            alert("LỖI XÓA DATABASE:\n" + result);
        } else {
            btn.parentElement.remove();
            updateSortOrder(); 
        }
    });
}

const galleryGrid = document.getElementById('galleryGrid');
let draggedItem = null;

galleryGrid.addEventListener('dragstart', function(e) {
    if(e.target.classList.contains('gallery-item')) {
        draggedItem = e.target;
        setTimeout(() => e.target.style.opacity = "0.5", 0);
    }
});
galleryGrid.addEventListener('dragend', function(e) {
    if(e.target.classList.contains('gallery-item')) {
        setTimeout(() => {
            e.target.style.opacity = "1";
            draggedItem = null;
            updateSortOrder(); 
        }, 0);
    }
});
galleryGrid.addEventListener('dragover', function(e) {
    e.preventDefault();
    const afterElement = getDragAfterElement(galleryGrid, e.clientX, e.clientY);
    if (afterElement == null) {
        galleryGrid.appendChild(draggedItem);
    } else {
        galleryGrid.insertBefore(draggedItem, afterElement);
    }
});
function getDragAfterElement(container, x, y) {
    const draggableElements = [...container.querySelectorAll('.gallery-item:not([style*="opacity: 0.5"])')];
    return draggableElements.reduce((closest, child) => {
        const box = child.getBoundingClientRect();
        const offsetX = x - box.left - box.width / 2;
        const offsetY = y - box.top - box.height / 2;
        if (offsetX < 0 && offsetY < box.height / 2 && offsetX > closest.offset) {
            return { offset: offsetX, element: child }
        } else {
            return closest;
        }
    }, { offset: Number.NEGATIVE_INFINITY }).element;
}
function updateSortOrder() {
    const items = [...galleryGrid.querySelectorAll('.gallery-item')];
    if(items.length === 0) return;
    let ids = items.map(item => item.getAttribute('data-id')).join(',');
    fetch('ajax_loadanh.asp', { 
        method: 'POST', 
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: 'action=sort&sorted_ids=' + encodeURIComponent(ids)
    });
}
</script>