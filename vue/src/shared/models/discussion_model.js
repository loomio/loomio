import BaseModel        from '@/shared/record_store/base_model';
import AppConfig        from '@/shared/services/app_config';
import Session          from '@/shared/services/session';
import RangeSet         from '@/shared/services/range_set';
import HasDocuments     from '@/shared/mixins/has_documents';
import { isAfter } from 'date-fns';
import dateIsEqual from 'date-fns/isEqual';
import { map, compact, flatten, isEqual, isEmpty, filter, some, head, last, sortBy, isArray } from 'lodash-es';
import { I18n } from '@/i18n';
import Records from '@/shared/services/records';

export default class DiscussionModel extends BaseModel {
  static singular = 'discussion';
  static plural = 'discussions';
  static uniqueIndices = ['id', 'key'];
  static indices = ['groupId', 'authorId'];

  collabKeyParams(){
    return [this.groupId, this.discussionTemplateId, this.discussionTemplateKey]
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
      files: null,
      imageFiles: null,
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
      topicId: null,
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
    clone.title = I18n.global.t('templates.copy_of_title', {title: clone.title});
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
      return Records.pollTemplates.find(keyOrId);
    })
    );
  }

  audienceValues() {
    return {name: this.group().name};
  }

  relationships() {
    this.hasMany('polls', {sortBy: 'createdAt', sortDesc: true, find: {discardedAt: null}});
    this.belongsTo('group');
    this.belongsTo('topic');
    this.belongsTo('author', {from: 'users'});
    this.belongsTo('closer', {from: 'users'});
    this.belongsTo('translation');
    this.belongsTo('discussionTemplate');
  }

  discussion() { return this; }

  template() {
    return Records.discussionTemplates.find(this.discussionTemplateId);
  }

  bestNamedId() {
    return ((this.id && this) || (this.groupId && this.group()) || {namedId() {}}).namedId();
  }

  createdEvent() {
    if (this.topicId) {
      const res = Records.events.find({topicId: this.topicId, sequenceId: 0});
      if (!isEmpty(res)) { return res[0]; }
    }
    const res = Records.events.find({kind: 'new_discussion', eventableId: this.id});
    if (!isEmpty(res)) { return res[0]; }
  }

  reactions() {
    return Records.reactions.find({reactableId: this.id, reactableType: "Discussion"});
  }

  authorName() {
    return this.author().nameWithTitle(this.group());
  }

  isBlank() {
    return (this.description === '') || (this.description === null) || (this.description === '<p></p>');
  }

  update(attributes) {
    if (isArray(this.readRanges) && isArray(attributes.readRanges) && !isEqual(attributes.readRanges, this.readRanges)) {
      attributes.readRanges = RangeSet.reduce(this.readRanges.concat(attributes.readRanges));
    }
    this.baseUpdate(attributes);
    return this.readRanges = RangeSet.intersectRanges(this.readRanges, this.ranges);
  }

  fetchUsersNotifiedCount() {
    return Records.fetch({
      path: 'announcements/users_notified_count',
      params: {
        discussion_id: this.id
      }}).then(data => {
      return this.usersNotifiedCount = data.count;
    });
  }

};
