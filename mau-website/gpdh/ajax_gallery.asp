<!--#include file="../connection.asp"-->
<%
Session.CodePage = 65001
Response.Expires = -1
On Error Resume Next

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

Dim action
action = Trim(Request.Form("action") & "")
If action = "" Then action = Trim(Request.QueryString("action") & "")

openconn

If action = "sort" Then
    Dim id_nhom, sorted_ids, cover_path, arrIds, i
    id_nhom = Request.Form("id_nhom")
    sorted_ids = Request.Form("sorted_ids")
    cover_path = Request.Form("cover_path")

    ' 1. Cập nhật thứ tự các ảnh trong tblanh
    If sorted_ids <> "" Then
        arrIds = Split(sorted_ids, ",")
        For i = 0 To UBound(arrIds)
            If IsNumeric(Trim(arrIds(i))) Then
                conn.Execute("UPDATE tblanh SET thutu=" & (i + 1) & " WHERE idanh=" & CLng(Trim(arrIds(i))))
            End If
        Next
    End If

    ' 2. Cập nhật ảnh đại diện mới vào tblnhomanh
    If cover_path <> "" And IsNumeric(id_nhom) Then
        Dim cleanCover
        cleanCover = Replace(GetCleanFileName(cover_path), "'", "''")
        conn.Execute("UPDATE tblnhomanh SET hinhanh='" & cleanCover & "' WHERE idnhomanh=" & CLng(id_nhom))
    End If
    
    Response.Write "Success"

ElseIf action = "delete" Then
    Dim id_anh, id_nhom_del, rsFirstImg, newCover, rsTemp, fileToDelete, fso, physicalPath
    id_anh = Request.Form("id_anh")
    id_nhom_del = Request.Form("id_nhom")

    If IsNumeric(id_anh) Then
        Set rsTemp = conn.Execute("SELECT idnhomanh, hinhanh FROM tblanh WHERE idanh=" & CLng(id_anh))
        If Not rsTemp.EOF Then
            If id_nhom_del = "" Or Not IsNumeric(id_nhom_del) Then id_nhom_del = rsTemp("idnhomanh")
            fileToDelete = GetCleanFileName(rsTemp("hinhanh"))
        End If
        rsTemp.Close: Set rsTemp = Nothing

        ' Xóa bản ghi trong tblanh
        conn.Execute("DELETE FROM tblanh WHERE idanh=" & CLng(id_anh))

        ' Xóa file vật lý trong thư mục /images/hinhanh/ (nếu tồn tại)
        If fileToDelete <> "" Then
            Set fso = Server.CreateObject("Scripting.FileSystemObject")
            physicalPath = Server.MapPath("/images/hinhanh/" & fileToDelete)
            If fso.FileExists(physicalPath) Then
                fso.DeleteFile physicalPath, True
            End If
            Set fso = Nothing
        End If
    End If

    ' Cập nhật lại ảnh đại diện cho nhóm ảnh
    If id_nhom_del <> "" And IsNumeric(id_nhom_del) Then
        Set rsFirstImg = conn.Execute("SELECT TOP 1 hinhanh FROM tblanh WHERE idnhomanh=" & CLng(id_nhom_del) & " ORDER BY thutu ASC, idanh DESC")
        If Not rsFirstImg.EOF Then
            newCover = Replace(GetCleanFileName(rsFirstImg("hinhanh")), "'", "''")
            conn.Execute("UPDATE tblnhomanh SET hinhanh='" & newCover & "' WHERE idnhomanh=" & CLng(id_nhom_del))
        Else
            conn.Execute("UPDATE tblnhomanh SET hinhanh='' WHERE idnhomanh=" & CLng(id_nhom_del))
        End If
        rsFirstImg.Close: Set rsFirstImg = Nothing
    End If

    Response.Write "Deleted"

ElseIf action = "upload" Then
    Dim id_nhom_up, hinhanh_up, max_thutu, rsMax, rsCheckCover
    id_nhom_up = Request.Form("id_nhom")
    hinhanh_up = Replace(GetCleanFileName(Request.Form("hinhanh")), "'", "''")
    
    Set rsMax = conn.Execute("SELECT MAX(ISNULL(thutu, 0)) AS max_tt FROM tblanh WHERE idnhomanh=" & CLng(id_nhom_up))
    If Not rsMax.EOF And Not IsNull(rsMax("max_tt")) Then
        max_thutu = CInt(rsMax("max_tt")) + 1
    Else
        max_thutu = 1
    End If
    rsMax.Close : Set rsMax = Nothing
    
    conn.Execute("INSERT INTO tblanh(idnhomanh, hinhanh, thutu) VALUES(" & CLng(id_nhom_up) & ", '" & hinhanh_up & "', " & max_thutu & ")")

    Set rsCheckCover = conn.Execute("SELECT hinhanh FROM tblnhomanh WHERE idnhomanh=" & CLng(id_nhom_up))
    If Not rsCheckCover.EOF Then
        If IsNull(rsCheckCover("hinhanh")) Or Trim(rsCheckCover("hinhanh")) = "" Then
            conn.Execute("UPDATE tblnhomanh SET hinhanh='" & hinhanh_up & "' WHERE idnhomanh=" & CLng(id_nhom_up))
        End If
    End If
    rsCheckCover.Close: Set rsCheckCover = Nothing

    Response.Write "Success"

End If

If Err.Number <> 0 Then
    Response.Status = "500 Internal Server Error"
    Response.Write "Lỗi SQL: " & Err.Description
    Err.Clear
End If

destroyconn
%>