import AppConfig     from '@/shared/services/app_config';
import Records       from '@/shared/services/records';
import LmoUrlService from '@/shared/services/lmo_url_service';
import RestfulClient from '@/shared/record_store/restful_client';
import EventBus      from '@/shared/services/event_bus';
import i18n          from '@/i18n';
import Vue from 'vue';
import { hardReload } from '@/shared/helpers/window';
import * as Sentry from "@sentry/browser";
import { pickBy, identity, compact } from 'lodash-es';

const loadedLocales = ['en'];
const clientLocales = import.meta.glob('/../config/locales/client.*.yml')
const dateLocales = import.meta.glob('/node_modules/date-fns/locale/*/index.js')

const setI18nLanguage = function(locale) {
  i18n.locale = locale;
  return document.querySelector('html').setAttribute('lang', locale);
};

const fixCase = function(locale) {
  const splits = locale.replace('-', '_').split('_');
  return compact([splits[0].toLowerCase(), splits[1] && splits[1].toUpperCase()]).join('_');
};

const loomioLocale = locale => locale.replace('-', '_');

const dateFnsLocale = function(locale) {
  if (locale.startsWith('nl')) { return 'nl'; }
  return locale.replace('_','-');
};

const loadLocale = function(locale) {
  if (i18n.locale !== locale) {
    if (loadedLocales.includes(locale)) {
      return setI18nLanguage(locale);
    } else {
      const dateLocaleKey = `/node_modules/date-fns/locale/${dateFnsLocale(locale)}/index.js`
      const clientLocaleKey = `../config/locales/client.${loomioLocale(locale)}.yml`

      if (!dateLocales[dateLocaleKey]){
        Sentry.captureMessage(`missing dateLocale: ${dateLocaleKey}`)
        return false
      }

      if (!clientLocales[clientLocaleKey]){
        Sentry.captureMessage(`missing clientLocale: ${clientLocaleKey}`)
        return false
      }

      dateLocales[dateLocaleKey]().then(dateLocale => i18n.dateLocale = dateLocale.default);
      clientLocales[clientLocaleKey]().then(function(mod) {
        const data = mod.default[locale]
        loadedLocales.push(locale);
        i18n.setLocaleMessage(locale, data);
        setI18nLanguage(locale);
        return EventBus.$emit('VueForceUpdate');
      });
    }
  }
};

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
    Vue.set(AppConfig, 'currentUserId', data.current_user_id);
    Vue.set(AppConfig, 'pendingIdentity', data.pending_identity);
    Records.importJSON(data);
    this.userId = data.current_user_id;
    const user = this.user();
    this.updateLocale(user.locale);

    if (this.isSignedIn()) {
      if (user.timeZone !== AppConfig.timeZone) {
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

  updateLocale(locale) {
    return loadLocale(locale);
  }

  providerIdentity() {
    if (!AppConfig.pendingIdentity) { return; }
    const validProviders = AppConfig.identityProviders.map(p => p.name);
    if (validProviders.includes(AppConfig.pendingIdentity.identity_type)) { return AppConfig.pendingIdentity; }
  }
};
