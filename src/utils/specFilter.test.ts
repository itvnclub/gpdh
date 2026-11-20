import assert from 'node:assert/strict';
import test from 'node:test';
import { computeSpecMetrics, filterSpecification, normalizeVietnamese } from './specFilter.ts';

test('normalizeVietnamese strips diacritics and converts đ/Đ cleanly', () => {
  assert.equal(normalizeVietnamese('Gia Phả Dòng Họ — Thủy Tổ'), 'gia pha dong ho — thuy to');
  assert.equal(normalizeVietnamese('Đời Thứ I · Đinh Nam'), 'doi thu i · dinh nam');
});

test('computeSpecMetrics matches exact verified repository schema counts', () => {
  const metrics = computeSpecMetrics();
  assert.equal(metrics.totalTables, 12);
  assert.equal(metrics.totalColumns, 10 + 3 + 22 + 29 + 3 + 3 + 9 + 4 + 5 + 4 + 3 + 4);
  assert.equal(metrics.totalRelationships, 7);
  assert.equal(metrics.totalAdminRoutes, 25);
  assert.equal(metrics.totalLandingBlocks, 7);
});

test('filterSpecification finds tblgiapha and related relationships by exact SQL name', () => {
  const res = filterSpecification('tblgiapha');
  assert.ok(res.tables.some((t) => t.name === 'tblgiapha'));
  assert.ok(res.relationships.length >= 5);
  assert.ok(res.totalMatches > 0);
});

test('filterSpecification matches Vietnamese queries without diacritics', () => {
  const res = filterSpecification('phan quyen nhanh');
  assert.ok(res.flows.some((f) => f.id === 'flow-rbac'));
});

test('filterSpecification finds ajax_dangky in Landing Page blocks', () => {
  const res = filterSpecification('ajax_dangky');
  assert.ok(res.landingBlocks.some((b) => b.anchor === '#dang-ky'));
  assert.equal(res.tables.length, 0);
});

test('filterSpecification returns zero matches for nonsense query', () => {
  const res = filterSpecification('zzzz_nonexistent_token_999');
  assert.equal(res.totalMatches, 0);
});
