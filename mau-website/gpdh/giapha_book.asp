<%session.CodePage=65001%>
<!--#include file="../connection.asp"-->
<%if session("username")="" then%>
<script language="javascript">
	alert("Bạn vui lòng đăng nhập để vào hệ thống quản trị!");
	window.location="../gp/";
</script>
<% 
    Response.End
end if
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Gia Phả Cuốn</title>
    <style>
        body { font-family: 'Times New Roman', Times, serif; line-height: 1.6; color: #000; background: #fff; margin: 0; padding: 0; }
        .container { width: 100%; max-width: 800px; margin: auto; padding: 20px; }
        
        /* Cấu trúc ngắt trang khi in */
        .page-break { page-break-after: always; min-height: 100vh; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center; }
        .page-content { page-break-after: always; padding: 40px 0; }
        
        /* Typography */
        h1 { font-size: 48px; margin-bottom: 10px; text-transform: uppercase; }
        h2 { font-size: 28px; text-transform: uppercase; margin-bottom: 20px; }
        h3.doi-title { font-size: 22px; color: #b22222; border-bottom: 2px solid #b22222; padding-bottom: 5px; margin-top: 40px; text-transform: uppercase; }
        
        .person-block { margin-bottom: 30px; text-align: left; }
        .person-name { font-size: 18px; font-weight: bold; margin-bottom: 5px; }
        .person-details { margin-left: 20px; font-size: 16px; }
        .person-details p { margin: 3px 0; }
        .child-list { margin-top: 5px; padding-left: 40px; }
        .child-list li { font-size: 16px; margin-bottom: 3px; }
        
        /* Ẩn nút in khi in thật */
        .print-btn { position: fixed; top: 20px; right: 20px; background: #0a69db; color: #fff; border: none; padding: 10px 20px; font-size: 16px; cursor: pointer; border-radius: 5px; font-weight: bold; box-shadow: 0 2px 5px rgba(0,0,0,0.3); }
        @media print {
            .print-btn { display: none !important; }
            body { background: transparent; }
            .container { max-width: 100%; padding: 0; }
        }
    </style>
</head>
<body>

<button class="print-btn" onclick="window.print()">🖨️ In PDF / Gia Phả</button>

<div class="container">
    <%
    openconn
    
    ' 1. LẤY THÔNG TIN CẤU HÌNH DÒNG HỌ
    Dim dongho, diachi, website, phaky, tocuoc
    Set rsConfig = conn.Execute("SELECT * FROM tblconfig")
    If Not rsConfig.EOF Then
        dongho = rsConfig("dongho") & ""
        diachi = rsConfig("diachi") & ""
        website = rsConfig("website") & ""
        phaky = rsConfig("phaky") & ""
        tocuoc = rsConfig("tocuoc") & ""
    End If
    rsConfig.Close
    %>

    <!-- TRANG 1: BÌA GIA PHẢ -->
    <div class="page-break">
        <h1>GIA PHẢ</h1>
        <h2><%=dongho%></h2>
        <div style="font-size: 18px; margin-top: 50px;">
            <p><strong>Địa chỉ:</strong> <%=diachi%></p>
            <p><strong>Website:</strong> <%=website%></p>
        </div>
    </div>

    <!-- TRANG 2: PHẢ KÝ -->
    <div class="page-content" style="text-align: justify;">
        <h2 style="text-align: center;">PHẢ KÝ DÒNG HỌ</h2>
        <div><%=phaky%></div>
    </div>

    <!-- TRANG 3: TỘC ƯỚC -->
    <div class="page-content" style="text-align: justify;">
        <h2 style="text-align: center;">TỘC ƯỚC DÒNG HỌ</h2>
        <div><%=tocuoc%></div>
    </div>

    <!-- CÁC TRANG TIẾP THEO: CHI TIẾT TỪNG ĐỜI -->
    <div class="page-content">
        <h2 style="text-align: center;">PHẢ ĐỒ CHI TIẾT</h2>
        <%
        Dim rsDoi, rsMember, rsSpouse, rsChild, rsCha
        Set rsDoi = conn.Execute("SELECT * FROM tbldoi ORDER BY iddoi ASC")
        
        Do While Not rsDoi.EOF
        %>
            <h3 class="doi-title">ĐỜI <%=UCase(rsDoi("tieude"))%></h3>
            
            <%
            ' Lấy các thành viên Nội tộc trong Đời này
            Set rsMember = conn.Execute("SELECT * FROM tblgiapha WHERE iddoi=" & rsDoi("iddoi") & " AND (loai_quanhe IS NULL OR loai_quanhe <> 2) ORDER BY thutu ASC")
            
            Do While Not rsMember.EOF
                Dim danhXung, tenCha, chucDanhCha
                If CInt(rsMember("gioitinh")) = 1 Then danhXung = "Ông" Else danhXung = "Bà"
                
                ' Xác định gốc gác (Thủy tổ hay Con thứ)
                If CInt(rsMember("idgiapha")) = 1 Then
                    chucDanhCha = "là Thủy tổ dòng họ."
                Else
                    tenCha = "Không rõ"
                    If CInt(rsMember("idcha")) > 0 Then
                        Set rsCha = conn.Execute("SELECT hoten, gioitinh FROM tblgiapha WHERE idgiapha=" & rsMember("idcha"))
                        If Not rsCha.EOF Then 
                            tenCha = rsCha("hoten")
                            If CInt(rsCha("gioitinh")) = 1 Then tenCha = "Ông " & tenCha Else tenCha = "Bà " & tenCha
                        End If
                        rsCha.Close
                    End If
                    chucDanhCha = "là con thứ " & rsMember("thutu") & " của " & tenCha & "."
                End If
            %>
            <div class="person-block">
                <div class="person-name"><%=danhXung%>: <%=rsMember("hoten")%> <%=chucDanhCha%></div>
                
                <div class="person-details">
                    <%
                    ' LẤY THÔNG TIN VỢ / CHỒNG
                    Set rsSpouse = conn.Execute("SELECT * FROM tblgiapha WHERE id_vochong=" & rsMember("idgiapha") & " AND loai_quanhe=2 ORDER BY thutu ASC")
                    If rsSpouse.EOF Then
                        Response.Write "<p><strong>" & (If CInt(rsMember("gioitinh")) = 1 Then "Vợ" Else "Chồng") & ":</strong> Không rõ.</p>"
                    Else
                        Do While Not rsSpouse.EOF
                            Dim danhXungVo
                            If CInt(rsSpouse("gioitinh")) = 2 Then danhXungVo = "Bà" Else danhXungVo = "Ông"
                            Dim qqVo: qqVo = rsSpouse("diachi") & ""
                            If qqVo = "" Then qqVo = "Không rõ"
                            Response.Write "<p><strong>" & (If CInt(rsMember("gioitinh")) = 1 Then "Vợ" Else "Chồng") & " là " & LCase(danhXungVo) & ":</strong> " & rsSpouse("hoten") & ", <strong>quê quán tại:</strong> " & qqVo & ".</p>"
                            rsSpouse.MoveNext
                        Loop
                    End If
                    rsSpouse.Close
                    %>

                    <% If rsMember("tentu") & "" <> "" Then %>
                        <p><strong>Tên tự (thụy/hiệu):</strong> <%=rsMember("tentu")%></p>
                    <% End If %>
                    
                    <p><strong>Năm sinh:</strong> <% If rsMember("namsinh")&""<>"" Then Response.Write rsMember("namsinh") Else Response.Write "Không rõ" %></p>
                    <p><strong>Địa chỉ:</strong> <% If rsMember("diachi")&""<>"" Then Response.Write rsMember("diachi") Else Response.Write "Không rõ" %></p>
                    
                    <% If CInt(rsMember("tinhtrang")) = 2 Then %>
                        <p><strong>Năm mất:</strong> <% If rsMember("nammat")&""<>"" Then Response.Write rsMember("nammat") Else Response.Write "Không rõ" %></p>
                        <p><strong>Hưởng thọ (hưởng dương):</strong> <% If rsMember("huongtho")&""<>"" Then Response.Write rsMember("huongtho") & " tuổi" Else Response.Write "Không rõ" %></p>
                        <p><strong>An táng tại:</strong> <% If rsMember("noiantang")&""<>"" Then Response.Write rsMember("noiantang") Else Response.Write "Không rõ" %></p>
                    <% End If %>

                    <% If rsMember("tieusu") & "" <> "" Then %>
                        <p><strong>Tiểu sử, sự nghiệp:</strong></p>
                        <div style="margin-top: 5px; text-align: justify;"><%=rsMember("tieusu")%></div>
                    <% End If %>

                    <%
                    ' LẤY DANH SÁCH CÁC CON
                    Set rsChild = conn.Execute("SELECT hoten FROM tblgiapha WHERE idcha=" & rsMember("idgiapha") & " AND (loai_quanhe IS NULL OR loai_quanhe <> 2) ORDER BY thutu ASC")
                    Dim childCount: childCount = 0
                    Dim childArr()
                    Do While Not rsChild.EOF
                        ReDim Preserve childArr(childCount)
                        childArr(childCount) = rsChild("hoten")
                        childCount = childCount + 1
                        rsChild.MoveNext
                    Loop
                    rsChild.Close
                    
                    If childCount > 0 Then
                        Response.Write "<p><strong>" & danhXung & " có " & childCount & " người con:</strong></p>"
                        Response.Write "<ol class='child-list'>"
                        Dim i
                        For i = 0 To childCount - 1
                            Response.Write "<li>" & childArr(i) & "</li>"
                        Next
                        Response.Write "</ol>"
                    End If
                    %>
                </div>
            </div>
            <%
                rsMember.MoveNext
            Loop
            rsMember.Close
            %>
        <%
            rsDoi.MoveNext
        Loop
        rsDoi.Close
        destroyconn
        %>
    </div>
</div>

</body>
</html>