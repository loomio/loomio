import BaseModel        from '@/shared/record_store/base_model';
import AppConfig        from '@/shared/services/app_config';
import Session          from '@/shared/services/session';
import RangeSet         from '@/shared/services/range_set';
import HasDocuments     from '@/shared/mixins/has_documents';
import HasTranslations  from '@/shared/mixins/has_translations';
import { isAfter } from 'date-fns';
import dateIsEqual from 'date-fns/isEqual';
import { map, compact, flatten, isEqual, isEmpty, filter, some, head, last, sortBy, find, min, max, isArray, throttle, without } from 'lodash';
import I18n from '@/i18n';

export default class DiscussionModel extends BaseModel {
  static singular = 'discussion';
  static plural = 'discussions';
  static uniqueIndices = ['id', 'key'];
  static indices = ['groupId', 'authorId'];
  constructor(...args) {
    super(...args);
    this.privateDefaultValue = this.privateDefaultValue.bind(this);
    this.saveVolume = this.saveVolume.bind(this);
    this.move = this.move.bind(this);
    this.savePin = this.savePin.bind(this);
    this.saveUnpin = this.saveUnpin.bind(this);
    this.close = this.close.bind(this);
    this.reopen = this.reopen.bind(this);
    this.moveComments = this.moveComments.bind(this);
    this.discussion = this.discussion.bind(this);
    this.updateReadRanges = throttle(function() {
      return this.remote.patchMember(this.keyOrId(), 'mark_as_read', {ranges: RangeSet.serialize(this.readRanges)});
    } , 2000);
  }

  afterConstruction() {
    if (this.isNew()) { this.private = this.privateDefaultValue(); }
    HasDocuments.apply(this, {showTitle: true});
    return HasTranslations.apply(this);
  }

  defaultValues() {
    return {
      id: null,
      key: null,
      private: true,
      lastItemAt: null,
      title: '',
      description: '',
      descriptionFormat: 'html',
      forkedEventIds: [],
      ranges: [],
      readRanges: [],
      newestFirst: false,
      files: [],
      imageFiles: [],
      attachments: [],
      linkPreviews: [],
      tags: [],
      recipientMessage: null,
      recipientAudience: null,
      recipientUserIds: [],
      recipientChatbotIds: [],
      recipientEmails: [],
      notifyRecipients: true,
      groupId: null,
      usersNotifiedCount: null,
      discussionReaderUserId: null,
      pinnedAt: null,
      poll_template_keys_or_ids: []
    };
  }

  buildCopy() {
    const clone = this.clone();
    clone.id = null;
    clone.key = null;
    clone.title = I18n.t('templates.copy_of_title', {title: clone.title});
    clone.authorId = Session.user().id;
    clone.pinnedAt = null;
    clone.forkedEventIds = [];
    clone.groupId = null;
    clone.closedAt = null;
    clone.closerId = null;
    clone.createdAt = null;
    clone.updatedAt = null;
    return clone;
  }

  pollTemplates() {
    return compact(this.pollTemplateKeysOrIds.map(keyOrId => {
      return this.recordStore.pollTemplates.find(keyOrId);
    })
    );
  }

  audienceValues() {
    return {name: this.group().name};
  }

  privateDefaultValue() {
    return this.group().discussionPrivacyOptions !== 'public_only';
  }

  relationships() {
    this.hasMany('polls', {sortBy: 'createdAt', sortDesc: true, find: {discardedAt: null}});
    this.belongsTo('group');
    this.belongsTo('author', {from: 'users'});
    this.belongsTo('closer', {from: 'users'});
    return this.hasMany('discussionReaders');
  }

  discussion() { return this; }

  template() {
    return this.recordStore.discussionTemplates.find(this.discussionTemplateId);
  }

  tags() {
    return this.recordStore.tags.collection.chain().find({id: {$in: this.tagIds}}).simplesort('priority').data();
  }

  members() {
    return this.recordStore.users.find(this.group().memberIds().concat(map(this.discussionReaders(), 'userId')));
  }

  membersInclude(user) {
    return (this.inviterId && !this.revokedAt && (Session.user().id === user.id)) ||
    this.group().membersInclude(user);
  }

  adminsInclude(user) {
    return (this.authorId === user.id) ||
    (this.inviterId && this.admin && !this.revokedAt && (AppConfig.currentUserId === user.id)) ||
    this.group().adminsInclude(user);
  }

  // known current participants for quick mentioning
  participantIds() {
    return compact(flatten(
      map(this.recordStore.comments.find({discussionId: this.id}), 'authorId'),
      map(this.recordStore.polls.find({discussionId: this.id}), p => p.participantIds()),
      [this.authorId]
    )
    );
  }

  bestNamedId() {
    return ((this.id && this) || (this.groupId && this.group()) || {namedId() {}}).namedId();
  }

  createdEvent() {
    const res = this.recordStore.events.find({kind: 'new_discussion', eventableId: this.id});
    if (!isEmpty(res)) { return res[0]; }
  }

  forkedEvent() {
    const res = this.recordStore.events.find({kind: 'discussion_forked', eventableId: this.id});
    if (!isEmpty(res)) { return res[0]; }
  }

  reactions() {
    return this.recordStore.reactions.find({reactableId: this.id, reactableType: "Discussion"});
  }

  translationOptions() {
    return {
      title: this.title,
      groupName: this.groupName()
    };
  }

  authorName() {
    return this.author().nameWithTitle(this.group());
  }

  isBlank() {
    return (this.description === '') || (this.description === null) || (this.description === '<p></p>');
  }

  groupName() {
    return (this.group() || {}).name;
  }

  activePolls() {
    return filter(this.polls(), poll => poll.isVotable());
  }

  hasActivePoll() {
    return some(this.activePolls());
  }

  hasDecision() {
    return this.hasActivePoll();
  }

  closedPolls() {
    return filter(this.polls(), poll => !poll.isVotable());
  }

  activePoll() {
    return head(this.activePolls());
  }

  isUnread() {
    return !this.isDismissed() && ((this.lastReadAt == null) || (this.unreadItemsCount() > 0));
  }

  isDismissed() {
    return (this.discussionReaderId != null) && (this.dismissedAt != null) &&
    (dateIsEqual(this.dismissedAt, this.lastActivityAt) || isAfter(this.dismissedAt, this.lastActivityAt));
  }

  hasUnreadActivity() {
    return this.isUnread() && (this.unreadItemsCount() > 0);
  }

  membership() {
    return this.recordStore.memberships.find({userId: AppConfig.currentUserId, groupId: this.groupId})[0];
  }

  volume() { return this.discussionReaderVolume; }

  saveVolume(volume, applyToAll) {
    if (applyToAll == null) { applyToAll = false; }
    this.processing = true;
    if (applyToAll) {
      return this.membership().saveVolume(volume).finally(() => { return this.processing = false; });
    } else {
      if (volume != null) { this.discussionReaderVolume = volume; }
      return this.remote.patchMember(this.keyOrId(), 'set_volume', { volume: this.discussionReaderVolume }).finally(() => {
        return this.processing = false;
      });
    }
  }

  isMuted() {
    return this.volume() === 'mute';
  }

  markAsSeen() {
    if (this.lastReadAt) { return; }
    this.remote.patchMember(this.keyOrId(), 'mark_as_seen');
    return this.update({lastReadAt: new Date});
  }

  markAsRead(id) {
    if (this.hasRead(id)) { return; }
    this.readRanges.push([id,id]);
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

  hasRead(id) {
    return RangeSet.includesValue(this.readRanges, id);
  }

  unreadItemsCount() {
    return this.itemsCount - this.readItemsCount();
  }

  readItemsCount() {
    return RangeSet.length(this.readRanges);
  }

  firstSequenceId() {
    return (head(this.ranges) || [])[0];
  }

  lastSequenceId() {
    return (last(this.ranges) || [])[1];
  }

  lastReadSequenceId() {
    return (last(this.readRanges) || [])[1];
  }

  firstUnreadSequenceId() {
    return (this.unreadRanges()[0] || [])[0];
  }

  readSequenceIds() {
    return RangeSet.rangesToArray(this.readRanges);
  }

  unreadRanges() {
    return RangeSet.subtractRanges(this.ranges, this.readRanges);
  }

  unreadSequenceIds() {
    return RangeSet.rangesToArray(this.unreadRanges());
  }

  dismiss() {
    this.update({dismissedAt: new Date});
    this.processing = true;
    return this.remote.patchMember(this.keyOrId(), 'dismiss').finally(() => { return this.processing = false; });
  }

  recall() {
    this.update({dismissedAt: null});
    this.processing = true;
    return this.remote.patchMember(this.keyOrId(), 'recall').finally(() => { return this.processing = false; });
  }

  move() {
    this.processing = true;
    return this.remote.patchMember(this.keyOrId(), 'move', { group_id: this.groupId }).finally(() => { return this.processing = false; });
  }

  savePin() {
    this.processing = true;
    return this.remote.patchMember(this.keyOrId(), 'pin').finally(() => { return this.processing = false; });
  }

  saveUnpin() {
    this.processing = true;
    return this.remote.patchMember(this.keyOrId(), 'unpin').finally(() => { return this.processing = false; });
  }

  close() {
    this.processing = true;
    return this.remote.patchMember(this.keyOrId(), 'close').finally(() => { return this.processing = false; });
  }

  reopen() {
    this.processing = true;
    return this.remote.patchMember(this.keyOrId(), 'reopen').finally(() => { return this.processing = false; });
  }

  moveComments() {
    this.processing = true;
    return this.remote.patchMember(this.keyOrId(), 'move_comments', { forked_event_ids: this.forkedEventIds }).finally(() => { return this.processing = false; });
  }

  fetchUsersNotifiedCount() {
    return this.recordStore.fetch({
      path: 'announcements/users_notified_count',
      params: {
        discussion_id: this.id
      }}).then(data => {
      return this.usersNotifiedCount = data.count;
    });
  }

  forkedEvents() {
    return sortBy(this.recordStore.events.find(this.forkedEventIds), 'sequenceId');
  }

  forkTarget() {
    if (some(this.forkedEvents())) { return this.forkedEvents()[0].model(); }
  }
};
