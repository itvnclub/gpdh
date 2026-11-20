import { Download, FileText } from 'lucide-react';
import { DOCUMENT_META } from '../data/specData.ts';

interface TopBarProps {
  activeSection: string;
}

const NAV_ITEMS = [
  { id: 'phan-1', label: '01 · CSDL' },
  { id: 'phan-2', label: '02 · Chức năng' },
  { id: 'phan-3', label: '03 · Nghiệp vụ' },
  { id: 'phan-4', label: '04 · Landing Page' },
];

export function TopBar({ activeSection }: TopBarProps) {
  return (
    <header className="no-print sticky top-0 z-40 border-b border-[#E7E2D8] bg-[#FBF9F5]/95 backdrop-blur-sm">
      <div className="mx-auto flex h-16 max-w-[1280px] items-center justify-between gap-4 px-4 sm:px-6 lg:px-8">
        {/* Zone 1: Brand Title */}
        <a
          href="#top"
          className="flex min-w-0 items-center gap-2.5 text-[#1C1917] transition-opacity hover:opacity-80"
        >
          <span className="flex h-8 w-8 shrink-0 items-center justify-center border border-[#D6CEBE] bg-white text-[#14532D]">
            <FileText className="h-4 w-4" strokeWidth={1.75} />
          </span>
          <span className="truncate font-serif text-base font-semibold tracking-tight sm:text-lg">
            Đặc Tả Kỹ Thuật · GPDH
          </span>
        </a>

        {/* Zone 2: Concise Section Links */}
        <nav aria-label="Điều hướng chương" className="hidden items-center gap-6 md:flex">
          {NAV_ITEMS.map((item) => {
            const isActive = activeSection === item.id;
            return (
              <a
                key={item.id}
                href={`#${item.id}`}
                className={`border-b-2 py-5 text-xs font-medium tracking-wider uppercase transition-colors ${
                  isActive
                    ? 'border-[#14532D] text-[#14532D]'
                    : 'border-transparent text-[#57534E] hover:text-[#1C1917]'
                }`}
              >
                {item.label}
              </a>
            );
          })}
        </nav>

        {/* Zone 3: Single Primary Action */}
        <div className="flex shrink-0 items-center">
          <a
            href={DOCUMENT_META.pdfPath}
            download={DOCUMENT_META.pdfFilename}
            data-testid="download-pdf-primary"
            className="inline-flex items-center gap-2 bg-[#14532D] px-4 py-2 text-xs font-semibold tracking-wide text-white transition-colors hover:bg-[#166534] sm:text-sm"
          >
            <Download className="h-4 w-4" strokeWidth={1.85} />
            <span>Tải file PDF</span>
          </a>
        </div>
      </div>
    </header>
  );
}
