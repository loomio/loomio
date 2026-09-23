import AppConfig from '@/shared/services/app_config';
import Records   from '@/shared/services/records';
import Session from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import CredentialPromptService from '@/shared/services/credential_prompt_service';
import AccountCompletionService from '@/shared/services/account_completion_service';
import { I18n } from '@/i18n';
import {pickBy, camelCase, mapKeys, pick, keys} from 'lodash-es';
import RestfulClient from '@/shared/record_store/restful_client';
import { passkeyPlatformName } from '@/shared/helpers/passkey_name.mjs';

const passkeys = new RestfulClient('passkey_credentials');

const passkeysSupported = () => Boolean(
  globalThis.PublicKeyCredential?.parseCreationOptionsFromJSON &&
  globalThis.PublicKeyCredential?.parseRequestOptionsFromJSON &&
  globalThis.PublicKeyCredential?.prototype?.toJSON
);

const createPasskeyCredential = async (options) => {
  const publicKey = PublicKeyCredential.parseCreationOptionsFromJSON(options);
  const credential = await navigator.credentials.create({ publicKey });
  return credential.toJSON();
};

const getPasskeyCredential = async (options) => {
  const publicKey = PublicKeyCredential.parseRequestOptionsFromJSON(options);
  const credential = await navigator.credentials.get({ publicKey });
  return credential.toJSON();
};

export default new class AuthService {
  applyEmailStatus(user, data) {
    if (data == null) { data = {}; }
    const vals = ['name', 'email', 'avatar_kind', 'avatar_initials', 'email_hash',
            'avatar_url', 'has_password', 'email_status', 'email_verified',
            'legal_accepted_at', 'legal_acceptance_required', 'auth_form', 'incomplete', 'name_managed'];
    user.update(pickBy(mapKeys(pick(data, vals), (v, k) => camelCase(k)), val => !!val));
    user.update({hasToken: data.has_token});
    return user;
  }

  authSuccess(data) {
    const user = Session.apply(data);
    EventBus.$emit('closeModal');
    Flash.fromServer(data.flash);
    const signInMethod = {
      signedInViaCode: Boolean(data.signed_in_via_login_code),
      signedInViaPassword: Boolean(data.signed_in_via_password)
    };
    AccountCompletionService.maybeOpen().then(() => {
      if (signInMethod.signedInViaCode || signInMethod.signedInViaPassword) {
        CredentialPromptService.maybeOpen(signInMethod);
      }
    });
    if (data.authentication_redirect) { window.location.assign(data.authentication_redirect); }
    return user;
  }

  passkeysSupported() {
    return passkeysSupported();
  }

  suggestedPasskeyName() {
    const platform = passkeyPlatformName();
    const name = I18n.global.t('auth_form.passkey_default_name');
    return platform ? `${platform} ${name.toLocaleLowerCase()}` : name;
  }

  async signInWithPasskey() {
    const options = await passkeys.post('authentication_options');
    const credential = await getPasskeyCredential(options);
    const data = await passkeys.post('authenticate', {public_key_credential: credential});
    this.authSuccess(data);
    return data;
  }

  async createPasskey(name) {
    const options = await passkeys.post('registration_options');
    const credential = await createPasskeyCredential(options);
    return passkeys.post('', {name, public_key_credential: credential});
  }

  passkeyCredentials() {
    return passkeys.get('');
  }

  removePasskey(id) {
    return passkeys.destroy(id);
  }

  signIn(user) {
    if (user == null) { user = {}; }
    return Records.sessions.build(
      pick(user, ['email', 'name', 'password', 'code', 'turnstileToken'])
    ).save().then(data => {
      if (data.incomplete) {
        user.update({
          errors: {},
          name: data.name,
          legalAcceptanceRequired: data.legal_acceptance_required,
          emailNewsletter: data.email_newsletter
        });
        AccountCompletionService.openPending(user);
        return user;
      }
      this.authSuccess(data);
      return data;
    }
    , function(data) {
      const serverErrors = (data && data.errors) || {};
      const errors = Object.keys(serverErrors).length ? { ...serverErrors } : {};
      if (user.code) {
        errors.code = errors.code || errors.turnstile || errors.token ||
                      [I18n.global.t('auth_form.invalid_code')];
      } else if (!Object.keys(errors).length) {
        errors[user.hasToken ? 'token' : 'password'] =
          [I18n.global.t(user.hasToken ? 'auth_form.invalid_token' : 'auth_form.invalid_password')];
      }
      return user.update({errors});
    });
  }

  completeAccount(user) {
    return new RestfulClient('registrations').post('complete', {
      user: {
        name: user.name,
        legal_accepted: user.legalAccepted,
        email_newsletter: user.emailNewsletter
      }
    }).then(data => this.authSuccess(data), data => {
      user.errors = data.errors || {};
      throw data;
    });
  }

  signUp(user) {
    return Records.registrations.build(
      pick(user, ['email', 'turnstileToken'])
    ).save().then(data => {
      if (data.incomplete) {
        user.update({ errors: {}, name: data.name, legalAcceptanceRequired: data.legal_acceptance_required, emailNewsletter: data.email_newsletter });
        AccountCompletionService.openPending(user);
      } else if (data.signed_in) {
        this.authSuccess(data);
      } else {
        user.update({authForm: 'complete', sentLoginLink: true, createAccount: true});
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
    return Records.loginTokens.fetchToken(user.email, user.turnstileToken).then(
      (data) => {
        if (data.account_status === 'unused') {
          return user.update({errors: {email: [I18n.global.t('auth_form.email_not_found')]}});
        }
        if (data.account_status === 'inactive') {
          return user.update({emailStatus: 'inactive', authForm: 'inactive'});
        }
        return user.update({authForm: 'complete', sentLoginLink: true, createAccount: false});
      },
      (data) => {
        const key = data.status === 429
          ? 'auth_form.login_link_rate_limited'
          : 'auth_form.send_login_link_error';
        Flash.error(key);
      }
    );
  }

  validSignup(vars, user) {
    user.errors = {};

    if (!vars.email) {
      user.errors.email = [I18n.global.t('auth_form.email_not_present')];
    } else if (!vars.email.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)) {
      user.errors.email = [I18n.global.t('auth_form.invalid_email')];
    }

    if (keys(user.errors)) {
      user.email          = vars.email;
    }

    return keys(user.errors).length === 0;
  }
}
