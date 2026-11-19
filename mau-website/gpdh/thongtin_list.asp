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
    alert("Bạn không có quyền truy cập vào chức năng Quản lý Thông tin dòng họ!");
    window.location.href = "/gpdh/bang-dieu-khien/";
</script>
<% 
    Response.End
End If

' Hàm chuyển đổi số nguyên an toàn, chống lỗi Null và Type mismatch tuyệt đối
Function ValInt(v)
    If IsNull(v) Or Trim(v & "") = "" Then
        ValInt = 0
    ElseIf IsNumeric(v) Then
        ValInt = CInt(v)
    Else
        ValInt = 0
    End If
End Function

' Hàm an toàn lấy QueryString/Form khi IIS URL Rewrite gộp tham số (vd: id=8,8)
Function GetSafeInt(paramName, defaultVal)
    Dim val
    val = Request.QueryString(paramName)
    If val = "" Then val = Request.Form(paramName)
    If val = "" Then
        GetSafeInt = defaultVal
        Exit Function
    End If
    If InStr(val, ",") > 0 Then
        Dim arr
        arr = Split(val, ",")
        val = Trim(arr(0))
    End If
    GetSafeInt = ValInt(val)
End Function

' ====================================================
' 1. XỬ LÝ SẮP XẾP THỨ TỰ VÀ XÓA (AN TOÀN TUYỆT ĐỐI)
' ====================================================
action_News = Trim(Request.QueryString("action"))
id_News = GetSafeInt("id", 0)

If action_News <> "" Then
    openconn
    
    If action_News = "del_one" Then
        Dim nid_del
        nid_del = GetSafeInt("nid", 0)
        If nid_del > 0 Then
            conn.execute("DELETE FROM tblthongtin WHERE idthongtin=" & nid_del)
        End If
        destroyconn
        Response.Write "<script>window.location.href = window.location.pathname;</script>"
        Response.End
        
    ElseIf action_News = "delall" Then
        narr = Request("chkID")
        If narr <> "" Then
            arrIDs = Split(narr, ",")
            safeIDs = ""
            For ii = 0 To UBound(arrIDs)
                If IsNumeric(Trim(arrIDs(ii))) Then
                    safeIDs = safeIDs & CInt(Trim(arrIDs(ii))) & ","
                End If
            Next
            If Len(safeIDs) > 0 Then
                safeIDs = Left(safeIDs, Len(safeIDs) - 1)
                conn.execute("DELETE FROM tblthongtin WHERE idthongtin IN (" & safeIDs & ")")
            End If
        End If
        destroyconn
        Response.Write "<script>window.location.href = window.location.pathname;</script>"
        Response.End
        
    ElseIf id_News > 0 Then
        If action_News = "top" Then
            Set rsMax = conn.Execute("SELECT MIN(thutu) FROM tblthongtin")
            If Not rsMax.EOF Then 
                If IsNull(rsMax(0)) Then 
                    maxOrderVal = 1 
                Else 
                    maxOrderVal = ValInt(rsMax(0)) - 1
                End If
            Else
                maxOrderVal = 1
            End If
            rsMax.Close : Set rsMax = Nothing
            conn.execute("UPDATE tblthongtin SET thutu=" & maxOrderVal & " WHERE idthongtin=" & id_News)
            
        ElseIf action_News = "up" Then
            Set rsCurrentOrder = conn.Execute("SELECT thutu FROM tblthongtin WHERE idthongtin=" & id_News)
            If Not rsCurrentOrder.EOF Then
                currentOrderVal = ValInt(rsCurrentOrder("thutu"))
                rsCurrentOrder.Close : Set rsCurrentOrder = Nothing
                
                Set rsTarget = conn.Execute("SELECT TOP 1 idthongtin, thutu FROM tblthongtin WHERE thutu < " & currentOrderVal & " ORDER BY thutu DESC")
                If Not rsTarget.EOF Then
                    targetID = ValInt(rsTarget("idthongtin"))
                    targetOrderVal = ValInt(rsTarget("thutu"))
                    rsTarget.Close : Set rsTarget = Nothing
                    
                    conn.execute("UPDATE tblthongtin SET thutu=" & targetOrderVal & " WHERE idthongtin=" & id_News)
                    conn.execute("UPDATE tblthongtin SET thutu=" & currentOrderVal & " WHERE idthongtin=" & targetID)
                End If
            End If
            
        ElseIf action_News = "down" Then
            Set rsCurrentOrder = conn.Execute("SELECT thutu FROM tblthongtin WHERE idthongtin=" & id_News)
            If Not rsCurrentOrder.EOF Then
                currentOrderVal = ValInt(rsCurrentOrder("thutu"))
                rsCurrentOrder.Close : Set rsCurrentOrder = Nothing
                
                Set rsTarget = conn.Execute("SELECT TOP 1 idthongtin, thutu FROM tblthongtin WHERE thutu > " & currentOrderVal & " ORDER BY thutu ASC")
                If Not rsTarget.EOF Then
                    targetID = ValInt(rsTarget("idthongtin"))
                    targetOrderVal = ValInt(rsTarget("thutu"))
                    rsTarget.Close : Set rsTarget = Nothing
                    
                    conn.execute("UPDATE tblthongtin SET thutu=" & targetOrderVal & " WHERE idthongtin=" & id_News)
                    conn.execute("UPDATE tblthongtin SET thutu=" & currentOrderVal & " WHERE idthongtin=" & targetID)
                End If
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
    h1 { font-size: calc(<%=currentFontSize%> * 1.8); }
    h2 { font-size: calc(<%=currentFontSize%> * 1.5); }
    h3 { font-size: calc(<%=currentFontSize%> * 1.25); }

.table-modern { width: 100%; border-collapse: collapse; font-size: 14px; font-family: <%=currentFont%> !important;}
.table-modern th { background: #f1f5f9; color: #334155; font-weight: bold; padding: 12px; text-align: left; border-bottom: 2px solid #cbd5e1; font-family: <%=currentFont%> !important;}
.table-modern td { padding: 12px; border-bottom: 1px solid #e2e8f0; vertical-align: middle; color: #475569; font-size: 14px; font-family: <%=currentFont%> !important;}
.table-modern tr:hover { background-color: #f8fafc; }

.order-actions { display: flex; align-items: center; justify-content: center; gap: 4px; }
.btn-move { display: inline-flex; align-items: center; justify-content: center; width: 28px; height: 28px; background: #e2e8f0; color: #475569; border-radius: 4px; font-size: 13px; text-decoration: none; transition: 0.2s; }
.btn-move:hover { background: #0a69db; color: #fff; }

.action-icon { color: #64748b; font-size: 18px; margin: 0 5px; cursor: pointer; transition: 0.2s; }
.action-icon:hover { color: #0a69db; transform: scale(1.1); }
.action-delete:hover { color: #dc3545; }

.btn-primary { background: #0a69db; color: #fff; border: none; padding: 10px 20px; border-radius: 4px; font-size: 14px; font-weight: bold; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; transition: 0.2s; }
.btn-primary:hover { background: #0056b3; }
.btn-secondary { background: #64748b; color: #fff; border: none; padding: 5px 10px; border-radius: 4px; text-decoration: none; display: inline-block; }
.btn-secondary:hover { background: #475569; }
</style>

<script>
function del_one(nid) {
  if (confirm("Bạn có chắc chắn muốn xóa thông tin này không?")) {
    document.location.href = "?action=del_one&nid=" + nid;
  }
}
function checkAll() {
    var state = document.frmNews.chkAll.checked;
    var chks = document.frmNews.elements['chkID'];
    if(chks) {
        if(chks.length) {
            for (var i = 0; i < chks.length; i++) { chks[i].checked = state; }
        } else {
            chks.checked = state;
        }
    }
}
function checkOne() {
    document.frmNews.chkAll.checked = false;
}
function delAll() {
    var ic = 0;
    var chks = document.frmNews.elements['chkID'];
    if (document.frmNews.chkAll.checked == true) {
        if (confirm ("Bạn có chắc chắn muốn xóa các mục đã chọn không?")) {
            document.frmNews.action = "?action=delall";
            document.frmNews.submit();
        }
    } else if(chks) {
        if(chks.length) {
            for (var i = 0; i < chks.length; i++) {
                if (chks[i].checked == true) { ic++; }
            }
        } else if(chks.checked) {
            ic++;
        }
        
        if (ic > 0) {
            if (confirm ("Bạn có chắc chắn muốn xóa " + ic + " mục đã chọn không?")) {
                document.frmNews.action = "?action=delall";
                document.frmNews.submit();
            }
        } else {
            alert("Vui lòng chọn ít nhất một mục để xóa!");
        }
    }
}
</script>

<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-book"></i> QUẢN LÝ THÔNG TIN DÒNG HỌ</div>
    <div class="admin-card-body">
        
        <div style="margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
            <a href="/gpdh/them-thong-tin-dong-ho/" class="btn-primary"><i class="fa fa-plus-circle"></i> Thêm thông tin</a>
            <button type="button" onclick="delAll()" style="background:#dc2626; color:#fff; border:none; padding:10px 15px; border-radius:4px; cursor:pointer; font-weight:bold;"><i class="fa fa-trash"></i> Xóa mục đã chọn</button>
        </div>

        <form name="frmNews" method="post" action="">
        <div style="overflow-x: auto;">
            <table class="table-modern">
              <tr>
                <th style="width: 40px; text-align:center;"><input type="checkbox" name="chkAll" onclick="checkAll()"></th>
                <th>TIÊU ĐỀ</th>
                <th style="width: 140px; text-align:center;">SẮP XẾP</th>
                <th style="width: 100px; text-align:center;">QUẢN LÝ</th>
              </tr>
              <%    
                     openconn   
                     Set rsListNews = Server.CreateObject("ADODB.Recordset")
                     rsListNews.open "SELECT * FROM tblthongtin ORDER BY thutu ASC, idthongtin DESC", conn, 3, 1
                     
                     If Request.QueryString("page") = "" Then
                         intCurrentPage = 1
                     Else
                         intCurrentPage = GetSafeInt("page", 1)
                     End If
                     rsListNews.PageSize = 20
                     If rsListNews.PageCount > 0 then rsListNews.AbsolutePage = intCurrentPage
                     
                     jCount = 1
                     Do While Not rsListNews.EOF
              %>
              <tr>
                <td align="center"><input type="checkbox" name="chkID" value="<%= rsListNews("idthongtin") %>" onclick="checkOne()"></td>
                <td><%= rsListNews("tieude") %></td>
                <td align="center">
                    <div class="order-actions">
                        <a href="?action=top&id=<%= rsListNews("idthongtin") %>" title="Đưa lên trên cùng" class="btn-move"><i class="fa fa-angle-double-up"></i></a>
                        <a href="?action=up&id=<%= rsListNews("idthongtin") %>" title="Lên 1 hàng" class="btn-move"><i class="fa fa-angle-up"></i></a>
                        <a href="?action=down&id=<%= rsListNews("idthongtin") %>" title="Xuống 1 hàng" class="btn-move"><i class="fa fa-angle-down"></i></a>
                    </div>
                </td>
                <td align="center">
                    <a href="/gpdh/sua-thong-tin-dong-ho/?id=<%= rsListNews("idthongtin") %>" title="Sửa thông tin"><i class="fa fa-pencil-square-o action-icon"></i></a>
                    <i class="fa fa-trash-o action-icon action-delete" title="Xóa" onClick="del_one('<%= rsListNews("idthongtin") %>');"></i>
                </td>
              </tr>
              <% 
                     If jCount = rsListNews.PageSize Then Exit Do
                     jCount = jCount + 1                   
                     rsListNews.MoveNext
                  Loop
                  rsListNews.Close : Set rsListNews = Nothing
                  destroyconn
              %>
            </table>    
        </div>

        <!-- PHÂN TRANG -->
        <div style="margin-top: 20px; text-align: center; font-size: 14px;">
            <%
                openconn
                Set rsPageCheck = conn.Execute("SELECT COUNT(*) FROM tblthongtin")
                totalRecCount = ValInt(rsPageCheck(0))
                rsPageCheck.Close : Set rsPageCheck = Nothing
                destroyconn
                
                totalPageCount = Int(totalRecCount / 20)
                If (totalRecCount Mod 20) > 0 Then totalPageCount = totalPageCount + 1
                
                If totalPageCount > 1 Then
                    If intCurrentPage <> 1 Then
                        Response.Write "<a href='?page=" & (intCurrentPage - 1) & "' class='btn-secondary'>Trang trước</a> "
                    End If
                    
                    Response.Write "<b style='margin:0 10px;'>Trang " & intCurrentPage & " / " & totalPageCount & "</b>"
                    
                    If intCurrentPage <> totalPageCount Then
                        Response.Write " <a href='?page=" & (intCurrentPage + 1) & "' class='btn-secondary'>Trang sau</a>"
                    End If
                End If
            %>
        </div>
        </form>
    </div>
</div>