import AppConfig     from '@/shared/services/app_config';
import Records       from '@/shared/services/records';
import LmoUrlService from '@/shared/services/lmo_url_service';
import RestfulClient from '@/shared/record_store/restful_client';
import EventBus      from '@/shared/services/event_bus';
import { hardReload } from '@/shared/helpers/window';
import { compact } from 'lodash-es';
import { I18n, loadLocaleMessages } from '@/i18n';

export default new class Session {
  returnTo() {
    const h = new URL(window.location.href);
    return h.pathname + h.search;
  }
    
  defaultFormat() {
    if (this.user().experiences['html-editor.uses-markdown']) {
      return 'md';
    } else {
      return 'html';
    }
  }

  apply(data) {
    AppConfig['currentUserId'] = data.current_user_id
    AppConfig['pendingIdentity'] = data.pending_identity;
    Records.importJSON(data);
    this.userId = data.current_user_id;
    const user = this.user();
    loadLocaleMessages(I18n, user.locale);

    if (this.isSignedIn()) {
      if (user.autodetectTimeZone && user.timeZone !== AppConfig.timeZone) {
        user.timeZone = AppConfig.timeZone;
        Records.users.updateProfile(user);
      }
      EventBus.$emit('signedIn', user);
    }

    return user;
  }

  signOut() {
    AppConfig.currentUserId = null;
    return Records.sessions.remote.destroy('').then(() => hardReload('/'));
  }

  isSignedIn() {
    return AppConfig.currentUserId && (this.user().restricted == null);
  }

  user() {
    return Records.users.find(AppConfig.currentUserId) || Records.users.build();
  }

  currentGroupId() {
    return (this.currentGroup != null) && this.currentGroup.id;
  }

  providerIdentity() {
    if (!AppConfig.pendingIdentity) { return; }
    const validProviders = AppConfig.identityProviders.map(p => p.name);
    if (validProviders.includes(AppConfig.pendingIdentity.identity_type)) { return AppConfig.pendingIdentity; }
  }
};
