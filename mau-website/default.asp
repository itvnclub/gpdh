<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="connection.asp"-->
<!--#include file="functions.asp"-->
<%  
    openconn    
    Set rsgp = Server.CreateObject("ADODB.Recordset")
    rsgp.Open "SELECT * FROM tblconfig", conn
    
    ' Khởi tạo Dictionary để lưu trữ text giao diện
    Dim uiText, rsText, currentKey
    Set uiText = Server.CreateObject("Scripting.Dictionary")

    ' Load toàn bộ bảng tblUI_Text 1 lần duy nhất
    Set rsText = conn.Execute("SELECT TextKey, TextValue FROM tblUI_Text")
    Do While Not rsText.EOF
        currentKey = Trim(rsText("TextKey"))
        ' Kiểm tra xem Key đã tồn tại chưa để tránh lỗi 800a01c9
        If currentKey <> "" Then
            If Not uiText.Exists(currentKey) Then
                uiText.Add currentKey, rsText("TextValue") & "" 
            End If
        End If
        rsText.MoveNext
    Loop
    rsText.Close
    Set rsText = Nothing

    ' Chuẩn hóa đường dẫn bgchinh luôn xuất phát từ gốc thư mục
    Dim bgChinhUrl
    bgChinhUrl = Trim(rsgp("bgchinh") & "")
    If bgChinhUrl <> "" Then
        If Left(bgChinhUrl, 3) = "../" Then
            bgChinhUrl = "/" & Mid(bgChinhUrl, 4)
        ElseIf Left(bgChinhUrl, 1) <> "/" And InStr(bgChinhUrl, "http") = 0 Then
            bgChinhUrl = "/" & bgChinhUrl
        End If
    End If

    Dim bgTrenUrl
    bgTrenUrl = Trim(rsgp("bgtren") & "")
    If bgTrenUrl <> "" Then
        If Left(bgTrenUrl, 3) = "../" Then
            bgTrenUrl = "/" & Mid(bgTrenUrl, 4)
        ElseIf Left(bgTrenUrl, 1) <> "/" And InStr(bgTrenUrl, "http") = 0 Then
            bgTrenUrl = "/" & bgTrenUrl
        End If
    End If

    ' Lấy các QueryString để điều hướng
    gpdh = Request.QueryString("gpdh")
    tintuc = Request.QueryString("tintuc")
    thongtin = Request.QueryString("thongtin")
    hinhanh = Request.QueryString("hinhanh")
    nhomtin = Request.QueryString("nhomtin")
    video = Request.QueryString("video")
    giapha = Request.QueryString("giapha")
%>
<!DOCTYPE html>
<html lang="vi">
<!--#include file="Includes/inc_header.asp"-->
    <% If gpdh = "1" Then %>
        <!--#include file="Includes/inc_tintuc.asp"-->
    <% Elseif gpdh = "2" Then %>
        <!--#include file="Includes/inc_hinhanh.asp"-->
    <% Elseif gpdh = "3" Then %>
        <!--#include file="Includes/inc_video.asp"-->
    <% Elseif gpdh = "5" Then %>
        <!--#include file="Includes/inc_phadodoc.asp"-->
    <% ElseIf gpdh = "6" Then %>
        <!--#include file="Includes/inc_phadotheodoi.asp"-->
    <% ElseIf gpdh = "7" Then %>
        <!--#include file="Includes/inc_phadongang.asp"-->
    <%elseif thongtin <> "" then%>
        <!--#include file = "Includes/inc_thongtin.asp" -->
    <%elseif nhomtin <> "" then%>
        <!--#include file = "Includes/inc_nhomtin.asp" -->
    <%elseif giapha <> "" then%>
        <!--#include file = "Includes/inc_giapha.asp" -->
    <%elseif hinhanh <> "" then%>
        <!--#include file = "Includes/inc_xemanh.asp" -->
    <%elseif tintuc <> "" then%>
        <!--#include file = "Includes/inc_chitiet.asp" -->
    <% Else %>
        <!--#include file="Includes/inc_main.asp"-->
    <% End If %>

<!--#include file="Includes/inc_footer.asp"-->
</html>
<% 
    rsgp.Close
    Set rsgp = Nothing
    destroyconn() 
%>
