<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%session.CodePage=65001%>
<!--#include file="../connection.asp"-->
<!--#include file="../functions.asp"-->
<!--#include file="sha256.asp"-->
<%
' ==========================================================
' 1. XỬ LÝ ĐĂNG NHẬP
' ==========================================================
If Request.Form("action") = "login" Then
    username_login = Replace(Request.Form("username"), "'", "''")
    password_login = sha256(Replace(Request.Form("password"), "'", "''"))
    
    openconn
    Set rsLogin = Server.CreateObject("ADODB.Recordset")
    rsLogin.Open "SELECT * FROM tbladmin WHERE username = '" & username_login & "' AND password = '" & password_login & "'", conn 
    
    If Not rsLogin.EOF Then 
        Session("username")               = rsLogin("username")
        Session("idadmin")                = rsLogin("idadmin")
        Session("is_super")               = rsLogin("is_super")
        Session("is_content")             = rsLogin("is_content")
        Session("is_genealogy")           = rsLogin("is_genealogy")
        Session("allowed_start_idgiapha") = rsLogin("allowed_start_idgiapha")
        
        rsLogin.Close : Set rsLogin = Nothing
        destroyconn
        Response.Redirect("?")
    Else
        Session("username") = ""
        Session("idadmin")  = ""
        rsLogin.Close : Set rsLogin = Nothing
        destroyconn
        Response.Write "<script>alert('Đăng nhập thất bại! Sai tài khoản hoặc mật khẩu.'); window.history.back();</script>"
        Response.End
    End If
End If
%>

<% 
' ==========================================================
' 2. GIAO DIỆN ĐĂNG NHẬP (NẾU CHƯA CÓ SESSION)
' ==========================================================
If Session("username") = "" Then 
    ' Truy vấn lấy ảnh background từ tblloadanh
    Dim bgImage, actualPath
    bgImage = "" 
    actualPath = ""
    
    On Error Resume Next
    openconn
    Set rsBg = conn.Execute("SELECT TOP 1 hinhanh FROM tblloadanh ORDER BY thutu ASC, idloadanh DESC")
    If Not rsBg.EOF Then
        bgImage = Trim(rsBg("hinhanh") & "")
        
        ' XỬ LÝ ĐƯỜNG DẪN: Đảm bảo đường dẫn tuyệt đối từ root
        If bgImage <> "" Then
            If Left(bgImage, 4) = "http" Or Left(bgImage, 1) = "/" Then
                actualPath = bgImage
            Else
                ' LƯU Ý: Nếu ảnh của bạn tải lên nằm trong thư mục cụ thể (ví dụ: upload, images), 
                ' hãy thêm tên thư mục vào đây. Ví dụ: actualPath = "/upload/" & bgImage
                actualPath = "/" & bgImage 
            End If
        End If
    End If
    rsBg.Close : Set rsBg = Nothing
    destroyconn
    Err.Clear
    On Error GoTo 0
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập Hệ thống Quản trị</title>
    <!-- Kế thừa Google Fonts từ hệ thống -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Roboto', sans-serif;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f0f2f5;
            <% If actualPath <> "" Then %>
            /* Set background động từ Database với đường dẫn đã chuẩn hóa */
            background-image: url('<%=actualPath%>');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            <% End If %>
        }
        /* Lớp phủ tối mờ để làm nổi bật form đăng nhập */
        .overlay {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1;
        }
        /* Hiệu ứng Glassmorphism cho thẻ đăng nhập */
        .login-card {
            background: rgba(255, 255, 255, 0.95);
            padding: 40px 30px;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 400px;
            z-index: 2;
            position: relative;
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .login-header h2 {
            color: #0a69db;
            font-size: 22px;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 8px;
        }
        .login-header p {
            color: #64748b;
            font-size: 14px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 8px;
            color: #334155;
        }
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 15px;
            transition: all 0.3s;
            font-family: inherit;
        }
        .form-control:focus {
            outline: none;
            border-color: #0a69db;
            box-shadow: 0 0 0 3px rgba(10, 105, 219, 0.15);
        }
        .btn-login {
            width: 100%;
            padding: 14px;
            background: #0a69db;
            color: #fff;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: background 0.3s, transform 0.1s;
            margin-top: 10px;
        }
        .btn-login:hover {
            background: #0852ab;
        }
        .btn-login:active {
            transform: translateY(1px);
        }
        .copyright {
            text-align: center;
            margin-top: 25px;
            font-size: 12px;
            color: #94a3b8;
        }
    </style>
</head>
<body>
    <div class="overlay"></div>
    <div class="login-card">
        <div class="login-header">
            <h2>Gia Phả Dòng Họ</h2>
            <p>Đăng nhập hệ thống quản trị</p>
        </div>
        <form name="frmLogin" method="post" action="?">
            <input type="hidden" name="action" value="login">
            
            <div class="form-group">
                <label for="username">Tên truy cập</label>
                <input id="username" name="username" type="text" class="form-control" required autocomplete="off" placeholder="Nhập tài khoản">
            </div>
            
            <div class="form-group">
                <label for="password">Mật khẩu</label>
                <input id="password" name="password" type="password" class="form-control" required placeholder="Nhập mật khẩu">
            </div>
            
            <button type="submit" name="submit" class="btn-login">Đăng nhập</button>
            
            <div class="copyright">
                &copy; <%=Year(Now())%> Hệ thống Quản trị Gia phả
            </div>
        </form>
    </div>
</body>
</html>
<% 
Else 
' ==========================================================
' 3. GIAO DIỆN QUẢN TRỊ (KHI ĐÃ ĐĂNG NHẬP)
' ==========================================================
Dim raw_gpdh, arr_gpdh
raw_gpdh = Request.QueryString("gpdh")

' [FIX LỖI CINT] Xử lý tình trạng IIS URL Rewrite gộp tham số thành chuỗi
If InStr(raw_gpdh, ",") > 0 Then
    arr_gpdh = Split(raw_gpdh, ",")
    gpdh = Trim(arr_gpdh(0))
Else
    gpdh = Trim(raw_gpdh)
End If

is_super = CInt("0" & Session("is_super"))
is_content = CInt("0" & Session("is_content"))
is_genealogy = CInt("0" & Session("is_genealogy"))

' Tự động nạp Font & Cỡ chữ cấu hình từ Database
openconn
Set rsConfig = conn.Execute("SELECT TOP 1 * FROM tblconfig")
If Not rsConfig.EOF Then
    currentFont = rsConfig("font_family") & ""
    On Error Resume Next
    currentFontSize = rsConfig("font_size") & ""
    Err.Clear
    On Error GoTo 0
End If
rsConfig.Close : Set rsConfig = Nothing
destroyconn

If currentFont = "" Then currentFont = "Arial, sans-serif"
If currentFontSize = "" Then currentFontSize = "14px"
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QUẢN TRỊ GIA PHẢ DÒNG HỌ</title>
    <link rel="stylesheet" type="text/css" href="/gpdh/css/cms.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fancybox/3.5.7/jquery.fancybox.min.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/fancybox/3.5.7/jquery.fancybox.min.js"></script>
    <script language="javascript" src="/gpdh/NgayThang.js"></script>
    <script language="javascript" src="/Editor/scripts/innovaeditor.js"></script>

    <!-- Nạp Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&family=Open+Sans:wght@400;700&family=Montserrat:wght@400;700&family=Lora:wght@400;700&family=Nunito:wght@400;700&family=Playfair+Display:wght@400;700&family=Merriweather:wght@400;700&family=Pattaya&family=Dancing+Script:wght@400;700&family=Quicksand:wght@400;700&display=swap" rel="stylesheet">
<style>
    /* ========================================================== */
    /* ĐỒNG BỘ HÓA TYPOGRAPHY TOÀN HỆ THỐNG                      */
    /* ========================================================== */
    body, html, input, select, textarea, button, table th, table td {
        font-family: <%=currentFont%> !important;
        font-size: <%=currentFontSize%> !important;
        line-height: 1.5;
        color: #334155;
    }

    /* Chuẩn hóa tỷ lệ phân cấp tiêu đề */
    h1 { font-size: 1.8rem !important; font-weight: bold; color: #0f172a; }
    h2 { font-size: 1.5rem !important; font-weight: bold; color: #0f172a; }
    h3 { font-size: 1.25rem !important; font-weight: bold; color: #0f172a; }

    /* Đồng bộ kích thước text bên trong các thành phần form */
    input[type="text"], input[type="password"], input[type="number"], select, textarea {
        font-size: 1rem !important;
        font-family: inherit !important;
    }

    /* Đồng bộ kích thước text trên bảng dữ liệu */
    .table-modern th, .table-modern td, .table-matrix th, .table-matrix td {
        font-size: 0.95rem !important;
        font-family: inherit !important;
    }
</style>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {background: #f0f2f5; color: #333;}
        
        /* Bố cục Card Layout chuẩn mực */
        .admin-card { background: #fff; border-radius: 6px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 25px; border: 1px solid #e2e8f0; overflow: hidden; }
        .admin-card-header { background: #f8fafc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0; font-weight: bold; color: #0f172a; font-size: 15px; text-transform: uppercase; display: flex; align-items: center; gap: 10px; }
        .admin-card-header i { color: #0a69db; font-size: 18px; }
        .admin-card-body { padding: 20px; }
        .font14 { font-size: 14px; }
        
        /* Top Navigation Bar */
        .topbar { height: 50px; background: #0a69db; display: flex; align-items: center; justify-content: space-between; padding: 0 20px; color: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); position: sticky; top: 0; z-index: 1000; }
        .topbar-left { display: flex; align-items: center; gap: 15px; }
        .btn-toggle-menu { background: none; border: none; color: #fff; font-size: 20px; cursor: pointer; padding: 5px 8px; border-radius: 4px; }
        .btn-toggle-menu:hover { background: rgba(255,255,255,0.15); }
        .brand-title { font-size: 16px; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; }
        .topbar-right { display: flex; align-items: center; gap: 15px; font-size: 13px; }
        .topbar-right a { color: #fff; text-decoration: none; padding: 4px 8px; border-radius: 4px; transition: 0.2s; }
        .topbar-right a:hover { background: rgba(255,255,255,0.2); }
        
        /* Layout Framework */
        .admin-wrapper { display: flex; min-height: calc(100vh - 50px); }
        
        /* Collapsible Sidebar Menu */
        .sidebar { width: 240px; background: #23282d; color: #eee; transition: all 0.25s ease; flex-shrink: 0; overflow-y: auto; }
        .sidebar.collapsed { width: 60px; }
        .sidebar-menu { list-style: none; padding: 10px 0; }
        .sidebar-menu li a { display: flex; align-items: center; padding: 12px 18px; color: #c3c4c7; text-decoration: none; font-size: 15px; font-weight: 500; transition: 0.2s; white-space: nowrap; }
        .sidebar-menu li a i { font-size: 16px; width: 24px; text-align: center; margin-right: 12px; flex-shrink: 0; }
        .sidebar.collapsed .sidebar-menu li a span { display: none; }
        .sidebar.collapsed .sidebar-menu li a i { margin-right: 0; width: 100%; }
        .sidebar-menu li a:hover, .sidebar-menu li.active a { background: #0a69db; color: #fff; }
        .sidebar-heading { font-size: 11px; text-transform: uppercase; padding: 12px 18px 6px; color: #888; font-weight: bold; letter-spacing: 0.5px; }
        .sidebar.collapsed .sidebar-heading { display: none; }

        /* Main Workspace Content Area */
        .main-content { flex: 1; padding: 25px; overflow-x: hidden; }

        /* Dashboard Overview Statistics Styles */
        .dashboard-container { max-width: 1200px; margin: 0 auto;}
        .clan-header-card { background: #fff; border-radius: 8px; padding: 25px; margin-bottom: 25px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); border-left: 5px solid #0a69db; }
        .clan-name { font-size: 24px; font-weight: bold; color: #0a69db; margin-bottom: 12px; text-transform: uppercase; }
        .clan-meta { display: flex; flex-wrap: wrap; gap: 20px; font-size: 14px; color: #555; }
        .clan-meta-item { display: flex; align-items: center; gap: 8px; }
        
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 20px; margin-bottom: 25px; }
        .stat-card { background: #fff; border-radius: 8px; padding: 20px; display: flex; align-items: center; gap: 15px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); border: 1px solid #e5e7eb; }
        .stat-icon { width: 50px; height: 50px; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0; }
        .stat-info { display: flex; flex-direction: column; }
        .stat-label { font-size: 13px; color: #6b7280; font-weight: 500; }
        .stat-value { font-size: 22px; font-weight: bold; color: #111827; margin-top: 2px; }

        .icon-blue { background: #ebf5ff; color: #0a69db; }
        .icon-green { background: #ecfdf5; color: #10b981; }
        .icon-male { background: #eff6ff; color: #2563eb; }
        .icon-female { background: #fdf2f8; color: #db2777; }
        .icon-spouse-female { background: #fff1f2; color: #e11d48; }
        .icon-spouse-male { background: #f0fdf4; color: #16a34a; }
        .icon-orange { background: #fff7ed; color: #ea580c; }

        .empty-state-card { background: #fff; border-radius: 8px; padding: 50px 20px; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }
        .empty-state-card i { font-size: 54px; color: #d1d5db; margin-bottom: 15px; }
        .empty-state-title { font-size: 18px; font-weight: bold; color: #374151; margin-bottom: 8px; }
        .empty-state-desc { font-size: 14px; color: #6b7280; margin-bottom: 20px; }
        .btn-create-root { display: inline-flex; align-items: center; gap: 8px; background: #0a69db; color: #fff; padding: 10px 24px; border-radius: 5px; font-size: 14px; font-weight: bold; text-decoration: none; transition: 0.2s; }
        .btn-create-root:hover { background: #0056b3; }
    </style>
</head>
<body>

    <!-- THANH ĐIỀU HƯỚNG TRÊN CÙNG -->
    <div class="topbar">
        <div class="topbar-left">
            <button class="btn-toggle-menu" onclick="toggleSidebar()" title="Đóng/Mở thanh công cụ"><i class="fa fa-bars"></i></button>
            <span class="brand-title">Quản Trị Gia Phả</span>
        </div>
        <div class="topbar-right">
    <span>Xin chào, <b><%= Session("username") %></b></span>
    <span>|</span>
    <!-- Thêm ?id= để phân biệt chế độ Đổi mật khẩu cá nhân hay Quản lý danh sách -->
    <a href="/gpdh/nguoi-dung/?id=<%= Session("idadmin") %>"><i class="fa fa-key"></i> Đổi mật khẩu</a>
    <a href="/gpdh/logout"><i class="fa fa-sign-out"></i> Thoát</a>
</div>
    </div>

    <!-- KHUNG LÀM VIỆC CHÍNH -->
    <div class="admin-wrapper">
        <!-- SIDEBAR MENU THÔNG MINH -->
        <div class="sidebar" id="mainSidebar">
            <ul class="sidebar-menu">
                <li class="<%If gpdh="" Then Response.Write "active"%>">
                    <a href="/gpdh/bang-dieu-khien"><i class="fa fa-tachometer"></i><span>Bảng điều khiển</span></a>
                </li>
                
                <% If is_super = 1 Or is_genealogy = 1 Then %>
                <div class="sidebar-heading">Phả hệ dòng họ</div>
                <li class="<%If gpdh="12" Then Response.Write "active"%>">
                    <a href="/gpdh/pha-do"><i class="fa fa-sitemap"></i><span>Quản lý phả đồ</span></a>
                </li>
                <li class="<%If gpdh="9" Then Response.Write "active"%>">
                    <a href="/gpdh/quan-ly-doi"><i class="fa fa-list-ol"></i><span>Quản lý đời</span></a>
                </li>
                <% End If %>

                <% If is_super = 1 Or is_content = 1 Then %>
                <div class="sidebar-heading">Nội dung tư liệu</div>
                <li class="<%If gpdh="2" Or gpdh="1" Or gpdh="3" Then Response.Write "active"%>">
                    <a href="/gpdh/tin-tuc"><i class="fa fa-newspaper-o"></i><span>Tin tức & Sự kiện</span></a>
                </li>
                <li class="<%If gpdh="18" Then Response.Write "active"%>">
                    <a href="/gpdh/nhom-tin"><i class="fa fa-newspaper-o"></i><span>Quản lý nhóm tin</span></a>
                </li>
                <li class="<%If gpdh="29" Then Response.Write "active"%>">
                    <a href="/gpdh/gioi-thieu"><i class="fa fa-book"></i><span>Giới thiệu ngắn</span></a>
                </li>
                <li class="<%If gpdh="6" Or gpdh="5" Or gpdh="7" Then Response.Write "active"%>">
                    <a href="/gpdh/thong-tin-dong-ho"><i class="fa fa-book"></i><span>Thông tin dòng họ</span></a>
                </li>
                <li class="<%If gpdh="23" Or gpdh="24"  Or gpdh="25" Then Response.Write "active"%>">
                    <a href="/gpdh/thu-vien-anh"><i class="fa fa-picture-o"></i><span>Thư viện hình ảnh</span></a>
                </li>
                <li class="<%If gpdh="26" Then Response.Write "active"%>">
                    <a href="/gpdh/thu-vien-video"><i class="fa fa-video-camera"></i><span>Thư viện video</span></a>
                </li>
                <li class="<%If gpdh="8" Then Response.Write "active"%>">
                    <a href="/gpdh/slider-anh"><i class="fa fa-cogs"></i><span>Quản lý slider ảnh</span></a>
                </li>
                <% End If %>

                <% If is_super = 1 Then %>
                <div class="sidebar-heading">Hệ thống</div>
                <li class="<%If gpdh="4" Then Response.Write "active"%>">
                    <a href="/gpdh/cau-hinh"><i class="fa fa-cogs"></i><span>Cấu hình website</span></a>
                </li>
                <li class="<%If gpdh="10" Then Response.Write "active"%>">
                    <a href="/gpdh/cau-hinh-text"><i class="fa fa-cogs"></i><span>Cấu hình text</span></a>
                </li>
                <li class="<%If gpdh="30" Or gpdh="31" Then Response.Write "active"%>">
                    <a href="/gpdh/nguoi-dung"><i class="fa fa-users"></i><span>Quản lý người dùng</span></a>
                </li>
                <% End If %>
            </ul>
        </div>

        <!-- WORKSPACE CONTENT -->
        <div class="main-content">
            <% If gpdh <> "" Then %>
                <% 
                Select Case CInt("0" & gpdh)
                    Case 1:  %><!--#include file="tintuc_new.asp"--><%
                    Case 2:  %><!--#include file="tintuc_list.asp"--><%
                    Case 3:  %><!--#include file="tintuc_edit.asp"--><%
                    Case 4:  %><!--#include file="config.asp"--><%
                    Case 5:  %><!--#include file="thongtin_new.asp"--><%
                    Case 6:  %><!--#include file="thongtin_list.asp"--><%
                    Case 7:  %><!--#include file="thongtin_edit.asp"--><%
                    Case 8:  %><!--#include file="loadanh.asp"--><%
                    Case 9:  %><!--#include file="doi_list.asp"--><%
                    Case 10:  %><!--#include file="config_text.asp"--><%
                    Case 12: %><!--#include file="giapha_list.asp"--><%
                    Case 13: %><!--#include file="giapha_new.asp"--><%
                    Case 14: %><!--#include file="giapha_edit.asp"--><%
                    Case 15: %><!--#include file="giaphangoai_new.asp"--><%
                    Case 16: %><!--#include file="giaphangoai_list.asp"--><%
                    Case 18: %><!--#include file="nhomtin_list.asp"--><%
                    Case 23: %><!--#include file="nhomanh_list.asp"--><%
                    Case 24: %><!--#include file="nhomanh_new.asp"--><%
                    Case 25: %><!--#include file="nhomanh_edit.asp"--><%
                    Case 26: %><!--#include file="video_list.asp"--><%
                    Case 29: %><!--#include file="gioithieu.asp"--><%
                    Case 30: %><!--#include file="user_list.asp"--><%
                    Case 32: %><!--#include file="logout.asp"--><%
                End Select
                %>
            <% Else %>
                <!-- BẢNG ĐIỀU KHIỂN - THỐNG KÊ TỔNG QUAN -->
                <%
                openconn
                db_dongho = "" : db_diachi = "" : db_dienthoai = ""
                
                On Error Resume Next
                Set rsConfig = conn.Execute("SELECT * FROM tblconfig")
                If Not rsConfig.EOF Then
                    For Each fieldItem In rsConfig.Fields
                        If LCase(fieldItem.Name) = "dongho" Then db_dongho = fieldItem.Value & ""
                        If LCase(fieldItem.Name) = "diachi" Then db_diachi = fieldItem.Value & ""
                        If LCase(fieldItem.Name) = "dienthoai" Then db_dienthoai = fieldItem.Value & ""
                    Next
                End If
                rsConfig.Close : Set rsConfig = Nothing
                Err.Clear
                On Error GoTo 0
                
                c_doi = 0 : c_total = 0 : c_nam = 0 : c_nu = 0 : c_dau = 0 : c_re = 0 : c_ngoai = 0
                
                Set rsDash = conn.Execute("SELECT COUNT(*) FROM tbldoi")
                c_doi = CInt("0" & rsDash(0)) : rsDash.Close
                
                Set rsDash = conn.Execute("SELECT COUNT(*) FROM tblgiapha")
                c_total = CInt("0" & rsDash(0)) : rsDash.Close
                
                If c_total > 0 Then
                    Set rsDash = conn.Execute("SELECT COUNT(*) FROM tblgiapha WHERE gioitinh = 1 AND (loai_quanhe IS NULL OR loai_quanhe = 1)")
                    c_nam = CInt("0" & rsDash(0)) : rsDash.Close
                    
                    Set rsDash = conn.Execute("SELECT COUNT(*) FROM tblgiapha WHERE gioitinh = 2 AND (loai_quanhe IS NULL OR loai_quanhe = 1)")
                    c_nu = CInt("0" & rsDash(0)) : rsDash.Close
                    
                    Set rsDash = conn.Execute("SELECT COUNT(*) FROM tblgiapha WHERE gioitinh = 2 AND loai_quanhe = 2")
                    c_dau = CInt("0" & rsDash(0)) : rsDash.Close
                    
                    Set rsDash = conn.Execute("SELECT COUNT(*) FROM tblgiapha WHERE gioitinh = 1 AND loai_quanhe = 2")
                    c_re = CInt("0" & rsDash(0)) : rsDash.Close
                    
                    Set rsDash = conn.Execute("SELECT COUNT(*) FROM tblgiapha WHERE loai_quanhe = 3")
                    c_ngoai = CInt("0" & rsDash(0)) : rsDash.Close
                End If

                ' ==========================================================
                ' XỬ LÝ HẠN MỨC GIA TỘC (KHI KẾT NỐI ĐANG MỞ)
                ' ==========================================================
                Dim totalNow, maxDinh, phanTram, mauSac
                totalNow = 0 : maxDinh = 100
                Call KiemTraHanMucGiaPha(totalNow, maxDinh)

                If maxDinh > 0 Then
                    phanTram = Round((totalNow / maxDinh) * 100, 1)
                    If phanTram > 100 Then phanTram = 100
                    If phanTram >= 90 Then
                        mauSac = "#e74c3c" ' Đỏ (Sắp đầy)
                    ElseIf phanTram >= 70 Then
                        mauSac = "#f39c12" ' Vàng cam
                    Else
                        mauSac = "#10b981" ' Xanh lá
                    End If
                Else
                    phanTram = 100
                    mauSac = "#0a69db" ' Xanh dương (Không giới hạn)
                End If

                destroyconn
                %>

                <div class="dashboard-container">
                    <!-- THÔNG TIN DÒNG HỌ -->
                    <div class="clan-header-card">
                        <div class="clan-name">
                            <% If db_dongho <> "" Then Response.Write db_dongho Else Response.Write "GIA PHẢ DÒNG HỌ" End If %>
                        </div>
                        <div class="clan-meta">
                            <% If db_diachi <> "" Then %>
                            <div class="clan-meta-item"><i class="fa fa-map-marker text-danger"></i> <b>Địa chỉ:</b> <%= db_diachi %></div>
                            <% End If %>
                            <% If db_dienthoai <> "" Then %>
                            <div class="clan-meta-item"><i class="fa fa-phone text-success"></i> <b>Điện thoại:</b> <%= db_dienthoai %></div>
                            <% End If %>
                        </div>
                    </div>

                    <!-- BỘ ĐẾM SỐ LƯỢNG -->
                    <% If c_total = 0 Then %>
                        <div class="empty-state-card" style="margin-bottom: 25px;">
                            <i class="fa fa-folder-open-o"></i>
                            <div class="empty-state-title">Hệ thống Gia phả chưa có dữ liệu thành viên</div>
                            <div class="empty-state-desc">Chào mừng bạn đến với trang quản trị. Hãy bắt đầu bằng cách tạo vị Thủy Tổ đầu tiên cho dòng họ.</div>
                            <a href="javascript:void(0);" onclick="$.fancybox.open({src: '/gpdh/them-nhan-vat/?sessionpage=0', type: 'iframe', opts: {iframe: {css: {width: '800px', height: '90%'}}}});" class="btn-create-root">
                                <i class="fa fa-user-plus"></i> Khởi tạo Thủy Tổ
                            </a>
                        </div>
                    <% Else %>
                        <div class="stats-grid">
                            <% If c_doi > 0 Then %>
                            <div class="stat-card">
                                <div class="stat-icon icon-blue"><i class="fa fa-hourglass-half"></i></div>
                                <div class="stat-info"><span class="stat-label">Số đời</span><span class="stat-value"><%= c_doi %></span></div>
                            </div>
                            <% End If %>

                            <div class="stat-card">
                                <div class="stat-icon icon-green"><i class="fa fa-users"></i></div>
                                <div class="stat-info"><span class="stat-label">Tổng thành viên</span><span class="stat-value"><%= c_total %></span></div>
                            </div>

                            <% If c_nam > 0 Then %>
                            <div class="stat-card">
                                <div class="stat-icon icon-male"><i class="fa fa-male"></i></div>
                                <div class="stat-info"><span class="stat-label">Đinh nam</span><span class="stat-value"><%= c_nam %></span></div>
                            </div>
                            <% End If %>

                            <% If c_nu > 0 Then %>
                            <div class="stat-card">
                                <div class="stat-icon icon-female"><i class="fa fa-female"></i></div>
                                <div class="stat-info"><span class="stat-label">Đinh nữ</span><span class="stat-value"><%= c_nu %></span></div>
                            </div>
                            <% End If %>

                            <% If c_dau > 0 Then %>
                            <div class="stat-card">
                                <div class="stat-icon icon-spouse-female"><i class="fa fa-heart"></i></div>
                                <div class="stat-info"><span class="stat-label">Con dâu</span><span class="stat-value"><%= c_dau %></span></div>
                            </div>
                            <% End If %>

                            <% If c_re > 0 Then %>
                            <div class="stat-card">
                                <div class="stat-icon icon-spouse-male"><i class="fa fa-handshake-o"></i></div>
                                <div class="stat-info"><span class="stat-label">Con rể</span><span class="stat-value"><%= c_re %></span></div>
                            </div>
                            <% End If %>

                            <% If c_ngoai > 0 Then %>
                            <div class="stat-card">
                                <div class="stat-icon icon-orange"><i class="fa fa-child"></i></div>
                                <div class="stat-info"><span class="stat-label">Cháu ngoại</span><span class="stat-value"><%= c_ngoai %></span></div>
                            </div>
                            <% End If %>
                        </div>
                    <% End If %>

                    <!-- KHỐI QUY MÔ NHÂN KHẨU GIA TỘC (DƯỚI BỘ ĐẾM SỐ LƯỢNG) -->
                    <div style="background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; margin-bottom: 25px; box-shadow: 0 1px 3px rgba(0,0,0,0.06);">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                            <span style="font-weight: 700; font-size: 15px; color: #1e293b; display: flex; align-items: center; gap: 8px;">
                                <i class="fa fa-bar-chart" style="color: #0a69db;"></i> Quy mô nhân khẩu gia tộc
                            </span>
                            <span style="font-size: 14px; font-weight: bold; color: <%=mauSac%>;">
                                <%=totalNow%> / <% If maxDinh = 0 Then %>Không giới hạn<% Else %><%=maxDinh%> người<% End If %>
                                <% If maxDinh > 0 Then %>(<%=phanTram%>%)<% End If %>
                            </span>
                        </div>

                        <% If maxDinh > 0 Then %>
                        <div style="width: 100%; background: #edf2f7; height: 10px; border-radius: 5px; overflow: hidden;">
                            <div style="width: <%=phanTram%>%; height: 100%; background: <%=mauSac%>; transition: width 0.5s ease-in-out;"></div>
                        </div>
                        <% If phanTram >= 85 Then %>
                        <p style="margin: 10px 0 0 0; font-size: 13px; color: #c0392b; font-style: italic;">
                            ⚠️ Dòng họ sắp sử dụng hết hạn mức nhân khẩu cho phép. Vui lòng liên hệ ban quản trị để mở rộng thêm khi cần thiết.
                        </p>
                        <% End If %>
                        <% Else %>
                        <div style="font-size: 13px; color: #10b981; font-weight: 500;">
                            ✓ Website đang áp dụng gói quy mô lớn không giới hạn số lượng thành viên.
                        </div>
                        <% End If %>
                    </div>
                </div>
            <% End If %>
        </div>
    </div>

    <!-- SCRIPT ĐIỀU KHIỂN SIDEBAR TOGGLE -->
    <script>
    function toggleSidebar() {
        var sb = document.getElementById('mainSidebar');
        sb.classList.toggle('collapsed');
        localStorage.setItem('sidebar_collapsed', sb.classList.contains('collapsed'));
    }

    $(document).ready(function() {
        if (localStorage.getItem('sidebar_collapsed') === 'true') {
            $('#mainSidebar').addClass('collapsed');
        }
    });
    </script>
</body>
</html>
<% End If %>