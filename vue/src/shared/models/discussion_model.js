import BaseModel        from '@/shared/record_store/base_model';
import AppConfig        from '@/shared/services/app_config';
import Session          from '@/shared/services/session';
import RangeSet         from '@/shared/services/range_set';
import { isAfter } from 'date-fns';
import dateIsEqual from 'date-fns/isEqual';
import { map, compact, flatten, isEqual, isEmpty, filter, some, head, last, sortBy, isArray, cloneDeep, pick, camelCase } from 'lodash-es';
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
      selectedTopicItemIds: [],
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
      discussionTemplateId: null,
      commentLengthMax: null,
      attachmentsAdminOnly: false,
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
    clone.selectedTopicItemIds = [];
    clone.groupId = null;
    clone.lockedAt = null;
    clone.lockerId = null;
    clone.createdAt = null;
    clone.updatedAt = null;
    return clone;
  }

  buildTemplate() {
    // Carry reusable content and thread settings into a fresh template, leaving
    // participants, activity, and lifecycle state on the source discussion.
    const template = Records.discussionTemplates.build();
    const attrs = cloneDeep(pick(this, AppConfig.templateSettings.discussion_template.map(camelCase)));
    Object.assign(attrs, pick(this.topic(), [
      'newestFirst', 'maxDepth', 'pollsOneAtATime', 'allowComments', 'allowReactions', 'commentLengthMax', 'attachmentsAdminOnly'
    ]));
    attrs.tags = this.createdTopicItem().tags.slice();
    attrs.groupId = this.groupId;
    attrs.processName = this.title;
    attrs.public = false;
    attrs.defaultToDirectDiscussion = false;
    template.update(attrs);
    return template;
  }

  pollTemplates() {
    return compact(this.pollTemplateKeysOrIds.map(keyOrId => {
      return Records.pollTemplates.find(keyOrId);
    })
    );
  }

  privateDefaultValue() {
    return this.group().discussionPrivacyOptions !== 'public_only';
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
    const target = (this.id && this) || (this.groupId && this.group());
    return target ? target.namedId() : {};
  }

  createdTopicItem() {
    if (this.topicId) {
      const res = Records.topicItems.find({topicId: this.topicId, sequenceId: 0});
      if (!isEmpty(res)) { return res[0]; }
    }
    const res = Records.topicItems.find({kind: 'new_discussion', itemableId: this.id});
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
};
