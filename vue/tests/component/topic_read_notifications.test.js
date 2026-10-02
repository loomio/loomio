import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

const mocks = vi.hoisted(() => ({
  patchMember: vi.fn(),
  isSignedIn: vi.fn(),
  notifications: null
}));

vi.mock('@/shared/services/records', () => ({default: {
  groups: {nullModel: () => ({discussionPrivacyOptions: 'private_only'})},
  topics: {remote: {patchMember: mocks.patchMember}},
  get notifications() { return mocks.notifications; }
}}));
vi.mock('@/shared/record_store/restful_client', () => ({default: class {}}));
vi.mock('@/shared/services/app_config', () => ({default: {}}));
vi.mock('@/shared/services/session', () => ({default: {isSignedIn: mocks.isSignedIn}}));
vi.mock('@/shared/services/event_bus', () => ({default: {$emit: vi.fn()}}));

import TopicModel from '@/shared/models/topic_model';
import TopicLoader from '@/shared/loaders/topic_loader';
import NotificationRecordsInterface from '@/shared/interfaces/notification_records_interface';
import Loki from 'lokijs';

describe('notifications for viewed topic items', () => {
  let topic;
  let loader;
  const item = {sequenceId: 1, positionKey: '00000-00001'};

  beforeEach(() => {
    vi.useFakeTimers();
    vi.clearAllMocks();
    mocks.isSignedIn.mockReturnValue(true);
    mocks.notifications = new NotificationRecordsInterface({db: new Loki('notifications')});
    topic = new TopicModel({id: 42, ranges: [[0, 2]], readRanges: [[0, 1]]});
    loader = new TopicLoader(topic);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('updates notification read state when an already-read comment becomes visible', () => {
    const notification = mocks.notifications.create({id: 1, topicId: 42, sequenceId: 1, viewed: false});
    loader.setVisible(true, item);
    vi.advanceTimersByTime(500);

    expect(mocks.patchMember).toHaveBeenCalledWith(42, 'mark_as_read', {ranges: '1-1'});
    expect(topic.readRanges).toEqual([[0, 1]]);

    expect(notification.viewed).toBe(true);
    loader.setVisible(false, item);
    vi.advanceTimersByTime(2000);
    loader.setVisible(true, item);
    vi.advanceTimersByTime(500);
    expect(mocks.patchMember).toHaveBeenCalledTimes(1);

    // Revisit the comment after another reaction arrives in the same session.
    mocks.notifications.create({id: 2, topicId: 42, sequenceId: 1, viewed: false});
    loader.setVisible(false, item);
    vi.advanceTimersByTime(2000);
    loader.setVisible(true, item);
    vi.advanceTimersByTime(500);

    expect(mocks.patchMember).toHaveBeenCalledTimes(2);
  });

  it('skips already-read items with only unrelated or viewed notifications', () => {
    mocks.notifications.create({id: 1, topicId: 43, sequenceId: 1, viewed: false});
    mocks.notifications.create({id: 2, topicId: 42, sequenceId: 2, viewed: false});
    mocks.notifications.create({id: 3, topicId: 42, sequenceId: 1, viewed: true});
    loader.setVisible(true, item);
    vi.advanceTimersByTime(500);

    expect(mocks.patchMember).not.toHaveBeenCalled();
  });

  it('reduces the bell unread count for all matching notifications and leaves unrelated ones unread', () => {
    const commentNotifications = [1, 2].map(id => mocks.notifications.create({
      id, topicId: 42, sequenceId: 1, viewed: false
    }));
    const otherItem = mocks.notifications.create({id: 3, topicId: 42, sequenceId: 0, viewed: false});
    const otherTopic = mocks.notifications.create({id: 4, topicId: 43, sequenceId: 1, viewed: false});
    expect(mocks.notifications.find({viewed: {$ne: true}})).toHaveLength(4);

    loader.setVisible(true, item);
    vi.advanceTimersByTime(500);

    expect(commentNotifications.every(notification => notification.viewed)).toBe(true);
    expect(mocks.notifications.find({viewed: {$ne: true}})).toEqual([otherItem, otherTopic]);
    expect(mocks.patchMember).toHaveBeenCalledWith(42, 'mark_as_read', {ranges: '1-1'});
  });

  it('still adds newly-read items to the read ranges', () => {
    loader.setVisible(true, {...item, sequenceId: 2});
    vi.advanceTimersByTime(500);

    expect(topic.readRanges).toEqual([[0, 2]]);
    expect(mocks.patchMember).toHaveBeenCalledWith(42, 'mark_as_read', {ranges: '2-2'});
  });

  it('keeps every viewed item in a throttled batch without resending historical ranges', () => {
    topic.markAsRead(2);
    mocks.notifications.create({id: 1, topicId: 42, sequenceId: 0, viewed: false});
    mocks.notifications.create({id: 2, topicId: 42, sequenceId: 1, viewed: false});
    topic.markAsRead(0);
    topic.markAsRead(1);

    expect(mocks.patchMember).toHaveBeenCalledTimes(1);
    expect(mocks.patchMember).toHaveBeenNthCalledWith(1, 42, 'mark_as_read', {ranges: '2-2'});
    vi.advanceTimersByTime(2000);

    expect(mocks.patchMember).toHaveBeenNthCalledWith(2, 42, 'mark_as_read', {ranges: '0-1'});
    expect(topic.readRanges).toEqual([[0, 2]]);
  });

  it('does not mark a comment read if it leaves view before the reading delay', () => {
    loader.setVisible(true, item);
    vi.advanceTimersByTime(250);
    loader.setVisible(false, item);
    vi.advanceTimersByTime(500);

    expect(mocks.patchMember).not.toHaveBeenCalled();
  });

  it('does not send read updates for signed-out readers', () => {
    mocks.isSignedIn.mockReturnValue(false);
    loader.setVisible(true, item);
    vi.advanceTimersByTime(500);

    expect(mocks.patchMember).not.toHaveBeenCalled();
  });
});
