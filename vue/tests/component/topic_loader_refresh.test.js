import { describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({fetch: vi.fn()}));
vi.mock('@/shared/services/records', () => ({default: {topicItems: {fetch: mocks.fetch}}}));
vi.mock('@/shared/services/app_config', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
import TopicLoader from '@/shared/loaders/topic_loader';

describe('edited discussion context', () => {
  function contextLoader(announcedAt) {
    const discussion = {contextAnnouncedAt: new Date(announcedAt), updatedAt: new Date('2026-11-08T12:00:00Z')};
    const topic = {id: 1, topicableType: 'Discussion', ranges: [[0, 2]], readRanges: [[0, 1]],
      lastReadAt: new Date('2026-11-08T10:00:00Z'), topicable: () => discussion};
    return {loader: new TopicLoader(topic), topic, discussion};
  }

  it('shows context edited since the previous read in full from the first render', () => {
    const {loader} = contextLoader('2026-11-08T11:00:00Z');
    expect(loader.bodyPreview(0)).toMatchObject({readBeforeVisit: true, revealed: false, announcedSinceRead: true});
    expect(loader.bodyPreview(1)).toMatchObject({readBeforeVisit: true, revealed: false});
    expect(loader.revealedBodies.size).toBe(0);
  });

  it('keeps context read after the edit eligible for a preview', () => {
    const {loader} = contextLoader('2026-11-08T09:00:00Z');
    expect(loader.bodyPreview(0)).toMatchObject({readBeforeVisit: true, revealed: false, announcedSinceRead: false});
  });

  it('reveals an edit arriving during the visit and keeps it revealed as read state changes', () => {
    const {loader, topic, discussion} = contextLoader('2026-11-08T09:00:00Z');
    const preview = loader.bodyPreview(0);
    expect(preview.revealed).toBe(false);
    discussion.contextAnnouncedAt = new Date('2026-11-08T11:00:00Z');
    expect(loader.bodyPreview(0).announcedSinceRead).toBe(true);
    loader.bodyPreview(0).reveal();
    topic.lastReadAt = new Date('2026-11-08T12:00:00Z');
    expect(loader.bodyPreview(0).revealed).toBe(true);
  });
});

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
