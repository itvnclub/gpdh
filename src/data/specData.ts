export interface ColumnSpec {
  name: string;
  type: string;
  constraint: string;
  description: string;
}

export interface TableSpec {
  id: string;
  name: string;
  purpose: string;
  columns: ColumnSpec[];
  note?: string;
}

export interface RelationshipSpec {
  from: string;
  to: string;
  cardinality: string;
  mechanism: string;
  description: string;
}

export interface RouteSpec {
  pattern: string;
  target: string;
  module: string;
  group: string;
}

export interface FeatureGroupSpec {
  id: string;
  title: string;
  files: string;
  items: {
    name: string;
    detail: string;
  }[];
}

export interface FlowSectionSpec {
  id: string;
  code: string;
  title: string;
  summary: string;
  blocks: {
    heading: string;
    bullets: string[];
    codeNote?: string;
  }[];
}

export interface LandingBlockSpec {
  order: string;
  anchor: string;
  title: string;
  summary: string;
  details: string[];
}

export interface PricingTierSpec {
  name: string;
  initPrice: string;
  annualPrice: string;
  scale: string;
  highlight: string;
}

export interface FeatureSlideSpec {
  index: number;
  title: string;
  image: string;
  desc: string;
}

export const DOCUMENT_META = {
  code: 'DOC-GPDH-SPEC-01',
  title: 'Bản Đặc Tả Kỹ Thuật Hệ Thống Gia Phả Dòng Họ',
  subtitle:
    'Phân tích hiện trạng mã nguồn thư mục mau-website (Classic ASP + SQL Server) và landingpage thuộc kho mã nguồn itvnclub/gpdh',
  repository: 'https://github.com/itvnclub/gpdh',
  branch: 'main',
  commit: 'de05a3e2',
  pdfFilename: 'Ban_Dac_Ta_Ky_Thuat_GPDH.pdf',
  pdfPath: '/Ban_Dac_Ta_Ky_Thuat_GPDH.pdf',
  stackWeb: 'Classic ASP (VBScript, UTF-8 / CODEPAGE="65001") · SQL Server (ADODB SQLOLEDB, DB hobuixuanbang) · IIS URL Rewrite · jQuery 3.6 · Fancybox 3.5.7 · SortableJS · InnovaEditor · FontAwesome 4.7',
  stackLanding: 'Classic ASP · Tailwind CSS (CDN) · Swiper 10 · Google Fonts (Philosopher, Italianno) · MSXML2.ServerXMLHTTP.6.0 (TLS 1.2) tích hợp Telegram Bot API & Google Apps Script',
  scopeNote:
    'Tài liệu mô tả chính xác và đầy đủ những gì đang hiện hữu trong mã nguồn gốc, bao gồm cả các tệp bị thiếu trong kho mã nguồn, các tệp kế thừa chưa gắn định tuyến và các điểm kiểm soát phân quyền thực tế trong code.',
};

export const REPO_GAPS: { category: string; detail: string }[] = [
  {
    category: 'Tệp Includes/ thiếu ở Frontend (13/14 tệp)',
    detail:
      'mau-website/default.asp gọi #include 14 tệp trong thư mục Includes/, nhưng kho mã nguồn hiện chỉ có duy nhất Includes/inc_chitiet.asp. 13 tệp không tồn tại trong repo gồm: inc_header.asp, inc_footer.asp, inc_main.asp, inc_tintuc.asp, inc_hinhanh.asp, inc_video.asp, inc_phadodoc.asp, inc_phadotheodoi.asp, inc_phadongang.asp, inc_thongtin.asp, inc_nhomtin.asp, inc_giapha.asp, inc_xemanh.asp.',
  },
  {
    category: 'Tệp kế thừa / chưa gắn route trong Admin (3 tệp)',
    detail:
      'Trong mau-website/gpdh/ tồn tại 3 tệp không được gắn trong gpdh/web.config hoặc luồng chính: user_edit1.asp (biểu mẫu sửa người dùng cũ), giapha_book.asp (giao diện xuất sách gia phả chưa nối link menu), và md5.asp (hàm băm MD5 cũ, hiện đăng nhập dùng sha256.asp).',
  },
  {
    category: 'Liên kết đích chưa có tệp trong landingpage/ (5 đích)',
    detail:
      'landingpage/index.asp tham chiếu tới tintuc_list.asp, cam-nang.asp, dich-vu.asp, ajax_login.asp và thư mục /user/, tuy nhiên các tệp này không có trong thư mục landingpage/ của kho mã nguồn.',
  },
];

export const DATABASE_TABLES: TableSpec[] = [
  {
    id: 'tbladmin',
    name: 'tbladmin',
    purpose: 'Lưu tài khoản quản trị viên, nhóm quyền chức năng và nhánh phả hệ được phép quản lý.',
    note: 'Cột dienthoai khai báo kiểu int trong SQL Server, nhưng user_list.asp chèn/cập nhật dạng chuỗi N\'...\' (dễ lỗi chuyển kiểu nếu nhập số 0 đầu hoặc ký tự không phải số). Mật khẩu băm SHA-256 hex qua sha256.asp.',
    columns: [
      { name: 'idadmin', type: 'int', constraint: 'PK · IDENTITY(1,1) · NOT NULL', description: 'Khóa chính tài khoản quản trị' },
      { name: 'hoten', type: 'nvarchar(200)', constraint: 'NULL', description: 'Họ tên quản trị viên' },
      { name: 'email', type: 'varchar(50)', constraint: 'NULL', description: 'Địa chỉ email' },
      { name: 'dienthoai', type: 'int', constraint: 'NULL', description: 'Số điện thoại (kiểu int trong DB)' },
      { name: 'username', type: 'varchar(50)', constraint: 'NULL', description: 'Tên đăng nhập' },
      { name: 'password', type: 'nvarchar(100)', constraint: 'NULL', description: 'Mật khẩu mã hóa SHA-256' },
      { name: 'is_super', type: 'int', constraint: 'NULL · DEFAULT 0', description: 'Quyền Super Admin (1 = toàn quyền hệ thống)' },
      { name: 'is_content', type: 'int', constraint: 'NULL · DEFAULT 0', description: 'Quyền quản trị nội dung (tin tức, ảnh, video...)' },
      { name: 'is_genealogy', type: 'int', constraint: 'NULL · DEFAULT 0', description: 'Quyền quản trị phả đồ dòng họ' },
      { name: 'allowed_start_idgiapha', type: 'int', constraint: 'NULL · DEFAULT 0 · FK logic', description: 'ID nhân vật gốc trong tblgiapha mà quản trị viên được quản lý (0 = toàn bộ)' },
    ],
  },
  {
    id: 'tbldoi',
    name: 'tbldoi',
    purpose: 'Danh mục các đời (thế hệ) trong dòng họ; tiêu đề được sinh tự động bằng chữ số La Mã (I, II, III...).',
    columns: [
      { name: 'iddoi', type: 'int', constraint: 'PK · IDENTITY(1,1) · NOT NULL', description: 'Khóa chính bảng đời' },
      { name: 'tieude', type: 'nvarchar(100)', constraint: 'NULL', description: 'Tên đời (ví dụ: I, II, III, IV...)' },
      { name: 'thutu', type: 'int', constraint: 'NULL', description: 'Số thứ tự đời dùng để sắp xếp và tính đời con' },
    ],
  },
  {
    id: 'tblgiapha',
    name: 'tblgiapha',
    purpose: 'Bảng lõi lưu toàn bộ thành viên nội tộc, vợ/chồng (dâu/rể) và cháu ngoại theo mô hình Adjacency List.',
    note: 'Cột idme được kiểm tra khi xóa ở giapha_delete.asp nhưng không xuất hiện trong các biểu mẫu thêm/sửa. Bản ghi idgiapha = 1 được xử lý đặc biệt là Thủy Tổ (không cho xóa).',
    columns: [
      { name: 'idgiapha', type: 'int', constraint: 'PK (PK_tblgiapha1) · IDENTITY(1,1)', description: 'Khóa chính nhân vật' },
      { name: 'idcha', type: 'int', constraint: 'NULL · Self FK logic', description: 'ID cha (0 nếu là Thủy Tổ hoặc bản ghi vợ/chồng)' },
      { name: 'iddoi', type: 'int', constraint: 'NULL · FK logic → tbldoi', description: 'Mã đời của nhân vật' },
      { name: 'hoten', type: 'nvarchar(200)', constraint: 'NULL', description: 'Họ và tên nhân vật' },
      { name: 'thutu', type: 'int', constraint: 'NULL', description: 'Thứ tự con trong cùng gia đình (tự động sắp lại khi thêm/sửa/xóa)' },
      { name: 'gioitinh', type: 'int', constraint: 'NULL', description: 'Giới tính (1 = Nam, 2 = Nữ)' },
      { name: 'namsinh', type: 'nvarchar(200)', constraint: 'NULL', description: 'Ngày/năm sinh (dạng văn bản tự do)' },
      { name: 'nammat', type: 'nvarchar(200)', constraint: 'NULL', description: 'Ngày/năm mất hoặc ngày giỗ' },
      { name: 'tinhtrang', type: 'int', constraint: 'NULL', description: 'Tình trạng (1 = Còn sống, 2 = Đã mất)' },
      { name: 'diachi', type: 'nvarchar(200)', constraint: 'NULL', description: 'Địa chỉ hiện tại / quê quán' },
      { name: 'tieusu', type: 'ntext', constraint: 'NULL', description: 'Tiểu sử, ghi chú chi tiết (HTML/văn bản dài)' },
      { name: 'noiantang', type: 'nvarchar(200)', constraint: 'NULL', description: 'Nơi an táng / phần mộ' },
      { name: 'huongtho', type: 'nvarchar(50)', constraint: 'NULL', description: 'Hưởng thọ / hưởng dương' },
      { name: 'tentu', type: 'nvarchar(200)', constraint: 'NULL', description: 'Tên tự / tên húy / biệt hiệu' },
      { name: 'nghenghiep', type: 'nvarchar(200)', constraint: 'NULL', description: 'Nghề nghiệp / chức vụ' },
      { name: 'dienthoai', type: 'nvarchar(200)', constraint: 'NULL', description: 'Số điện thoại liên hệ' },
      { name: 'email', type: 'nvarchar(200)', constraint: 'NULL', description: 'Địa chỉ email' },
      { name: 'hienthi', type: 'int', constraint: 'NULL · DEFAULT 1', description: 'Trạng thái hiển thị (1 = hiển thị)' },
      { name: 'hinhanh', type: 'varchar(200)', constraint: 'NULL', description: 'Đường dẫn ảnh chân dung' },
      { name: 'loai_quanhe', type: 'int', constraint: 'NULL · DEFAULT 1', description: '1 hoặc NULL = Nội tộc · 2 = Vợ/Chồng (dâu/rể) · 3 = Cháu ngoại' },
      { name: 'idme', type: 'int', constraint: 'NULL · DEFAULT 0', description: 'ID mẹ (kiểm tra ràng buộc lúc xóa, chưa nhập qua form)' },
      { name: 'id_vochong', type: 'int', constraint: 'NULL · DEFAULT 0 · Self FK', description: 'Liên kết tới idgiapha của vợ/chồng khi loai_quanhe = 2' },
    ],
  },
  {
    id: 'tblconfig',
    name: 'tblconfig',
    purpose: 'Bảng cấu hình toàn cục đơn dòng (idconfig = 1): thông tin dòng họ, giao diện, SEO, ảnh nền và hạn mức số đinh.',
    note: 'config.asp cập nhật thông tin chung/giao diện/SEO/bản đồ/6 ảnh; gioithieu.asp cập nhật gioithieu; giapha_book.asp tham chiếu phaky/tocuoc; các cột toctruongtel, quanly, quanlytel, email, facebook, kieu_hienthi, gioihan_dinh chưa có ô nhập trên giao diện cấu hình (chỉnh trực tiếp DB).',
    columns: [
      { name: 'idconfig', type: 'int', constraint: 'PK · IDENTITY(1,1) · NOT NULL', description: 'Khóa chính (luôn truy vấn bản ghi idconfig = 1)' },
      { name: 'dongho', type: 'nvarchar(200)', constraint: 'NULL', description: 'Tên dòng họ (ví dụ: Gia phả họ Bùi Xuân Bảng)' },
      { name: 'diachi', type: 'nvarchar(200)', constraint: 'NULL', description: 'Địa chỉ nhà thờ họ / trụ sở' },
      { name: 'toctruong', type: 'nvarchar(200)', constraint: 'NULL', description: 'Tên tộc trưởng' },
      { name: 'toctruongtel', type: 'nvarchar(200)', constraint: 'NULL', description: 'Số điện thoại tộc trưởng (chưa mở trên UI)' },
      { name: 'quanly', type: 'nvarchar(200)', constraint: 'NULL', description: 'Người quản lý website (chưa mở trên UI)' },
      { name: 'quanlytel', type: 'nvarchar(200)', constraint: 'NULL', description: 'Điện thoại người quản lý (chưa mở trên UI)' },
      { name: 'logo', type: 'varchar(200)', constraint: 'NULL', description: 'Ảnh logo đầu trang (header)' },
      { name: 'logof', type: 'varchar(200)', constraint: 'NULL', description: 'Ảnh logo chân trang (footer)' },
      { name: 'tukhoa', type: 'ntext', constraint: 'NULL', description: 'Thẻ meta keywords SEO' },
      { name: 'mota', type: 'ntext', constraint: 'NULL', description: 'Thẻ meta description SEO' },
      { name: 'phaky', type: 'ntext', constraint: 'NULL', description: 'Nội dung Phả ký dòng họ' },
      { name: 'tocuoc', type: 'ntext', constraint: 'NULL', description: 'Nội dung Tộc ước dòng họ' },
      { name: 'gioithieu', type: 'ntext', constraint: 'NULL', description: 'Bài viết Giới thiệu chung (sửa tại gioithieu.asp)' },
      { name: 'bgtren', type: 'varchar(200)', constraint: 'NULL', description: 'Ảnh nền khu vực đầu trang' },
      { name: 'hinhanh', type: 'varchar(200)', constraint: 'NULL', description: 'Ảnh đại diện / banner phụ' },
      { name: 'bando', type: 'varchar(500)', constraint: 'NULL', description: 'Mã nhúng / liên kết Google Maps' },
      { name: 'email', type: 'nvarchar(200)', constraint: 'NULL', description: 'Email dòng họ (chưa mở trên UI)' },
      { name: 'website', type: 'nvarchar(200)', constraint: 'NULL', description: 'Tên miền website' },
      { name: 'facebook', type: 'nvarchar(200)', constraint: 'NULL', description: 'Liên kết Facebook (chưa mở trên UI)' },
      { name: 'icon', type: 'varchar(200)', constraint: 'NULL', description: 'Biểu tượng favicon website' },
      { name: 'kieu_hienthi', type: 'int', constraint: 'NULL · DEFAULT 3', description: 'Kiểu hiển thị mặc định (chưa mở trên UI)' },
      { name: 'dienthoai', type: 'nvarchar(200)', constraint: 'NULL', description: 'Điện thoại liên hệ chung' },
      { name: 'font_family', type: 'varchar(100)', constraint: "NULL · DEFAULT 'Arial, sans-serif'", description: 'Phông chữ website (20 Google Fonts trên config.asp)' },
      { name: 'font_size', type: 'varchar(20)', constraint: 'NULL', description: 'Cỡ chữ giao diện (15px–25px)' },
      { name: 'mausac', type: 'varchar(50)', constraint: 'NULL', description: 'Mã màu chủ đạo giao diện' },
      { name: 'bgchinh', type: 'varchar(200)', constraint: 'NULL', description: 'Ảnh nền chính toàn trang' },
      { name: 'anhdaidien', type: 'varchar(200)', constraint: 'NULL', description: 'Ảnh đại diện chia sẻ / banner trang chủ' },
      { name: 'gioihan_dinh', type: 'int', constraint: 'NULL', description: 'Hạn mức số đinh (0 = không giới hạn; fallback 200 trong functions.asp)' },
    ],
  },
  {
    id: 'tblUI_Text',
    name: 'tblUI_Text',
    purpose: 'Lưu các nhãn văn bản động trên giao diện trang chủ (dữ liệu mẫu có 12 khóa như Hero_Sub, Hero_Desc, Sec_History_*, Sec_Event_*, Sec_News_*, Sec_Gallery_*, Sec_Video_*).',
    columns: [
      { name: 'TextKey', type: 'varchar(50)', constraint: 'PK · NOT NULL', description: 'Mã định danh văn bản giao diện' },
      { name: 'TextValue', type: 'nvarchar(max)', constraint: 'NULL', description: 'Nội dung hiển thị thực tế' },
      { name: 'GhiChu', type: 'nvarchar(255)', constraint: 'NULL', description: 'Mô tả vị trí hiển thị dành cho quản trị viên' },
    ],
  },
  {
    id: 'tblnhomtin',
    name: 'tblnhomtin',
    purpose: 'Danh mục chuyên mục tin tức (ví dụ: Tin dòng họ, Sự kiện, Hoạt động...).',
    columns: [
      { name: 'idnhomtin', type: 'int', constraint: 'PK · IDENTITY(1,1) · NOT NULL', description: 'Khóa chính nhóm tin' },
      { name: 'tieude', type: 'nvarchar(200)', constraint: 'NULL', description: 'Tên chuyên mục tin' },
      { name: 'thutu', type: 'int', constraint: 'NULL', description: 'Thứ tự hiển thị' },
    ],
  },
  {
    id: 'tbltintuc',
    name: 'tbltintuc',
    purpose: 'Lưu bài viết tin tức, sự kiện dòng họ gắn theo từng chuyên mục tblnhomtin.',
    columns: [
      { name: 'idtintuc', type: 'int', constraint: 'PK · IDENTITY(1,1) · NOT NULL', description: 'Khóa chính bài viết' },
      { name: 'tieude', type: 'nvarchar(1000)', constraint: 'NULL', description: 'Tiêu đề bài viết' },
      { name: 'hinhanh', type: 'varchar(200)', constraint: 'NULL', description: 'Ảnh đại diện bài viết' },
      { name: 'trichdan', type: 'ntext', constraint: 'NULL', description: 'Đoạn trích dẫn ngắn (sapo)' },
      { name: 'noidung', type: 'ntext', constraint: 'NULL', description: 'Nội dung HTML chi tiết (soạn bằng InnovaEditor)' },
      { name: 'top1', type: 'int', constraint: 'NULL', description: 'Đánh dấu bài viết nổi bật (1 = nổi bật)' },
      { name: 'ngaycapnhat', type: 'varchar(50)', constraint: 'NULL', description: 'Ngày đăng / cập nhật dạng chuỗi' },
      { name: 'thutu', type: 'int', constraint: 'NULL · DEFAULT 0', description: 'Thứ tự ưu tiên' },
      { name: 'idnhomtin', type: 'int', constraint: 'NULL · FK logic → tblnhomtin', description: 'Mã chuyên mục tin tức' },
    ],
  },
  {
    id: 'tblthongtin',
    name: 'tblthongtin',
    purpose: 'Lưu các trang thông tin tĩnh của dòng họ (lịch sử, phả ký, tộc ước, quy định...).',
    columns: [
      { name: 'idthongtin', type: 'int', constraint: 'PK · IDENTITY(1,1) · NOT NULL', description: 'Khóa chính mục thông tin' },
      { name: 'tieude', type: 'nvarchar(1000)', constraint: 'NULL', description: 'Tiêu đề mục thông tin' },
      { name: 'noidung', type: 'ntext', constraint: 'NULL', description: 'Nội dung HTML chi tiết' },
      { name: 'thutu', type: 'int', constraint: 'NULL · DEFAULT 0', description: 'Thứ tự hiển thị' },
    ],
  },
  {
    id: 'tblnhomanh',
    name: 'tblnhomanh',
    purpose: 'Lưu danh sách album ảnh. Ảnh bìa (hinhanh) được tự động đồng bộ từ ảnh đầu tiên trong tblanh.',
    columns: [
      { name: 'idnhomanh', type: 'int', constraint: 'PK · IDENTITY(1,1) · NOT NULL', description: 'Khóa chính album ảnh' },
      { name: 'tieude', type: 'nvarchar(500)', constraint: 'NULL', description: 'Tên album ảnh' },
      { name: 'thutu', type: 'int', constraint: 'NULL', description: 'Thứ tự hiển thị' },
      { name: 'top1', type: 'int', constraint: 'NULL', description: 'Đánh dấu album nổi bật' },
      { name: 'hinhanh', type: 'nvarchar(200)', constraint: 'NULL', description: 'Ảnh bìa tự đồng bộ theo ảnh thứ tự đầu tiên của tblanh' },
    ],
  },
  {
    id: 'tblanh',
    name: 'tblanh',
    purpose: 'Lưu từng tệp ảnh con thuộc một album trong tblnhomanh, hỗ trợ kéo thả sắp xếp thứ tự.',
    columns: [
      { name: 'idanh', type: 'int', constraint: 'PK · IDENTITY(1,1) · NOT NULL', description: 'Khóa chính ảnh chi tiết' },
      { name: 'idnhomanh', type: 'int', constraint: 'NULL · FK logic → tblnhomanh', description: 'Mã album chứa ảnh' },
      { name: 'hinhanh', type: 'varchar(200)', constraint: 'NULL', description: 'Tên/đường dẫn tệp ảnh đã tải lên' },
      { name: 'thutu', type: 'int', constraint: 'NULL · DEFAULT 0', description: 'Thứ tự ảnh trong album (SortableJS)' },
    ],
  },
  {
    id: 'tblloadanh',
    name: 'tblloadanh',
    purpose: 'Lưu danh sách ảnh banner/slider trang chủ và làm nguồn ảnh nền động cho trang đăng nhập Admin.',
    columns: [
      { name: 'idloadanh', type: 'int', constraint: 'PK · IDENTITY(1,1) · NOT NULL', description: 'Khóa chính ảnh slider' },
      { name: 'hinhanh', type: 'varchar(200)', constraint: 'NULL', description: 'Đường dẫn tệp ảnh banner' },
      { name: 'thutu', type: 'int', constraint: 'NULL', description: 'Thứ tự trình chiếu' },
    ],
  },
  {
    id: 'tblvideo',
    name: 'tblvideo',
    purpose: 'Lưu danh sách video tư liệu dòng họ (nhúng liên kết YouTube hoặc URL video).',
    columns: [
      { name: 'idvideo', type: 'int', constraint: 'PK · IDENTITY(1,1) · NOT NULL', description: 'Khóa chính video' },
      { name: 'tieude', type: 'nvarchar(1000)', constraint: 'NULL', description: 'Tiêu đề video' },
      { name: 'lienket', type: 'varchar(200)', constraint: 'NULL', description: 'Đường dẫn / mã liên kết video' },
      { name: 'thutu', type: 'int', constraint: 'NULL', description: 'Thứ tự hiển thị' },
    ],
  },
];

export const DATABASE_RELATIONSHIPS: RelationshipSpec[] = [
  {
    from: 'tblgiapha.idcha',
    to: 'tblgiapha.idgiapha',
    cardinality: 'N : 1 (tự tham chiếu)',
    mechanism: 'Khóa ngoại logic (ASP)',
    description: 'Liên kết con tới cha để xây dựng cây phân cấp Adjacency List (0 = Thủy Tổ hoặc bản ghi vợ/chồng).',
  },
  {
    from: 'tblgiapha.id_vochong',
    to: 'tblgiapha.idgiapha',
    cardinality: 'N : 1 (tự tham chiếu)',
    mechanism: 'Khóa ngoại logic (ASP)',
    description: 'Khi loai_quanhe = 2 (vợ/chồng), trỏ tới idgiapha của thành viên nội tộc tương ứng.',
  },
  {
    from: 'tblgiapha.idme',
    to: 'tblgiapha.idgiapha',
    cardinality: 'N : 1 (tự tham chiếu)',
    mechanism: 'Kiểm tra khi xóa',
    description: 'Được kiểm tra tồn tại con trong giapha_delete.asp trước khi xóa, nhưng chưa có trường nhập ở các biểu mẫu.',
  },
  {
    from: 'tblgiapha.iddoi',
    to: 'tbldoi.iddoi',
    cardinality: 'N : 1',
    mechanism: 'Khóa ngoại logic (ASP)',
    description: 'Xác định nhân vật thuộc đời thứ mấy; tự động cộng đời khi thêm con mới.',
  },
  {
    from: 'tbladmin.allowed_start_idgiapha',
    to: 'tblgiapha.idgiapha',
    cardinality: 'N : 1',
    mechanism: 'Khóa ngoại logic (ASP)',
    description: 'Giới hạn phạm vi quản lý phả hệ của quản trị viên chỉ từ nhân vật gốc này trở xuống (0 = toàn dòng họ).',
  },
  {
    from: 'tbltintuc.idnhomtin',
    to: 'tblnhomtin.idnhomtin',
    cardinality: 'N : 1',
    mechanism: 'Khóa ngoại logic + chặn xóa',
    description: 'Phân loại bài viết theo chuyên mục; nhomtin_list.asp chặn xóa nhóm nếu vẫn còn bài viết liên kết.',
  },
  {
    from: 'tblanh.idnhomanh',
    to: 'tblnhomanh.idnhomanh',
    cardinality: 'N : 1',
    mechanism: 'Khóa ngoại logic + đồng bộ bìa',
    description: 'Gắn từng ảnh con vào album; khi thêm/sắp xếp/xóa ảnh, hệ thống cập nhật lại tblnhomanh.hinhanh theo ảnh đầu tiên.',
  },
];

export const FRONTEND_ROUTES: { param: string; target: string; status: string; desc: string }[] = [
  { param: 'gpdh=1', target: 'Includes/inc_tintuc.asp', status: 'Thiếu file trong repo', desc: 'Danh sách tin tức tổng hợp' },
  { param: 'gpdh=2', target: 'Includes/inc_hinhanh.asp', status: 'Thiếu file trong repo', desc: 'Thư viện hình ảnh' },
  { param: 'gpdh=3', target: 'Includes/inc_video.asp', status: 'Thiếu file trong repo', desc: 'Thư viện video' },
  { param: 'gpdh=5', target: 'Includes/inc_phadodoc.asp', status: 'Thiếu file trong repo', desc: 'Hiển thị phả đồ dạng dọc' },
  { param: 'gpdh=6', target: 'Includes/inc_phadotheodoi.asp', status: 'Thiếu file trong repo', desc: 'Hiển thị phả đồ theo đời' },
  { param: 'gpdh=7', target: 'Includes/inc_phadongang.asp', status: 'Thiếu file trong repo', desc: 'Hiển thị phả đồ dạng ngang' },
  { param: 'thongtin=<id>', target: 'Includes/inc_thongtin.asp', status: 'Thiếu file trong repo', desc: 'Xem trang thông tin dòng họ' },
  { param: 'nhomtin=<id>', target: 'Includes/inc_nhomtin.asp', status: 'Thiếu file trong repo', desc: 'Danh sách bài viết theo chuyên mục' },
  { param: 'giapha=<id>', target: 'Includes/inc_giapha.asp', status: 'Thiếu file trong repo', desc: 'Trang hồ sơ chi tiết nhân vật gia phả' },
  { param: 'hinhanh=<id>', target: 'Includes/inc_xemanh.asp', status: 'Thiếu file trong repo', desc: 'Xem chi tiết một album ảnh' },
  { param: 'tintuc=<id>', target: 'Includes/inc_chitiet.asp', status: 'Có mã nguồn đầy đủ', desc: 'Chi tiết bài viết tin tức (2 cột, breadcrumb, in bài, TOP 5 tin khác)' },
  { param: 'Mặc định', target: 'Includes/inc_main.asp', status: 'Thiếu file trong repo', desc: 'Trang chủ hệ thống gia phả' },
];

export const FRONTEND_IMPLEMENTED_FEATURES: FeatureGroupSpec[] = [
  {
    id: 'fe-default',
    title: 'Điều hướng tổng & cấu trúc khung trang (default.asp + functions.asp)',
    files: 'mau-website/default.asp · mau-website/functions.asp · mau-website/connection.asp',
    items: [
      {
        name: 'Tải cấu hình toàn cục & bảo mật cơ bản',
        detail: 'Đọc bảng tblconfig (idconfig = 1) để áp font_family, font_size, mausac, logo, SEO (tukhoa, mota). Dùng ConvertiTitoloInNomeScript để tạo đường dẫn thân thiện tiếng Việt không dấu.',
      },
      {
        name: 'Phân nhánh nội dung qua QueryString',
        detail: 'Kiểm tra lần lượt các tham số gpdh (1, 2, 3, 5, 6, 7), thongtin, nhomtin, giapha, hinhanh, tintuc và nhánh mặc định inc_main.asp, bọc trong inc_header.asp và inc_footer.asp.',
      },
    ],
  },
  {
    id: 'fe-chitiet',
    title: 'Trang chi tiết tin tức (Includes/inc_chitiet.asp)',
    files: 'mau-website/Includes/inc_chitiet.asp',
    items: [
      {
        name: 'Bố cục 2 cột & thanh dẫn đường (Breadcrumb)',
        detail: 'Hiển thị banner đầu trang, breadcrumb theo chuyên mục tblnhomtin, tiêu đề, ngày cập nhật, nút In bài viết (window.print) và nội dung HTML đầy đủ.',
      },
      {
        name: 'Cột bên dính (Sticky Sidebar)',
        detail: 'Tự động truy vấn TOP 5 bài viết khác cùng/khác mục kèm đường dẫn slug hóa, và danh sách liên kết nhanh tới các mục trong tblthongtin.',
      },
    ],
  },
  {
    id: 'fe-ajax',
    title: 'API xem nhanh & xóa nhân vật (ajax_chitiet.asp · giapha_delete.asp)',
    files: 'mau-website/ajax_chitiet.asp · mau-website/giapha_delete.asp',
    items: [
      {
        name: 'Thẻ xem nhanh hồ sơ nhân vật (ajax_chitiet.asp)',
        detail: 'Nhận tham số ID qua AJAX, trả về khối HTML chi tiết gồm ảnh đại diện, họ tên, tên tự, đời, năm sinh/mất, hưởng thọ, tình trạng, nghề nghiệp, nơi an táng, địa chỉ, tiểu sử và nút mở trang đầy đủ /giapha/<id>.',
      },
      {
        name: 'Xóa nhân vật an toàn theo giao dịch (giapha_delete.asp)',
        detail: 'Nhận POST trả về JSON. Xác thực phiên đăng nhập, mã chống giả mạo CSRF, quyền theo nhánh quản trị (CheckGenealogyPermissionOnConnection), khóa bản ghi bằng UPDLOCK/HOLDLOCK trong SQL Transaction, chặn xóa idgiapha = 1 hoặc khi còn con/vợ chồng liên kết, sau đó đánh lại thutu các anh chị em.',
      },
    ],
  },
];

export const ADMIN_ROUTES: RouteSpec[] = [
  { pattern: '^bang-dieu-khien/?$', target: 'default.asp', module: 'Bảng điều khiển tổng quan', group: 'Bảng điều khiển' },
  { pattern: '^pha-do/?$', target: 'default.asp?gpdh=12', module: 'giapha_list.asp (Cây gia phả ma trận)', group: 'Phả hệ dòng họ' },
  { pattern: '^them-nhan-vat/?$', target: 'default.asp?gpdh=13', module: 'giapha_new.asp (Thêm nội tộc / vợ chồng)', group: 'Phả hệ dòng họ' },
  { pattern: '^sua-nhan-vat/?$', target: 'default.asp?gpdh=14', module: 'giapha_edit.asp (Sửa hồ sơ nhân vật)', group: 'Phả hệ dòng họ' },
  { pattern: '^them-nhan-vat-ngoai/?$', target: 'default.asp?gpdh=15', module: 'giaphangoai_new.asp (Thêm cháu ngoại)', group: 'Phả hệ dòng họ' },
  { pattern: '^nhan-vat-ngoai/?$', target: 'default.asp?gpdh=16', module: 'giaphangoai_list.asp (Danh sách cháu ngoại)', group: 'Phả hệ dòng họ' },
  { pattern: '^quan-ly-doi/?$', target: 'default.asp?gpdh=9', module: 'doi_list.asp (Quản lý danh mục đời)', group: 'Phả hệ dòng họ' },
  { pattern: '^quan-ly-doi/sua/([0-9]+)/?$', target: 'default.asp?gpdh=9&id={R:1}', module: 'doi_list.asp (Sửa đời theo ID)', group: 'Phả hệ dòng họ' },
  { pattern: '^tin-tuc/?$', target: 'default.asp?gpdh=2', module: 'tintuc_list.asp (Danh sách tin tức)', group: 'Nội dung tư liệu' },
  { pattern: '^them-tin-moi/?$', target: 'default.asp?gpdh=1', module: 'tintuc_new.asp (Thêm bài viết mới)', group: 'Nội dung tư liệu' },
  { pattern: '^sua-tin/?$', target: 'default.asp?gpdh=3', module: 'tintuc_edit.asp (Chỉnh sửa bài viết)', group: 'Nội dung tư liệu' },
  { pattern: '^gioi-thieu/?$', target: 'default.asp?gpdh=29', module: 'gioithieu.asp (Sửa bài Giới thiệu dòng họ)', group: 'Nội dung tư liệu' },
  { pattern: '^nhom-tin/?$', target: 'default.asp?gpdh=18', module: 'nhomtin_list.asp (Quản lý chuyên mục tin)', group: 'Nội dung tư liệu' },
  { pattern: '^thong-tin-dong-ho/?$', target: 'default.asp?gpdh=6', module: 'thongtin_list.asp (Danh sách thông tin)', group: 'Nội dung tư liệu' },
  { pattern: '^them-thong-tin-dong-ho/?$', target: 'default.asp?gpdh=5', module: 'thongtin_new.asp (Thêm mục thông tin)', group: 'Nội dung tư liệu' },
  { pattern: '^sua-thong-tin-dong-ho/?$', target: 'default.asp?gpdh=7', module: 'thongtin_edit.asp (Sửa mục thông tin)', group: 'Nội dung tư liệu' },
  { pattern: '^thu-vien-anh/?$', target: 'default.asp?gpdh=23', module: 'nhomanh_list.asp (Danh sách album ảnh)', group: 'Nội dung tư liệu' },
  { pattern: '^them-thu-vien-anh/?$', target: 'default.asp?gpdh=24', module: 'nhomanh_new.asp (Tạo album ảnh mới)', group: 'Nội dung tư liệu' },
  { pattern: '^sua-thu-vien-anh/?$', target: 'default.asp?gpdh=25', module: 'nhomanh_edit.asp + ajax_gallery.asp', group: 'Nội dung tư liệu' },
  { pattern: '^thu-vien-video/?$', target: 'default.asp?gpdh=26', module: 'video_list.asp (Quản lý thư viện video)', group: 'Nội dung tư liệu' },
  { pattern: '^slider-anh/?$', target: 'default.asp?gpdh=8', module: 'loadanh.asp + ajax_loadanh.asp (Slider)', group: 'Nội dung tư liệu' },
  { pattern: '^cau-hinh/?$', target: 'default.asp?gpdh=4', module: 'config.asp (Cấu hình chung & giao diện)', group: 'Hệ thống' },
  { pattern: '^cau-hinh-text/?$', target: 'default.asp?gpdh=10', module: 'config_text.asp (Cấu hình nhãn UI)', group: 'Hệ thống' },
  { pattern: '^nguoi-dung/?$', target: 'default.asp?gpdh=30', module: 'user_list.asp (Quản lý tài khoản & quyền)', group: 'Hệ thống' },
  { pattern: '^logout/?$', target: 'default.asp?gpdh=32', module: 'Đăng xuất, xóa Session quản trị', group: 'Hệ thống' },
];

export const ADMIN_FEATURE_GROUPS: FeatureGroupSpec[] = [
  {
    id: 'adm-auth-dash',
    title: 'Đăng nhập & Bảng điều khiển tổng quan (Dashboard)',
    files: 'gpdh/login.asp · gpdh/sha256.asp · gpdh/default.asp',
    items: [
      {
        name: 'Xác thực SHA-256 & ảnh nền động',
        detail: 'Trang đăng nhập nạp ảnh nền ngẫu nhiên/đầu tiên từ tblloadanh, đối chiếu mật khẩu băm SHA-256 hex với tbladmin và khởi tạo 6 biến Session phân quyền.',
      },
      {
        name: 'Trạng thái khởi tạo Thủy Tổ',
        detail: 'Khi bảng tblgiapha chưa có dữ liệu, Dashboard hiển thị khối hướng dẫn và nút "Khởi tạo Thủy Tổ" dẫn trực tiếp tới quy trình tạo nhân vật gốc.',
      },
      {
        name: '7 thẻ thống kê & thanh hạn mức số đinh (Quota Bar)',
        detail: 'Hiển thị tổng quan số lượng thành viên/đinh, nam/nữ, vợ/chồng, cháu ngoại, đời, tin tức, ảnh/video. Thanh hạn mức tính tỷ lệ sử dụng so với tblconfig.gioihan_dinh (fallback 200 nếu chưa đặt): <70% xanh lá, 70–89% vàng cam, >=90% đỏ và bật cảnh báo khi >=85%.',
      },
    ],
  },
  {
    id: 'adm-genealogy',
    title: 'Quản lý Phả hệ dòng họ & Xuất bản dữ liệu',
    files: 'giapha_list.asp · giapha_new.asp · giapha_edit.asp · giaphangoai_new.asp · giaphangoai_list.asp · giapha_excel.asp · giapha_word.asp · giapha_book.asp · doi_list.asp',
    items: [
      {
        name: 'Hiển thị & thao tác cây gia phả ma trận (giapha_list.asp)',
        detail: 'Nạp toàn bộ dữ liệu phả hệ vào RAM bằng GetRows(), duyệt đệ quy DFS render bảng ma trận theo các cột đời, phân biệt màu dòng theo giới tính/cháu ngoại, xem nhanh Fancybox và xóa qua AJAX Transaction.',
      },
      {
        name: 'Thêm / Sửa nội tộc, vợ/chồng và cháu ngoại',
        detail: 'giapha_new.asp và giapha_edit.asp kiểm tra hạn mức KiemTraHanMucGiaPha, tự động sinh đời mới bằng chữ số La Mã trong tbldoi nếu đời con vượt mức hiện có, tự động đánh lại số thứ tự thutu khi thêm/đổi vị trí/chuyển cha. giaphangoai_new.asp & giaphangoai_list.asp quản lý riêng nhánh con của con gái (loai_quanhe = 3).',
      },
      {
        name: 'Xuất file Excel, Word & Sách Gia Phả',
        detail: 'giapha_excel.asp xuất bảng HTML định dạng Excel (.xls) theo từng cột đời phẳng (không gộp colspan ô tên). giapha_word.asp xuất văn bản Word (.doc) tường thuật lần lượt theo từng đời. giapha_book.asp (tệp tồn tại trong repo nhưng chưa gắn menu) định dạng trình bày dạng cuốn phả hệ kết hợp phaky/tocuoc.',
      },
      {
        name: 'Quản lý danh mục Đời (doi_list.asp)',
        detail: 'Thêm, sửa tiêu đề và thứ tự các đời trong tbldoi.',
      },
    ],
  },
  {
    id: 'adm-content',
    title: 'Quản trị Nội dung tư liệu & Tải tệp đa phương tiện',
    files: 'tintuc_*.asp · nhomtin_list.asp · gioithieu.asp · thongtin_*.asp · nhomanh_*.asp · ajax_gallery.asp · video_list.asp · loadanh.asp · ajax_loadanh.asp · ajax_upload_ha.asp',
    items: [
      {
        name: 'Tin tức, Chuyên mục, Giới thiệu & Thông tin dòng họ',
        detail: 'CRUD đầy đủ với trình soạn thảo WYSIWYG InnovaEditor. nhomtin_list.asp chặn xóa chuyên mục nếu còn bài viết trong tbltintuc.',
      },
      {
        name: 'Thư viện ảnh thông minh (nhomanh_edit.asp + ajax_gallery.asp)',
        detail: 'Hỗ trợ tải nhiều ảnh với nén phía trình duyệt bằng HTML5 Canvas (kích thước tối đa <=1600px, dung lượng <=200KB), kéo thả sắp xếp thứ tự bằng SortableJS, tự động đồng bộ ảnh bìa tblnhomanh.hinhanh theo ảnh đầu tiên và xóa tệp vật lý trên đĩa bằng FileSystemObject (FSO).',
      },
      {
        name: 'Slider ảnh & Video (loadanh.asp · ajax_loadanh.asp · video_list.asp)',
        detail: 'Quản lý danh sách ảnh trình chiếu đầu trang và danh mục video YouTube theo thứ tự.',
      },
      {
        name: 'Cổng tải ảnh tập trung (ajax_upload_ha.asp)',
        detail: 'Xử lý upload nhị phân bằng ADODB.Stream, kiểm tra danh sách đuôi tệp cho phép (jpg, jpeg, png, gif, webp) và gắn tiền tố thời gian (timestamp) chống trùng tên tệp.',
      },
    ],
  },
  {
    id: 'adm-system',
    title: 'Cấu hình Hệ thống, Nhãn giao diện & Người dùng',
    files: 'config.asp · config_text.asp · user_list.asp · user_edit1.asp (kế thừa)',
    items: [
      {
        name: 'Cấu hình giao diện & thương hiệu (config.asp)',
        detail: 'Tùy chỉnh tên dòng họ, tộc trưởng, địa chỉ, điện thoại, website, chọn 20 bộ Google Fonts, cỡ chữ 15px–25px, bộ chọn màu chủ đạo, 6 vị trí ảnh (logo, logof, icon, bgtren, bgchinh, anhdaidien), thẻ SEO và mã nhúng Google Maps.',
      },
      {
        name: 'Quản lý nhãn văn bản động (config_text.asp)',
        detail: 'Chỉnh sửa trực tiếp các bản ghi trong tblUI_Text để thay đổi tiêu đề và mô tả các khối trang chủ mà không cần sửa mã nguồn.',
      },
      {
        name: 'Quản lý tài khoản & phân quyền (user_list.asp)',
        detail: 'Tạo/sửa/xóa tài khoản quản trị trong tbladmin, gán cờ quyền is_super, is_content, is_genealogy và chỉ định nhân vật gốc allowed_start_idgiapha để phân quyền theo chi/nhánh.',
      },
    ],
  },
];

export const BUSINESS_FLOWS: FlowSectionSpec[] = [
  {
    id: 'flow-tree',
    code: '3.1',
    title: 'Luồng vẽ cây gia phả & quản trị cấu trúc phả hệ',
    summary:
      'Hệ thống lưu trữ cây phả hệ bằng mô hình Adjacency List (idcha, id_vochong) và tối ưu hiệu năng hiển thị bằng kỹ thuật nạp RAM 2 truy vấn kết hợp duyệt đệ quy DFS.',
    blocks: [
      {
        heading: 'Nạp dữ liệu vào RAM (LoadGenealogyArrays)',
        bullets: [
          'Thay vì truy vấn SQL lặp lại cho từng nút con (N+1 queries), giapha_list.asp thực thi đúng 2 câu truy vấn SQL để nạp toàn bộ danh sách thành viên (loai_quanhe <> 2) và danh sách vợ/chồng (loai_quanhe = 2) vào mảng bộ nhớ qua rs.GetRows().',
          'Toàn bộ bước tìm con theo idcha và ghép vợ/chồng theo id_vochong đều thực hiện trên mảng bộ nhớ RAM.',
        ],
      },
      {
        heading: 'Thuật toán dựng bảng ma trận đệ quy (RenderMatrixTree_Array)',
        bullets: [
          'Xác định dải cột đời từ startIndex đến endIndex (theo khoảng đời lọc hoặc toàn bộ tbldoi).',
          'Với mỗi nút nhân vật ở vị trí đời colIdx, tạo một dòng <tr> gồm: các ô trống bên trái gộp bằng colspan = (colIdx - startIndex), nối tiếp là ô hiển thị tên nhân vật gộp bằng colspan = (endIndex - colIdx + 1) để tên dài không bị bóp hẹp cột.',
          'Khác biệt ở các bộ xuất tệp: giapha_excel.asp xuất từng ô <td></td> rỗng riêng lẻ không dùng colspan ở ô tên để tương thích cột Excel; giapha_word.asp không vẽ ma trận mà duyệt nhóm theo từng đời để xuất văn bản tường thuật.',
        ],
        codeNote: 'Định dạng nhãn hiển thị: [Đời La Mã].[thutu]. [hoten] [(Cháu ngoại)] - [Vợ/Chồng...]',
      },
      {
        heading: 'Quy ước màu sắc, phân loại & ràng buộc thao tác',
        bullets: [
          'Phân biệt màu nền dòng trong giapha_list.asp: row-male (trắng) cho nam nội tộc, row-female (#fff1f2 hồng nhạt) cho nữ nội tộc, row-ngoai (#fefce8 vàng nhạt) cho cháu ngoại (loai_quanhe = 3).',
          'Nhân vật Thủy Tổ (idgiapha = 1) hiển thị nổi bật màu đỏ và bị khóa thao tác xóa cả ở giao diện lẫn API giapha_delete.asp.',
          'Nhân vật cháu ngoại (loai_quanhe = 3) bị ẩn nút thêm con và thêm vợ/chồng để giữ đúng biên giới phả hệ nội tộc.',
        ],
      },
      {
        heading: 'Tự động sinh đời La Mã, đánh lại thứ tự & kiểm soát hạn mức',
        bullets: [
          'Khi thêm con mà đời kế tiếp (đời cha + 1) chưa có trong tbldoi, hệ thống tự động tạo bản ghi đời mới với tiêu đề chữ số La Mã tương ứng.',
          'Hàm đánh lại thutu chạy tự động sau khi thêm, sửa vị trí, chuyển cha hoặc xóa nhân vật nhằm đảm bảo thứ tự con trong cùng gia đình luôn liên tục (1, 2, 3...).',
          'Hàm KiemTraHanMucGiaPha kiểm tra tổng số đinh hiện có so với tblconfig.gioihan_dinh (0 = không giới hạn, mặc định dự phòng 200) trước khi cho phép thêm mới.',
          'Khi xóa qua giapha_delete.asp, hệ thống mở SQL Transaction với khóa UPDLOCK, HOLDLOCK, kiểm tra đồng thời các ràng buộc con (idcha, idme) và vợ/chồng (id_vochong) để ngăn xóa làm đứt gãy cây.',
        ],
      },
    ],
  },
  {
    id: 'flow-rbac',
    code: '3.2',
    title: 'Luồng phân quyền thành viên & giới hạn nhánh phả hệ',
    summary:
      'Phân quyền kết hợp giữa nhóm chức năng (RBAC 3 cờ) và phạm vi dữ liệu theo nhánh cây gia phả (Branch-level Scope) lưu trực tiếp trong Session sau khi đăng nhập.',
    blocks: [
      {
        heading: '6 biến Session phân quyền được khởi tạo khi đăng nhập',
        bullets: [
          'Session("username") và Session("idadmin"): định danh quản trị viên hiện tại.',
          'Session("is_super") = 1: toàn quyền quản trị hệ thống, cấu hình, người dùng và toàn bộ cây phả hệ.',
          'Session("is_content") = 1: quản trị nhóm nội dung (tin tức, chuyên mục, thông tin, thư viện ảnh, video).',
          'Session("is_genealogy") = 1: quản trị phả hệ dòng họ.',
          'Session("allowed_start_idgiapha"): ID nhân vật gốc mà tài khoản được phép thao tác (0 = toàn bộ dòng họ; >0 = chỉ quản lý từ nhân vật đó và các hậu duệ trở xuống).',
        ],
      },
      {
        heading: 'Thuật toán kiểm tra hậu duệ nhánh (IsDescendant)',
        bullets: [
          'giapha_list.asp sử dụng CheckGenealogyPermission; giapha_delete.asp sử dụng CheckGenealogyPermissionOnConnection kết hợp hàm IsDescendant.',
          'Với bản ghi vợ/chồng (loai_quanhe = 2), thuật toán tự động ánh xạ sang nhân vật nội tộc qua id_vochong trước khi dò ngược lên tổ tiên theo idcha.',
          'Thuật toán duy trì tập hợp visitedIDs (chống vòng lặp vô hạn nếu dữ liệu idcha bị tham chiếu vòng) cho tới khi gặp allowed_start_idgiapha (hợp lệ) hoặc về tới 0 (từ chối).',
        ],
      },
      {
        heading: 'Thực trạng áp dụng kiểm tra quyền trong mã nguồn (Điểm cần lưu ý)',
        bullets: [
          'Kiểm tra chặt chẽ theo nhánh: được thực thi rõ tại giapha_list.asp (xác định gốc hiển thị & quyền thao tác) và giapha_delete.asp (xác thực Session + CSRF + CheckGenealogyPermissionOnConnection).',
          'Kiểm tra chưa đồng đều ở một số điểm cuối: các tệp giapha_new.asp, giapha_edit.asp, giaphangoai_new.asp, giaphangoai_list.asp, giapha_excel.asp và giapha_word.asp chưa đồng bộ đầy đủ kiểm tra nhánh allowed_start_idgiapha ở tầng xử lý POST/GET.',
          'Một số trang cấu hình và endpoint AJAX (config.asp, config_text.asp, gioithieu.asp, loadanh.asp, các tệp ajax_*.asp) mới chủ yếu kiểm tra đăng nhập cơ bản hoặc ẩn liên kết ở menu mà chưa luôn chặn cứng theo cờ is_super/is_content ở đầu tệp.',
        ],
      },
    ],
  },
  {
    id: 'flow-search',
    code: '3.3',
    title: 'Luồng tìm kiếm & lọc dữ liệu phả hệ',
    summary:
      'Hỗ trợ đồng thời 4 tham số lọc qua phương thức GET, với hành vi hiển thị khác biệt rõ rệt giữa màn hình tra cứu trực tuyến và các bộ xuất tệp in ấn.',
    blocks: [
      {
        heading: 'Bộ tham số lọc đầu vào (GET QueryString)',
        bullets: [
          'tukhoa: chuỗi từ khóa tìm kiếm theo tên/thông tin nhân vật.',
          'tu_doi và den_doi: giới hạn khoảng đời hiển thị; nếu người dùng chọn tu_doi > den_doi, mã nguồn tự động hoán đổi hai giá trị để khoảng lọc luôn hợp lệ.',
          'gioitinh: lọc theo giới tính (tất cả / Nam = 1 / Nữ = 2).',
        ],
      },
      {
        heading: 'Khác biệt hành vi giữa màn hình quản lý và xuất tệp',
        bullets: [
          'Tại giapha_list.asp (trực tuyến): tham số tukhoa KHÔNG ẩn các dòng không khớp nhằm giữ nguyên cấu trúc huyết thống của cây, mà tô sáng màu vàng (highlight) trực tiếp vào các nút khớp từ khóa.',
          'Tại giapha_excel.asp và giapha_word.asp (xuất tệp): tham số tukhoa lọc cứng và ẨN toàn bộ các nhân vật không khớp điều kiện tìm kiếm.',
          'Xử lý gioitinh = 1 (Nam): giapha_list.asp và giapha_excel.asp tự động loại trừ nhóm cháu ngoại (loai_quanhe = 3) khi lọc Nam nội tộc, trong khi giapha_word.asp không áp dụng loại trừ bổ sung này.',
        ],
      },
    ],
  },
];

export const LANDING_BLOCKS: LandingBlockSpec[] = [
  {
    order: '01',
    anchor: 'header',
    title: 'Thanh điều hướng cố định (Sticky Header)',
    summary: 'Cố định ở đầu trang, chứa logo GPDH, hệ thống menu chính và nút truy cập tài khoản động theo Session.',
    details: [
      'Gồm 5 mục điều hướng chính: Giới thiệu (#gioi-thieu), Tính năng (#tinh-nang), Bảng giá (#bang-gia), Đăng ký (#dang-ky) và menu thả xuống Tin tức (dẫn tới tintuc_list.asp, cam-nang.asp, dich-vu.asp).',
      'Nút bên phải thay đổi động theo trạng thái Session("KhachHangID"): hiển thị "ĐĂNG NHẬP" (mở #login-modal) khi chưa đăng nhập, hoặc "QUẢN LÝ" (dẫn tới /user/) khi đã có phiên khách hàng.',
      'Phiên bản di động (Mobile Drawer) bổ sung sẵn nút gọi nhanh Hotline 0915 555 977.',
    ],
  },
  {
    order: '02',
    anchor: '#gioi-thieu',
    title: 'Khối Mở đầu — Hero Banner (#gioi-thieu)',
    summary: 'Khối toàn màn hình dùng ảnh nền bgslider.jpg kết hợp kiểu chữ truyền thống Philosopher & Italianno.',
    details: [
      'Tiêu đề 2 tầng giới thiệu giải pháp số hóa Gia phả dòng họ trực tuyến.',
      'Nút kêu gọi hành động chính "XEM DEMO" liên kết trực tiếp tới trang mẫu thực tế https://hobuixuanbang.com.',
    ],
  },
  {
    order: '03',
    anchor: '#tinh-nang',
    title: 'Khối Tính năng nổi bật — Swiper 10 Slider (#tinh-nang)',
    summary: 'Trình chiếu toàn chiều rộng (full-width slider) khởi tạo bằng Swiper 10 với 10 slide tính năng được nạp động bằng mảng JavaScript features.',
    details: [
      'Mỗi slide gồm ảnh nền minh họa riêng (tuong-tac.jpg, them-moi.jpg, nhac-lich.jpg, luu-tru.jpg, tra-cuu.jpg, xuat-file.jpg, bao-cao.jpg, thiet-lap.jpg, giao-dien.jpg, tinh-nang.jpg), tiêu đề và đoạn mô tả chi tiết.',
      'Danh sách đầy đủ 10 slide được liệt kê chi tiết trong bảng bên dưới.',
    ],
  },
  {
    order: '04',
    anchor: '#bang-gia',
    title: 'Khối Bảng giá dịch vụ — 4 gói triển khai (#bang-gia)',
    summary: 'Trình bày lưới 4 gói dịch vụ theo quy mô số đinh của dòng họ, tách rõ phí khởi tạo năm đầu và phí duy trì hằng năm.',
    details: [
      'Gồm 4 gói: Gói Chi họ (<100 đinh), Gói Phái hệ (100–200 đinh), Gói Tộc hệ (200–400 đinh) và Gói Đại tôn (không giới hạn — gắn nhãn "Khuyên Dùng").',
      'Kèm ghi chú về chi phí tên miền riêng (Domain) và chứng chỉ bảo mật SSL.',
    ],
  },
  {
    order: '05',
    anchor: '#dang-ky',
    title: 'Khối Biểu mẫu đăng ký & Luồng xử lý ajax_dangky.asp (#dang-ky)',
    summary: 'Thu thập nhu cầu khách hàng kèm lớp chống spam Honeypot và chuyển tiếp thông báo đồng thời tới 2 dịch vụ ngoài qua HTTPS TLS 1.2.',
    details: [
      'Trường biểu mẫu: trường ẩn honeypot website, họ tên (fullname), số điện thoại (phone), email (email), địa chỉ (address), và chọn gói dịch vụ (package — 5 tùy chọn gồm 4 gói giá và nhu cầu tư vấn).',
      'Luồng xử lý backend (landingpage/ajax_dangky.asp): (1) Kiểm tra trường honeypot website — nếu có dữ liệu thì chặn spam; (2) Gửi thông báo tức thời tới Telegram Bot API bằng MSXML2.ServerXMLHTTP.6.0 cấu hình TLS 1.2 (setOption 2, 13056); (3) Ghi lưu dữ liệu đăng ký sang Google Sheets qua Google Apps Script Webhook (TLS 1.2); (4) Trả về JSON thành công để trình duyệt bật hộp thoại #success-popup.',
    ],
  },
  {
    order: '06',
    anchor: 'footer',
    title: 'Khối Chân trang (Footer)',
    summary: 'Nền xanh lục đậm thương hiệu (#005a3c) với đường viền vàng kim đặc trưng.',
    details: [
      'Hiển thị thông tin liên hệ Hotline 0915 555 977 và dòng bản quyền năm 2026 GPDH.',
    ],
  },
  {
    order: '07',
    anchor: 'modals',
    title: 'Hệ thống hộp thoại bật lên (Modals)',
    summary: 'Gồm 2 modal tương tác trên trang Landing Page.',
    details: [
      '#success-popup: Hộp thoại xác nhận đăng ký thành công hiển thị ngay sau khi ajax_dangky.asp trả kết quả hợp lệ.',
      '#login-modal: Hộp thoại đăng nhập khách hàng gửi POST tới ajax_login.asp, dự kiến chuyển hướng vào /user/ khi thành công, kèm liên kết hỗ trợ quên mật khẩu qua Zalo (lưu ý: ajax_login.asp và /user/ không có trong thư mục landingpage/ của repo).',
    ],
  },
];

export const LANDING_FEATURE_SLIDES: FeatureSlideSpec[] = [
  { index: 1, title: 'Cây gia phả tương tác', image: 'tuong-tac.jpg', desc: 'Hiển thị trực quan sơ đồ phả hệ qua nhiều thế hệ, hỗ trợ phóng to, thu nhỏ mượt mà.' },
  { index: 2, title: 'Quản lý thành viên', image: 'them-moi.jpg', desc: 'Thêm mới và cập nhật tiểu sử, năm sinh, năm mất, nơi an táng theo từng đời và chi phái.' },
  { index: 3, title: 'Lịch sự kiện & Ngày giỗ', image: 'nhac-lich.jpg', desc: 'Tự động tính toán và nhắc nhở ngày giỗ chạp, lễ trọng đại của dòng họ theo lịch Âm/Dương.' },
  { index: 4, title: 'Thư viện tư liệu số', image: 'luu-tru.jpg', desc: 'Lưu trữ an toàn tài liệu, hình ảnh, video kỷ niệm của dòng họ qua nhiều thế hệ.' },
  { index: 5, title: 'Tìm kiếm thông minh', image: 'tra-cuu.jpg', desc: 'Tra cứu nhanh thành viên theo tên, năm sinh hoặc đời thứ.' },
  { index: 6, title: 'Xuất file in ấn', image: 'xuat-file.jpg', desc: 'Trích xuất sơ đồ phả hệ và danh sách thành viên ra Excel hoặc định dạng chuẩn biên soạn Gia phả cuốn.' },
  { index: 7, title: 'Thống kê tổng quan', image: 'bao-cao.jpg', desc: 'Tổng hợp báo cáo số lượng thành viên, đinh nam/đinh nữ, dâu/rể giúp Hội đồng gia tộc nắm quy mô.' },
  { index: 8, title: 'Phân quyền quản trị', image: 'thiet-lap.jpg', desc: 'Cấp quyền cập nhật dữ liệu linh hoạt cho từng trưởng chi, trưởng phái.' },
  { index: 9, title: 'Giao diện thân thiện', image: 'giao-dien.jpg', desc: 'Bố cục tối ưu hiển thị trên máy tính, máy tính bảng và điện thoại di động.' },
  { index: 10, title: 'Quản trị toàn diện', image: 'tinh-nang.jpg', desc: 'Bộ công cụ quản lý chuyên sâu cho phép sắp xếp, tùy chỉnh và mở rộng dữ liệu theo thời gian.' },
];

export const LANDING_PRICING_TIERS: PricingTierSpec[] = [
  { name: 'Gói Chi họ', initPrice: '1.300.000đ', annualPrice: '800.000đ / năm', scale: 'Dưới 100 đinh', highlight: 'Phù hợp chi nhỏ khởi tạo số hóa' },
  { name: 'Gói Phái hệ', initPrice: '2.000.000đ', annualPrice: '1.000.000đ / năm', scale: '100 – 200 đinh', highlight: 'Phù hợp phái hệ quy mô vừa' },
  { name: 'Gói Tộc hệ', initPrice: '2.700.000đ', annualPrice: '1.200.000đ / năm', scale: '200 – 400 đinh', highlight: 'Phù hợp dòng họ nhiều chi nhánh' },
  { name: 'Gói Đại tôn', initPrice: '3.500.000đ', annualPrice: '1.500.000đ / năm', scale: 'Không giới hạn số đinh', highlight: 'Khuyên Dùng · Mở rộng lâu dài' },
];
