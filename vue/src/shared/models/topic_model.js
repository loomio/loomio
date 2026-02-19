import BaseModel from '@/shared/record_store/base_model';
import RangeSet  from '@/shared/services/range_set';
import Records   from '@/shared/services/records';
import { head, last, isArray, isEqual, throttle } from 'lodash-es';

export default class TopicModel extends BaseModel {
  static singular = 'topic';
  static plural = 'topics';
  static uniqueIndices = ['id'];
  static indices = ['topicableId'];

  constructor(...args) {
    super(...args);
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
  }

  topicable() {
    if (this.topicableType === 'Discussion') {
      return Records.discussions.find(this.topicableId);
    } else if (this.topicableType === 'Poll') {
      return Records.polls.find(this.topicableId);
    }
  }

  createdEvent() {
    const topicable = this.topicable();
    return topicable && topicable.createdEvent ? topicable.createdEvent() : null;
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
    const t = this.topicable();
    return t && t.group ? t.group() : null;
  }

  membersInclude(user) {
    const t = this.topicable();
    return t && t.membersInclude ? t.membersInclude(user) : false;
  }

  adminsInclude(user) {
    const t = this.topicable();
    return t && t.adminsInclude ? t.adminsInclude(user) : false;
  }
};
