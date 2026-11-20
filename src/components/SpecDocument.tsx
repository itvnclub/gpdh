import { Printer, Search, X } from 'lucide-react';
import {
  DOCUMENT_META,
  REPO_GAPS,
} from '../data/specData.ts';
import type { FilteredSpecResult, SpecMetrics } from '../utils/specFilter.ts';

interface SpecDocumentProps {
  query: string;
  onQueryChange: (next: string) => void;
  filtered: FilteredSpecResult;
  metrics: SpecMetrics;
}

export function SpecDocument({
  query,
  onQueryChange,
  filtered,
  metrics,
}: SpecDocumentProps) {
  const isFiltering = filtered.normalizedQuery.length > 0;

  return (
    <article
      id="top"
      className="print-container border border-[#E7E2D8] bg-white px-5 py-8 sm:px-10 sm:py-12 lg:px-14 lg:py-14"
    >
      {/* Editorial Masthead / Cover Header */}
      <header className="border-b border-[#D6CEBE] pb-8">
        <p className="font-mono text-[11px] font-medium tracking-[0.14em] text-[#57534E] uppercase">
          {DOCUMENT_META.code} · {DOCUMENT_META.repository.replace('https://', '')} · Nhánh{' '}
          {DOCUMENT_META.branch} ({DOCUMENT_META.commit})
        </p>

        <h1 className="mt-4 font-serif text-3xl leading-tight font-semibold tracking-tight text-[#1C1917] sm:text-4xl lg:text-[42px]">
          {DOCUMENT_META.title}
        </h1>

        <p className="mt-3 max-w-3xl text-sm leading-relaxed text-[#44403C] sm:text-base">
          {DOCUMENT_META.subtitle}
        </p>

        {/* Accession Metadata Grid */}
        <dl className="mt-7 grid grid-cols-1 gap-x-8 gap-y-4 border-t border-[#EBE6DF] pt-6 text-xs sm:grid-cols-2">
          <div>
            <dt className="font-mono text-[10px] tracking-[0.12em] text-[#78716C] uppercase">
              Ngăn xếp kỹ thuật — Web Gia phả (mau-website/)
            </dt>
            <dd className="mt-1 leading-relaxed text-[#292524]">{DOCUMENT_META.stackWeb}</dd>
          </div>
          <div>
            <dt className="font-mono text-[10px] tracking-[0.12em] text-[#78716C] uppercase">
              Ngăn xếp kỹ thuật — Trang đích (landingpage/)
            </dt>
            <dd className="mt-1 leading-relaxed text-[#292524]">{DOCUMENT_META.stackLanding}</dd>
          </div>
          <div className="sm:col-span-2">
            <dt className="font-mono text-[10px] tracking-[0.12em] text-[#78716C] uppercase">
              Nguyên tắc đặc tả
            </dt>
            <dd className="mt-1 leading-relaxed text-[#292524]">{DOCUMENT_META.scopeNote}</dd>
          </div>
        </dl>

        {/* Key Numeric Summary Strip */}
        <div className="mt-6 grid grid-cols-2 gap-4 border-t border-[#EBE6DF] pt-5 sm:grid-cols-4">
          <div>
            <p className="font-serif text-2xl font-semibold text-[#14532D] tabular-nums">
              {metrics.totalTables}
            </p>
            <p className="mt-0.5 text-xs text-[#57534E]">Bảng CSDL SQL Server</p>
          </div>
          <div>
            <p className="font-serif text-2xl font-semibold text-[#1C1917] tabular-nums">
              {metrics.totalColumns}
            </p>
            <p className="mt-0.5 text-xs text-[#57534E]">Tổng số cột dữ liệu</p>
          </div>
          <div>
            <p className="font-serif text-2xl font-semibold text-[#1C1917] tabular-nums">
              {metrics.totalAdminRoutes}
            </p>
            <p className="mt-0.5 text-xs text-[#57534E]">Quy tắc định tuyến Admin</p>
          </div>
          <div>
            <p className="font-serif text-2xl font-semibold text-[#1C1917] tabular-nums">
              0{metrics.totalLandingBlocks}
            </p>
            <p className="mt-0.5 text-xs text-[#57534E]">Khối nội dung Landing Page</p>
          </div>
        </div>
      </header>

      {/* Utility Strip: Search + Print/PDF Secondary Controls (Hidden in Print/PDF) */}
      <div className="no-print mt-6 flex flex-col gap-3 border border-[#E7E2D8] bg-[#FAF7F2] p-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="relative flex-1">
          <Search
            className="pointer-events-none absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-[#78716C]"
            strokeWidth={1.75}
          />
          <input
            type="search"
            value={query}
            onChange={(e) => onQueryChange(e.target.value)}
            placeholder="Tra cứu bảng SQL, route, hàm ASP, Landing Page..."
            aria-label="Tra cứu nội dung bản đặc tả"
            data-testid="spec-search-input"
            className="w-full border border-[#D6CEBE] bg-white py-2 pr-9 pl-9 text-sm text-[#1C1917] placeholder:text-[#78716C] focus:border-[#14532D] focus:outline-none"
          />
          {query && (
            <button
              type="button"
              onClick={() => onQueryChange('')}
              aria-label="Xóa từ khóa tìm kiếm"
              data-testid="spec-search-clear"
              className="absolute top-1/2 right-2.5 -translate-y-1/2 p-1 text-[#78716C] hover:text-[#1C1917]"
            >
              <X className="h-4 w-4" />
            </button>
          )}
        </div>

        <div className="flex shrink-0 items-center gap-3">
          <span className="hidden font-mono text-[11px] text-[#78716C] xl:inline">
            A4 · UTF-8 · {DOCUMENT_META.pdfFilename}
          </span>
          <button
            type="button"
            onClick={() => window.print()}
            className="inline-flex items-center gap-1.5 border border-[#D6CEBE] bg-white px-3.5 py-2 text-xs font-medium text-[#292524] transition-colors hover:border-[#1C1917]"
          >
            <Printer className="h-3.5 w-3.5" />
            <span>In / Lưu PDF</span>
          </button>
        </div>
      </div>

      {isFiltering && (
        <div
          data-testid="search-status"
          className="no-print mt-4 flex items-center justify-between border-b border-[#EBE6DF] pb-3 text-xs text-[#57534E]"
        >
          <span>
            Kết quả lọc cho <strong className="font-semibold text-[#1C1917]">“{query}”</strong>:{' '}
            <strong className="font-mono text-[#14532D] tabular-nums">
              {filtered.totalMatches}
            </strong>{' '}
            mục phù hợp
          </span>
          <button
            type="button"
            onClick={() => onQueryChange('')}
            className="font-medium text-[#14532D] underline underline-offset-4 hover:text-[#166534]"
          >
            Hiển thị toàn bộ tài liệu
          </button>
        </div>
      )}

      {isFiltering && filtered.totalMatches === 0 ? (
        <div className="mt-10 border border-[#E7E2D8] bg-[#FAF7F2] p-8 text-center">
          <p className="font-serif text-lg font-medium text-[#1C1917]">
            Không tìm thấy nội dung khớp với “{query}”
          </p>
          <p className="mt-2 text-sm text-[#57534E]">
            Thử tìm kiếm bằng tên bảng SQL (ví dụ: tblgiapha, tblconfig), tên tệp ASP (ajax_dangky)
            hoặc từ khóa tiếng Việt không dấu.
          </p>
        </div>
      ) : (
        <>
          {/* Repository Scope & Gaps Note */}
          {!isFiltering && (
            <section className="print-avoid-break mt-8 border border-[#E7E2D8] bg-[#FAF7F2] p-5">
              <p className="font-mono text-[11px] font-semibold tracking-[0.12em] text-[#78350F] uppercase">
                Ghi nhận hiện trạng kho mã nguồn trước khi đọc chi tiết
              </p>
              <div className="mt-3 space-y-2.5 text-sm leading-relaxed text-[#292524]">
                {REPO_GAPS.map((gap) => (
                  <p key={gap.category}>
                    <strong className="font-semibold text-[#1C1917]">{gap.category}:</strong>{' '}
                    {gap.detail}
                  </p>
                ))}
              </div>
            </section>
          )}

          {/* ============================================================== */}
          {/* SECTION 1: DATABASE SCHEMA                                     */}
          {/* ============================================================== */}
          {(filtered.tables.length > 0 || filtered.relationships.length > 0) && (
            <section id="phan-1" className="mt-12 scroll-mt-24">
              <div className="border-b border-[#1C1917] pb-3">
                <p className="font-mono text-[11px] font-medium tracking-[0.14em] text-[#14532D] uppercase">
                  Phần 01 · Cơ sở dữ liệu
                </p>
                <h2 className="mt-1 font-serif text-2xl font-semibold text-[#1C1917] sm:text-3xl">
                  Danh sách toàn bộ các bảng cơ sở dữ liệu (SQL Server)
                </h2>
              </div>

              <p className="mt-4 text-sm leading-relaxed text-[#44403C]">
                Tệp <code className="font-mono text-xs text-[#14532D]">mau-website/database.sql</code>{' '}
                định nghĩa cơ sở dữ liệu <code className="font-mono text-xs">hobuixuanbang</code>{' '}
                gồm đúng <strong>12 bảng</strong> thuộc lược đồ{' '}
                <code className="font-mono text-xs">dbo</code>. Tất cả 12 bảng đều có khóa chính{' '}
                <code className="font-mono text-xs">PRIMARY KEY CLUSTERED</code>, tuy nhiên{' '}
                <strong>không khai báo bất kỳ ràng buộc FOREIGN KEY vật lý nào</strong> ở tầng SQL
                Server — toàn bộ quan hệ liên kết được quản lý ở tầng mã nguồn Classic ASP.
              </p>

              {/* Tables Detail */}
              <div className="mt-6 space-y-8">
                {filtered.tables.map((table, idx) => (
                  <div key={table.id} className="space-y-2.5">
                    <div className="flex flex-wrap items-baseline justify-between gap-2 border-b border-[#EBE6DF] pb-1.5">
                      <h3 className="font-serif text-lg font-semibold text-[#1C1917]">
                        <span className="mr-2 font-mono text-xs font-medium text-[#78716C] tabular-nums">
                          1.{idx + 1}
                        </span>
                        Bảng <code className="font-mono text-base text-[#14532D]">dbo.{table.name}</code>
                      </h3>
                      <span className="font-mono text-xs text-[#78716C] tabular-nums">
                        {table.columns.length} cột
                      </span>
                    </div>

                    <p className="text-sm text-[#44403C]">{table.purpose}</p>

                    <div className="overflow-x-auto border border-[#E7E2D8]">
                      <table className="w-full border-collapse text-left text-xs sm:text-[13px]">
                        <thead>
                          <tr className="border-b border-[#D6CEBE] bg-[#F7F4EE] text-[11px] font-semibold tracking-wider text-[#44403C] uppercase">
                            <th className="px-3 py-2.5">Tên cột</th>
                            <th className="px-3 py-2.5">Kiểu dữ liệu</th>
                            <th className="px-3 py-2.5">Ràng buộc / Khóa</th>
                            <th className="px-3 py-2.5">Ý nghĩa & Sử dụng trong code</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-[#EBE6DF]">
                          {table.columns.map((col) => (
                            <tr key={col.name} className="align-top hover:bg-[#FBF9F5]">
                              <td className="px-3 py-2 font-mono font-medium whitespace-nowrap text-[#1C1917]">
                                {col.name}
                              </td>
                              <td className="px-3 py-2 font-mono whitespace-nowrap text-[#14532D]">
                                {col.type}
                              </td>
                              <td className="px-3 py-2 font-mono text-[11px] text-[#57534E]">
                                {col.constraint}
                              </td>
                              <td className="px-3 py-2 leading-relaxed text-[#292524]">
                                {col.description}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>

                    {table.note && (
                      <p className="print-avoid-break border border-[#EBE6DF] bg-[#FAF7F2] px-3.5 py-2.5 text-xs leading-relaxed text-[#57534E]">
                        <strong className="font-semibold text-[#78350F]">Ghi chú kỹ thuật:</strong>{' '}
                        {table.note}
                      </p>
                    )}
                  </div>
                ))}
              </div>

              {/* Relationships Matrix */}
              {filtered.relationships.length > 0 && (
                <div className="mt-10 space-y-3">
                  <h3 className="border-b border-[#EBE6DF] pb-1.5 font-serif text-lg font-semibold text-[#1C1917]">
                    <span className="mr-2 font-mono text-xs font-medium text-[#78716C]">1.13</span>
                    Tổng hợp mối quan hệ logic giữa các bảng
                  </h3>
                  <div className="overflow-x-auto border border-[#E7E2D8]">
                    <table className="w-full border-collapse text-left text-xs sm:text-[13px]">
                      <thead>
                        <tr className="border-b border-[#D6CEBE] bg-[#F7F4EE] text-[11px] font-semibold tracking-wider text-[#44403C] uppercase">
                          <th className="px-3 py-2.5">Cột nguồn</th>
                          <th className="px-3 py-2.5">Tham chiếu tới</th>
                          <th className="px-3 py-2.5">Bản số</th>
                          <th className="px-3 py-2.5">Cơ chế thực thi</th>
                          <th className="px-3 py-2.5">Mô tả quan hệ</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-[#EBE6DF]">
                        {filtered.relationships.map((rel) => (
                          <tr key={`${rel.from}-${rel.to}`} className="align-top">
                            <td className="px-3 py-2 font-mono font-medium whitespace-nowrap text-[#1C1917]">
                              {rel.from}
                            </td>
                            <td className="px-3 py-2 font-mono whitespace-nowrap text-[#14532D]">
                              {rel.to}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap text-[#292524]">
                              {rel.cardinality}
                            </td>
                            <td className="px-3 py-2 text-[#57534E]">{rel.mechanism}</td>
                            <td className="px-3 py-2 leading-relaxed text-[#292524]">
                              {rel.description}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
            </section>
          )}

          {/* ============================================================== */}
          {/* SECTION 2: FRONTEND & ADMIN FEATURES                           */}
          {/* ============================================================== */}
          {(filtered.frontendRoutes.length > 0 ||
            filtered.frontendFeatures.length > 0 ||
            filtered.adminRoutes.length > 0 ||
            filtered.adminFeatures.length > 0) && (
            <section id="phan-2" className="print-section-break mt-14 scroll-mt-24">
              <div className="border-b border-[#1C1917] pb-3">
                <p className="font-mono text-[11px] font-medium tracking-[0.14em] text-[#14532D] uppercase">
                  Phần 02 · Danh mục chức năng
                </p>
                <h2 className="mt-1 font-serif text-2xl font-semibold text-[#1C1917] sm:text-3xl">
                  Chức năng trang người dùng (Frontend) và trang quản trị (Admin)
                </h2>
              </div>

              {/* 2.1 Frontend */}
              {(filtered.frontendRoutes.length > 0 || filtered.frontendFeatures.length > 0) && (
                <div className="mt-7 space-y-6">
                  <h3 className="border-b border-[#EBE6DF] pb-1.5 font-serif text-xl font-semibold text-[#1C1917]">
                    <span className="mr-2 font-mono text-xs font-medium text-[#78716C]">2.1</span>
                    Trang người dùng (Frontend — thư mục mau-website/)
                  </h3>

                  {filtered.frontendRoutes.length > 0 && (
                    <div className="overflow-x-auto border border-[#E7E2D8]">
                      <table className="w-full border-collapse text-left text-xs sm:text-[13px]">
                        <thead>
                          <tr className="border-b border-[#D6CEBE] bg-[#F7F4EE] text-[11px] font-semibold tracking-wider text-[#44403C] uppercase">
                            <th className="px-3 py-2.5">Tham số điều hướng (default.asp)</th>
                            <th className="px-3 py-2.5">Tệp #include đích</th>
                            <th className="px-3 py-2.5">Trạng thái trong repo</th>
                            <th className="px-3 py-2.5">Chức năng</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-[#EBE6DF]">
                          {filtered.frontendRoutes.map((route) => (
                            <tr key={route.param} className="align-top">
                              <td className="px-3 py-2 font-mono font-medium whitespace-nowrap text-[#1C1917]">
                                {route.param}
                              </td>
                              <td className="px-3 py-2 font-mono whitespace-nowrap text-[#14532D]">
                                {route.target}
                              </td>
                              <td
                                className={`px-3 py-2 whitespace-nowrap font-medium ${
                                  route.status.includes('Có mã nguồn')
                                    ? 'text-[#14532D]'
                                    : 'text-[#78350F]'
                                }`}
                              >
                                {route.status}
                              </td>
                              <td className="px-3 py-2 text-[#292524]">{route.desc}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  )}

                  {filtered.frontendFeatures.length > 0 && (
                    <div className="space-y-4">
                      {filtered.frontendFeatures.map((group) => (
                        <div
                          key={group.id}
                          className="print-avoid-break border border-[#E7E2D8] p-4 sm:p-5"
                        >
                          <h4 className="font-serif text-base font-semibold text-[#1C1917]">
                            {group.title}
                          </h4>
                          <p className="mt-0.5 font-mono text-[11px] text-[#57534E]">{group.files}</p>
                          <ul className="mt-3 space-y-2 text-sm leading-relaxed text-[#292524]">
                            {group.items.map((item) => (
                              <li key={item.name} className="flex gap-2">
                                <span className="mt-1.5 h-1.5 w-1.5 shrink-0 bg-[#14532D]" />
                                <span>
                                  <strong className="font-semibold text-[#1C1917]">
                                    {item.name}:
                                  </strong>{' '}
                                  {item.detail}
                                </span>
                              </li>
                            ))}
                          </ul>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {/* 2.2 Admin */}
              {(filtered.adminFeatures.length > 0 || filtered.adminRoutes.length > 0) && (
                <div className="mt-10 space-y-6">
                  <h3 className="border-b border-[#EBE6DF] pb-1.5 font-serif text-xl font-semibold text-[#1C1917]">
                    <span className="mr-2 font-mono text-xs font-medium text-[#78716C]">2.2</span>
                    Trang quản trị (Admin — thư mục mau-website/gpdh/)
                  </h3>

                  {filtered.adminFeatures.length > 0 && (
                    <div className="space-y-4">
                      {filtered.adminFeatures.map((group) => (
                        <div
                          key={group.id}
                          className="print-avoid-break border border-[#E7E2D8] p-4 sm:p-5"
                        >
                          <h4 className="font-serif text-base font-semibold text-[#1C1917]">
                            {group.title}
                          </h4>
                          <p className="mt-0.5 font-mono text-[11px] text-[#57534E]">{group.files}</p>
                          <ul className="mt-3 space-y-2 text-sm leading-relaxed text-[#292524]">
                            {group.items.map((item) => (
                              <li key={item.name} className="flex gap-2">
                                <span className="mt-1.5 h-1.5 w-1.5 shrink-0 bg-[#14532D]" />
                                <span>
                                  <strong className="font-semibold text-[#1C1917]">
                                    {item.name}:
                                  </strong>{' '}
                                  {item.detail}
                                </span>
                              </li>
                            ))}
                          </ul>
                        </div>
                      ))}
                    </div>
                  )}

                  {filtered.adminRoutes.length > 0 && (
                    <div className="space-y-2.5">
                      <h4 className="font-serif text-base font-semibold text-[#1C1917]">
                        Bảng ánh xạ 25 quy tắc IIS URL Rewrite (mau-website/gpdh/web.config)
                      </h4>
                      <div className="overflow-x-auto border border-[#E7E2D8]">
                        <table className="w-full border-collapse text-left text-xs sm:text-[13px]">
                          <thead>
                            <tr className="border-b border-[#D6CEBE] bg-[#F7F4EE] text-[11px] font-semibold tracking-wider text-[#44403C] uppercase">
                              <th className="px-3 py-2.5">Phân hệ</th>
                              <th className="px-3 py-2.5">URL Rewrite Pattern</th>
                              <th className="px-3 py-2.5">Đích thực thi</th>
                              <th className="px-3 py-2.5">Module xử lý</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-[#EBE6DF]">
                            {filtered.adminRoutes.map((route) => (
                              <tr key={route.pattern} className="align-top">
                                <td className="px-3 py-2 whitespace-nowrap text-[#57534E]">
                                  {route.group}
                                </td>
                                <td className="px-3 py-2 font-mono font-medium whitespace-nowrap text-[#1C1917]">
                                  {route.pattern}
                                </td>
                                <td className="px-3 py-2 font-mono whitespace-nowrap text-[#14532D]">
                                  {route.target}
                                </td>
                                <td className="px-3 py-2 text-[#292524]">{route.module}</td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  )}
                </div>
              )}
            </section>
          )}

          {/* ============================================================== */}
          {/* SECTION 3: SPECIALIZED BUSINESS FLOWS                          */}
          {/* ============================================================== */}
          {filtered.flows.length > 0 && (
            <section id="phan-3" className="print-section-break mt-14 scroll-mt-24">
              <div className="border-b border-[#1C1917] pb-3">
                <p className="font-mono text-[11px] font-medium tracking-[0.14em] text-[#14532D] uppercase">
                  Phần 03 · Luồng nghiệp vụ đặc thù
                </p>
                <h2 className="mt-1 font-serif text-2xl font-semibold text-[#1C1917] sm:text-3xl">
                  Cơ chế vẽ cây gia phả, phân quyền thành viên và tìm kiếm
                </h2>
              </div>

              <div className="mt-7 space-y-8">
                {filtered.flows.map((flow) => (
                  <div key={flow.id} className="space-y-4">
                    <div className="border-b border-[#EBE6DF] pb-2">
                      <h3 className="font-serif text-xl font-semibold text-[#1C1917]">
                        <span className="mr-2 font-mono text-xs font-medium text-[#78716C]">
                          {flow.code}
                        </span>
                        {flow.title}
                      </h3>
                      <p className="mt-1.5 text-sm leading-relaxed text-[#44403C]">
                        {flow.summary}
                      </p>
                    </div>

                    <div className="space-y-4">
                      {flow.blocks.map((block) => (
                        <div
                          key={block.heading}
                          className="print-avoid-break border border-[#E7E2D8] bg-[#FCFBF9] p-4 sm:p-5"
                        >
                          <h4 className="text-sm font-semibold text-[#1C1917]">{block.heading}</h4>
                          <ul className="mt-2.5 space-y-2 text-sm leading-relaxed text-[#292524]">
                            {block.bullets.map((bullet, i) => (
                              <li key={i} className="flex gap-2.5">
                                <span className="font-mono text-xs text-[#78716C] tabular-nums">
                                  {String(i + 1).padStart(2, '0')}.
                                </span>
                                <span>{bullet}</span>
                              </li>
                            ))}
                          </ul>
                          {block.codeNote && (
                            <p className="mt-3 border-t border-[#EBE6DF] pt-2.5 font-mono text-xs text-[#14532D]">
                              {block.codeNote}
                            </p>
                          )}
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            </section>
          )}

          {/* ============================================================== */}
          {/* SECTION 4: LANDING PAGE STRUCTURE                              */}
          {/* ============================================================== */}
          {(filtered.landingBlocks.length > 0 ||
            filtered.landingSlides.length > 0 ||
            filtered.pricingTiers.length > 0) && (
            <section id="phan-4" className="print-section-break mt-14 scroll-mt-24">
              <div className="border-b border-[#1C1917] pb-3">
                <p className="font-mono text-[11px] font-medium tracking-[0.14em] text-[#14532D] uppercase">
                  Phần 04 · Trang đích giới thiệu
                </p>
                <h2 className="mt-1 font-serif text-2xl font-semibold text-[#1C1917] sm:text-3xl">
                  Cấu trúc 7 khối nội dung trên Landing Page (landingpage/)
                </h2>
              </div>

              <p className="mt-4 text-sm leading-relaxed text-[#44403C]">
                Thư mục <code className="font-mono text-xs text-[#14532D]">landingpage/</code> gồm
                trang trình bày chính <code className="font-mono text-xs">index.asp</code>, API xử
                lý đăng ký <code className="font-mono text-xs">ajax_dangky.asp</code>, tệp cấu
                hình <code className="font-mono text-xs">web.config</code> và bộ ảnh minh họa. Toàn
                bộ nội dung được sắp xếp theo trình tự 7 khối từ trên xuống dưới:
              </p>

              {/* 7 Landing Page Blocks */}
              {filtered.landingBlocks.length > 0 && (
                <div className="mt-6 space-y-4">
                  {filtered.landingBlocks.map((block) => (
                    <div
                      key={block.order}
                      className="print-avoid-break border border-[#E7E2D8] p-4 sm:p-5"
                    >
                      <div className="flex flex-wrap items-baseline justify-between gap-2">
                        <h3 className="font-serif text-lg font-semibold text-[#1C1917]">
                          <span className="mr-2 font-mono text-xs font-medium text-[#14532D] tabular-nums">
                            Khối {block.order}
                          </span>
                          {block.title}
                        </h3>
                        <code className="font-mono text-xs text-[#78716C]">{block.anchor}</code>
                      </div>
                      <p className="mt-1 text-sm text-[#44403C]">{block.summary}</p>
                      <ul className="mt-3 space-y-1.5 text-sm leading-relaxed text-[#292524]">
                        {block.details.map((detail, idx) => (
                          <li key={idx} className="flex gap-2">
                            <span className="mt-1.5 h-1.5 w-1.5 shrink-0 bg-[#14532D]" />
                            <span>{detail}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  ))}
                </div>
              )}

              {/* 10 Feature Slides Table */}
              {filtered.landingSlides.length > 0 && (
                <div className="mt-8 space-y-2.5">
                  <h3 className="border-b border-[#EBE6DF] pb-1.5 font-serif text-lg font-semibold text-[#1C1917]">
                    <span className="mr-2 font-mono text-xs font-medium text-[#78716C]">4.1</span>
                    Danh sách 10 Slide Tính năng trong Swiper 10 (#tinh-nang)
                  </h3>
                  <div className="overflow-x-auto border border-[#E7E2D8]">
                    <table className="w-full border-collapse text-left text-xs sm:text-[13px]">
                      <thead>
                        <tr className="border-b border-[#D6CEBE] bg-[#F7F4EE] text-[11px] font-semibold tracking-wider text-[#44403C] uppercase">
                          <th className="px-3 py-2.5">STT</th>
                          <th className="px-3 py-2.5">Tiêu đề Slide</th>
                          <th className="px-3 py-2.5">Tệp ảnh nền</th>
                          <th className="px-3 py-2.5">Nội dung mô tả trong mảng features</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-[#EBE6DF]">
                        {filtered.landingSlides.map((slide) => (
                          <tr key={slide.index} className="align-top">
                            <td className="px-3 py-2 font-mono text-[#78716C] tabular-nums">
                              {String(slide.index).padStart(2, '0')}
                            </td>
                            <td className="px-3 py-2 font-semibold whitespace-nowrap text-[#1C1917]">
                              {slide.title}
                            </td>
                            <td className="px-3 py-2 font-mono whitespace-nowrap text-[#14532D]">
                              {slide.image}
                            </td>
                            <td className="px-3 py-2 leading-relaxed text-[#292524]">
                              {slide.desc}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {/* 4 Pricing Tiers Table */}
              {filtered.pricingTiers.length > 0 && (
                <div className="mt-8 space-y-2.5">
                  <h3 className="border-b border-[#EBE6DF] pb-1.5 font-serif text-lg font-semibold text-[#1C1917]">
                    <span className="mr-2 font-mono text-xs font-medium text-[#78716C]">4.2</span>
                    Chi tiết 4 Gói dịch vụ tại khối Bảng giá (#bang-gia)
                  </h3>
                  <div className="overflow-x-auto border border-[#E7E2D8]">
                    <table className="w-full border-collapse text-left text-xs sm:text-[13px]">
                      <thead>
                        <tr className="border-b border-[#D6CEBE] bg-[#F7F4EE] text-[11px] font-semibold tracking-wider text-[#44403C] uppercase">
                          <th className="px-3 py-2.5">Tên gói</th>
                          <th className="px-3 py-2.5">Phí khởi tạo</th>
                          <th className="px-3 py-2.5">Phí duy trì hằng năm</th>
                          <th className="px-3 py-2.5">Quy mô số đinh</th>
                          <th className="px-3 py-2.5">Ghi chú hiển thị</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-[#EBE6DF]">
                        {filtered.pricingTiers.map((tier) => (
                          <tr key={tier.name} className="align-top">
                            <td className="px-3 py-2 font-semibold whitespace-nowrap text-[#1C1917]">
                              {tier.name}
                            </td>
                            <td className="px-3 py-2 font-mono font-semibold whitespace-nowrap text-[#14532D] tabular-nums">
                              {tier.initPrice}
                            </td>
                            <td className="px-3 py-2 font-mono whitespace-nowrap text-[#292524] tabular-nums">
                              {tier.annualPrice}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap text-[#292524]">
                              {tier.scale}
                            </td>
                            <td className="px-3 py-2 text-[#57534E]">{tier.highlight}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}
            </section>
          )}
        </>
      )}

      {/* Editorial Colophon / Document Footer */}
      <footer className="mt-14 border-t border-[#D6CEBE] pt-6 text-xs text-[#57534E]">
        <div className="flex flex-col justify-between gap-2 sm:flex-row">
          <p>
            Tài liệu đặc tả hiện trạng mã nguồn{' '}
            <span className="font-mono text-[#1C1917]">itvnclub/gpdh</span> (Classic ASP + SQL
            Server &amp; Landing Page).
          </p>
          <p className="font-mono">
            {DOCUMENT_META.code} · {DOCUMENT_META.pdfFilename}
          </p>
        </div>
      </footer>
    </article>
  );
}
