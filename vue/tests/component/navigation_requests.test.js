import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

vi.mock('@sentry/vue', () => ({metrics: {count: vi.fn()}}));
import RestfulClient from '@/shared/record_store/restful_client';

function deferred() {
  let resolve;
  const promise = new Promise(yes => { resolve = yes; });
  return {promise, resolve};
}

describe('navigation reads', () => {
  beforeEach(() => {
    vi.stubGlobal('fetch', vi.fn());
    vi.spyOn(console, 'warn').mockImplementation(() => {});
  });
  afterEach(() => { vi.unstubAllGlobals(); vi.restoreAllMocks(); });

  it('shares concurrent identical reads and refreshes again after completion', async () => {
    const response = deferred();
    fetch.mockReturnValueOnce(response.promise);
    const client = new RestfulClient('topics');
    const first = client.get('', {limit: 30, offset: 0});
    const second = client.get('', {offset: 0, limit: 30});
    expect(first).toBe(second);
    expect(fetch).toHaveBeenCalledTimes(1);
    response.resolve({ok: true, json: async () => ({topics: []})});
    await first;
    fetch.mockResolvedValueOnce({ok: true, json: async () => ({topics: []})});
    await client.get('', {limit: 30, offset: 0});
    expect(fetch).toHaveBeenCalledTimes(2);
  });

  it('retries failed reads and preserves HTTP authorization errors', async () => {
    fetch.mockResolvedValueOnce({ok: false, status: 403, json: async () => ({error: 'Forbidden'})});
    const client = new RestfulClient('topics');
    await expect(client.get('', {limit: 30})).rejects.toMatchObject({status: 403});
    fetch.mockResolvedValueOnce({ok: true, json: async () => ({topics: []})});
    await client.get('', {limit: 30});
    expect(fetch).toHaveBeenCalledTimes(2);
  });
});
