import { describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({fetch: vi.fn()}));

vi.mock('@/shared/services/records', () => ({
  default: {attachments: {fetch: mocks.fetch}}
}));

import RecordLoader from '@/shared/services/record_loader';

describe('RecordLoader.fetchRecords', () => {
  it('clears a network error once a later request succeeds', async () => {
    const loader = new RecordLoader({collection: 'attachments'});

    mocks.fetch.mockRejectedValueOnce(new TypeError('Failed to fetch'));
    expect(await loader.fetchRecords()).toBeUndefined();
    expect(loader.err).toBeInstanceOf(TypeError);

    mocks.fetch.mockResolvedValueOnce({meta: {total: 1}, attachments: [{id: 1}]});
    expect(await loader.fetchRecords()).toEqual({meta: {total: 1}, attachments: [{id: 1}]});
    expect(loader.err).toBeNull();
    expect(loader.status).toBeNull();
  });
});
