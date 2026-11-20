import { useEffect, useMemo, useState } from 'react';
import { Download } from 'lucide-react';
import { SpecDocument } from './components/SpecDocument.tsx';
import { TopBar } from './components/TopBar.tsx';
import { DATABASE_TABLES, DOCUMENT_META } from './data/specData.ts';
import { computeSpecMetrics, filterSpecification } from './utils/specFilter.ts';

const SECTION_ANCHORS = [
  { id: 'phan-1', num: '01', label: 'Cơ sở dữ liệu (12 bảng)' },
  { id: 'phan-2', num: '02', label: 'Chức năng Frontend & Admin' },
  { id: 'phan-3', num: '03', label: 'Luồng nghiệp vụ đặc thù' },
  { id: 'phan-4', num: '04', label: 'Cấu trúc Landing Page' },
];

export default function App() {
  const [query, setQuery] = useState('');
  const [activeSection, setActiveSection] = useState('phan-1');

  const metrics = useMemo(() => computeSpecMetrics(), []);
  const filtered = useMemo(() => filterSpecification(query), [query]);

  useEffect(() => {
    const ids = SECTION_ANCHORS.map((s) => s.id);
    const handleScroll = () => {
      const offset = window.scrollY + 140;
      let current = ids[0];
      for (const id of ids) {
        const el = document.getElementById(id);
        if (el && el.offsetTop <= offset) {
          current = id;
        }
      }
      setActiveSection(current);
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    handleScroll();
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <div className="min-h-screen bg-[#FBF9F5] text-[#1C1917]">
      <TopBar activeSection={activeSection} />

      <div className="mx-auto max-w-[1280px] px-4 py-6 sm:px-6 sm:py-10 lg:px-8">
        <div className="grid grid-cols-1 gap-8 lg:grid-cols-[248px_minmax(0,1fr)]">
          {/* Editorial Sticky TOC Margin Rail (Hidden in Print/PDF) */}
          <aside className="no-print hidden lg:block">
            <div className="sticky top-24 space-y-6">
              <div>
                <p className="font-mono text-[10px] font-semibold tracking-[0.14em] text-[#78716C] uppercase">
                  Mục lục tài liệu
                </p>
                <nav aria-label="Mục lục chi tiết" className="mt-3 space-y-1 border-t border-[#E7E2D8] pt-3">
                  {SECTION_ANCHORS.map((section) => {
                    const isActive = activeSection === section.id;
                    return (
                      <a
                        key={section.id}
                        href={`#${section.id}`}
                        className={`flex items-baseline gap-2.5 py-1.5 text-sm transition-colors ${
                          isActive
                            ? 'font-semibold text-[#14532D]'
                            : 'text-[#57534E] hover:text-[#1C1917]'
                        }`}
                      >
                        <span className="font-mono text-[11px] text-[#78716C] tabular-nums">
                          {section.num}
                        </span>
                        <span>{section.label}</span>
                      </a>
                    );
                  })}
                </nav>
              </div>

              <div className="border-t border-[#E7E2D8] pt-5">
                <p className="font-mono text-[10px] font-semibold tracking-[0.14em] text-[#78716C] uppercase">
                  12 Bảng SQL Server
                </p>
                <div className="mt-2.5 flex flex-wrap gap-x-2.5 gap-y-1.5 font-mono text-[11px] text-[#57534E]">
                  {DATABASE_TABLES.map((t) => (
                    <button
                      key={t.id}
                      type="button"
                      onClick={() => setQuery(t.name)}
                      className="text-left underline-offset-4 hover:text-[#14532D] hover:underline"
                    >
                      {t.name}
                    </button>
                  ))}
                </div>
              </div>

              <div className="border border-[#E7E2D8] bg-white p-4">
                <p className="font-mono text-[10px] font-semibold tracking-[0.12em] text-[#78716C] uppercase">
                  Bản xuất PDF chuẩn A4
                </p>
                <p className="mt-1.5 text-xs leading-relaxed text-[#44403C]">
                  Tệp PDF được dàn trang sẵn đầy đủ 4 phần, hỗ trợ tiếng Việt UTF-8 và bảng biểu rõ
                  nét khi in ấn.
                </p>
                <a
                  href={DOCUMENT_META.pdfPath}
                  download={DOCUMENT_META.pdfFilename}
                  className="mt-3 inline-flex w-full items-center justify-center gap-2 bg-[#14532D] px-3 py-2 text-xs font-semibold text-white transition-colors hover:bg-[#166534]"
                >
                  <Download className="h-3.5 w-3.5" />
                  <span>Tải file PDF</span>
                </a>
              </div>
            </div>
          </aside>

          {/* Main Reading & Print Canvas */}
          <main className="min-w-0">
            <SpecDocument
              query={query}
              onQueryChange={setQuery}
              filtered={filtered}
              metrics={metrics}
            />
          </main>
        </div>
      </div>
    </div>
  );
}
