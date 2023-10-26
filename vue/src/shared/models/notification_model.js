/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let NotificationModel;
import BaseModel from '@/shared/record_store/base_model';
import AppConfig from '@/shared/services/app_config';
import { colonToUnicode } from '@/shared/helpers/emojis';
import AnonymousUserModel   from '@/shared/models/anonymous_user_model';

export default NotificationModel = (function() {
  NotificationModel = class NotificationModel extends BaseModel {
    static initClass() {
      this.singular = 'notification';
      this.plural = 'notifications';
      this.uniqueIndices = ['id'];
      this.indices = ['eventId', 'userId'];
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
      return this.belongsTo('actor', {from: 'users'});
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
  NotificationModel.initClass();
  return NotificationModel;
})();
