import BaseModel        from '@/shared/record_store/base_model';
import AppConfig        from '@/shared/services/app_config';
import HasDocuments     from '@/shared/mixins/has_documents';
import NullGroupModel   from '@/shared/models/null_group_model';
import {capitalize} from 'lodash-es';
import Records from '@/shared/services/records';

export default class OutcomeModel extends BaseModel {
  static singular = 'outcome';
  static plural = 'outcomes';
  static indices = ['pollId', 'authorId'];
  static uniqueIndices = ['id'];

  defaultValues() {
    return {
      statement: '',
      statementFormat: 'html',
      eventSummary: null,
      eventDescription: null,
      includeActor: false,
      files: null,
      imageFiles: null,
      attachments: [],
      linkPreviews: [],
      recipientUserIds: [],
      recipientChatbotIds: [],
      recipientEmails: [],
      recipientAudience: null,
      notifyRecipients: true,
      groupId: null,
      reviewOn: null
    };
  }

  afterConstruction() {
    HasDocuments.apply(this);
  }

  collabKeyParams() {
    return [this.pollId];
  }

  relationships() {
    this.belongsTo('author', {from: 'users'});
    this.belongsTo('poll');
    this.belongsTo('group');
    this.belongsTo('translation');
    return this.belongsTo('pollOption');
  }

  reactions() {
    return Records.reactions.find({
      reactableId: this.id,
      reactableType: capitalize(this.constructor.singular)
    });
  }

  authorName() {
    return this.author().nameWithTitle(this.poll().group());
  }

  isBlank() {
    return (this.statement === '') || (this.statement === null) || (this.statement === '<p></p>');
  }

  members() {
    return this.poll().members();
  }

  membersInclude(user) {
    return this.poll().membersInclude(user);
  }

  adminsInclude(user) {
    return this.poll().adminsInclude(user);
  }

  participantIds() {
    return this.poll().participantIds();
  }

  memberIds() {
    return this.poll().memberIds();
  }

  announcementSize() {
    return this.poll().announcementSize(this.notifyAction());
  }

  discussion() {
    return this.poll().discussion();
  }

  notifyAction() {
    return 'publish';
  }

  bestNamedId() {
    return ((this.id && this) || (this.pollId && this.poll()) || (this.groupId && this.group()) || {namedId() {}}).namedId();
  }

  aiSuggestionKeys() {
    const type = (this.poll() && this.poll().pollType) || null;
    switch (type) {
      case 'proposal':
        return ['draft_outcome', 'summarize', 'consensus_and_divergence'];
      case 'check':
        return ['summarize', 'consensus_and_divergence', 'suggest_next_steps'];
      case 'count':
        return ['summarize', 'suggest_next_steps'];
      case 'ranked_choice':
        return ['summarize', 'extract_themes', 'consensus_and_divergence'];
      case 'dot_vote':
        return ['summarize', 'extract_themes', 'suggest_next_steps'];
      case 'score':
        return ['summarize', 'extract_themes', 'consensus_and_divergence'];
      case 'poll':
        return ['summarize', 'consensus_and_divergence', 'suggest_next_steps'];
      case 'meeting':
        return ['summarize', 'extract_themes', 'suggest_next_steps'];
      default:
        return ['draft_outcome', 'summarize', 'consensus_and_divergence'];
    }
  }
};
