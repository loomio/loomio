<script lang="js">
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';

export default {
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

    startDemo() {
      return this.$route.path === '/try';
    },

    startTrial() {
      return AppConfig.features.app.trials && this.$route.path == '/g/new'
    }
  }
}

</script>
<template>

<v-card class="auth-form">
  <v-card-title>
    <h1 class="headline" tabindex="-1" role="status" aria-live="polite"><span v-if="$te('auth_form.sign_up_or_log_in', {locale: userLocale})" v-t="{ path: 'auth_form.sign_up_or_log_in', args: { site_name: siteName } }"></span><span v-else v-t="{ path: 'auth_form.sign_in_to_loomio', args: { site_name: siteName } }"></span></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button v-if="!preventClose"></dismiss-modal-button>
  </v-card-title>
  <v-sheet>
    <v-alert class="ma-4" text="text" outlined="outlined" type="info" v-if="startDemo" v-t="'templates.demo_needs_user'"></v-alert>
    <v-alert class="ma-4 mb-8" text="text" outlined="outlined" type="info" v-if="startTrial" v-t="'templates.trial_needs_user'"></v-alert>
    <p class="headline text-center" v-if="pendingGroup" v-t="{path: 'auth_form.youre_invited', args: {group_name: pendingGroup.name}}"></p>
    <p class="headline text-center" v-if="pendingDiscussion" v-t="'auth_form.youre_invited_discussion'"></p>
    <p class="headline text-center" v-if="pendingPoll" v-t="'auth_form.youre_invited_poll'"></p>
    <p class="text-center caption" v-if="isInvitedNewUser" v-t="{path: 'auth_form.existing_account_can_sign_in', args: { site_name: siteName } }"></p>
    <auth-provider-form :user="user"></auth-provider-form>
    <auth-email-form :user="user" v-if="emailLogin"></auth-email-form>
    <div class="d-flex caption mt-4 justify-space-between pa-4 text--secondary"><a class="text--secondary" v-if="privacyUrl" target="_blank" v-t="'powered_by.privacy_policy'" :href="privacyUrl"></a>
      <space></space><a class="auth-form__sign-in-help text--secondary" href="https://help.loomio.org/en/user_manual/users/sign_in/" target="_blank" v-t="'auth_form.sign_in_help'"></a>
    </div>
  </v-sheet>
</v-card>
</template>
