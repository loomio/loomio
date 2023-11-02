import BaseModel       from '@/shared/record_store/base_model';
import AppConfig       from '@/shared/services/app_config';
import HasDocuments    from '@/shared/mixins/has_documents';
import RecordStore    from '@/shared/record_store/record_store';
import HasTranslations from '@/shared/mixins/has_translations';
import {capitalize, map, last, invokeMap} from 'lodash';

export default class CommentModel extends BaseModel {
  static singular = 'comment';
  static plural = 'comments';
  static indices = ['discussionId', 'authorId'];
  static uniqueIndices = ['id'];

  afterConstruction() {
    HasDocuments.apply(this);
    HasTranslations.apply(this);
  }

  defaultValues() {
    return {
      discussionId: null,
      files: [],
      imageFiles: [],
      attachments: [],
      linkPreviews: [],
      body: '',
      bodyFormat: 'html',
      mentionedUsernames: []
    };
  }

  relationships() {
    this.belongsTo('author', {from: 'users'});
    this.belongsTo('discussion');
  }

  createdEvent() {
    return this.recordStore.events.find({kind: "new_comment", eventableId: this.id})[0];
  }

  reactions() {
    return this.recordStore.reactions.find({
      reactableId: this.id,
      reactableType: capitalize(this.constructor.singular)
    });
  }

  group() {
    return this.discussion().group();
  }

  memberIds() {
    return this.discussion().memberIds();
  }

  // isMostRecent: ->
  //   last(@discussion().comments()) == @
  participantIds() {
    return this.discussion().participantIds();
  }

  isReply() {
    return (this.parentId != null);
  }

  isBlank() {
    return (this.body === '') || (this.body === null) || (this.body === '<p></p>');
  }

  parent() {
    return this.recordStore[BaseModel.eventTypeMap[this.parentType]].find(this.parentId);
  }

  reactors() {
    return this.recordStore.users.find(map(this.reactions(), 'userId'));
  }

  authorName() {
    if (this.author()) { return this.author().nameWithTitle(this.discussion().group()); }
  }

  authorUsername() {
    return this.author().username;
  }

  authorAvatar() {
    return this.author().avatarOrInitials();
  }

  beforeDestroy() {
    return invokeMap(this.recordStore.events.find({kind: 'new_comment', eventableId: this.id}), 'remove');
  }
};
