import { describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({fetch: vi.fn()}));

vi.mock('@/shared/services/records', () => ({
  default: {attachments: {fetch: mocks.fetch}}
}));

import RecordLoader from '@/shared/services/record_loader';

describe('RecordLoader.fetchRecords', () => {
  it('advances and resets limit/offset pagination without legacy parameters', async () => {
    mocks.fetch.mockResolvedValue({meta: {total: 31}});
    const loader = new RecordLoader({collection: 'attachments', params: {limit: 30}});
    await loader.fetchRecords();
    expect(loader.params).toEqual({limit: 30, offset: 30, order: 'id'});
    expect(loader.exhausted).toBe(false);
    await loader.fetchRecords();
    expect(loader.exhausted).toBe(true);
    loader.reset();
    expect(loader.params.offset).toBe(0);
  });

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
