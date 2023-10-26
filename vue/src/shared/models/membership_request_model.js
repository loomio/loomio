/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let MembershipRequestModel;
import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';
import { capitalize } from 'lodash';

export default MembershipRequestModel = (function() {
  MembershipRequestModel = class MembershipRequestModel extends BaseModel {
    static initClass() {
      this.singular = 'membershipRequest';
      this.plural = 'membershipRequests';
      this.indices = ['id', 'groupId'];
    }

    defaultValues() {
      return {
        introduction: null,
        groupId: null
      };
    }

    relationships() {
      this.belongsTo('group');
      this.belongsTo('requestor', {from: 'users'});
      return this.belongsTo('responder', {from: 'users'});
    }

    afterConstruction() {
      const name = this.name || this.email || '';
      return this.fakeUser = {
        name,
        email: this.email,
        avatarKind: 'initials',
        constructor: {singular: 'user'},
        avatarInitials: name.split(' ').map(t => t[0]).join('')
      };
    }

    nameAndEmail() {
      if (this.actor().email) {
        return `${this.actor().name} <${this.actor().email}>`;
      } else {
        return this.actor().name;
      }
    }

    actor() {
      if (this.byExistingUser()) { return this.requestor(); } else { return this.fakeUser; }
    }

    byExistingUser() {
      return (this.requestorId != null);
    }

    isPending() {
      return (this.respondedAt == null);
    }

    formattedResponse() {
      return capitalize(this.response);
    }
  };
  MembershipRequestModel.initClass();
  return MembershipRequestModel;
})();
