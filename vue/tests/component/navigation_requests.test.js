import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

vi.mock('@sentry/vue', () => ({metrics: {count: vi.fn()}}));
import RestfulClient from '@/shared/record_store/restful_client';
import { loading } from '@/shared/services/loading_state';

function deferred() {
  let resolve, reject;
  const promise = new Promise((yes, no) => { resolve = yes; reject = no; });
  return {promise, resolve, reject};
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
    expect(loading.value).toBe(true);
    response.resolve({ok: true, json: async () => ({topics: []})});
    await first;
    expect(loading.value).toBe(false);
    fetch.mockResolvedValueOnce({ok: true, json: async () => ({topics: []})});
    await client.get('', {limit: 30, offset: 0});
    expect(fetch).toHaveBeenCalledTimes(2);
  });

  it('keeps loading through response import and another request failing', async () => {
    const imported = deferred();
    const failed = deferred();
    fetch.mockResolvedValueOnce({ok: true, json: () => imported.promise});
    fetch.mockReturnValueOnce(failed.promise);
    const client = new RestfulClient('topics');
    const first = client.get('', {limit: 30});
    const second = client.get('', {limit: 25});
    failed.reject(new TypeError('offline'));
    await expect(second).rejects.toMatchObject({networkError: true});
    expect(loading.value).toBe(true);
    imported.resolve({topics: []});
    await first;
    expect(loading.value).toBe(false);
  });

  it('retries failed reads and preserves HTTP authorization errors', async () => {
    fetch.mockResolvedValueOnce({ok: false, status: 403, json: async () => ({error: 'Forbidden'})});
    const client = new RestfulClient('topics');
    await expect(client.get('', {limit: 30})).rejects.toMatchObject({status: 403});
    expect(loading.value).toBe(false);
    fetch.mockResolvedValueOnce({ok: true, json: async () => ({topics: []})});
    await client.get('', {limit: 30});
    expect(fetch).toHaveBeenCalledTimes(2);
  });
});
