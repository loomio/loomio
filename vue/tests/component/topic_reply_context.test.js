import { beforeEach, describe, expect, it, vi } from 'vitest';
import Loki from 'lokijs';

const mocks = vi.hoisted(() => ({items: null}));
vi.mock('@/shared/services/records', () => ({default: {
  get topicItems() { return mocks.items; },
  comments: {find: id => ({id, isA: type => type === 'comment'})},
  discussions: {find: id => ({id, isA: type => type === 'discussion'})}
}}));
vi.mock('@/shared/services/session', () => ({default: {isSignedIn: () => true}}));
vi.mock('@/shared/services/app_config', () => ({default: {currentUserId: 1}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));
vi.mock('@/shared/record_store/restful_client', () => ({default: class {}}));

import TopicLoader from '@/shared/loaders/topic_loader';
import TopicItemRecordsInterface from '@/shared/interfaces/topic_item_records_interface';

describe('reply context at the nesting limit', () => {
  let loader;

  beforeEach(() => {
    mocks.items = new TopicItemRecordsInterface({db: new Loki('reply-context')});
    loader = new TopicLoader({id: 42, ranges: [[0, 10]], readRanges: [[0, 9]], lastReadAt: new Date()});
    item({id: 1, parentId: null, depth: 0, position: 0, positionKey: '00000', itemableType: 'Discussion'});
    item({id: 2, parentId: 1, depth: 1, position: 1, positionKey: '00000-00001'});
  });

  function item(attributes) {
    return mocks.items.create({
      topicId: 42, sequenceId: attributes.id, itemableId: attributes.id,
      itemableType: 'Comment', childCount: 10, replyParentId: null, ...attributes
    });
  }

  function cappedReply(id, position, replyParentId = null) {
    return item({id, parentId: 2, depth: 2, position,
      positionKey: `00000-00001-${String(position).padStart(5, '0')}`, replyParentId});
  }

  function load(id) {
    loader.addRule({local: {find: {id, topicId: 42}}});
    loader.updateCollection();
    return loader.collection[0].children[0].children;
  }

  it('shows the actual parent beside a capped reply while leaving unrelated comments hidden', () => {
    cappedReply(3, 1);
    cappedReply(4, 4);
    cappedReply(5, 5);
    cappedReply(10, 8, 4);

    const siblings = load(10);

    expect(siblings.map(obj => obj.topic_item.id)).toEqual([4, 10]);
    expect(siblings.every(obj => obj.children.length === 0)).toBe(true);
    expect(siblings.every(obj => obj.topic_item.depth === 2)).toBe(true);
    expect(siblings.map(obj => obj.missingEarlier)).toEqual([true, true]);
    expect(siblings[1].missingAfter).toBe(true);
    expect(siblings.map(obj => obj.isUnread)).toEqual([false, true]);
  });

  it('includes the complete actual parent chain even when it exceeds the display depth', () => {
    cappedReply(3, 1);
    cappedReply(4, 2, 3);
    cappedReply(5, 3, 4);
    cappedReply(6, 4, 5);
    cappedReply(10, 5, 6);

    expect(load(10).map(obj => obj.topic_item.id)).toEqual([3, 4, 5, 6, 10]);
    expect(loader.records.map(item => item.id)).toEqual([1, 2, 3, 4, 5, 6, 10]);
  });

  it('keeps ordinary replies nested under their display parent', () => {
    cappedReply(10, 1);

    expect(load(10).map(obj => obj.topic_item.id)).toEqual([10]);
    expect(loader.records.map(item => item.id)).toEqual([1, 2, 10]);
  });

  it('shows shared context only once across loading rules', () => {
    cappedReply(4, 1);
    cappedReply(9, 2, 4);
    cappedReply(10, 3, 4);
    loader.addRule({local: {find: {id: 9}}});

    expect(load(10).map(obj => obj.topic_item.id)).toEqual([4, 9, 10]);
  });
});
