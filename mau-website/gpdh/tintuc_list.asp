<%
' ====================================================
' 0. KIỂM TRA QUYỀN TRUY CẬP TRANG QUẢN LÝ NHÓM TIN
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

' Kiểm tra phân quyền: Yêu cầu quyền Quản trị tối cao hoặc Quản lý nội dung
If CInt("0" & Session("is_super")) = 0 And CInt("0" & Session("is_content")) = 0 Then
%>
<script language="javascript">
    alert("Bạn không có quyền truy cập vào chức năng Quản lý Nhóm tin!");
    window.location.href = "/gpdh/bang-dieu-khien/";
</script>
<% 
    Response.End
End If
%>
<% 

' ====================================================
' 1. XỬ LÝ SẮP XẾP THỨ TỰ VÀ XÓA TIN (AN TOÀN TUYỆT ĐỐI)
' ====================================================
Dim action_news, id_news, rsMax, maxOrderVal, rsCurrentOrder, currentOrderVal, rsTarget, targetID, targetOrderVal
action_news = Request.QueryString("action")
id_news = Request.QueryString("id")

If action_news <> "" Then
    openconn
    
    If action_news = "del_one" And IsNumeric(Request.QueryString("nid")) Then
        conn.execute("DELETE FROM tbltintuc WHERE idtintuc=" & CInt(Request.QueryString("nid")))
        
    ElseIf action_news = "delall" Then
        Dim narr, arrIDs, safeIDs, i
        narr = Request("chkID")
        If narr <> "" Then
            ' Làm sạch mảng ID để chống SQL Injection
            arrIDs = Split(narr, ",")
            safeIDs = ""
            For i = 0 To UBound(arrIDs)
                If IsNumeric(Trim(arrIDs(i))) Then
                    safeIDs = safeIDs & Trim(arrIDs(i)) & ","
                End If
            Next
            
            If Len(safeIDs) > 0 Then
                safeIDs = Left(safeIDs, Len(safeIDs) - 1)
                conn.execute("DELETE FROM tbltintuc WHERE idtintuc IN (" & safeIDs & ")")
            End If
        End If
        
    ElseIf IsNumeric(id_news) Then
        id_news = CInt(id_news)
        
        If action_news = "top" Then
            Set rsMax = conn.Execute("SELECT MIN(thutu) FROM tbltintuc")
            If Not rsMax.EOF Then 
                If IsNull(rsMax(0)) Then maxOrderVal = 1 Else maxOrderVal = CInt(rsMax(0)) - 1
            Else
                maxOrderVal = 1
            End If
            rsMax.Close : Set rsMax = Nothing
            conn.execute("UPDATE tbltintuc SET thutu=" & maxOrderVal & " WHERE idtintuc=" & id_news)
            
        ElseIf action_news = "up" Then
            Set rsCurrentOrder = conn.Execute("SELECT thutu FROM tbltintuc WHERE idtintuc=" & id_news)
            If Not rsCurrentOrder.EOF Then
                currentOrderVal = CInt("0" & rsCurrentOrder("thutu"))
                Set rsTarget = conn.Execute("SELECT TOP 1 idtintuc, thutu FROM tbltintuc WHERE thutu < " & currentOrderVal & " ORDER BY thutu DESC")
                If Not rsTarget.EOF Then
                    targetID = CInt(rsTarget("idtintuc"))
                    targetOrderVal = CInt(rsTarget("thutu"))
                    conn.execute("UPDATE tbltintuc SET thutu=" & targetOrderVal & " WHERE idtintuc=" & id_news)
                    conn.execute("UPDATE tbltintuc SET thutu=" & currentOrderVal & " WHERE idtintuc=" & targetID)
                End If
                rsTarget.Close : Set rsTarget = Nothing
            End If
            rsCurrentOrder.Close : Set rsCurrentOrder = Nothing
            
        ElseIf action_news = "down" Then
            Set rsCurrentOrder = conn.Execute("SELECT thutu FROM tbltintuc WHERE idtintuc=" & id_news)
            If Not rsCurrentOrder.EOF Then
                currentOrderVal = CInt("0" & rsCurrentOrder("thutu"))
                Set rsTarget = conn.Execute("SELECT TOP 1 idtintuc, thutu FROM tbltintuc WHERE thutu > " & currentOrderVal & " ORDER BY thutu ASC")
                If Not rsTarget.EOF Then
                    targetID = CInt(rsTarget("idtintuc"))
                    targetOrderVal = CInt(rsTarget("thutu"))
                    conn.execute("UPDATE tbltintuc SET thutu=" & targetOrderVal & " WHERE idtintuc=" & id_news)
                    conn.execute("UPDATE tbltintuc SET thutu=" & currentOrderVal & " WHERE idtintuc=" & targetID)
                End If
                rsTarget.Close : Set rsTarget = Nothing
            End If
            rsCurrentOrder.Close : Set rsCurrentOrder = Nothing
        End If
    End If
    
    destroyconn
    ' Xử lý chuyển hướng bằng JS thay vì Response.Redirect để làm sạch URL
    Response.Write "<script>window.location.href = window.location.pathname;</script>"
    Response.End
End If
%>

<style>
    body, html, input, select, textarea, button { font-family: <%=currentFont%> !important; font-size: <%=currentFontSize%> !important; }
    h1 { font-size: calc(<%=currentFontSize%> * 1.8); }
    h2 { font-size: calc(<%=currentFontSize%> * 1.5); }
    h3 { font-size: calc(<%=currentFontSize%> * 1.25); }

.admin-card { background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 25px; border: 1px solid #e2e8f0; overflow: hidden; }
.admin-card-header { background: #f8fafc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0; font-weight: bold; color: #0f172a; font-size: 15px; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
.admin-card-header i { color: #0a69db; font-size: 18px; }
.admin-card-body { padding: 20px; }

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
.btn-secondary { background: #64748b; color: #fff; border: none; padding: 5px 10px; border-radius: 4px; text-decoration: none; display: inline-block; transition: 0.2s; }
.btn-secondary:hover { background: #475569; }
.badge-category { background: #e0f2fe; color: #0284c7; padding: 3px 8px; border-radius: 12px; font-size: 12px; font-weight: 600; }
</style>

<script>
function del_one(nid) {
  if (confirm("Bạn có chắc chắn muốn xóa tin tức này không?")) {
    document.location.href="?action=del_one&nid=" + nid;
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
        if (confirm ("Bạn có chắc chắn muốn xóa các tin đã chọn không?")) {
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
            if (confirm ("Bạn có chắc chắn muốn xóa " + ic + " tin đã chọn không?")) {
                document.frmNews.action = "?action=delall";
                document.frmNews.submit();
            }
        } else {
            alert("Vui lòng chọn ít nhất một tin để xóa!");
        }
    }
}
</script>

<div class="admin-card">
    <div class="admin-card-header"><i class="fa fa-newspaper-o"></i> QUẢN LÝ TIN TỨC & SỰ KIỆN</div>
    <div class="admin-card-body">
        
        <div style="margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
            <a href="/gpdh/them-tin-moi/" class="btn-primary"><i class="fa fa-plus-circle"></i> Thêm tin mới</a>
            <button type="button" onclick="delAll()" style="background:#dc2626; color:#fff; border:none; padding:10px 15px; border-radius:4px; cursor:pointer; font-weight:bold;"><i class="fa fa-trash"></i> Xóa mục đã chọn</button>
        </div>

        <!-- KIỂM TRA NHÓM TIN ĐỂ ẨN/HIỆN CỘT -->
        <%
        openconn
        Set rsCheckCat = conn.Execute("SELECT TOP 1 idnhomtin FROM tblnhomtin")
        If Not rsCheckCat.EOF Then
            hasCategory = True
        Else
            hasCategory = False
        End If
        rsCheckCat.Close : Set rsCheckCat = Nothing
        %>

        <form name="frmNews" method="post">
        <div style="overflow-x: auto;">
            <table class="table-modern">
              <tr>
                <th style="width: 40px; text-align:center;"><input type="checkbox" name="chkAll" onclick="checkAll()"></th>
                <th>TIÊU ĐỀ</th>
                <% If hasCategory Then %>
                    <th style="width: 180px;">NHÓM TIN</th>
                <% End If %>
                <th style="width: 140px; text-align:center;">SẮP XẾP</th>
                <th style="width: 100px; text-align:center;">QUẢN LÝ</th>
              </tr>
              <%    
                     Set rsListNews = Server.CreateObject("ADODB.Recordset")
                     Dim sqlList
                     
                     ' Tối ưu SQL: Tùy biến truy vấn dựa vào việc có nhóm tin hay không
                     If hasCategory Then
                         sqlList = "SELECT t.*, ISNULL(n.tieude, N'Chưa phân loại') AS tennhom FROM tbltintuc t LEFT JOIN tblnhomtin n ON t.idnhomtin = n.idnhomtin ORDER BY t.thutu ASC, t.idtintuc DESC"
                     Else
                         sqlList = "SELECT * FROM tbltintuc ORDER BY thutu ASC, idtintuc DESC"
                     End If
                     
                     rsListNews.open sqlList, conn, 3, 1
                     
                     Dim intCurrentPage
                     If Request.QueryString("page") = "" Then
                         intCurrentPage = 1
                     Else
                         intCurrentPage = CInt(Request.QueryString("page"))
                     End If
                     
                     rsListNews.PageSize = 20
                     If rsListNews.PageCount > 0 then rsListNews.AbsolutePage = intCurrentPage
                     
                     Dim jCount
                     jCount = 1
                     Do While Not rsListNews.EOF
              %>
              <tr>
                <td align="center"><input type="checkbox" name="chkID" value="<%= rsListNews("idtintuc") %>" onclick="checkOne()"></td>
                <td>
                    <strong style="color: #0f172a;"><%= rsListNews("tieude") %></strong>
                    <% If CInt("0" & rsListNews("top1")) = 1 Then %>
                        <span style="background:#fef08a; color:#854d0e; font-size:11px; padding:2px 6px; border-radius:3px; margin-left:8px; font-weight:bold;"><i class="fa fa-star"></i> Nổi bật</span>
                    <% End If %>
                </td>
                
                <% If hasCategory Then %>
                    <td><span class="badge-category"><%= rsListNews("tennhom") %></span></td>
                <% End If %>

                <td align="center">
                    <div class="order-actions">
                        <a href="?action=top&id=<%= rsListNews("idtintuc") %>" title="Đưa lên trên cùng" class="btn-move"><i class="fa fa-angle-double-up"></i></a>
                        <a href="?action=up&id=<%= rsListNews("idtintuc") %>" title="Lên 1 hàng" class="btn-move"><i class="fa fa-angle-up"></i></a>
                        <a href="?action=down&id=<%= rsListNews("idtintuc") %>" title="Xuống 1 hàng" class="btn-move"><i class="fa fa-angle-down"></i></a>
                    </div>
                </td>
                <td align="center">
                    <a href="/gpdh/sua-tin/?id=<%= rsListNews("idtintuc") %>" title="Sửa thông tin"><i class="fa fa-pencil-square-o action-icon"></i></a>
                    <i class="fa fa-trash-o action-icon action-delete" title="Xóa" onClick="del_one('<%= rsListNews("idtintuc") %>');"></i>
                </td>
              </tr>
              <% 
                     If jCount = rsListNews.PageSize Then Exit Do
                     jCount = jCount + 1                   
                     rsListNews.MoveNext
                 Loop
                 rsListNews.Close : Set rsListNews = Nothing
              %>
            </table>    
        </div>

        <!-- PHÂN TRANG -->
        <div style="margin-top: 20px; text-align: center; font-size: 14px;">
            <%
                Set rsPageCheck = conn.Execute("SELECT COUNT(*) FROM tbltintuc")
                Dim totalRecCount, totalPageCount
                totalRecCount = CInt("0" & rsPageCheck(0))
                rsPageCheck.Close : Set rsPageCheck = Nothing
                destroyconn
                
                totalPageCount = Int(totalRecCount / 20)
                If (totalRecCount Mod 20) > 0 Then totalPageCount = totalPageCount + 1
                
                If totalPageCount > 1 Then
                    If intCurrentPage <> 1 Then
                        Response.Write "<a href='?page=" & (intCurrentPage - 1) & "' class='btn-secondary'>Trang trước</a> "
                    End If
                    
                    Response.Write "<span style='margin:0 15px; display: inline-block; padding: 5px 12px; background: #f1f5f9; border-radius: 4px; font-weight: 600; color: #334155;'>Trang " & intCurrentPage & " / " & totalPageCount & "</span>"
                    
                    If intCurrentPage <> totalPageCount Then
                        Response.Write " <a href='?page=" & (intCurrentPage + 1) & "' class='btn-secondary'>Trang sau</a>"
                    End If
                End If
            %>
        </div>
        </form>
    </div>
</div>