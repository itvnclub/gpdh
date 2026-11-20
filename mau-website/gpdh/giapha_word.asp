<%
Response.Buffer = True
session.CodePage = 65001
%>
<!--#include file="../connection.asp"-->
<%
' Cấu hình xuất file Word chuẩn MS Office
Response.ContentType = "application/msword"
Response.AddHeader "Content-Disposition", "attachment; filename=Gia_Pha_Cuon.doc"
Response.Charset = "UTF-8"

' Ghi mã BOM để ép MS Word nhận diện tiếng Việt 100%
Response.BinaryWrite ChrB(239) & ChrB(187) & ChrB(191)

' Hàm kiểm tra rỗng (nếu rỗng trả về "Không rõ")
Function checkNull(val)
    If IsNull(val) Then 
        checkNull = "Không rõ" 
    ElseIf Trim(val) = "" Then
        checkNull = "Không rõ"
    Else 
        checkNull = val
    End If
End Function
%>
<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns="http://www.w3.org/TR/REC-html40">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<style>
    body { font-family: 'Times New Roman', Times, serif; font-size: 14pt; line-height: 1.5; }
    .center { text-align: center; }
    .bold { font-weight: bold; }
    p { margin: 3pt 0; }
    
    /* Cấu hình Section để MS Word nhận diện Header/Footer và Đánh số trang */
    @page Section1 {
        mso-footer: f1;
        margin: 1in 1in 1in 1in;
    }
    div.Section1 { page: Section1; }
    p.MsoFooter { text-align: center; font-size: 12pt; }
</style>
</head>
<body>
<div class="Section1">
    <%
    openconn
    Dim dongho, diachi, website, rsConfig
    Set rsConfig = conn.Execute("SELECT * FROM tblconfig")
    If Not rsConfig.EOF Then
        dongho = rsConfig("dongho") & ""
        diachi = rsConfig("diachi") & ""
        website = rsConfig("website") & ""
    End If
    rsConfig.Close
    Set rsConfig = Nothing
    %>

    <!-- TRANG 1: BÌA GIA PHẢ -->
    <div style="margin-top: 150pt;" class="center">
        <h1 style="font-size: 36pt; font-weight:bold;">GIA PHẢ</h1>
        <h2 style="font-size: 24pt; text-transform: uppercase;"><%=dongho%></h2>
        <div style="margin-top: 50pt; font-size: 16pt;">
            <p>Địa chỉ: <%=diachi%></p>
            <p>Website: <%=website%></p>
        </div>
    </div>

    <%
    ' LẤY DỮ LIỆU TỪ BẢNG tblthongtin (Phả ký, Tộc ước, Lời ngỏ...)
    Dim rsThongTin
    Set rsThongTin = conn.Execute("SELECT tieude, noidung FROM tblthongtin ORDER BY thutu ASC")
    
    Do While Not rsThongTin.EOF
        ' Chỉ in trang nếu mục đó có nội dung
        If Trim(rsThongTin("noidung") & "") <> "" Then
    %>
    <!-- TRANG THÔNG TIN ĐỘNG (Ép ngắt trang chuẩn Word) -->
    <br clear="all" style="mso-special-character:line-break; page-break-before:always" />
    <h2 class="center bold" style="text-transform:uppercase;"><%=rsThongTin("tieude")%></h2>
    <div style="text-align: justify;"><%=rsThongTin("noidung")%></div>
    <%
        End If
        rsThongTin.MoveNext
    Loop
    rsThongTin.Close
    Set rsThongTin = Nothing
    %>

    <!-- PHẦN PHẢ ĐỒ (Ngắt trang 1 lần đầu tiên, sau đó nội dung chảy liên tục) -->
    <br clear="all" style="mso-special-character:line-break; page-break-before:always" />
    
    <%
    Dim tu_doi, den_doi, strWhereDoi, strWhereMem
    Dim rsDoi, rsMem, rsSpouse, rsChild, rsCha
    Dim danhXung, danhXungVoChong, moTaCha, tenCha
    Dim dxVo, prefixVoChong
    Dim countChild, arrChild(), iChild
    
    tu_doi = Request.QueryString("tu_doi")
    den_doi = Request.QueryString("den_doi")
    
    strWhereDoi = " WHERE 1=1 "
    If tu_doi <> "" Then strWhereDoi = strWhereDoi & " AND iddoi >= " & CInt(tu_doi)
    If den_doi <> "" Then strWhereDoi = strWhereDoi & " AND iddoi <= " & CInt(den_doi)

    Set rsDoi = conn.Execute("SELECT * FROM tbldoi " & strWhereDoi & " ORDER BY iddoi ASC")
    
    Do While Not rsDoi.EOF
    %>
        <h2 class="center bold" style="text-transform:uppercase; margin-top: 20pt;">ĐỜI <%=rsDoi("tieude")%></h2>
        
        <%
        strWhereMem = " AND (loai_quanhe IS NULL OR loai_quanhe <> 2) "
        If Request.QueryString("gioitinh") <> "" Then strWhereMem = strWhereMem & " AND gioitinh = " & CInt(Request.QueryString("gioitinh"))
        If Request.QueryString("tukhoa") <> "" Then strWhereMem = strWhereMem & " AND hoten LIKE N'%" & Replace(Trim(Request.QueryString("tukhoa")), "'", "''") & "%' "
        
        Set rsMem = conn.Execute("SELECT * FROM tblgiapha WHERE iddoi=" & rsDoi("iddoi") & strWhereMem & " ORDER BY thutu ASC")
        
        Do While Not rsMem.EOF
            If CInt(rsMem("gioitinh")) = 1 Then 
                danhXung = "Ông" 
                danhXungVoChong = "Vợ"
            Else 
                danhXung = "Bà"
                danhXungVoChong = "Chồng"
            End If
            
            If CInt(rsMem("idgiapha")) = 1 Then
                moTaCha = "là thủy tổ dòng họ."
            Else
                tenCha = "Không rõ"
                If CInt(rsMem("idcha")) > 0 Then
                    Set rsCha = conn.Execute("SELECT hoten, gioitinh FROM tblgiapha WHERE idgiapha=" & rsMem("idcha"))
                    If Not rsCha.EOF Then 
                        If CInt(rsCha("gioitinh")) = 1 Then tenCha = "Ông " & rsCha("hoten") Else tenCha = "Bà " & rsCha("hoten")
                    End If
                    rsCha.Close
                End If
                moTaCha = "là con thứ " & checkNull(rsMem("thutu")) & " của " & tenCha & "."
            End If
        %>
        
        <div>
            <p><span class="bold"><%=danhXung%>: <%=rsMem("hoten")%></span> <%=moTaCha%></p>
            
            <%
            Set rsSpouse = conn.Execute("SELECT * FROM tblgiapha WHERE id_vochong=" & rsMem("idgiapha") & " AND loai_quanhe=2 ORDER BY thutu ASC")
            If rsSpouse.EOF Then
                Response.Write "<p><span class='bold'>" & danhXungVoChong & " là:</span> Không rõ.</p>"
            Else
                Do While Not rsSpouse.EOF
                    If CInt(rsSpouse("gioitinh")) = 2 Then dxVo = "bà" Else dxVo = "ông"
                    If CInt(rsMem("gioitinh")) = 1 Then prefixVoChong = "Vợ là " Else prefixVoChong = "Chồng là "
                    
                    Response.Write "<p><span class='bold'>" & prefixVoChong & dxVo & ": " & rsSpouse("hoten") & "</span>, quê quán tại: " & checkNull(rsSpouse("diachi")) & ".</p>"
                    rsSpouse.MoveNext
                Loop
            End If
            rsSpouse.Close
            %>

            <% If rsMem("tentu") & "" <> "" Then %>
                <p><span class="bold">Tên tự (thụy/hiệu):</span> <%=rsMem("tentu")%></p>
            <% End If %>
            
            <p><span class="bold">Năm sinh:</span> <%=checkNull(rsMem("namsinh"))%></p>
            <p><span class="bold">Địa chỉ:</span> <%=checkNull(rsMem("diachi"))%></p>
            
            <% If CInt(rsMem("tinhtrang")) = 2 Then %>
                <p><span class="bold">Năm mất:</span> <%=checkNull(rsMem("nammat"))%></p>
                <p><span class="bold">Hưởng thọ (hưởng dương):</span> <% If rsMem("huongtho")&""<>"" Then Response.Write rsMem("huongtho") & " tuổi" Else Response.Write "Không rõ" %></p>
                <p><span class="bold">An táng tại:</span> <%=checkNull(rsMem("noiantang"))%></p>
            <% End If %>

            <% If rsMem("tieusu") & "" <> "" Then %>
                <p><span class="bold">Tiểu sử, sự nghiệp:</span></p>
                <div style="text-align: justify;"><%=rsMem("tieusu")%></div>
            <% End If %>

            <%
            Set rsChild = conn.Execute("SELECT hoten FROM tblgiapha WHERE idcha=" & rsMem("idgiapha") & " AND (loai_quanhe IS NULL OR loai_quanhe <> 2) ORDER BY thutu ASC")
            countChild = 0
            ReDim arrChild(0)
            
            Do While Not rsChild.EOF
                ReDim Preserve arrChild(countChild)
                arrChild(countChild) = rsChild("hoten")
                countChild = countChild + 1
                rsChild.MoveNext
            Loop
            rsChild.Close
            
            If countChild > 0 Then
                Response.Write "<p><span class='bold'>" & danhXung & " có " & countChild & " người con:</span></p>"
                For iChild = 0 To countChild - 1
                    Response.Write "<p style='margin-left: 20pt;'>" & (iChild + 1) & ". " & arrChild(iChild) & "</p>"
                Next
            End If
            %>
        </div>
        
        <!-- Khoảng trắng 2 Enters giữa các nhân vật -->
        <br><br>
        
        <%
            rsMem.MoveNext
        Loop
        rsMem.Close
        %>
    <%
        rsDoi.MoveNext
    Loop
    rsDoi.Close
    destroyconn
    %>
</div>

<!-- KHỐI FOOTER ĐÁNH SỐ TRANG TỰ ĐỘNG CHO MS WORD -->
<div style="mso-element:footer" id="f1">
    <p class="MsoFooter">
        Trang <span style="mso-field-code:' PAGE '"></span> / <span style="mso-field-code:' NUMPAGES '"></span>
    </p>
</div>
</body>
</html>