<script lang="js">
import EventBus    from '@/shared/services/event_bus';
import AuthService from '@/shared/services/auth_service';
import AppConfig from '@/shared/services/app_config';

export default {
  props: {
    user: Object,
    identity: Object
  },

  data() {
    return {
      loading: false,
      email: ''
    };
  },

  methods: {
    submit() {
      this.loading = true;
      this.user.email = this.email;
      AuthService.sendLoginLink(this.user).then((() => {}), () => {
        return this.user.errors = {email: [this.$t('auth_form.email_not_found')]};
      })
      .finally(() => {
        this.loading = false;
      });
    },
    createAccount() {
      this.user.createAccount = true;
      this.user.authForm = 'signUp';
    }
  },
  computed: {
    siteName() { return AppConfig.theme.site_name; }
  }
}

</script>
<template>

<v-card class="auth-identity-form" @keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()" @keydown.enter="submit()">
  <v-card-title>
    <h1 class="headline" tabindex="-1" role="status" aria-live="polite" v-t="{ path: 'auth_form.hello', args: { name: user.name || user.email } }"></h1>
    <v-spacer></v-spacer>
    <v-btn class="back-button" icon="icon" :title="$t('common.action.back')" @click="user.authForm = null">
      <common-icon name="mdi-close"></common-icon>
    </v-btn>
  </v-card-title>
  <v-sheet class="mx-4 pb-4">
    <div class="mb-4 text-center">
      <v-layout justify-center="justify-center">
        <user-avatar :user="user"></user-avatar>
      </v-layout>
    </div>
    <div class="mb-4 text-center"></div>
    <div class="auth-identity-form__options">
      <div class="auth-identity-form__new-account mb-8">
        <p class="text-center" v-t="{ path: 'auth_form.new_to_loomio', args: { site_name: siteName } }"></p>
        <v-layout justify-center="justify-center">
          <v-btn color="primary" @click="createAccount()" v-t="'auth_form.create_account'" :disabled="email.length > 0"></v-btn>
        </v-layout>
      </div>
      <div class="auth-identity-form__existing-account">
        <div class="auth-email-form__email">
          <p class="text-center" v-t="'auth_form.already_a_user'"></p>
          <v-text-field class="lmo-primary-form-input" id="email" name="email" type="text" :placeholder="$t('auth_form.email_address_of_existing_account')" v-model="email"></v-text-field>
          <validation-errors :subject="user" :field="email"></validation-errors>
        </div>
        <v-layout justify-center="justify-center">
          <v-btn color="primary" @click="submit()" v-t="'auth_form.link_accounts'" :loading="loading" :disabled="email.length == 0"></v-btn>
        </v-layout>
      </div>
    </div>
  </v-sheet>
</v-card>
</template>
