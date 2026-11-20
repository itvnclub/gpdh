import {
  ADMIN_FEATURE_GROUPS,
  ADMIN_ROUTES,
  BUSINESS_FLOWS,
  DATABASE_RELATIONSHIPS,
  DATABASE_TABLES,
  FRONTEND_IMPLEMENTED_FEATURES,
  FRONTEND_ROUTES,
  LANDING_BLOCKS,
  LANDING_FEATURE_SLIDES,
  LANDING_PRICING_TIERS,
} from '../data/specData.ts';

export interface SpecMetrics {
  totalTables: number;
  totalColumns: number;
  totalRelationships: number;
  totalAdminRoutes: number;
  totalLandingBlocks: number;
}

export interface FilteredSpecResult {
  query: string;
  normalizedQuery: string;
  tables: typeof DATABASE_TABLES;
  relationships: typeof DATABASE_RELATIONSHIPS;
  frontendRoutes: typeof FRONTEND_ROUTES;
  frontendFeatures: typeof FRONTEND_IMPLEMENTED_FEATURES;
  adminRoutes: typeof ADMIN_ROUTES;
  adminFeatures: typeof ADMIN_FEATURE_GROUPS;
  flows: typeof BUSINESS_FLOWS;
  landingBlocks: typeof LANDING_BLOCKS;
  landingSlides: typeof LANDING_FEATURE_SLIDES;
  pricingTiers: typeof LANDING_PRICING_TIERS;
  totalMatches: number;
}

/**
 * Strips Vietnamese diacritics and normalizes text for accent-insensitive search.
 */
export function normalizeVietnamese(input: string): string {
  return input
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D')
    .toLowerCase()
    .trim();
}

export function matchesQuery(fields: (string | undefined)[], normalizedQuery: string): boolean {
  if (!normalizedQuery) return true;
  const tokens = normalizedQuery.split(/\s+/).filter(Boolean);
  if (tokens.length === 0) return true;
  const combined = normalizeVietnamese(fields.filter(Boolean).join(' '));
  return tokens.every((token) => combined.includes(token));
}

export function computeSpecMetrics(): SpecMetrics {
  const totalColumns = DATABASE_TABLES.reduce((sum, table) => sum + table.columns.length, 0);
  return {
    totalTables: DATABASE_TABLES.length,
    totalColumns,
    totalRelationships: DATABASE_RELATIONSHIPS.length,
    totalAdminRoutes: ADMIN_ROUTES.length,
    totalLandingBlocks: LANDING_BLOCKS.length,
  };
}

export function filterSpecification(rawQuery: string): FilteredSpecResult {
  const normalizedQuery = normalizeVietnamese(rawQuery);

  const tables = DATABASE_TABLES.filter((table) =>
    matchesQuery(
      [
        table.name,
        table.purpose,
        table.note,
        ...table.columns.flatMap((col) => [col.name, col.type, col.constraint, col.description]),
      ],
      normalizedQuery,
    ),
  );

  const relationships = DATABASE_RELATIONSHIPS.filter((rel) =>
    matchesQuery([rel.from, rel.to, rel.cardinality, rel.mechanism, rel.description], normalizedQuery),
  );

  const frontendRoutes = FRONTEND_ROUTES.filter((route) =>
    matchesQuery([route.param, route.target, route.status, route.desc], normalizedQuery),
  );

  const frontendFeatures = FRONTEND_IMPLEMENTED_FEATURES.filter((group) =>
    matchesQuery(
      [group.title, group.files, ...group.items.flatMap((item) => [item.name, item.detail])],
      normalizedQuery,
    ),
  );

  const adminRoutes = ADMIN_ROUTES.filter((route) =>
    matchesQuery([route.pattern, route.target, route.module, route.group], normalizedQuery),
  );

  const adminFeatures = ADMIN_FEATURE_GROUPS.filter((group) =>
    matchesQuery(
      [group.title, group.files, ...group.items.flatMap((item) => [item.name, item.detail])],
      normalizedQuery,
    ),
  );

  const flows = BUSINESS_FLOWS.filter((flow) =>
    matchesQuery(
      [
        flow.code,
        flow.title,
        flow.summary,
        ...flow.blocks.flatMap((block) => [block.heading, block.codeNote, ...block.bullets]),
      ],
      normalizedQuery,
    ),
  );

  const landingBlocks = LANDING_BLOCKS.filter((block) =>
    matchesQuery([block.order, block.anchor, block.title, block.summary, ...block.details], normalizedQuery),
  );

  const landingSlides = LANDING_FEATURE_SLIDES.filter((slide) =>
    matchesQuery([slide.title, slide.image, slide.desc], normalizedQuery),
  );

  const pricingTiers = LANDING_PRICING_TIERS.filter((tier) =>
    matchesQuery([tier.name, tier.initPrice, tier.annualPrice, tier.scale, tier.highlight], normalizedQuery),
  );

  const totalMatches =
    tables.length +
    relationships.length +
    frontendRoutes.length +
    frontendFeatures.length +
    adminRoutes.length +
    adminFeatures.length +
    flows.length +
    landingBlocks.length +
    landingSlides.length +
    pricingTiers.length;

  return {
    query: rawQuery,
    normalizedQuery,
    tables,
    relationships,
    frontendRoutes,
    frontendFeatures,
    adminRoutes,
    adminFeatures,
    flows,
    landingBlocks,
    landingSlides,
    pricingTiers,
    totalMatches,
  };
}
