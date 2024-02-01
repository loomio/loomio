import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';
import { colonToUnicode } from '@/shared/helpers/emojis';
import AnonymousUserModel   from '@/shared/models/anonymous_user_model';

export default class NotificationModel extends BaseModel {
  static singular = 'notification';
  static plural = 'notifications';
  static uniqueIndices = ['id'];
  static indices = ['eventId', 'userId'];

  constructor(...args) {
    super(...args)
    this.href = this.href.bind(this);
  }

  defaultValues() {
    return {
      title: null,
      model: null,
      pollType: null,
      name: null, 
      reaction: null
    };
  }

  relationships() {
    this.belongsTo('event');
    this.belongsTo('user');
    this.belongsTo('actor', {from: 'users'});
  }

  actionPath() {
    switch (this.kind()) {
      case 'invitation_accepted': return this.actor().username;
    }
  }

  href() {
    if (!this.url) { return '/'; }
    if (this.kind === 'membership_requested') {
      return "/" + this.url.split('/')[1] + "/members/requests";
    } else if (this.url.startsWith(AppConfig.baseUrl)) {
      return "/" + this.url.replace(AppConfig.baseUrl, '');
    } else {
      return "/" + this.url;
    }
  }

  args() {
    return {
      actor: this.name,
      reaction: (this.kind === "reaction_created" ? colonToUnicode(this.reaction) : undefined),
      title: this.title,
      poll_type: this.pollType,
      model: this.model
    };
  }

  actor() {
    return this.actor() || this.membershipRequestActor();
  }

  membershipRequestActor() {
    const name = (this.name || '').toString();
    return Records.users.build({
      name,
      avatarInitials: name.split(' ').map(n => n[0]).join(''),
      avatarKind: 'initials'
    });
  }

  isRouterLink() {
    return !this.url.includes("/invitations/");
  }
};
