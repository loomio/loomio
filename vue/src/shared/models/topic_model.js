import BaseModel  from '@/shared/record_store/base_model';
import RangeSet   from '@/shared/services/range_set';
import Records    from '@/shared/services/records';
import AppConfig  from '@/shared/services/app_config';
import { head, last, isArray, isEqual, throttle } from 'lodash-es';

export default class TopicModel extends BaseModel {
  static singular = 'topic';
  static plural = 'topics';
  static uniqueIndices = ['id'];
  static indices = ['topicableId'];

  constructor(...args) {
    super(...args);
    this.savePin = this.savePin.bind(this);
    this.saveUnpin = this.saveUnpin.bind(this);
    this.close = this.close.bind(this);
    this.reopen = this.reopen.bind(this);
    this.discard = this.discard.bind(this);
    this.saveVolume = this.saveVolume.bind(this);
    this.updateReadRanges = throttle(function() {
      return Records.topics.remote.patchMember(this.id, 'mark_as_read', {ranges: RangeSet.serialize(this.readRanges)});
    }, 2000);
  }

  defaultValues() {
    return {
      itemsCount: 0,
      ranges: [],
      readRanges: [],
      maxDepth: 2,
      newestFirst: false,
      lastActivityAt: null,
      topicableId: null,
      topicableType: null,
      closedAt: null,
      closerId: null,
      pinnedAt: null,
      // reader state
      readerId: null,
      readerVolume: null,
      lastReadAt: null,
      dismissedAt: null,
      readerInviterId: null,
      readerGuest: false,
      readerAdmin: false
    };
  }

  relationships() {
    this.belongsToPolymorphic('topicable');
    this.belongsTo('group');
  }

  discussion() {
    return this.topicableType === 'Discussion' ? Records.discussions.find(this.topicableId) : null
  }

  get title() { return this.topicable().title; }
  get key() { return this.topicable().key; }
  get tags() { return this.topicable().tags || []; }
  author() { return this.topicable().author(); }

  repliesCount() {
    return Math.max(0, this.itemsCount - 1);
  }

  hasUnreadActivity() {
    return this.isUnread() && (this.unreadItemsCount() > 0);
  }

  isDismissed() {
    return (this.readerId != null) && (this.dismissedAt != null) &&
      (this.dismissedAt >= this.lastActivityAt);
  }

  createdEvent() {
    return this.topicable().createdEvent();
  }

  hasRead(id) {
    return RangeSet.includesValue(this.readRanges, id);
  }

  markAsRead(id) {
    if (this.hasRead(id)) { return; }
    this.readRanges.push([id, id]);
    this.readRanges = RangeSet.reduce(this.readRanges);
    return this.updateReadRanges();
  }

  update(attributes) {
    if (isArray(this.readRanges) && isArray(attributes.readRanges) && !isEqual(attributes.readRanges, this.readRanges)) {
      attributes.readRanges = RangeSet.reduce(this.readRanges.concat(attributes.readRanges));
    }
    this.baseUpdate(attributes);
    return this.readRanges = RangeSet.intersectRanges(this.readRanges, this.ranges);
  }

  firstSequenceId() {
    return (head(this.ranges) || [])[0];
  }

  lastSequenceId() {
    return (last(this.ranges) || [])[1];
  }

  unreadRanges() {
    return RangeSet.subtractRanges(this.ranges, this.readRanges);
  }

  readItemsCount() {
    return RangeSet.length(this.readRanges);
  }

  unreadItemsCount() {
    return this.itemsCount - this.readItemsCount();
  }

  isUnread() {
    return (this.lastReadAt == null) || (this.unreadItemsCount() > 0);
  }

  volume() {
    return this.readerVolume;
  }

  group() {
    return this.topicable().group();
  }

  membersInclude(user) {
    return this.topicable().membersInclude(user);
  }

  adminsInclude(user) {
    return this.topicable().adminsInclude(user);
  }

  membership() {
    return Records.memberships.find({userId: AppConfig.currentUserId, groupId: this.groupId})[0];
  }

  savePin() {
    this.processing = true;
    return Records.topics.remote.patchMember(this.id, 'pin').finally(() => { this.processing = false; });
  }

  saveUnpin() {
    this.processing = true;
    return Records.topics.remote.patchMember(this.id, 'unpin').finally(() => { this.processing = false; });
  }

  close() {
    this.processing = true;
    return Records.topics.remote.patchMember(this.id, 'close').finally(() => { this.processing = false; });
  }

  reopen() {
    this.processing = true;
    return Records.topics.remote.patchMember(this.id, 'reopen').finally(() => { this.processing = false; });
  }

  dismiss() {
    this.update({dismissedAt: new Date});
    this.processing = true;
    return Records.topics.remote.patchMember(this.id, 'dismiss').finally(() => { this.processing = false; });
  }

  recall() {
    this.update({dismissedAt: null});
    this.processing = true;
    return Records.topics.remote.patchMember(this.id, 'recall').finally(() => { this.processing = false; });
  }

  saveVolume(volume, applyToAll) {
    if (applyToAll == null) { applyToAll = false; }
    this.processing = true;
    if (applyToAll) {
      return this.membership().saveVolume(volume).finally(() => { this.processing = false; });
    } else {
      if (volume != null) { this.readerVolume = volume; }
      return Records.topics.remote.patchMember(this.id, 'set_volume', { volume: this.readerVolume }).finally(() => {
        this.processing = false;
      });
    }
  }

  markAsSeen() {
    if (this.lastReadAt) { return; }
    Records.topics.remote.patchMember(this.id, 'mark_as_seen');
    return this.update({lastReadAt: new Date});
  }

  isMuted() {
    return this.volume() === 'mute';
  }

  moveComments(forkedEventIds) {
    this.processing = true;
    return Records.topics.remote.patchMember(this.id, 'move_comments', { forked_event_ids: forkedEventIds }).finally(() => { this.processing = false; });
  }

  discard() {
    this.processing = true;
    return Records.topics.remote.discard(this.id).finally(() => { this.processing = false; });
  }
};
