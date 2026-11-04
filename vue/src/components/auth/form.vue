<script lang="js">
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
  props: {
    user: Object,
    preventClose: Boolean
  },

  data() {
    return {
      localLogin: AppConfig.features.app.local_login,
      siteName: AppConfig.theme.site_name,
      privacyUrl: AppConfig.theme.privacy_url,
      isDisabled: false,
      pendingGroup: null
    };
  },

  created() {
    this.watchRecords({
      key: 'authForm',
      collections: ['groups'],
      query: store => {
        this.pendingGroup = store.groups.find(this.pendingIdentity.group_id);
      }
    });
  },

  methods: {
    emailCode() {
      if (!this.user.email?.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/)) {
        this.user.email = '';
      }
      this.user.errors = {};
      this.user.authForm = 'emailCode';
    },

    createAccount() {
      if (!this.user.email?.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/)) {
        this.user.email = '';
      }
      this.user.errors = {};
      this.user.authForm = 'signUp';
    }
  },

  computed: {
    canCreateAccount() {
      return AppConfig.features.app.create_user || this.pendingIdentity.identity_type;
    },

    userLocale() {
      return Session.user().locale;
    },

    isInvitedNewUser() {
      return AppConfig.pending_identity.email_verified === false;
    },

    pendingDiscussion() {
      return this.pendingIdentity.identity_type === 'discussion_reader';
    },

    pendingPoll() {
      return this.pendingIdentity.identity_type === 'stance';
    },

    pendingIdentity() {
      return (AppConfig.pending_identity || {});
    },
  }
}

</script>
<template lang="pug">
v-card.auth-form(:title="$t('auth_form.sign_in_to_loomio', { site_name: siteName })")
  template(v-slot:append)
    dismiss-modal-button(v-if='!preventClose')
  v-sheet
    //- p.text-headline-small.text-center(v-if="pendingGroup" v-t="{path: 'auth_form.youre_invited', args: {group_name: pendingGroup.name}}")
    //- p.text-headline-small.text-center(v-if="pendingDiscussion" v-t="'auth_form.youre_invited_discussion'")
    //- p.text-headline-small.text-center(v-if="pendingPoll" v-t="'auth_form.youre_invited_poll'")
    p.text-center.text-body-small(v-if="isInvitedNewUser" v-t="{path: 'auth_form.existing_account_can_sign_in', args: { site_name: siteName } }")
    .max-width-400.mx-auto
      auth-provider-form(:user='user')
      auth-passkey-button.mb-2(v-if='localLogin')
      v-btn.auth-email-form__login-link(
        v-if='localLogin'
        block
        variant="tonal"
        @click="emailCode")
        common-icon(name="mdi-email-outline")
        space
        span {{ $t('auth_form.send_me_a_code') }}
      .d-flex.align-center.my-6(v-if='localLogin')
        v-divider
        span.text-body-small.text-medium-emphasis.text-no-wrap.mx-3 {{ $t('auth_form.or_sign_in_with_password') }}
        v-divider
    auth-email-form(:user='user' v-if='localLogin')
    .d-flex.align-center.justify-center.mt-6(v-if="canCreateAccount")
      span.text-body-small.text-medium-emphasis {{ $t('auth_form.new_to_site') }}
      v-btn.auth-form__create-account(variant="text" @click="createAccount")
        span {{ $t('auth_form.create_account') }}
    .d-flex.text-body-small.mt-4.justify-space-between.pa-4.text-medium-emphasis
      a.text-medium-emphasis(href="/about-loomio" v-t="'powered_by.about_loomio'")
      a.text-medium-emphasis(v-if='privacyUrl' target="_blank" v-t="'powered_by.privacy_policy'" :href="privacyUrl")
</template>
