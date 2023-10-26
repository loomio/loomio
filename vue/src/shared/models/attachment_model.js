/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let AttachmentModel;
import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';

export default AttachmentModel = (function() {
  AttachmentModel = class AttachmentModel extends BaseModel {
    static initClass() {
      this.singular = 'attachment';
      this.plural = 'attachments';
      this.indices = ['recordType', 'recordId'];
  
      this.eventTypeMap = {
        Group: 'groups',
        Discussion: 'discussions',
        Poll: 'polls',
        Outcome: 'outcomes',
        Stance: 'stances',
        Comment: 'comments',
        CommentVote: 'comments',
        Membership: 'memberships',
        MembershipRequest: 'membershipRequests'
      };
    }

    model() {
      return this.recordStore[this.constructor.eventTypeMap[this.recordType]].find(this.recordId);
    }

    group() {
      return this.model().group();
    }

    relationships() {
      return this.belongsTo('author', {from: 'users'});
    }

    isAnImage() {
      return this.icon === 'image';
    }
  };
  AttachmentModel.initClass();
  return AttachmentModel;
})();
