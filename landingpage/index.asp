<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%Session.CodePage=65001%>
<%
Dim isLogged, btnText, btnLink, btnIcon
If Session("KhachHangID") <> "" Then
    isLogged = True
    btnText = "QUẢN LÝ"
    btnLink = "/user/" ' Đường dẫn vào trang quản trị của khách hàng
    btnIcon = "<path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z'></path><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M15 12a3 3 0 11-6 0 3 3 0 016 0z'></path>"
Else
    isLogged = False
    btnText = "ĐĂNG NHẬP"
    btnLink = "javascript:openLoginModal();"
    btnIcon = "<path fill-rule='evenodd' d='M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z' clip-rule='evenodd' />"
End If
%>
<!DOCTYPE html>
...
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Tiêu đề trang (Tối ưu cho cả SEO và hiển thị tab) -->
    <title>Gia Phả Dòng Họ - Kết nối dòng tộc, tôn vinh tổ tiên</title>
    
    <!-- Thẻ Meta SEO Cơ Bản -->
    <meta name="description" content="Nền tảng thiết kế và quản lý gia phả dòng họ trực tuyến chuyên nghiệp. Dễ dàng lập sơ đồ phả hệ, quản lý thành viên, tự động nhắc ngày giỗ chạp và lưu trữ tư liệu số an toàn.">
    <meta name="keywords" content="gia phả dòng họ, phần mềm gia phả, quản lý gia phả, sơ đồ phả hệ, lập gia phả trực tuyến, cây gia phả, thiết kế gia phả, ứng dụng gia phả">
    <meta name="author" content="Gia Phả Dòng Họ">
    <meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large, max-video-preview:-1">

    <!-- Thẻ Open Graph (Tối ưu chia sẻ Facebook, Zalo, LinkedIn) -->
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://giaphadongho.com.vn/">
    <meta property="og:title" content="Gia Phả Dòng Họ - Kết nối dòng tộc, tôn vinh tổ tiên">
    <meta property="og:description" content="Giải pháp lưu giữ truyền thống gia tộc muôn đời. Lập phả đồ, quản lý hồ sơ thành viên, tự động nhắc giỗ chạp và lưu trữ tư liệu số bảo mật tuyệt đối.">
    <meta property="og:image" content="https://giaphadongho.com.vn/bgchinh.jpg">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="630">
    <meta property="og:image:alt" content="Hệ thống quản lý gia phả dòng họ">
    <meta property="og:site_name" content="Gia Phả Dòng Họ">

    <!-- Thẻ Twitter Card (Tối ưu chia sẻ X/Twitter) -->
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="Gia Phả Dòng Họ - Kết nối dòng tộc, tôn vinh tổ tiên">
    <meta name="twitter:description" content="Giải pháp lưu giữ truyền thống gia tộc muôn đời. Lập phả đồ, quản lý hồ sơ thành viên, tự động nhắc giỗ chạp.">
    <meta name="twitter:image" content="https://giaphadongho.com.vn/bgchinh.jpg">

    <!-- Favicon (Icon trên tab trình duyệt) -->
    <link rel="icon" href="icon.png" type="image/png">
    <link rel="apple-touch-icon" href="icon.png">
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Italianno&family=Philosopher:ital,wght@0,400;0,700;1,400;1,700&display=swap" rel="stylesheet">
    
    <!-- Swiper CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.css" />
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        philo: ['Philosopher', 'sans-serif'],
                        ital: ['Italianno', 'cursive'],
                    },
                    colors: {
                        gold: '#d1a659',
                        brandGreen: '#005a3c',
                        brandRed: '#E53935',
                        bgCream: '#fcfaf5',
                        textDark: '#333333',
                    }
                }
            }
        }
    </script>
    <style>
        /* Smooth scrolling */
        html { scroll-behavior: smooth; }
        
        body {
            background-color: #fcfaf5;
            background-image: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23d1a659' fill-opacity='0.05'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
        }

        /* Swiper Customizations */
        .swiper-button-next, .swiper-button-prev { 
            color: #d1a659 !important; 
            top: 50% !important; 
            text-shadow: 0 2px 4px rgba(0,0,0,0.8);
        }
        .swiper-button-next { right: 20px !important; }
        .swiper-button-prev { left: 20px !important; }
        
        .swiper-pagination {
            bottom: 25px !important; 
        }
        .swiper-pagination-bullet { background-color: #ffffff; opacity: 0.6; }
        .swiper-pagination-bullet-active { background-color: #d1a659 !important; opacity: 1; }
        
        /* Mobile menu transition */
        #mobile-menu {
            transition: max-height 0.3s ease-in-out;
            max-height: 0;
            overflow: hidden;
        }
        #mobile-menu.open { max-height: 600px; }
        
        /* Custom UI elements */
        .divider-floral {
            height: 15px;
            background-image: radial-gradient(circle, #d1a659 2px, transparent 2.5px);
            background-size: 15px 15px;
            background-position: center;
        }
    </style>
</head>
<body class="font-philo antialiased text-textDark">

    <!-- Header -->
    <header class="fixed w-full top-0 z-50 bg-white/95 backdrop-blur-md shadow-sm transition-all duration-300">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center h-24">
                <!-- Logo -->
                <div class="flex-shrink-0 cursor-pointer" onclick="window.scrollTo(0,0)">
                    <img class="h-16 w-auto" src="logo.png" alt="Logo Gia Phả Dòng Họ">
                </div>
                
                <!-- Desktop Navigation -->
                <nav class="hidden md:flex space-x-6 lg:space-x-8 items-center">
                    <a href="#gioi-thieu" class="text-textDark hover:text-gold font-bold transition-colors text-base lg:text-lg uppercase tracking-wide">Giới thiệu</a>
                    <a href="#tinh-nang" class="text-textDark hover:text-gold font-bold transition-colors text-base lg:text-lg uppercase tracking-wide">Tính năng</a>
                    <a href="#bang-gia" class="text-textDark hover:text-gold font-bold transition-colors text-base lg:text-lg uppercase tracking-wide">Bảng giá</a>
                    
                    <!-- Menu Dropdown TIN TỨC -->
                    <div class="relative group cursor-pointer py-4">
                        <a href="tintuc_list.asp" class="text-textDark group-hover:text-gold font-bold transition-colors text-base lg:text-lg uppercase tracking-wide flex items-center gap-1">
                            Tin tức
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 transition-transform group-hover:rotate-180" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" /></svg>
                        </a>
                        <!-- Khối Menu con -->
                        <div class="absolute left-0 mt-2 w-56 bg-white border border-gray-100 shadow-xl rounded-xl opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-300 transform translate-y-2 group-hover:translate-y-0 z-50 overflow-hidden">
                            <a href="cam-nang.asp" class="block px-5 py-3 text-textDark hover:bg-gold/10 hover:text-brandGreen font-medium transition-colors border-b border-gray-50">Cẩm nang gia phả</a>
                            <a href="dich-vu.asp" class="block px-5 py-3 text-textDark hover:bg-gold/10 hover:text-brandGreen font-medium transition-colors">Dịch vụ thiết kế phả đồ</a>
                        </div>
                    </div>

                    <a href="#dang-ky" class="text-textDark hover:text-gold font-bold transition-colors text-base lg:text-lg uppercase tracking-wide">Đăng ký</a>
                    
                    <!-- Vách ngăn phân tách -->
                    <div class="h-6 w-px bg-gray-300 mx-1"></div>

                    <!-- Nút ĐĂNG NHẬP -->
                    <a href="<%=btnLink%>" class="text-brandGreen hover:text-gold font-bold transition-colors text-base lg:text-lg uppercase tracking-wide flex items-center gap-1">
    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
        <%=btnIcon%>
    </svg>
    <%=btnText%>
</a>

                </nav>
                <!-- Mobile menu button -->
                <div class="md:hidden flex items-center">
                    <button id="mobile-menu-btn" class="text-brandGreen hover:text-gold focus:outline-none p-2">
                        <svg class="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>

<!-- Mobile Navigation Menu -->
        <div id="mobile-menu" class="md:hidden bg-white border-t border-gray-100">
            <div class="px-4 pt-2 pb-6 space-y-1 shadow-inner">
                <a href="#gioi-thieu" class="block px-3 py-3 rounded-md text-base font-bold text-textDark hover:text-gold hover:bg-gray-50 uppercase">Giới thiệu</a>
                <a href="#tinh-nang" class="block px-3 py-3 rounded-md text-base font-bold text-textDark hover:text-gold hover:bg-gray-50 uppercase">Tính năng</a>
                <a href="#bang-gia" class="block px-3 py-3 rounded-md text-base font-bold text-textDark hover:text-gold hover:bg-gray-50 uppercase">Bảng giá</a>
                
                <!-- Nhóm TIN TỨC trên Mobile -->
                <div class="px-3 py-2">
                    <span class="block text-base font-bold text-textDark uppercase mb-2">Tin tức</span>
                    <div class="pl-4 border-l-2 border-gold/30 space-y-2">
                        <a href="cam-nang.asp" class="block py-2 text-gray-600 hover:text-brandGreen font-medium">Cẩm nang gia phả</a>
                        <a href="dich-vu.asp" class="block py-2 text-gray-600 hover:text-brandGreen font-medium">Dịch vụ thiết kế phả đồ</a>
                    </div>
                </div>

                <a href="#dang-ky" class="block px-3 py-3 rounded-md text-base font-bold text-textDark hover:text-gold hover:bg-gray-50 uppercase">Đăng ký</a>
                
                <!-- Cụm Hành động (Đăng nhập + Hotline) -->
                <div class="mt-4 pt-4 border-t border-gray-100 space-y-3">
                    <a href="<%=btnLink%>" class="w-full flex justify-center items-center gap-2 px-4 py-3 bg-gray-50 rounded-md text-base font-bold text-textDark hover:bg-gray-100 uppercase">
    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-brandGreen" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <%=btnIcon%>
    </svg>
    <%=btnText%>
</a>
                    <a href="tel:0915555977" class="w-full flex justify-center px-4 py-3 border border-gold rounded-md text-base font-bold text-brandGreen bg-white shadow-sm">
                        HOTLINE: 0915 555 977
                    </a>
                </div>
            </div>
        </div>
    </header>

    <!-- Giới thiệu (Hero Section) -->
    <section id="gioi-thieu" class="relative pt-24 pb-32 flex items-center min-h-[80vh] md:min-h-[90vh] mt-24 md:mt-0">
        <div class="absolute inset-0 z-0">
            <div class="absolute inset-0" style="background-image: url('bgslider.jpg'); background-size: cover; background-position: center;"></div>
            <div class="absolute inset-0 bg-gradient-to-r from-[#2a1a0f]/90 via-[#2a1a0f]/70 to-transparent"></div>
        </div>

        <div class="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
            <div class="max-w-3xl">
                <h1 class="mb-4">
                    <span class="block font-ital text-gold text-6xl md:text-7xl lg:text-8xl mb-2 drop-shadow-lg">Nguồn cội tâm giao</span>
                    <span class="block text-4xl md:text-6xl lg:text-7xl font-bold text-white uppercase drop-shadow-md mt-2">Hệ Thống<br>Gia Phả Dòng Họ</span>
                </h1>
                
                <p class="mt-6 text-lg md:text-xl text-gray-200 leading-relaxed drop-shadow-md border-l-4 border-gold pl-4">
                    Tự hào tiếp nối truyền thống cha ông. Nơi lưu giữ những giá trị văn hóa, lịch sử<br>và kết nối các thế hệ con cháu trên khắp mọi miền tổ quốc.
                </p>
                
                <div class="mt-10">
                    <a href="https://hobuixuanbang.com" target="_blank" rel="noopener noreferrer" class="px-10 py-4 bg-gold text-white rounded-full font-bold text-lg hover:bg-yellow-600 transition-all duration-300 transform hover:-translate-y-1 shadow-[0_5px_15px_rgba(209,166,89,0.4)] flex items-center gap-2 inline-flex">
    XEM DEMO
    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M14.707 10.293a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 111.414-1.414L9 12.586V5a1 1 0 012 0v7.586l2.293-2.293a1 1 0 011.414 0z" clip-rule="evenodd" />
    </svg>
</a>
                </div>
            </div>
        </div>
    </section>

    <!-- Tính năng Section -->
    <section id="tinh-nang" class="pt-20 md:pt-28 relative">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 mb-10 text-center">
            <h2 class="text-3xl md:text-5xl font-bold text-brandGreen uppercase tracking-wider">Tính năng hệ thống</h2>
            <div class="w-32 mx-auto mt-6 divider-floral"></div>
        </div>

        <!-- Swiper Container - Full Width với Gradient Tối -> Sáng ở đáy -->
        <div class="swiper mySwiper w-full h-[75vh] md:h-[85vh] bg-black">
            <div class="swiper-wrapper" id="features-wrapper">
                <!-- Slides injected via JS -->
            </div>
            
            <div class="swiper-pagination"></div>
            <div class="swiper-button-next"></div>
            <div class="swiper-button-prev"></div>
        </div>
    </section>

    <!-- Bảng giá Section -->
    <section id="bang-gia" class="py-20 md:py-28 relative">
        <div class="absolute inset-0 z-0 opacity-10">
            <div class="absolute inset-0" style="background-image: url('background.jpg'); background-size: cover; background-position: center; filter: grayscale(50%);"></div>
        </div>
        
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
            <div class="text-center mb-16">
                <h2 class="text-3xl md:text-5xl font-bold text-brandGreen uppercase tracking-wider">Bảng giá dịch vụ</h2>
                <div class="w-32 mx-auto mt-6 divider-floral"></div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
                <!-- Cơ bản 1 -->
                <div class="bg-white rounded-xl shadow-lg border-t-4 border-gray-200 flex flex-col hover:border-gold hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2">
                    <div class="p-8 flex-1 text-center">
                        <h3 class="text-3xl font-bold text-brandGreen mb-2">GÓI CHI HỌ</h3>
                        <p class="text-brandGreen font-medium mb-6 pb-4 border-b border-gray-100">Dành cho các nhánh nhỏ, gia đình dưới 100 người</p>
                        
                        <ul class="space-y-4 mb-8 text-textDark text-sm md:text-base text-left">
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Cập nhật được 100 người</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Sử dụng đầy đủ tính năng</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Hỗ trợ thiết kế logo</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Hỗ trợ kỹ thuật trong giờ hành chính</li>
                        </ul>
                        
                        <div class="mt-auto space-y-3 pt-6 border-t border-gray-100 text-left bg-gray-50 p-4 rounded-lg">
                            <div class="flex flex-col items-center justify-center">
                                <span class="text-gray-500 font-medium mb-1">Chi phí năm đầu tiên</span>
                                <span class="text-brandRed font-bold text-2xl">1.300.000 Đ</span>
                            </div>
                            
                            <div class="flex flex-col items-center justify-center mt-4 pt-4 border-t border-gray-200">
                                <span class="text-gray-500 font-medium mb-1">Duy trì các năm tiếp theo</span>
                                <span class="text-brandRed font-bold text-2xl">800.000 Đ</span>
                            </div>
                        </div>
                    </div>
                    <div class="p-6 pt-0">
                        <button onclick="selectPackage('Gói chi họ')" class="w-full bg-brandGreen text-white font-bold rounded-full py-3 hover:bg-green-800 transition-colors shadow-md">Đăng ký gói này</button>
                    </div>
                </div>

                <!-- Cơ bản 2 -->
                <div class="bg-white rounded-xl shadow-lg border-t-4 border-brandGreen flex flex-col hover:border-gold hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2">
                    <div class="p-8 flex-1 text-center">
                        <h3 class="text-3xl font-bold text-brandGreen mb-2">GÓI PHÁI HỆ</h3>
                        <p class="text-brandGreen font-medium mb-6 pb-4 border-b border-gray-100">Dành cho các phái, hệ vừa phải từ 100 - 200 người</p>
                        
                        <ul class="space-y-4 mb-8 text-textDark text-sm md:text-base text-left">
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Cập nhật được 200 người</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Sử dụng đầy đủ tính năng</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Hỗ trợ thiết kế logo</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Hỗ trợ kỹ thuật trong giờ hành chính</li>
                        </ul>
                        
                        <div class="mt-auto space-y-3 pt-6 border-t border-gray-100 text-left bg-gray-50 p-4 rounded-lg">
                            <div class="flex flex-col items-center justify-center">
                                <span class="text-gray-500 font-medium mb-1">Chi phí năm đầu tiên</span>
                                <span class="text-brandRed font-bold text-2xl">2.000.000 Đ</span>
                            </div>
                            <div class="flex flex-col items-center justify-center mt-4 pt-4 border-t border-gray-200">
                                <span class="text-gray-500 font-medium mb-1">Duy trì các năm tiếp theo</span>
                                <span class="text-brandRed font-bold text-2xl">1.000.000 Đ</span>
                            </div>
                        </div>
                    </div>
                    <div class="p-6 pt-0">
                        <button onclick="selectPackage('Gói phái hệ')" class="w-full bg-brandGreen text-white font-bold rounded-full py-3 hover:bg-green-800 transition-colors shadow-md">Đăng ký gói này</button>
                    </div>
                </div>

                <!-- Cơ bản 3 -->
                <div class="bg-white rounded-xl shadow-lg border-t-4 border-gray-200 flex flex-col hover:border-gold hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2">
                    <div class="p-8 flex-1 text-center">
                        <h3 class="text-3xl font-bold text-brandGreen mb-2">GÓI TỘC HỆ</h3>
                        <p class="text-brandGreen font-medium mb-6 pb-4 border-b border-gray-100">Dành cho dòng họ quy mô từ 200 - 400 người</p>
                        
                        <ul class="space-y-4 mb-8 text-textDark text-sm md:text-base text-left">
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Cập nhật được 400 người</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Sử dụng đầy đủ tính năng</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Hỗ trợ thiết kế logo</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Hỗ trợ import dữ liệu từ file Excel chuẩn</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Hỗ trợ kỹ thuật 24/7</li>
                        </ul>
                        
                        <div class="mt-auto space-y-3 pt-6 border-t border-gray-100 text-left bg-gray-50 p-4 rounded-lg">
                            <div class="flex flex-col items-center justify-center">
                                <span class="text-gray-500 font-medium mb-1">Chi phí năm đầu tiên</span>
                                <span class="text-brandRed font-bold text-2xl">2.700.000 Đ</span>
                            </div>
                            <div class="flex flex-col items-center justify-center mt-4 pt-4 border-t border-gray-200">
                                <span class="text-gray-500 font-medium mb-1">Duy trì các năm tiếp theo</span>
                                <span class="text-brandRed font-bold text-2xl">1.200.000 Đ</span>
                            </div>
                        </div>
                    </div>
                    <div class="p-6 pt-0">
                        <button onclick="selectPackage('Gói tộc hệ')" class="w-full bg-brandGreen text-white font-bold rounded-full py-3 hover:bg-green-800 transition-colors shadow-md">Đăng ký gói này</button>
                    </div>
                </div>

                <!-- Cao cấp -->
                <div class="bg-brandGreen rounded-xl shadow-2xl border border-brandGreen flex flex-col hover:shadow-[0_10px_30px_rgba(0,90,60,0.3)] transition-all duration-300 relative overflow-hidden transform lg:-translate-y-4">
                    <div class="absolute top-0 right-0 bg-gold text-white text-xs font-bold px-4 py-1 rounded-bl-lg">Khuyên Dùng</div>
                    
                    <div class="p-8 flex-1 text-center">
                        <h3 class="text-3xl font-bold text-white mb-2">GÓI ĐẠI TÔN</h3>
                        <p class="text-gold font-medium mb-6 pb-4 border-b border-white/20">Dành cho nhà thờ tổ, có quy mô lớn</p>
                        
                        <ul class="space-y-4 mb-8 text-white text-sm md:text-base text-left">
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span><span class="font-bold">Không giới hạn số lượng</span></li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Sử dụng đầy đủ tính năng</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Hỗ trợ thiết kế logo</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Hỗ trợ import dữ liệu từ file Excel chuẩn</li>
                            <li class="flex items-start"><span class="text-gold mr-3">❖</span>Hỗ trợ kỹ thuật 24/7</li>
                        </ul>
                        
                        <div class="mt-auto space-y-3 pt-6 border-t border-white/20 text-left bg-black/20 p-4 rounded-lg">
                            <div class="flex flex-col items-center justify-center">
                                <span class="text-gray-300 font-medium mb-1">Chi phí năm đầu tiên</span>
                                <span class="text-gold font-bold text-2xl">3.500.000 Đ</span>
                            </div>
                            <div class="flex flex-col items-center justify-center mt-4 pt-4 border-t border-white/20">
                                <span class="text-gray-300 font-medium mb-1">Duy trì các năm tiếp theo</span>
                                <span class="text-gold font-bold text-2xl">1.500.000 Đ</span>
                            </div>
                        </div>
                    </div>
                    <div class="p-6 pt-0">
                        <button onclick="selectPackage('Gói đại tôn')" class="w-full bg-gold text-white font-bold rounded-full py-3 hover:bg-yellow-600 transition-colors shadow-lg">Đăng ký gói này</button>
                    </div>
                </div>

            </div>

            <!-- Ghi chú -->
            <div class="mt-12 bg-white border border-gray-200 p-6 rounded-xl max-w-4xl mx-auto flex items-start gap-4 shadow-sm">
                <div class="w-10 h-10 rounded-full bg-gold/10 flex items-center justify-center shrink-0">
                    <svg class="h-6 w-6 text-gold" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
                <div>
                    <h4 class="text-brandGreen font-bold text-lg mb-1">Ghi chú:</h4>
                    <p class="text-gray-600 text-sm md:text-base leading-relaxed">
                        Tên miền (Domain) và Chứng chỉ bảo mật (SSL) sẽ do dòng họ chủ động đăng ký hoặc bộ phận kỹ thuật GPDH hỗ trợ đăng ký - Chi phí theo bảng giá quy định. Chi phí này nằm ngoài các khoản phí khởi tạo và duy trì nêu trên.
                    </p>
                </div>
            </div>
        </div>
    </section>

    <!-- Đăng ký tư vấn -->
    <section id="dang-ky" class="py-20 md:py-28 relative bg-white border-t border-gray-100">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
            <div class="text-center mb-12">
                <h2 class="text-3xl md:text-5xl font-bold text-brandGreen uppercase tracking-wider">Đăng ký tư vấn</h2>
                <div class="w-32 mx-auto mt-6 divider-floral"></div>
            </div>

            <div class="bg-white border border-gray-200 rounded-2xl shadow-xl overflow-hidden p-8 md:p-12 relative">
                
                <form id="register-form" onsubmit="handleRegister(event)" class="space-y-6">
                    
                    <!-- TRƯỜNG HONEYPOT CHỐNG SPAM (ẨN VỚI NGƯỜI DÙNG) -->
                    <div style="opacity: 0; position: absolute; top: 0; left: 0; height: 0; width: 0; z-index: -1;">
                        <label for="website">Nếu bạn là người, đừng điền vào ô này</label>
                        <input type="text" id="website" name="website" tabindex="-1" autocomplete="off">
                    </div>
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-sm font-bold text-textDark mb-2">Họ và tên <span class="text-brandRed">*</span></label>
                            <input type="text" name="fullname" required class="w-full bg-gray-50 border border-gray-200 rounded-lg px-4 py-3 text-textDark focus:outline-none focus:ring-2 focus:ring-gold/50 focus:border-gold transition-colors" placeholder="VD: Nguyễn Văn A">
                        </div>
                        <div>
                            <label class="block text-sm font-bold text-textDark mb-2">Điện thoại <span class="text-brandRed">*</span></label>
                            <input type="tel" name="phone" required class="w-full bg-gray-50 border border-gray-200 rounded-lg px-4 py-3 text-textDark focus:outline-none focus:ring-2 focus:ring-gold/50 focus:border-gold transition-colors" placeholder="Số điện thoại liên hệ">
                        </div>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-bold text-textDark mb-2">Email </label>
                        <input type="email" name="email" class="w-full bg-gray-50 border border-gray-200 rounded-lg px-4 py-3 text-textDark focus:outline-none focus:ring-2 focus:ring-gold/50 focus:border-gold transition-colors" placeholder="Email của bạn">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-bold text-textDark mb-2">Địa chỉ </label>
                        <input type="text" name="address" class="w-full bg-gray-50 border border-gray-200 rounded-lg px-4 py-3 text-textDark focus:outline-none focus:ring-2 focus:ring-gold/50 focus:border-gold transition-colors" placeholder="Xã/Huyện/Tỉnh...">
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-textDark mb-2">Chọn gói đăng ký <span class="text-brandRed">*</span></label>
                        <select id="package-select" name="package" required class="w-full bg-gray-50 border border-gray-200 rounded-lg px-4 py-3 text-textDark focus:outline-none focus:ring-2 focus:ring-gold/50 focus:border-gold transition-colors">
                            <option value="" disabled selected>-- Vui lòng chọn gói --</option>
                            <option value="Gói chi họ">Gói Chi họ (Dưới 100 người)</option>
                            <option value="Gói phái hệ">Gói Phái hệ (100 - 200 người)</option>
                            <option value="Gói tộc hệ">Gói Tộc hệ (200 - 400 người)</option>
                            <option value="Gói đại tôn">Gói Đại tôn (Không giới hạn)</option>
                            <option value="Tư vấn thêm">Chưa rõ, cần tư vấn thêm</option>
                        </select>
                    </div>

                    <div class="pt-6 text-center">
                        <button type="submit" class="w-full md:w-auto px-12 py-4 bg-brandGreen text-white font-bold text-lg rounded-full hover:bg-green-800 transition-all duration-300 transform hover:-translate-y-1 shadow-[0_5px_15px_rgba(0,90,60,0.3)]">
                            ĐĂNG KÝ TƯ VẤN
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-brandGreen pt-12 pb-8 border-t-4 border-gold">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex flex-col md:flex-row justify-between items-center gap-6">
                <div class="flex flex-col items-center md:items-start text-center md:text-left">
                    <div class="bg-white p-2 rounded-lg inline-block mb-4 shadow-md">
                        <img src="logo.png" alt="Logo GPDH" class="h-12 w-auto">
                    </div>
                    <p class="text-green-100 text-sm max-w-xs">Giải pháp lưu giữ truyền thống, kết nối dòng tộc cho muôn đời sau.</p>
                </div>
                
                <div class="text-center md:text-right">
                    <p class="text-white text-xl font-bold mb-4">HOTLINE: <span class="text-gold">0915 555 977</span></p>
                    <p class="text-sm text-green-200 border-t border-green-700 pt-4">&copy; 2026 Hệ thống quản lý gia phả. Thiết kế và phát triển bởi GPDH.</p>
                </div>
            </div>
        </div>
    </footer>

    <!-- Popup Thông báo thành công -->
    <div id="success-popup" class="hidden fixed inset-0 z-[100] flex items-center justify-center bg-black/60 backdrop-blur-sm transition-opacity duration-300 opacity-0">
        <div id="success-popup-content" class="bg-white rounded-2xl shadow-2xl p-8 md:p-12 max-w-md w-[90%] text-center transform scale-95 transition-transform duration-300">
            <div class="w-24 h-24 bg-green-50 rounded-full flex items-center justify-center mx-auto mb-6">
                <svg class="w-12 h-12 text-brandGreen" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
            </div>
            <h4 class="text-3xl md:text-4xl font-bold text-brandGreen mb-4 font-philo">Đăng ký thành công!</h4>
            <p class="text-gray-600 text-lg mb-8 leading-relaxed">
                GPDH xin cảm ơn. Đội ngũ chuyên gia của chúng tôi sẽ liên hệ lại qua số điện thoại của bạn để tư vấn trong thời gian sớm nhất.
            </p>
            <button onclick="closePopup()" class="w-full md:w-auto px-8 py-3 bg-brandGreen text-white font-bold rounded-full hover:bg-green-800 transition-all shadow-md">
                Đóng thông báo
            </button>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/swiper@10/swiper-bundle.min.js"></script>
    <script>
        // --- Mobile Menu ---
        const btn = document.getElementById('mobile-menu-btn');
        const menu = document.getElementById('mobile-menu');
        btn.addEventListener('click', () => menu.classList.toggle('open'));
        menu.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => menu.classList.remove('open'));
        });

        // --- Features Data ---
        const features = [
            { title: "Cây gia phả tương tác", desc: "Hiển thị trực quan sơ đồ phả hệ qua nhiều thế hệ. Hỗ trợ thao tác phóng to, thu nhỏ mượt mà, giúp con cháu dễ dàng theo dõi nguồn cội và mối quan hệ huyết thống mọi lúc, mọi nơi.", bg: "tuong-tac.jpg" },
            { title: "Quản lý thành viên", desc: "Thêm mới và cập nhật chi tiết thông tin tiểu sử, năm sinh, năm mất, nơi an táng của từng cá nhân. Dữ liệu được tổ chức khoa học, phân chia rõ ràng theo từng đời và chi phái.", bg: "them-moi.jpg" },
            { title: "Lịch sự kiện & Ngày giỗ", desc: "Tự động tính toán và nhắc nhở ngày giỗ chạp, ngày lễ trọng đại của dòng họ theo lịch Âm/Dương. Giúp con cháu dù ở xa cũng luôn hướng về tổ tiên, gắn kết tình cảm gia tộc.", bg: "nhac-lich.jpg" },
            { title: "Thư viện tư liệu số", desc: "Không gian lưu trữ an toàn các tài liệu quý giá, hình ảnh, video kỷ niệm của dòng họ. Bảo tồn di sản văn hóa và ký ức gia tộc qua nhiều thế hệ mà không lo thất lạc hay hư hỏng.", bg: "luu-tru.jpg" },
            { title: "Tìm kiếm thông minh", desc: "Công cụ tra cứu mạnh mẽ giúp tìm kiếm nhanh chóng bất kỳ thành viên nào. Chỉ cần nhập tên, năm sinh hoặc đời thứ, hệ thống sẽ trả về kết quả chính xác trong tích tắc.", bg: "tra-cuu.jpg" },
            { title: "Xuất file in ấn", desc: "Hỗ trợ trích xuất toàn bộ dữ liệu sơ đồ phả hệ và danh sách thành viên ra file Excel hoặc định dạng chuẩn. Rất tiện lợi cho việc thiết kế, biên soạn Gia phả cuốn để in ấn.", bg: "xuat-file.jpg" },
            { title: "Thống kê tổng quan", desc: "Hệ thống tự động tổng hợp và báo cáo chi tiết về số lượng thành viên, phân bổ đinh nam/đinh nữ, dâu/rể. Giúp Hội đồng gia tộc dễ dàng nắm bắt quy mô dòng họ.", bg: "bao-cao.jpg" },
            { title: "Phân quyền quản trị", desc: "Cho phép phân chia quyền quản trị linh hoạt. Có thể cấp quyền cập nhật dữ liệu riêng cho từng trưởng chi, trưởng phái, đảm bảo tính bảo mật và giảm tải cho người quản trị chính.", bg: "thiet-lap.jpg" },
            { title: "Giao diện thân thiện", desc: "Thiết kế hiện đại, bố cục sang trọng, tối ưu hóa trải nghiệm người dùng. Hệ thống hiển thị hoàn hảo và thao tác dễ dàng trên mọi thiết bị: Máy tính, Máy tính bảng và Điện thoại di động.", bg: "giao-dien.jpg" },
            { title: "Quản trị toàn diện", desc: "Tích hợp bộ công cụ quản lý chuyên sâu, đáp ứng trọn vẹn mọi nhu cầu đặc thù của dòng họ. Cho phép người dùng dễ dàng sắp xếp, tùy chỉnh và mở rộng dữ liệu theo thời gian.", bg: "tinh-nang.jpg" }
        ];

        // --- Render Swiper ---
        const wrapper = document.getElementById('features-wrapper');
        features.forEach((feat) => {
            wrapper.innerHTML += `
                <div class="swiper-slide relative flex items-end justify-center w-full h-full">
                    <div class="absolute inset-0 z-0">
                        <img src="${feat.bg}" alt="${feat.title}" class="w-full h-full object-cover">
                    </div>
                    <div class="absolute inset-0 z-10 bg-gradient-to-t from-black/95 via-black/60 to-transparent"></div>
                    <div class="relative z-20 w-full max-w-6xl text-center px-6 pb-20 md:pb-28">
                        <h4 class="text-3xl md:text-5xl font-bold text-gold mb-4 md:mb-6 uppercase tracking-wide drop-shadow-xl">${feat.title}</h4>
                        <p class="text-gray-200 text-lg md:text-2xl leading-relaxed mx-auto drop-shadow-md max-w-4xl">${feat.desc}</p>
                    </div>
                </div>
            `;
        });

        // --- Init Swiper ---
        new Swiper(".mySwiper", {
            spaceBetween: 0,
            effect: "slide",
            loop: true,
            autoplay: { delay: 4500, disableOnInteraction: false },
            pagination: { el: ".swiper-pagination", clickable: true },
            navigation: { nextEl: ".swiper-button-next", prevEl: ".swiper-button-prev" }
        });

        // --- Form Handling ---
        function selectPackage(pkgName) {
            document.getElementById('package-select').value = pkgName;
            document.getElementById('dang-ky').scrollIntoView({ behavior: 'smooth' });
        }

        // ĐƯỜNG DẪN TRỎ VỀ FILE ASP BACKEND CỦA BẠN
        const scriptURL = 'ajax_dangky.asp';

        function handleRegister(e) {
            e.preventDefault();
            
            const form = document.getElementById('register-form');
            const submitBtn = form.querySelector('button[type="submit"]');
            const originalBtnText = submitBtn.innerHTML;
            
            submitBtn.innerHTML = 'ĐANG XỬ LÝ...';
            submitBtn.disabled = true;
            submitBtn.classList.add('opacity-70', 'cursor-not-allowed');

            // Chuyển FormData thành URL Encoded để Classic ASP Request.Form có thể đọc được
            const formData = new FormData(form);
            const urlEncodedData = new URLSearchParams(formData).toString();

            fetch(scriptURL, { 
                method: 'POST', 
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: urlEncodedData 
            })
            .then(response => response.json())
            .then(data => {
                if (data.result === 'success') {
                    // Hiển thị popup thay vì đè lên form
                    showPopup();
                    // Reset luôn form để người dùng có thể đăng ký thêm nếu muốn
                    form.reset(); 
                } else {
                    alert('Lỗi xử lý. Vui lòng liên hệ Hotline.');
                }
            })
            .catch(error => {
                console.error('Lỗi kết nối:', error);
                alert('Mạng lỗi hoặc file ASP chưa hoạt động đúng trên server.');
            })
            .finally(() => {
                submitBtn.innerHTML = originalBtnText;
                submitBtn.disabled = false;
                submitBtn.classList.remove('opacity-70', 'cursor-not-allowed');
            });
        }

        // --- Popup Control ---
        function showPopup() {
            const popup = document.getElementById('success-popup');
            const content = document.getElementById('success-popup-content');
            
            // Xóa class hidden để hiển thị khối DOM
            popup.classList.remove('hidden');
            
            // Trigger reflow để animation chạy mượt
            void popup.offsetWidth;
            
            // Chạy animation fade-in & scale-up
            popup.classList.remove('opacity-0');
            popup.classList.add('opacity-100');
            content.classList.remove('scale-95');
            content.classList.add('scale-100');
        }

        function closePopup() {
            const popup = document.getElementById('success-popup');
            const content = document.getElementById('success-popup-content');
            
            // Chạy animation fade-out & scale-down
            popup.classList.remove('opacity-100');
            popup.classList.add('opacity-0');
            content.classList.remove('scale-100');
            content.classList.add('scale-95');
            
            // Đợi CSS transition chạy xong mới ẩn hoàn toàn khối DOM
            setTimeout(() => {
                popup.classList.add('hidden');
            }, 300);
        }
        // --- Quản lý Popup Đăng Nhập ---
function openLoginModal() {
    const modal = document.getElementById('login-modal');
    const content = document.getElementById('login-modal-content');
    const errorBox = document.getElementById('login-error');
    
    errorBox.classList.add('hidden'); // Ẩn lỗi cũ nếu có
    document.getElementById('frm-login').reset(); // Xóa form cũ
    
    modal.classList.remove('hidden');
    void modal.offsetWidth; // Trigger reflow
    modal.classList.remove('opacity-0');
    content.classList.remove('scale-95');
}

function closeLoginModal() {
    const modal = document.getElementById('login-modal');
    const content = document.getElementById('login-modal-content');
    
    modal.classList.add('opacity-0');
    content.classList.add('scale-95');
    setTimeout(() => { modal.classList.add('hidden'); }, 300);
}

// --- Xử lý AJAX Đăng Nhập ---
function processLogin(e) {
    e.preventDefault();
    
    const phone = document.getElementById('login-phone').value;
    const pass = document.getElementById('login-pass').value;
    const btn = document.getElementById('btn-submit-login');
    const errorBox = document.getElementById('login-error');
    
    // UI trạng thái loading
    const originalText = btn.innerHTML;
    btn.innerHTML = '<svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>';
    btn.disabled = true;
    errorBox.classList.add('hidden');

    const formData = new URLSearchParams();
    formData.append('phone', phone);
    formData.append('password', pass);

    fetch('ajax_login.asp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: formData.toString()
    })
    .then(response => response.json())
    .then(data => {
        if(data.status === 'success') {
            // Chuyển hướng ngay lập tức về trang quản lý user
            window.location.href = '/user/'; 
        } else {
            // Báo lỗi
            errorBox.innerHTML = data.message;
            errorBox.classList.remove('hidden');
            btn.innerHTML = originalText;
            btn.disabled = false;
        }
    })
    .catch(err => {
        errorBox.innerHTML = 'Lỗi kết nối máy chủ. Vui lòng thử lại!';
        errorBox.classList.remove('hidden');
        btn.innerHTML = originalText;
        btn.disabled = false;
    });
}
    </script>
    <!-- Popup Đăng Nhập -->
<div id="login-modal" class="hidden fixed inset-0 z-[100] flex items-center justify-center bg-black/60 backdrop-blur-sm transition-opacity duration-300 opacity-0">
    <div id="login-modal-content" class="bg-white rounded-2xl shadow-2xl p-8 md:p-10 max-w-md w-[90%] relative transform scale-95 transition-transform duration-300 border-t-4 border-brandGreen">
        
        <!-- Nút Tắt -->
        <button onclick="closeLoginModal()" class="absolute top-4 right-4 text-gray-400 hover:text-brandRed transition-colors">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
        </button>

        <div class="text-center mb-6">
            <h3 class="text-2xl font-bold text-brandGreen uppercase mb-2">Đăng nhập hệ thống</h3>
            <p class="text-sm text-gray-500 italic">Chỉ người dùng dịch vụ gia phả dòng họ mới được quyền đăng nhập.</p>
        </div>

        <!-- Thông báo lỗi -->
        <div id="login-error" class="hidden mb-4 p-3 bg-red-50 border border-red-200 text-brandRed text-sm rounded-lg text-center font-medium"></div>

        <form id="frm-login" onsubmit="processLogin(event)" class="space-y-5">
            <div>
                <label class="block text-sm font-bold text-textDark mb-2">Số điện thoại <span class="text-brandRed">*</span></label>
                <input type="tel" id="login-phone" required class="w-full bg-gray-50 border border-gray-200 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-brandGreen/50 focus:border-brandGreen" placeholder="Nhập số điện thoại...">
            </div>
            <div>
                <label class="block text-sm font-bold text-textDark mb-2">Mật khẩu <span class="text-brandRed">*</span></label>
                <input type="password" id="login-pass" required class="w-full bg-gray-50 border border-gray-200 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-brandGreen/50 focus:border-brandGreen" placeholder="Nhập mật khẩu...">
            </div>
            
            <button type="submit" id="btn-submit-login" class="w-full py-3 bg-brandGreen text-white font-bold rounded-lg hover:bg-green-800 transition-colors shadow-md flex justify-center items-center">
                ĐĂNG NHẬP
            </button>
        </form>
        
        <div class="mt-6 text-center">
            <a href="https://zalo.me/0915555977" target="_blank" class="text-sm text-brandGreen hover:text-gold font-medium transition-colors">Quên mật khẩu? Liên hệ Zalo hỗ trợ</a>
        </div>
    </div>
</div>
</body>
</html>