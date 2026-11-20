<!--#include file="../connection.asp"-->
<%
Session.CodePage = 65001
Response.Expires = -1
On Error Resume Next ' Bật chế độ bắt lỗi

Dim action
action = Request.Form("action") 

openconn

If action = "sort" Then
    Dim sorted_ids, arrIds, i
    sorted_ids = Request.Form("sorted_ids")
    If sorted_ids <> "" Then
        arrIds = Split(sorted_ids, ",")
        For i = 0 To UBound(arrIds)
            conn.Execute("UPDATE tblloadanh SET thutu=" & (i + 1) & " WHERE idloadanh=" & CInt(arrIds(i)))
        Next
    End If
    Response.Write "Success"

ElseIf action = "delete" Then
    Dim id_del
    id_del = Request.Form("id")
    conn.Execute("DELETE FROM tblloadanh WHERE idloadanh=" & CInt(id_del))
    Response.Write "Deleted"

ElseIf action = "add" Then
    Dim hinhanh_new, max_thutu, rsMax
    hinhanh_new = Replace(Request.Form("hinhanh"), "'", "''")
    
    Set rsMax = conn.Execute("SELECT MAX(ISNULL(thutu, 0)) AS max_tt FROM tblloadanh")
    If Not rsMax.EOF And Not IsNull(rsMax("max_tt")) Then
        max_thutu = CInt(rsMax("max_tt")) + 1
    Else
        max_thutu = 1
    End If
    rsMax.Close : Set rsMax = Nothing
    
    conn.Execute("INSERT INTO tblloadanh(hinhanh, thutu) VALUES('" & hinhanh_new & "', " & max_thutu & ")")
    Response.Write "Added"
End If

' Xử lý in ra thông báo nếu có lỗi SQL
If Err.Number <> 0 Then
    Response.Status = "500 Internal Server Error"
    Response.Write "Chi tiết lỗi SQL: " & Err.Description
    Err.Clear
End If

destroyconn
%>