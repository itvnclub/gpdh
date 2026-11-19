<%session.CodePage=65001%>
<%
' ====================================================
' 0. KIỂM TRA QUYỀN TRUY CẬP TRANG QUẢN LÝ VIDEO
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

If CInt("0" & Session("is_super")) = 0 And CInt("0" & Session("is_content")) = 0 Then
%>
<script language="javascript">
    alert("Bạn không có quyền truy cập vào chức năng Quản lý Thư viện Video!");
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

' ====================================================
' 1. XỬ LÝ LƯU DỮ LIỆU (THÊM MỚI VÀ CẬP NHẬT)
' ====================================================
If Request.Form("action_submit") = "save" Then
    edit_id = GetSafeInt("edit_id", 0)
    tieude  = Replace(Request.Form("tieude"), "'", "''")
    lienket = Replace(Request.Form("lienket"), "'", "''")
    thutu   = GetSafeInt("thutu", 0)

    openconn
    If edit_id = 0 Then
        ' Thêm mới
        conn.Execute "INSERT INTO tblvideo(tieude, lienket, thutu) VALUES(N'"&tieude&"', '"&lienket&"', "&thutu&")"
    Else
        ' Cập nhật
        conn.Execute "UPDATE tblvideo SET tieude=N'"&tieude&"', lienket='"&lienket&"', thutu="&thutu&" WHERE idvideo=" & edit_id
    End If
    destroyconn
    Response.Redirect("/gpdh/thu-vien-video/")
End If

' ====================================================
' 2. XỬ LÝ XÓA VÀ SẮP XẾP THỨ TỰ
' ====================================================
Dim action_req, id_video
action_req = Trim(Request.QueryString("action"))
id_video = GetSafeInt("id", 0)

If action_req <> "" And id_video > 0 Then
    openconn
    If action_req = "del" Then
        conn.Execute "DELETE FROM tblvideo WHERE idvideo=" & id_video
    ElseIf action_req = "up" Or action_req = "down" Then
        Set rsCur = conn.Execute("SELECT ISNULL(thutu, 0) AS thutu FROM tblvideo WHERE idvideo=" & id_video)
        If Not rsCur.EOF Then
            curOrder = ValInt(rsCur("thutu"))
            If action_req = "up" Then
                sqlTarget = "SELECT TOP 1 idvideo, ISNULL(thutu, 0) AS thutu FROM tblvideo WHERE ISNULL(thutu, 0) < " & curOrder & " ORDER BY ISNULL(thutu, 0) DESC"
            Else
                sqlTarget = "SELECT TOP 1 idvideo, ISNULL(thutu, 0) AS thutu FROM tblvideo WHERE ISNULL(thutu, 0) > " & curOrder & " ORDER BY ISNULL(thutu, 0) ASC"
            End If
            
            Set rsTarget = conn.Execute(sqlTarget)
            If Not rsTarget.EOF Then
                tarID = ValInt(rsTarget("idvideo"))
                tarOrder = ValInt(rsTarget("thutu"))
                conn.Execute "UPDATE tblvideo SET thutu=" & tarOrder & " WHERE idvideo=" & id_video
                conn.Execute "UPDATE tblvideo SET thutu=" & curOrder & " WHERE idvideo=" & tarID
            End If
            rsTarget.Close : Set rsTarget = Nothing
        End If
        rsCur.Close : Set rsCur = Nothing
    End If
    destroyconn
    Response.Write "<script>window.location.href = window.location.pathname;</script>"
    Response.End
End If

' ====================================================
' 3. LẤY DỮ LIỆU ĐỂ HIỂN THỊ FORM SỬA (NẾU CÓ)
' ====================================================
Dim val_tieude, val_lienket, val_thutu, form_title, btn_text, btn_icon, edit_id_val
val_tieude = "" : val_lienket = "" : val_thutu = "0" : edit_id_val = ""
form_title = "THÊM VIDEO MỚI"
btn_text = "THÊM MỚI"
btn_icon = "fa-plus-circle"

Dim qEdit
qEdit = GetSafeInt("edit", 0)
If qEdit > 0 Then
    openconn
    Set rsEdit = conn.Execute("SELECT * FROM tblvideo WHERE idvideo=" & qEdit)
    If Not rsEdit.EOF Then
        val_tieude = rsEdit("tieude") & ""
        val_lienket = rsEdit("lienket") & ""
        val_thutu = ValInt(rsEdit("thutu"))
        edit_id_val = qEdit
        form_title = "CẬP NHẬT VIDEO"
        btn_text = "LƯU THAY ĐỔI"
        btn_icon = "fa-save"
    End If
    rsEdit.Close : Set rsEdit = Nothing
    destroyconn
End If
%>

<style>
    body, html, input, select, textarea, button {
        font-family: <%=currentFont%> !important;
        font-size: <%=currentFontSize%> !important;
    }
.row-grid { display: flex; flex-wrap: wrap; gap: 15px; margin-bottom: 15px; }
.col-flex { flex: 1; min-width: 200px; display: flex; flex-direction: column; }

.form-label { font-weight: 600; margin-bottom: 6px; color: #475569; font-size: 0.9em; }
.form-input { padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 4px; color: #334155; transition: 0.2s; font-family: inherit; font-size: 1em; box-sizing: border-box; }
.form-input:focus { border-color: #e11d48; outline: none; box-shadow: 0 0 0 3px rgba(225,29,72,0.1); }

.btn-primary { background: #e11d48; color: #fff; border: none; padding: 10px 24px; border-radius: 4px; font-weight: bold; cursor: pointer; transition: 0.2s; }
.btn-primary:hover { background: #be123c; }
.btn-secondary { background: #64748b; color: #fff; border: none; padding: 10px 15px; border-radius: 4px; font-weight: bold; text-decoration: none; display: inline-block; }
.btn-secondary:hover { background: #475569; }

.table-modern { width: 100%; border-collapse: collapse; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-modern th { background: #f1f5f9; color: #0f172a; font-weight: bold; padding: 12px; text-align: left; border-bottom: 2px solid #cbd5e1; text-transform: uppercase; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-modern td { padding: 10px 12px; border-bottom: 1px solid #e2e8f0; vertical-align: middle; color: #334155; font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important;}
.table-modern tr:hover { background-color: #f8fafc; }

.video-thumb { width: 120px; height: 68px; object-fit: cover; border-radius: 4px; border: 1px solid #cbd5e1; position: relative; display: block; }
.video-thumb::after { content: '\f01d'; font-family: 'FontAwesome'; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: rgba(255,255,255,0.8); font-size: 24px; pointer-events: none; }

.btn-move { display: inline-flex; align-items: center; justify-content: center; width: 24px; height: 24px; background: #f1f5f9; color: #475569; border-radius: 4px; text-decoration: none; margin: 0 2px; border: 1px solid #cbd5e1; transition: 0.2s; }
.btn-move:hover { background: #0a69db; color: #fff; border-color: #0a69db; }
.action-icon { font-size: 1.5em; margin: 0 5px; cursor: pointer; transition: 0.2s; color: #64748b; }
.action-icon:hover { color: #0a69db; transform: scale(1.15); }
.action-delete:hover { color: #dc2626; }
</style>

<script>
function check_input() {
    var frm = document.frmVideo;
    if (frm.tieude.value === "") { alert("Vui lòng nhập tên video!"); frm.tieude.focus(); return false; }
    if (frm.lienket.value === "") { alert("Vui lòng nhập ID Video Youtube!"); frm.lienket.focus(); return false; }
    return true;        
}
function del_one(id) {
    if (confirm("Bạn có chắc chắn muốn xóa video này không?")) {
        document.location.href = "?action=del&id=" + id;
    }
}
</script>

<!-- KHỐI 1: FORM THÊM / CẬP NHẬT -->
<div class="admin-card" style="border-top: 3px solid #e11d48;">
    <div class="admin-card-header"><i class="fa fa-youtube-play"></i> <%=form_title%></div>
    <div class="admin-card-body">
        <form name="frmVideo" method="post" action="" onSubmit="return check_input();" style="margin:0;">
            <input type="hidden" name="action_submit" value="save">
            <input type="hidden" name="edit_id" value="<%=edit_id_val%>">
            
            <div class="row-grid">
                <div class="col-flex" style="flex: 2;">
                    <label class="form-label">Tên video <span style="color:red">*</span></label>
                    <input name="tieude" type="text" class="form-input" value="<%=val_tieude%>" placeholder="Nhập tiêu đề hiển thị...">
                </div>
                <div class="col-flex">
                    <label class="form-label">ID hoặc Link Youtube <span style="color:red">*</span></label>
                    <input name="lienket" type="text" class="form-input" value="<%=val_lienket%>" placeholder="Ví dụ: dQw4w9WgXcQ">
                </div>
                <div class="col-flex" style="flex: 0.5;">
                    <label class="form-label">Thứ tự</label>
                    <input name="thutu" type="number" class="form-input" value="<%=val_thutu%>">
                </div>
            </div>
            <div style="margin-top: 10px;">
                <button type="submit" class="btn-primary"><i class="fa <%=btn_icon%>"></i> <%=btn_text%></button>
                <% If qEdit > 0 Then %>
                    <a href="/gpdh/thu-vien-video/" class="btn-secondary" style="margin-left: 10px;">Hủy bỏ</a>
                <% End If %>
            </div>
        </form>
    </div>
</div>

<!-- KHỐI 2: DANH SÁCH VIDEO -->
<div class="admin-card">
    <div class="admin-card-header" style="color: #0f172a;"><i class="fa fa-list" style="color: #0f172a;"></i> DANH SÁCH VIDEO DÒNG HỌ</div>
    <div class="admin-card-body" style="padding: 0;">
        <div style="overflow-x: auto;">
            <table class="table-modern">
                <tr>
                    <th style="width: 140px; text-align:center;">HÌNH ẢNH</th>
                    <th>TÊN VIDEO</th>
                    <th style="width: 120px; text-align:center;">THỨ TỰ</th>
                    <th style="width: 120px; text-align:center;">QUẢN LÝ</th>
                </tr>
                <%  
                    openconn    
                    Set rs = Server.CreateObject("ADODB.Recordset")
                    rs.Open "SELECT * FROM tblvideo ORDER BY ISNULL(thutu, 0) ASC, idvideo DESC", conn, 3, 1
                    
                    If rs.EOF Then
                        Response.Write "<tr><td colspan='4' style='text-align:center; padding:30px; color:#64748b;'>Chưa có video nào được thêm.</td></tr>"
                    End If
                    
                    Do While Not rs.EOF
                        Dim ytID
                        ytID = rs("lienket") & ""
                        If InStr(ytID, "v=") > 0 Then ytID = Mid(ytID, InStr(ytID, "v=") + 2, 11)
                        If InStr(ytID, "youtu.be/") > 0 Then ytID = Mid(ytID, InStr(ytID, "youtu.be/") + 9, 11)
                %>
                <tr>
                    <td align="center">
                        <a href="https://www.youtube.com/watch?v=<%=ytID%>" target="_blank" class="video-thumb" style="background: url('https://img.youtube.com/vi/<%=ytID%>/hqdefault.jpg') center/cover;"></a>
                    </td>
                    <td><span style="font-size: 15px"><%= rs("tieude") %></span><br><span style="font-size: 15px; color: #64748b;"><i class="fa fa-link"></i> ID: <%= rs("lienket") %></span></td>
                    <td align="center">
                        <span style="display:inline-block; width:20px; font-size: 14px"><%=rs("thutu")%></span>
                        <a href="?action=up&id=<%=rs("idvideo")%>" class="btn-move" title="Lên"><i class="fa fa-arrow-up"></i></a>
                        <a href="?action=down&id=<%=rs("idvideo")%>" class="btn-move" title="Xuống"><i class="fa fa-arrow-down"></i></a>
                    </td>
                    <td align="center">
                        <a href="?edit=<%=rs("idvideo")%>" title="Sửa video"><i class="fa fa-pencil-square-o action-icon" style="color: #f59e0b;"></i></a>
                        <i class="fa fa-trash-o action-icon action-delete" title="Xóa video" onClick="del_one('<%= rs("idvideo") %>');"></i>
                    </td>
                </tr>
                <%  
                        rs.MoveNext
                    Loop
                    rs.Close : Set rs = Nothing
                    destroyconn
                %>
            </table>    
        </div>
    </div>
</div>