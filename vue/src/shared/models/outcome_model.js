/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let OutcomeModel;
import BaseModel        from '@/shared/record_store/base_model';
import AppConfig        from '@/shared/services/app_config';
import HasDocuments     from '@/shared/mixins/has_documents';
import HasTranslations  from '@/shared/mixins/has_translations';
import NullGroupModel   from '@/shared/models/null_group_model';
import {capitalize} from 'lodash';

export default OutcomeModel = (function() {
  OutcomeModel = class OutcomeModel extends BaseModel {
    static initClass() {
      this.singular = 'outcome';
      this.plural = 'outcomes';
      this.indices = ['pollId', 'authorId'];
      this.uniqueIndices = ['id'];
    }

    defaultValues() {
      return {
        statement: '',
        statementFormat: 'html',
        calendarInvite: false,
        eventSummary: null,
        eventDescription: null,
        includeActor: false,
        files: [],
        imageFiles: [],
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
      return HasTranslations.apply(this);
    }

    relationships() {
      this.belongsTo('author', {from: 'users'});
      this.belongsTo('poll');
      this.belongsTo('group');
      return this.belongsTo('pollOption');
    }

    reactions() {
      return this.recordStore.reactions.find({
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
  };
  OutcomeModel.initClass();
  return OutcomeModel;
})();
