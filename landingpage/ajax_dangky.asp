<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%
Response.CodePage = 65001
Response.CharSet = "UTF-8"
Response.ContentType = "application/json"

' 1. CHỐNG SPAM BẰNG HONEYPOT
Dim honeypot
honeypot = Request.Form("website")
If honeypot <> "" Then
    ' Bọ SPAM đã sập bẫy, trả về thành công ảo
    Response.Write "{""result"": ""success""}"
    Response.End
End If

' 2. LẤY DỮ LIỆU TỪ FORM HTML
Dim fullname, phone, email, address, pkg
fullname = Request.Form("fullname")
phone = Request.Form("phone")
email = Request.Form("email")
address = Request.Form("address")
pkg = Request.Form("package")

' 3. GỬI THÔNG BÁO VỀ TELEGRAM
Dim botToken, chatID, message, telegramURL, xmlhttp
botToken = "8683945634:AAFHiWbz8hc2qR-qCo55_U7HmRXqqDdztc4"  ' Token của anh
chatID = "6528852919"                                      ' ID của anh

message = "🚨 <b>ĐĂNG KÝ GIA PHẢ MỚI</b>%0A%0A" & _
          "👤 <b>Họ tên:</b> " & fullname & "%0A" & _
          "📞 <b>Điện thoại:</b> " & phone & "%0A" & _
          "📧 <b>Email:</b> " & email & "%0A" & _
          "📍 <b>Địa chỉ:</b> " & address & "%0A" & _
          "📦 <b>Gói:</b> " & pkg

telegramURL = "https://api.telegram.org/bot" & botToken & "/sendMessage?chat_id=" & chatID & "&parse_mode=HTML&text=" & message

' Khởi tạo Object HTTP phiên bản 6.0 để hỗ trợ cấu hình TLS 1.2
Set xmlhttp = Server.CreateObject("MSXML2.ServerXMLHTTP.6.0")
xmlhttp.setTimeouts 5000, 5000, 10000, 10000

On Error Resume Next
xmlhttp.Open "GET", telegramURL, False
' Bắt buộc ép giao thức TLS 1.2 để API hiện đại không từ chối kết nối
xmlhttp.setOption 2, 13056
xmlhttp.Send
On Error GoTo 0

' Giải phóng Object sau khi gửi Telegram
Set xmlhttp = Nothing


' 4. BẮN NGẦM DỮ LIỆU SANG GOOGLE SHEET
Dim googleAppUrl, postData, xmlhttpGS
googleAppUrl = "https://script.google.com/macros/s/AKfycbyhvHsLzT61cbMLqzmHi3TFyprqAD_1CwtcfmB_UT2QfO_BegQAROnQ2xPnIvd7WDZm/exec" 

' Tạo chuỗi dữ liệu gửi đi an toàn (URLEncode để không lỗi tiếng Việt)
postData = "fullname=" & Server.URLEncode(fullname) & _
           "&phone=" & Server.URLEncode(phone) & _
           "&email=" & Server.URLEncode(email) & _
           "&address=" & Server.URLEncode(address) & _
           "&package=" & Server.URLEncode(pkg)

' Khởi tạo một Object HTTP mới chuyên biệt cho Google Sheet
Set xmlhttpGS = Server.CreateObject("MSXML2.ServerXMLHTTP.6.0")
xmlhttpGS.setTimeouts 5000, 5000, 15000, 15000

On Error Resume Next
xmlhttpGS.Open "POST", googleAppUrl, False
' Lệnh sống còn: Ép TLS 1.2 để vượt qua bảo mật khắt khe của hệ thống Google
xmlhttpGS.setOption 2, 13056
xmlhttpGS.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
xmlhttpGS.Send postData
On Error GoTo 0

Set xmlhttpGS = Nothing

' 5. BÁO KẾT QUẢ VỀ CHO WEBSITE HIỂN THỊ CẢM ƠN (Kích hoạt Popup)
Response.Write "{""result"": ""success""}"
%>