import AppConfig from '@/shared/services/app_config';
import Records   from '@/shared/services/records';
import Session from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import i18n from '@/i18n';
import {head, pickBy, camelCase, mapKeys, map, pick, identity, keys} from 'lodash';

export default new class AuthService {
  emailStatus(user) {
    const pendingToken = (AppConfig.pendingIdentity || {}).token;
    return Records.users.emailStatus(user.email, pendingToken).then(data => {
      return this.applyEmailStatus(user, head(data.users));
    });
  }

  applyEmailStatus(user, data) {
    if (data == null) { data = {}; }
    const vals = ['name', 'email', 'avatar_kind', 'avatar_initials', 'email_hash',
            'avatar_url', 'has_password', 'email_status', 'email_verified',
            'legal_accepted_at', 'auth_form'];
    user.update(pickBy(mapKeys(pick(data, vals), (v, k) => camelCase(k)), val => !!val));
    user.update({hasToken: data.has_token});
    return user;
  }

  authSuccess(data) {
    const user = Session.apply(data);
    EventBus.$emit('closeModal');
    return Flash.success('auth_form.signed_in');
  }

  signIn(user) {
    if (user == null) { user = {}; }
    return Records.sessions.build(
      pick(user, ['email', 'name', 'password', 'code'])
    ).save().then(data => {
      this.authSuccess(data);
      return data;
    }
    , function(err) {
      const errors = user.hasToken ?
        { token: [i18n.t('auth_form.invalid_token')] }
      :
        { password: [i18n.t('auth_form.invalid_password')]};
      return user.update({errors});
    });
  }

  signUp(user) {
    return Records.registrations.build(
      pick(user, ['email', 'name', 'recaptcha', 'legalAccepted', 'emailNewsletter'])
    ).save().then(data => {
      if (user.hasToken || data.signed_in) {
        this.authSuccess(data);
      } else {
        user.update({authForm: 'complete', sentLoginLink: true});
      }
      return data;
    }
    , data => {
      return user.errors = data.errors;
    });
  }

  reactivate(user) {
    return Records.users.reactivate(user).then(() => user.update({sentLoginLink: true}));
  }

  sendLoginLink(user) {
    return Records.loginTokens.fetchToken(user.email).then(() => user.update({authForm: 'complete', sentLoginLink: true}));
  }

  validSignup(vars, user) {
    user.errors = {};

    if (!vars.name) {
      user.errors.name = [i18n.t('auth_form.name_required')];
    }

    if (AppConfig.theme.terms_url && !vars.legalAccepted) {
      user.errors.legalAccepted = [i18n.t('auth_form.terms_required')];
    }

    if (keys(user.errors)) {
      user.name           = vars.name;
      user.legalAccepted  = vars.legalAccepted;
      user.emailNewsletter = vars.emailNewsletter;
    }

    return keys(user.errors).length === 0;
  }
}
