<script lang="js">
import AppConfig from '@/shared/services/app_config';
import Records       from '@/shared/services/records';
import EventBus      from '@/shared/services/event_bus';
import AuthService   from '@/shared/services/auth_service';
import Session from '@/shared/services/session';

import AuthInactive from '@/components/auth/inactive';
import AccountCompletion from '@/components/profile/account_completion';

export default {
  components: {
    AuthInactive,
    AccountCompletion
  },

  props: {
    preventClose: Boolean,
    close: Function
  },

  data() {
    return {
      siteName: AppConfig.theme.site_name,
      titleKey: 'auth_form.sign_in_to_loomio',
      user: Records.users.build({createAccount: false, email: this.$route.query['user_email']}),
      isDisabled: false,
      pendingProviderIdentity: Session.providerIdentity(),
      nameManaged: Boolean(AppConfig.pendingIdentity?.name_managed)
    };
  },

  mounted() {
    AuthService.applyEmailStatus(this.user, AppConfig.pendingIdentity);
    if (AppConfig.pendingIdentity?.incomplete) {
      this.user.authForm = 'accountCompletion';
    }
  },

  methods: {
    back() { this.user.emailStatus = null; }
  },

  computed: {
    showBackButton() {
      return this.user.emailStatus &&
            !this.user.sentLoginLink;
    }
  }
}
</script>
<template lang="pug">
.auth-modal
  auth-form(v-if="!user.authForm" :user='user' :prevent-close="preventClose")
  auth-signin-form(v-if='user.authForm == "signIn"' :user='user')
  auth-signup-form(v-if='user.authForm == "signUp"' :user='user')
  auth-email-code-form(v-if='user.authForm == "emailCode"' :user='user')
  auth-identity-form(v-if='user.authForm == "identity"' :user='user' :identity='pendingProviderIdentity')
  auth-complete(v-if='user.authForm == "complete"' :user='user')
  auth-inactive(v-if='user.authForm == "inactive"' :user='user')
  account-completion(
    v-if='user.authForm == "accountCompletion"'
    :user='user'
    :authentication-pending='true'
    :name-managed='nameManaged')
</template>
