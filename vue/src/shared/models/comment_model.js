import BaseModel       from '@/shared/record_store/base_model';
import AppConfig       from '@/shared/services/app_config';
import HasDocuments    from '@/shared/mixins/has_documents';
import {capitalize, map, invokeMap} from 'lodash-es';
import Records from '@/shared/services/records';

export default class CommentModel extends BaseModel {
  static singular = 'comment';
  static plural = 'comments';
  static indices = ['discussionId', 'authorId'];
  static uniqueIndices = ['id'];

  afterConstruction() {
    HasDocuments.apply(this);
  }

  collabKeyParams() {
    return [this.discussionId, this.parentType, this.parentId];
  }

  defaultValues() {
    return {
      parentType: null,
      parentId: null,
      pollId: null,
      files: null,
      imageFiles: null,
      attachments: [],
      linkPreviews: [],
      body: '',
      bodyFormat: 'html',
      mentionedUsernames: []
    };
  }

  relationships() {
    this.belongsTo('author', {from: 'users'});
    this.belongsToPolymorphic('parent');
    this.belongsTo('poll');
    this.belongsTo('translation');
  }

  topic() {
    return this.parent().topic();
  }

  createdEvent() {
    return Records.events.find({kind: "new_comment", eventableId: this.id})[0];
  }

  reactions() {
    return Records.reactions.find({
      reactableId: this.id,
      reactableType: capitalize(this.constructor.singular)
    });
  }

  group() {
    const topic = this.topic();
    return topic ? topic.group() : null;
  }

  memberIds() {
    const topicable = this.topic()?.topicable();
    return topicable && topicable.memberIds ? topicable.memberIds() : [];
  }

  participantIds() {
    const topicable = this.topic()?.topicable();
    return topicable && topicable.participantIds ? topicable.participantIds() : [];
  }

  isReply() {
    return (this.parentId != null);
  }

  isBlank() {
    return (this.body === '') || (this.body === null) || (this.body === '<p></p>');
  }

  parent() {
    return this.parentId && Records[BaseModel.eventTypeMap[this.parentType]].find(this.parentId);
  }

  reactors() {
    return Records.users.find(map(this.reactions(), 'userId'));
  }

  authorName() {
    if (this.author()) { return this.author().nameWithTitle(this.group()); }
  }

  authorUsername() {
    return this.author().username;
  }

  authorAvatar() {
    return this.author().avatarOrInitials();
  }

  beforeDestroy() {
    return invokeMap(Records.events.find({kind: 'new_comment', eventableId: this.id}), 'remove');
  }
};
