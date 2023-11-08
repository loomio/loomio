import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';
import { capitalize } from 'lodash-es';

export default class MembershipRequestModel extends BaseModel {
  static singular = 'membershipRequest';
  static plural = 'membershipRequests';
  static indices = ['id', 'groupId'];

  constructor(...args){
    super(...args);
    this.isPending = this.isPending.bind(this);
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
    this.belongsTo('responder', {from: 'users'});
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
