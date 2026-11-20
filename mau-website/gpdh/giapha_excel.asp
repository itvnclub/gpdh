<%session.CodePage=65001%>
<!--#include file="../connection.asp"-->
<%
If session("username")="" Then
    Response.End
End If

' Khai báo Header ép trình duyệt tải file Excel với chuẩn UTF-8
Response.Buffer = True
Response.ContentType = "application/vnd.ms-excel"
Response.AddHeader "Content-Disposition", "attachment; filename=Pha_do_dong_ho.xls"
Response.Charset = "UTF-8"
%>
<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">
<head>
<!-- THẺ META CỰC KỲ QUAN TRỌNG ĐỂ EXCEL HIỂN THỊ ĐÚNG TIẾNG VIỆT -->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<style>
    table { border-collapse: collapse; font-family: 'Times New Roman', serif; font-size: 12pt; }
    th { font-weight: bold; text-align: center; border: 1px solid #000; padding: 5px; background-color: #f2f2f2; }
    td { border: 1px solid #000; padding: 5px; vertical-align: top; white-space: nowrap; }
</style>
</head>
<body>
    <table>
        <tr>
            <%
                openconn
                
                ' Nhận các biến lọc từ form
                Dim tu_doi, den_doi, gioitinh_loc, tukhoa_loc
                tu_doi = Request.QueryString("tu_doi")
                den_doi = Request.QueryString("den_doi")
                gioitinh_loc = Request.QueryString("gioitinh")
                tukhoa_loc = Trim(Request.QueryString("tukhoa"))

                ' Lấy mảng Đời để làm Tiêu đề cột
                Dim rsTotalDoi, totalDoiCount
                Set rsTotalDoi = conn.Execute("SELECT iddoi, tieude FROM tbldoi ORDER BY iddoi ASC")
                
                Dim arrDoiID(), arrDoiTieuDe()
                totalDoiCount = 0
                Do While Not rsTotalDoi.EOF
                    totalDoiCount = totalDoiCount + 1
                    ReDim Preserve arrDoiID(totalDoiCount)
                    ReDim Preserve arrDoiTieuDe(totalDoiCount)
                    arrDoiID(totalDoiCount) = CInt(rsTotalDoi("iddoi"))
                    arrDoiTieuDe(totalDoiCount) = rsTotalDoi("tieude") & ""
                    rsTotalDoi.MoveNext
                Loop
                rsTotalDoi.Close

                Dim startIndex, endIndex, i
                startIndex = 1
                endIndex = totalDoiCount
                
                If tu_doi <> "" Then
                    For i = 1 To totalDoiCount
                        If arrDoiID(i) = CInt(tu_doi) Then startIndex = i
                    Next
                End If
                
                If den_doi <> "" Then
                    For i = 1 To totalDoiCount
                        If arrDoiID(i) = CInt(den_doi) Then endIndex = i
                    Next
                End If
                
                If startIndex > endIndex Then
                    Dim tempSwap: tempSwap = startIndex: startIndex = endIndex: endIndex = tempSwap
                End If

                ' IN TIÊU ĐỀ CỘT (Vd: Đời I, Đời II...)
                For i = startIndex To endIndex
                    Response.Write "<th style='width: 250px;'>DOI " & UCase(arrDoiTieuDe(i)) & "</th>"
                Next
            %>
        </tr>
<%
    ' Gọi hàm đệ quy để xuất cây phả hệ
    Call RenderMatrixTree(0, arrDoiID, arrDoiTieuDe, startIndex, endIndex, totalDoiCount, tu_doi, den_doi, gioitinh_loc, tukhoa_loc)
    
    destroyconn

    Sub RenderMatrixTree(parentID, arrDoiID, arrDoiTieuDe, startIndex, endIndex, totalDoiCount, loc_tu, loc_den, loc_gt, loc_key)
        Dim rsTree, isMatch, currentDoi
        Set rsTree = Server.CreateObject("ADODB.Recordset")
        rsTree.Open "SELECT g.*, d.tieude AS doi_tieude FROM tblgiapha g LEFT JOIN tbldoi d ON g.iddoi = d.iddoi WHERE g.idcha=" & parentID & " AND (g.loai_quanhe IS NULL OR g.loai_quanhe <> 2) ORDER BY g.thutu ASC", conn, 3, 1
        
        Do While Not rsTree.EOF
            isMatch = True
            currentDoi = CInt(rsTree("iddoi"))
            
            If loc_tu <> "" Then
                If currentDoi < CInt(loc_tu) Then isMatch = False
            End If
            If loc_den <> "" Then
                If currentDoi > CInt(loc_den) Then isMatch = False
            End If
            
            If loc_gt <> "" Then
                If CInt(rsTree("gioitinh")) <> CInt(loc_gt) Then 
                    isMatch = False
                ElseIf CInt(loc_gt) = 1 And (rsTree("loai_quanhe") & "" = "3") Then
                    isMatch = False
                End If
            End If
            
            If isMatch Then
                ' Lọc từ khóa
                If loc_key <> "" Then
                    If InStr(1, LCase(rsTree("hoten")), LCase(loc_key)) = 0 Then isMatch = False
                End If
            End If

            If isMatch Then
                Call PrintMemberRow(rsTree, arrDoiID, arrDoiTieuDe, startIndex, endIndex, totalDoiCount)
            End If
            
            RenderMatrixTree rsTree("idgiapha"), arrDoiID, arrDoiTieuDe, startIndex, endIndex, totalDoiCount, loc_tu, loc_den, loc_gt, loc_key
            
            rsTree.MoveNext
        Loop
        rsTree.Close
        Set rsTree = Nothing
    End Sub

    Sub PrintMemberRow(rsObj, arrDoiID, arrDoiTieuDe, startIndex, endIndex, totalDoiCount)
        Dim currentDoiId, doiText, thuTu, displayName, k
        Dim strSpouses, rsSpouse
        
        currentDoiId = CInt(rsObj("iddoi"))
        
        doiText = ""
        For k = 1 To totalDoiCount
            If CInt(arrDoiID(k)) = currentDoiId Then
                doiText = CStr(arrDoiTieuDe(k))
                Exit For
            End If
        Next
        
        ' TÌM TÊN VỢ/CHỒNG GHÉP VÀO
        strSpouses = ""
        Set rsSpouse = Server.CreateObject("ADODB.Recordset")
        rsSpouse.Open "SELECT hoten FROM tblgiapha WHERE loai_quanhe = 2 AND id_vochong=" & CInt(rsObj("idgiapha")) & " ORDER BY thutu ASC, idgiapha ASC", conn, 3, 1
        Do While Not rsSpouse.EOF
            strSpouses = strSpouses & " - " & rsSpouse("hoten")
            rsSpouse.MoveNext
        Loop
        rsSpouse.Close
        Set rsSpouse = Nothing

        thuTu = rsObj("thutu") & ""
        
        ' CHUẨN HÓA ĐỊNH DẠNG: III.1. Đinh Trọng Quýnh - Tên Vợ
        ' Tuyệt đối không dùng <span> màu đỏ hay chữ (Thủy Tổ), (Ngoại)
        displayName = UCase(doiText) & "." & thuTu & ". " & rsObj("hoten") & strSpouses

        Response.Write "<tr>"
        
        ' XUẤT CÁC CỘT DỮ LIỆU
        Dim i
        For i = startIndex To endIndex 
            If currentDoiId = CInt(arrDoiID(i)) Then 
                ' In tên nhân vật vào đúng cột Đời tương ứng (In đậm)
                Response.Write "<td>" & displayName & "</td>"
            Else
                ' Nếu không phải đời của nhân vật, xuất ô trống (không dùng colspan)
                Response.Write "<td></td>"
            End If
        Next
        
        Response.Write "</tr>"
    End Sub
%>
    </table>
</body>
</html>