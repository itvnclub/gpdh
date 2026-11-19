<%
' =======================================================
' 1. LẤY ID BÀI VIẾT TỪ URL VÀ XỬ LÝ BẢO MẬT (SQL INJECTION)
' =======================================================
Dim reqTinTuc : reqTinTuc = Request.QueryString("tintuc")

If reqTinTuc <> "" And IsNumeric(reqTinTuc) Then
    newsId = CLng(reqTinTuc)
Else
    newsId = 0
End If

' =======================================================
' 2. TRUY VẤN DỮ LIỆU TIN TỨC TỪ TBLTINTUC
' =======================================================
Dim rsDetail, sqlDetail
Set rsDetail = Server.CreateObject("ADODB.Recordset")

If newsId > 0 Then
    sqlDetail = "SELECT tieude, ngaycapnhat, trichdan, noidung, hinhanh FROM tbltintuc WHERE idtintuc = " & newsId
    rsDetail.Open sqlDetail, conn

    If Not rsDetail.EOF Then
        currentTitle   = rsDetail("tieude")
        currentDate    = rsDetail("ngaycapnhat")
        currentExcerpt = rsDetail("trichdan")
        currentContent = rsDetail("noidung")
        currentImage   = rsDetail("hinhanh")
    Else
        currentTitle   = "Không tìm thấy bài viết"
        currentContent = "<p class='text-center py-4 text-muted'>Bài viết này không tồn tại hoặc đã bị xóa.</p>"
    End If
    rsDetail.Close
Else
    currentTitle   = "Lỗi truy cập"
    currentContent = "<p class='text-center py-4 text-muted'>Đường dẫn không hợp lệ.</p>"
End If
Set rsDetail = Nothing
%>

<!-- ================= CSS GIAO DIỆN CHI TIẾT TIN TỨC ================= -->
<style>
    /* BỐ CỤC CHÍNH (LAYOUT) - QUAN TRỌNG ĐỂ STICKY HOẠT ĐỘNG */
    .detail-section { padding: 50px 0 70px; background-color: #f8f9fa; }
    .info-layout {
        display: flex;
        flex-wrap: wrap;
        gap: 30px;
        align-items: flex-start !important; 
    }
    .info-main-content { flex: 1 1 0; min-width: 0; }
    
    /* CỘT PHẢI (SIDEBAR STICKY) */
    .info-sidebar {
        flex: 0 0 320px; 
        position: -webkit-sticky !important;
        position: sticky !important;
        top: 90px !important; 
        align-self: flex-start; 
        height: max-content; 
        z-index: 99;
    }

    /* KHUNG NỘI DUNG CHÍNH (TRÁI) */
    .content-box {
        background: #fff;
        padding: 40px;
        border-radius: 8px;
        box-shadow: 0 2px 15px rgba(0,0,0,0.05);
        border-top: 4px solid var(--color-main); 
    }
    .detail-title {
        color: #1e293b;
        font-size: 32px;
        font-weight: bold;
        margin-top: 0;
        margin-bottom: 15px;
        font-family: var(--font-heading);
        line-height: 1.4;
    }
    .detail-meta {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding-bottom: 15px;
        border-bottom: 1px dashed #e2e8f0;
        margin-bottom: 25px;
        color: #64748b;
        font-size: 14px;
    }
    .detail-meta i { color: var(--color-main); margin-right: 5px; }
    
    /* Trích dẫn (Sapo) */
    .detail-excerpt {
        font-size: 16px;
        font-weight: 600;
        color: #334155;
        background: #f8fafc;
        padding: 20px;
        border-left: 4px solid var(--color-main);
        border-radius: 4px;
        margin-bottom: 30px;
        line-height: 1.6;
    }

    /* Nội dung CKEditor */
    .user-html-content { color: #334155; line-height: 1.8; font-size: 16px; font-family: var(--font-body); }
    .user-html-content p { margin-bottom: 15px; text-align: justify; }
    .user-html-content img { max-width: 100% !important; height: auto !important; border-radius: 6px; margin: 15px auto; display: block; }
    .user-html-content table { width: 100% !important; max-width: 100%; margin-bottom: 15px; border-collapse: collapse; }

    /* Footer Bài viết (Nút quay lại / Print) */
    .detail-footer {
        display: flex;
        justify-content: space-between;
        margin-top: 40px;
        padding-top: 20px;
        border-top: 1px solid #e2e8f0;
    }
    .btn-action {
        display: inline-flex; align-items: center; gap: 8px;
        padding: 10px 20px;
        background: #f1f5f9; color: #475569;
        text-decoration: none; border-radius: 4px;
        font-weight: 600; font-size: 14px; transition: 0.3s; border: none; cursor: pointer;
    }
    .btn-action:hover { background: var(--color-main); color: #fff; }

    /* WIDGET SIDEBAR (GIỐNG TRANG THÔNG TIN) */
    .sidebar-widget {
        background: #fff; border-radius: 8px; box-shadow: 0 2px 15px rgba(0,0,0,0.05);
        overflow: hidden; margin-bottom: 30px;
    }
    .sidebar-widget:last-child { margin-bottom: 0; }
    .widget-title {
        background: var(--color-main); color: #fff; font-size: 16px; padding: 15px 20px; margin: 0;
        text-transform: uppercase; font-family: var(--font-heading); font-weight: bold;
        display: flex; align-items: center; gap: 10px;
    }
    
    /* Tin nổi bật Sidebar */
    .widget-news { padding: 10px 20px; }
    .news-item {
        display: flex; gap: 15px; padding: 12px 0; border-bottom: 1px dashed #e2e8f0;
        text-decoration: none; align-items: flex-start;
    }
    .news-item:last-child { border-bottom: none; }
    .news-item:hover .news-title { color: var(--color-main); }
    .news-thumb { flex: 0 0 80px; height: 60px; border-radius: 4px; overflow: hidden; }
    .news-thumb img { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s ease; }
    .news-item:hover .news-thumb img { transform: scale(1.1); }
    .news-title {
        color: #334155; font-size: 14px; font-weight: 500; line-height: 1.4; transition: color 0.2s;
        display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;
    }

    /* List danh mục */
    .widget-list { list-style: none; padding: 0; margin: 0; }
    .widget-list li { border-bottom: 1px solid #f1f5f9; }
    .widget-list li:last-child { border-bottom: none; }
    .widget-list a {
        display: flex; align-items: center; padding: 12px 20px;
        color: #475569; text-decoration: none; font-size: 15px; transition: 0.3s ease; gap: 12px;
    }
    .widget-list a i { color: #cbd5e1; transition: 0.3s ease; }
    .widget-list a:hover { background: #f8fafc; color: var(--color-main); }
    .widget-list a:hover i { color: var(--color-main); }

    /* MOBILE RESPONSIVE */
    @media (max-width: 991px) {
        .info-sidebar { flex: 1 1 100%; position: relative !important; top: 0 !important; height: auto; }
        .content-box { padding: 25px 20px; }
        .detail-title { font-size: 24px; }
    }
    @media print {
        header, .page-banner, .info-sidebar, .detail-footer, footer { display: none !important; }
        .detail-section { padding: 0; background: #fff; }
        .content-box { box-shadow: none; border: none; padding: 0; }
    }
</style>

<!-- KHỐI BANNER CHUYÊN MỤC -->
<div class="page-banner" style="background-image: url('<%=bgTrenUrl%>');">
    <div class="banner-overlay"></div>
    <div class="container relative z-10 text-center">
        <h1 class="banner-title">TIN TỨC</h1>
        <p class="banner-breadcrumb">
            <a href="/">Trang chủ</a> <i class="fa fa-angle-right"></i> 
            <a href="/tin-tuc.html">Tin tức</a> <i class="fa fa-angle-right"></i> <%=currentTitle%>
        </p>
    </div>
</div>

<section class="detail-section">
    <div class="container">
        <div class="info-layout">
            
<!-- ================= CỘT TRÁI: NỘI DUNG CHI TIẾT ================= -->
            <div class="info-main-content">
                <div class="content-box">
                    
                    <h1 class="detail-title"><%=currentTitle%></h1>
                    
                    <div class="detail-meta">
                        <div class="meta-left">
                            <span><i class="fa fa-clock-o"></i> Đăng ngày: <%=currentDate%></span>
                        </div>
                        <div class="meta-right">
                            <button onclick="window.print();" class="btn-action" style="padding: 5px 10px; font-size:12px;">
                                <i class="fa fa-print"></i> In bài
                            </button>
                        </div>
                    </div>

                    <% If currentExcerpt <> "" And Not IsNull(currentExcerpt) Then %>
                        <div class="detail-excerpt">
                            <%=currentExcerpt%>
                        </div>
                    <% End If %>

                    <!-- BẮT ĐẦU: CHÈN HÌNH ẢNH BÀI VIẾT (NẰM GIỮA TRÍCH DẪN VÀ NỘI DUNG) -->
                    <% If currentImage <> "" And Not IsNull(currentImage) Then %>
                        <div class="detail-main-image" style="margin-bottom: 25px; text-align: center;">
                            <img src="<%=currentImage%>" alt="<%=currentTitle%>" style="max-width: 100%; height: auto; border-radius: 6px; box-shadow: 0 2px 10px rgba(0,0,0,0.05);">
                        </div>
                    <% End If %>
                    <!-- KẾT THÚC: CHÈN HÌNH ẢNH BÀI VIẾT -->

                    <div class="detail-body user-html-content">
                        <%=currentContent%>
                    </div>

                    <div class="detail-footer">
                        <a href="/tin-tuc.html" class="btn-action">
                            <i class="fa fa-angle-double-left"></i> Trở về danh sách tin
                        </a>
                        <a href="#" onclick="window.scrollTo({top: 0, behavior: 'smooth'}); return false;" class="btn-action">
                            Lên đầu trang <i class="fa fa-angle-double-up"></i>
                        </a>
                    </div>

                </div>
            </div>

            <!-- ================= CỘT PHẢI: THANH SIDEBAR GỢI Ý ================= -->
            <div class="info-sidebar">
                
                <!-- WIDGET 1: TIN TỨC MỚI KHÁC -->
                <div class="sidebar-widget">
                    <h3 class="widget-title"><i class="fa fa-newspaper-o"></i> TIN TỨC KHÁC</h3>
                    <div class="widget-news">
                        <%
                        Dim rsOtherNews
                        ' Lấy 5 tin mới nhất, nhưng loại trừ tin đang xem ra
                        Set rsOtherNews = conn.Execute("SELECT TOP 5 idtintuc, tieude, hinhanh FROM tbltintuc WHERE idtintuc <> " & newsId & " ORDER BY top1 DESC, idtintuc DESC")
                        
                        If Not rsOtherNews.EOF Then
                            Do While Not rsOtherNews.EOF
                                Dim imgOtherUrl
                                If IsNull(rsOtherNews("hinhanh")) Or rsOtherNews("hinhanh") = "" Then
                                    imgOtherUrl = "images/noimages.jpg" 
                                Else
                                    imgOtherUrl = rsOtherNews("hinhanh")
                                End If
                                
                                Dim linkOtherDetail
                                linkOtherDetail = "/tintuc/" & rsOtherNews("idtintuc") & "/" & ConvertiTitoloInNomeScript(rsOtherNews("tieude")) & ".html"
                        %>
                        <a href="<%=linkOtherDetail%>" class="news-item" title="<%=rsOtherNews("tieude")%>">
                            <div class="news-thumb">
                                <img src="<%=imgOtherUrl%>" alt="<%=rsOtherNews("tieude")%>">
                            </div>
                            <div class="news-title">
                                <%=rsOtherNews("tieude")%>
                            </div>
                        </a>
                        <%
                                rsOtherNews.MoveNext
                            Loop
                        Else
                            Response.Write "<p class='text-center text-muted' style='font-size:13px; padding:15px;'>Chưa có tin tức khác.</p>"
                        End If
                        rsOtherNews.Close
                        Set rsOtherNews = Nothing
                        %>
                    </div>
                </div>

                <!-- WIDGET 2: DANH MỤC THÔNG TIN DÒNG HỌ -->
                <div class="sidebar-widget">
                    <h3 class="widget-title"><i class="fa fa-list-ul"></i> THÔNG TIN DÒNG HỌ</h3>
                    <ul class="widget-list">
                        <%
                        Dim rsInfoList
                        Set rsInfoList = conn.Execute("SELECT idthongtin, tieude FROM tblthongtin ORDER BY thutu ASC, idthongtin ASC")
                        Do While Not rsInfoList.EOF
                            Dim linkInfoDetail
                            linkInfoDetail = "/thongtin/" & rsInfoList("idthongtin") & "/" & ConvertiTitoloInNomeScript(rsInfoList("tieude")) & ".html"
                        %>
                        <li>
                            <a href="<%=linkInfoDetail%>" title="<%=rsInfoList("tieude")%>">
                                <i class="fa fa-angle-right"></i> <%=rsInfoList("tieude")%>
                            </a>
                        </li>
                        <%
                            rsInfoList.MoveNext
                        Loop
                        rsInfoList.Close
                        Set rsInfoList = Nothing
                        %>
                    </ul>
                </div>

            </div> <!-- End Cột Phải -->

        </div>
    </div>
</section>
<script>document.body.classList.add('bg-full-watermark');</script>