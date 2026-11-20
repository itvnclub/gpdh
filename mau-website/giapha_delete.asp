<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="connection.asp"-->
<!--#include file="functions.asp"-->
<%
Response.ContentType = "application/json"
Response.Charset = "utf-8"
Response.CacheControl = "no-cache"

Function DeleteJsonEscape(ByVal rawValue)
    Dim escapedValue
    If IsNull(rawValue) Or IsEmpty(rawValue) Then
        escapedValue = ""
    Else
        escapedValue = CStr(rawValue)
    End If

    escapedValue = Replace(escapedValue, "\", "\\")
    escapedValue = Replace(escapedValue, Chr(34), "\" & Chr(34))
    escapedValue = Replace(escapedValue, vbCr, "\r")
    escapedValue = Replace(escapedValue, vbLf, "\n")
    escapedValue = Replace(escapedValue, vbTab, "\t")
    DeleteJsonEscape = escapedValue
End Function

Sub SendDeleteResponse(ByVal statusText, ByVal succeeded, ByVal message)
    Response.Status = statusText
    Response.Write "{""success"":" & LCase(CStr(succeeded)) & ",""message"":""" & DeleteJsonEscape(message) & """}"
End Sub

Dim deleteID, rsDeleteCheck, relatedCount, adminScopeCount, personCount
Dim transactionStarted, deleteErrorNumber, deleteErrorDescription, permissionAllowed
deleteID = SafePermissionID(Request.Form("id"))
transactionStarted = False

If UCase(Request.ServerVariables("REQUEST_METHOD")) <> "POST" Then
    SendDeleteResponse "405 Method Not Allowed", False, "Chức năng xóa chỉ chấp nhận yêu cầu POST."
    Response.End
End If

If Session("username") = "" Or SafePermissionID(Session("idadmin")) = 0 Then
    SendDeleteResponse "401 Unauthorized", False, "Phiên đăng nhập quản trị không còn hiệu lực."
    Response.End
End If

If Session("genealogy_csrf_token") = "" Or Request.Form("genealogy_csrf_token") <> CStr(Session("genealogy_csrf_token")) Then
    SendDeleteResponse "403 Forbidden", False, "Yêu cầu xác nhận không hợp lệ. Vui lòng tải lại trang phả đồ."
    Response.End
End If

If deleteID = 0 Then
    SendDeleteResponse "400 Bad Request", False, "Mã nhân vật không hợp lệ."
    Response.End
End If

On Error Resume Next
openconn
If Err.Number <> 0 Then
    deleteErrorDescription = Err.Description
    Err.Clear
    On Error GoTo 0
    SendDeleteResponse "500 Internal Server Error", False, "Không thể kết nối cơ sở dữ liệu."
    Response.End
End If

conn.BeginTrans
If Err.Number <> 0 Then
    deleteErrorDescription = Err.Description
    Err.Clear
    destroyconn
    On Error GoTo 0
    SendDeleteResponse "500 Internal Server Error", False, "Không thể bắt đầu giao dịch xóa. Dữ liệu chưa bị thay đổi."
    Response.End
End If
transactionStarted = True

permissionAllowed = CheckGenealogyPermissionOnConnection(conn, Session("idadmin"), deleteID)
If Err.Number <> 0 Then
    deleteErrorDescription = Err.Description
    Err.Clear
    conn.RollbackTrans
    transactionStarted = False
    destroyconn
    On Error GoTo 0
    SendDeleteResponse "500 Internal Server Error", False, "Không thể kiểm tra quyền xóa nhân vật."
    Response.End
End If

If Not permissionAllowed Then
    conn.RollbackTrans
    transactionStarted = False
    destroyconn
    On Error GoTo 0
    SendDeleteResponse "403 Forbidden", False, "Bạn không có quyền xóa nhân vật này."
    Response.End
End If

Set rsDeleteCheck = conn.Execute( _
    "SELECT " & _
    "(SELECT COUNT(*) FROM tblgiapha WITH (UPDLOCK, HOLDLOCK) WHERE idgiapha = " & deleteID & ") AS person_count, " & _
    "(SELECT COUNT(*) FROM tblgiapha WITH (UPDLOCK, HOLDLOCK) WHERE idcha = " & deleteID & " OR idme = " & deleteID & " OR id_vochong = " & deleteID & ") AS related_count, " & _
    "(SELECT COUNT(*) FROM tbladmin WITH (UPDLOCK, HOLDLOCK) WHERE allowed_start_idgiapha = " & deleteID & ") AS admin_scope_count" _
)

If Err.Number <> 0 Then
    deleteErrorDescription = Err.Description
    Err.Clear
    conn.RollbackTrans
    transactionStarted = False
    destroyconn
    On Error GoTo 0
    SendDeleteResponse "500 Internal Server Error", False, "Không thể kiểm tra các liên kết của nhân vật."
    Response.End
End If

personCount = CLng(rsDeleteCheck("person_count"))
relatedCount = CLng(rsDeleteCheck("related_count"))
adminScopeCount = CLng(rsDeleteCheck("admin_scope_count"))
rsDeleteCheck.Close
Set rsDeleteCheck = Nothing

If personCount = 0 Then
    conn.RollbackTrans
    transactionStarted = False
    destroyconn
    On Error GoTo 0
    SendDeleteResponse "404 Not Found", False, "Không tìm thấy nhân vật cần xóa."
    Response.End
End If

If relatedCount > 0 Then
    conn.RollbackTrans
    transactionStarted = False
    destroyconn
    On Error GoTo 0
    SendDeleteResponse "409 Conflict", False, "Không thể xóa vì nhân vật vẫn còn người liên quan. Hãy xử lý quan hệ cha, mẹ, vợ/chồng hoặc con trước."
    Response.End
End If

If adminScopeCount > 0 Then
    conn.RollbackTrans
    transactionStarted = False
    destroyconn
    On Error GoTo 0
    SendDeleteResponse "409 Conflict", False, "Không thể xóa vì nhân vật đang là điểm bắt đầu phân quyền của một tài khoản quản trị."
    Response.End
End If

conn.Execute "DELETE FROM tblgiapha WHERE idgiapha = " & deleteID
If Err.Number <> 0 Then
    deleteErrorNumber = Err.Number
    deleteErrorDescription = Err.Description
    Err.Clear
    If transactionStarted Then conn.RollbackTrans
    transactionStarted = False
    destroyconn
    On Error GoTo 0
    SendDeleteResponse "500 Internal Server Error", False, "Không thể xóa nhân vật. Dữ liệu chưa bị thay đổi."
    Response.End
End If

conn.CommitTrans
If Err.Number <> 0 Then
    deleteErrorDescription = Err.Description
    Err.Clear
    If transactionStarted Then conn.RollbackTrans
    transactionStarted = False
    destroyconn
    On Error GoTo 0
    SendDeleteResponse "500 Internal Server Error", False, "Không thể hoàn tất giao dịch xóa. Vui lòng kiểm tra lại dữ liệu."
    Response.End
End If
transactionStarted = False
destroyconn
On Error GoTo 0

SendDeleteResponse "200 OK", True, "Đã xóa nhân vật thành công."
%>
