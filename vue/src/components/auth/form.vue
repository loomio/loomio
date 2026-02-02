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
      emailLogin: AppConfig.features.app.email_login,
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

  computed: {
    userLocale() {
      return Session.user().locale;
    },

    isInvitedNewUser() {
      return AppConfig.pending_identity.email_verified === false;
    },

    loginComplete() {
      return this.user.sentLoginLink || this.user.sentPasswordLink;
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
v-card.auth-form(:title="$t('auth_form.sign_up_or_log_in', { site_name: siteName })")
  template(v-slot:append)
    dismiss-modal-button(v-if='!preventClose')
  v-sheet
    //- p.text-headline-small.text-center(v-if="pendingGroup" v-t="{path: 'auth_form.youre_invited', args: {group_name: pendingGroup.name}}")
    //- p.text-headline-small.text-center(v-if="pendingDiscussion" v-t="'auth_form.youre_invited_discussion'")
    //- p.text-headline-small.text-center(v-if="pendingPoll" v-t="'auth_form.youre_invited_poll'")
    p.text-center.text-body-small(v-if="isInvitedNewUser" v-t="{path: 'auth_form.existing_account_can_sign_in', args: { site_name: siteName } }")
    auth-provider-form(:user='user')
    auth-email-form.mt-4(:user='user' v-if='emailLogin')
    .d-flex.text-body-small.mt-4.justify-space-between.pa-4.text-medium-emphasis
      a.text-medium-emphasis(v-if='privacyUrl' target="_blank" v-t="'powered_by.privacy_policy'" :href="privacyUrl")
      space
      a.auth-form__sign-in-help.text-medium-emphasis(href="https://help.loomio.org/en/user_manual/users/sign_in/" target="_blank" v-t="'auth_form.sign_in_help'")
</template>
