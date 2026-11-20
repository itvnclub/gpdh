<%
    Dim conn
    
    Sub openConn()
        ' Thiết lập bảng mã để tránh lỗi tiếng Việt khi truy vấn
        Session.CodePage = 65001 
        Set conn = Server.CreateObject("ADODB.Connection")
        connstr = "provider=SQLOLEDB;Database=hobuixuanbang;server=localhost;uid=hobuixuanbang;pwd=S#d4F%g6h&J$"
        conn.Open connstr
    End Sub

    Sub destroyconn()
        ' Kiểm tra xem biến conn có phải là đối tượng hay không
        If IsObject(conn) Then
            ' Nếu kết nối đang mở (State = 1) thì mới thực hiện đóng
            If conn.State = 1 Then 
                conn.Close
            End If
            Set conn = Nothing
        End If
    End Sub
%>