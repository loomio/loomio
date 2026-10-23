import { describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({fetch: vi.fn()}));
vi.mock('@/shared/services/records', () => ({default: {topicItems: {fetch: mocks.fetch}}}));
vi.mock('@/shared/services/app_config', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
import TopicLoader from '@/shared/loaders/topic_loader';

describe('thread refresh windows', () => {
  it('retries a failed latest window while keeping successful windows fetched', async () => {
    const topic = {id: 1, ranges: [[0, 40]], readRanges: []};
    const loader = new TopicLoader(topic);
    loader.addLoadOldestRule();
    loader.addLoadNewestRule();
    mocks.fetch.mockResolvedValueOnce({}).mockRejectedValueOnce(new TypeError('offline'));
    await expect(loader.fetch()).rejects.toThrow('offline');
    mocks.fetch.mockClear().mockResolvedValue({});
    await loader.fetch();
    expect(mocks.fetch).toHaveBeenCalledOnce();
    expect(mocks.fetch).toHaveBeenCalledWith({params: expect.objectContaining({sequence_id_lte: 40})});
    await loader.fetch();
    expect(mocks.fetch).toHaveBeenCalledOnce();
  });
});
