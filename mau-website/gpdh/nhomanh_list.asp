<%session.CodePage=65001%>
<%
' ====================================================
' 0. KIỂM TRA QUYỀN TRUY CẬP TRANG
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
    alert("Bạn không có quyền truy cập vào chức năng Quản lý Thư viện ảnh!");
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

Function GetImgUrl(ByVal rawPath)
    rawPath = Trim(rawPath & "")
    If rawPath = "" Then GetImgUrl = "" : Exit Function
    If Left(LCase(rawPath), 4) = "http" Then GetImgUrl = rawPath : Exit Function
    rawPath = Replace(rawPath, "\", "/")
    Dim arrP, fileName
    If InStr(rawPath, "/") > 0 Then
        arrP = Split(rawPath, "/")
        fileName = arrP(UBound(arrP))
    Else
        fileName = rawPath
    End If
    GetImgUrl = "/images/hinhanh/" & fileName
End Function

' ====================================================
' XỬ LÝ SẮP XẾP THỨ TỰ VÀ XÓA NHÓM ẢNH
' ====================================================
action_nhom = Trim(Request.QueryString("action"))
id_nhom = GetSafeInt("id", 0)

If action_nhom <> "" And id_nhom > 0 Then
    openconn
    
    If action_nhom = "del_one" Then
        conn.execute("DELETE FROM tblanh WHERE idnhomanh=" & id_nhom)
        conn.execute("DELETE FROM tblnhomanh WHERE idnhomanh=" & id_nhom)
        destroyconn
        Response.Write "<script>window.location.href = window.location.pathname;</script>"
        Response.End
        
    ElseIf action_nhom = "top" Then
        Set rsMax = conn.Execute("SELECT MIN(ISNULL(thutu, 0)) FROM tblnhomanh")
        If Not rsMax.EOF Then 
            If IsNull(rsMax(0)) Then maxOrderVal = 1 Else maxOrderVal = ValInt(rsMax(0)) - 1
        Else 
            maxOrderVal = 1 
        End If
        rsMax.Close : Set rsMax = Nothing
        conn.execute("UPDATE tblnhomanh SET thutu=" & maxOrderVal & " WHERE idnhomanh=" & id_nhom)
        destroyconn
        Response.Write "<script>window.location.href = window.location.pathname;</script>"
        Response.End
        
    ElseIf action_nhom = "up" Then
        Set rsCurrentOrder = conn.Execute("SELECT ISNULL(thutu, 0) AS thutu FROM tblnhomanh WHERE idnhomanh=" & id_nhom)
        If Not rsCurrentOrder.EOF Then
            currentOrderVal = ValInt(rsCurrentOrder("thutu"))
            rsCurrentOrder.Close : Set rsCurrentOrder = Nothing
            
            Set rsTarget = conn.Execute("SELECT TOP 1 idnhomanh, ISNULL(thutu, 0) AS thutu FROM tblnhomanh WHERE ISNULL(thutu, 0) < " & currentOrderVal & " ORDER BY ISNULL(thutu, 0) DESC")
            If Not rsTarget.EOF Then
                targetID = ValInt(rsTarget("idnhomanh"))
                targetOrderVal = ValInt(rsTarget("thutu"))
                rsTarget.Close : Set rsTarget = Nothing
                
                conn.execute("UPDATE tblnhomanh SET thutu=" & targetOrderVal & " WHERE idnhomanh=" & id_nhom)
                conn.execute("UPDATE tblnhomanh SET thutu=" & currentOrderVal & " WHERE idnhomanh=" & targetID)
            End If
        End If
        destroyconn
        Response.Write "<script>window.location.href = window.location.pathname;</script>"
        Response.End
        
    ElseIf action_nhom = "down" Then
        Set rsCurrentOrder = conn.Execute("SELECT ISNULL(thutu, 0) AS thutu FROM tblnhomanh WHERE idnhomanh=" & id_nhom)
        If Not rsCurrentOrder.EOF Then
            currentOrderVal = ValInt(rsCurrentOrder("thutu"))
            rsCurrentOrder.Close : Set rsCurrentOrder = Nothing
            
            Set rsTarget = conn.Execute("SELECT TOP 1 idnhomanh, ISNULL(thutu, 0) AS thutu FROM tblnhomanh WHERE ISNULL(thutu, 0) > " & currentOrderVal & " ORDER BY ISNULL(thutu, 0) ASC")
            If Not rsTarget.EOF Then
                targetID = ValInt(rsTarget("idnhomanh"))
                targetOrderVal = ValInt(rsTarget("thutu"))
                rsTarget.Close : Set rsTarget = Nothing
                
                conn.execute("UPDATE tblnhomanh SET thutu=" & targetOrderVal & " WHERE idnhomanh=" & id_nhom)
                conn.execute("UPDATE tblnhomanh SET thutu=" & currentOrderVal & " WHERE idnhomanh=" & targetID)
            End If
        End If
        destroyconn
        Response.Write "<script>window.location.href = window.location.pathname;</script>"
        Response.End
    End If
    destroyconn
End If
%>

<style>
    body, html, input, select, textarea, button {
        font-family: <%=currentFont%> !important;
        font-size: <%=currentFontSize%> !important;
    }
.table-modern { width: 100%; border-collapse: collapse; font-size: 14px; }
.table-modern th { background: #f1f5f9; color: #334455; padding: 12px; text-align: left; border-bottom: 2px solid #cbd5e1; }
.table-modern td { padding: 12px; border-bottom: 1px solid #e2e8f0; vertical-align: middle; color: #475569; }
.table-modern tr:hover { background-color: #f8fafc; }

.img-thumbnail { width: 80px; height: 50px; object-fit: cover; border-radius: 4px; border: 1px solid #cbd5e1; }
.no-img { width: 80px; height: 50px; background: #e2e8f0; border-radius: 4px; display: flex; align-items: center; justify-content: center; color: #94a3b8; font-size: 11px; }

.order-actions { display: flex; align-items: center; justify-content: center; gap: 4px; }
.btn-move { display: inline-flex; align-items: center; justify-content: center; width: 28px; height: 28px; background: #e2e8f0; color: #475569; border-radius: 4px; font-size: 13px; text-decoration: none; transition: 0.2s; }
.btn-move:hover { background: #0a69db; color: #fff; }
.action-icon { color: #64748b; font-size: 18px; margin: 0 5px; cursor: pointer; transition: 0.2s; }
.action-icon:hover { color: #0a69db; transform: scale(1.1); }
.action-delete:hover { color: #dc3545; }
.btn-primary { background: #0a69db; color: #fff; border: none; padding: 10px 20px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; }
</style>

<script>
function del_one(nid) {
  if (confirm("Xóa nhóm ảnh này sẽ xóa toàn bộ hình ảnh bên trong. Bạn có chắc chắn không?")) {
    document.location.href = "?action=del_one&id=" + nid;
  }
}
</script>

<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-folder-open"></i> QUẢN LÝ THƯ VIỆN NHÓM ẢNH</div>
    <div class="admin-card-body">
        
        <div style="margin-bottom: 20px;">
            <a href="/gpdh/them-thu-vien-anh/" class="btn-primary"><i class="fa fa-plus-circle"></i> Thêm nhóm ảnh mới</a>
        </div>

        <div style="overflow-x: auto;">
            <table class="table-modern">
              <tr>
                <th style="width: 150px; text-align:center;">ẢNH ĐẠI DIỆN</th>
                <th>TÊN NHÓM ẢNH (SỰ KIỆN)</th>
                <th style="width: 120px; text-align:center;">SỐ LƯỢNG</th>
                <th style="width: 140px; text-align:center;">THỨ TỰ</th>
                <th style="width: 100px; text-align:center;">QUẢN LÝ</th>
              </tr>
              <%    
                     openconn   
                     Set rsList = Server.CreateObject("ADODB.Recordset")
                     rsList.open "SELECT n.*, (SELECT COUNT(idanh) FROM tblanh a WHERE a.idnhomanh = n.idnhomanh) AS so_anh, (SELECT TOP 1 hinhanh FROM tblanh a2 WHERE a2.idnhomanh = n.idnhomanh ORDER BY a2.thutu ASC, a2.idanh DESC) AS anh_dau FROM tblnhomanh n ORDER BY ISNULL(n.thutu, 0) ASC, n.idnhomanh DESC", conn, 3, 1
                     
                     Do While Not rsList.EOF
                        Dim rawCover, thumbUrl
                        rawCover = Trim(rsList("hinhanh") & "")
                        If rawCover = "" Then rawCover = Trim(rsList("anh_dau") & "")
                        thumbUrl = GetImgUrl(rawCover)
              %>
              <tr>
                <td align="center">
                    <% If thumbUrl <> "" Then %>
                        <img src="<%=thumbUrl%>" class="img-thumbnail">
                    <% Else %>
                        <div class="no-img">Chưa có ảnh</div>
                    <% End If %>
                </td>
                <td>
                    <span style="color:#0f172a; font-size:15px;"><%= rsList("tieude") %></span>
                </td>
                <td align="center"><span style="background:#e2e8f0; color:#475569; padding:4px 10px; border-radius:20px; font-weight:bold; font-size:12px;"><%= rsList("so_anh") %> ảnh</span></td>
                <td align="center">
                    <div class="order-actions">
                        <a href="?action=top&id=<%= rsList("idnhomanh") %>" title="Đưa lên trên cùng" class="btn-move"><i class="fa fa-angle-double-up"></i></a>
                        <a href="?action=up&id=<%= rsList("idnhomanh") %>" title="Lên 1 hàng" class="btn-move"><i class="fa fa-angle-up"></i></a>
                        <a href="?action=down&id=<%= rsList("idnhomanh") %>" title="Xuống 1 hàng" class="btn-move"><i class="fa fa-angle-down"></i></a>
                    </div>
                </td>
                <td align="center">
                    <a href="/gpdh/sua-thu-vien-anh/?id=<%= rsList("idnhomanh") %>" title="Quản lý ảnh & Sửa thông tin"><i class="fa fa-pencil-square-o action-icon" style="color:#f59e0b;"></i></a>
                    <i class="fa fa-trash-o action-icon action-delete" title="Xóa toàn bộ" onClick="del_one('<%= rsList("idnhomanh") %>');"></i>
                </td>
              </tr>
              <% 
                     rsList.MoveNext
                  Loop
                  rsList.Close : Set rsList = Nothing
                  destroyconn
              %>
            </table>    
        </div>
    </div>
</div>