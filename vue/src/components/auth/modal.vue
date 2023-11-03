<script lang="js">
import AppConfig from '@/services/app_config';
import Records       from '@/services/records';
import EventBus      from '@/services/event_bus';
import AuthService   from '@/services/auth_service';
import Session from '@/services/session';

import AuthInactive from '@/components/auth/inactive';

export default {
  components: {
    AuthInactive
  },

  props: {
    preventClose: Boolean,
    close: Function
  },

  data() {
    return {
      siteName: AppConfig.theme.site_name,
      titleKey: 'auth_form.sign_in_to_loomio',
      user: Records.users.build({createAccount: false}),
      isDisabled: false,
      pendingProviderIdentity: Session.providerIdentity()
    };
  },

  mounted() {
    AuthService.applyEmailStatus(this.user, AppConfig.pendingIdentity);
  },

  methods: {
    back() { this.user.emailStatus = null; }
  },

  computed: {
    showBackButton() {
      return this.user.emailStatus &&
            !this.user.sentLoginLink &&
            !this.user.sentPasswordLink;
    }
  }
}
</script>
<template lang="pug">
.auth-modal
  auth-form(v-if="!user.authForm" :user='user' :prevent-close="preventClose")
  auth-signin-form(v-if='user.authForm == "signIn"' :user='user')
  auth-signup-form(v-if='user.authForm == "signUp"' :user='user')
  auth-identity-form(v-if='user.authForm == "identity"' :user='user' :identity='pendingProviderIdentity')
  auth-complete(v-if='user.authForm == "complete"' :user='user')
  auth-inactive(v-if='user.authForm == "inactive"' :user='user')
</template>
