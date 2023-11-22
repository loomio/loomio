<script lang="js">
import AuthService  from '@/shared/services/auth_service';
import Session from '@/shared/services/session';
import AuthModalMixin from '@/mixins/auth_modal';
import AppConfig from '@/shared/services/app_config';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';

export default {
  mixins: [AuthModalMixin],
  props: {
    user: Object
  },

  data() {
    return {
      siteName: AppConfig.theme.site_name,
      vars: {},
      loading: false
    };
  },

  methods: {
    signIn() {
      if (this.vars.name != null) { this.user.name = this.vars.name; }
      this.loading = true;
      AuthService.signIn(this.user).finally(() => {
        this.loading = false;
      });
    },

    signInAndSetPassword() {
      this.loading = true;
      this.signIn().then(() => {
        this.loading = false;
        EventBus.$emit('openModal', {
          component: 'ChangePasswordForm',
          props: {
            user: Session.user()
          }
        }
        );
      });
    },

    sendLoginLink() {
      this.loading = true;
      AuthService.sendLoginLink(this.user).finally(() => {
        this.loading = false;
      });
    },

    submit() {
      if (this.user.hasPassword || this.user.hasToken) {
        this.signIn();
      } else {
        this.sendLoginLink();
      }
    }
  }
};
</script>
<template>

<v-card class="auth-signin-form" @keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()" @keydown.enter="submit()">
  <v-card-title>
    <h1 class="headline" tabindex="-1" role="status" aria-live="assertive" v-t="{ path: 'auth_form.welcome_back', args: { name: user.name } }"></h1>
    <v-spacer></v-spacer>
    <v-btn class="back-button" icon="icon" :title="$t('common.action.back')" @click="user.authForm = null">
      <common-icon name="mdi-close"></common-icon>
    </v-btn>
  </v-card-title>
  <v-sheet class="mx-4 pb-4">
    <submit-overlay :value="loading"></submit-overlay>
    <v-layout justify-center="justify-center">
      <user-avatar :user="user" :size="128"></user-avatar>
    </v-layout>
    <div class="auth-signin-form__token text-center" v-if="user.hasToken">
      <validation-errors :subject="user" field="token"></validation-errors>
      <v-btn class="my-4 auth-signin-form__submit" color="primary" @click="submit()" v-if="!user.errors.token" :loading="loading"><span v-t="{ path: 'auth_form.sign_in_as', args: {name: user.name}}"></span></v-btn>
      <v-btn class="my-4 auth-signin-form__submit" color="primary" @click="sendLoginLink()" v-if="user.errors.token" :loading="loading"><span v-t="'auth_form.login_link'"></span></v-btn>
      <p><span class="mr-1" v-t="'auth_form.set_password_helptext'"></span><a class="lmo-pointer" @click="signInAndSetPassword()" v-t="'auth_form.set_password'"></a></p>
    </div>
    <div class="auth-signin-form__no-token" v-if="!user.hasToken">
      <div class="auth-signin-form__password" v-if="user.hasPassword">
        <p class="text-center my-2" v-t="'auth_form.enter_your_password'"></p>
        <v-text-field id="password" :label="$t('auth_form.password')" name="password" type="password" outlined="outlined" autofocus="autofocus" required="required" v-model="user.password" autocomplete="current-password"></v-text-field>
        <validation-errors :subject="user" field="password"></validation-errors>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn class="auth-signin-form__login-link" :color="user.hasPassword ? '' : 'primary'" v-t="user.hasPassword ? 'auth_form.forgot_password' : 'auth_form.login_link'" @click="sendLoginLink()" :loading="!user.password && loading"></v-btn>
          <v-btn class="auth-signin-form__submit" :color="user.hasPassword ? 'primary' : ''" v-t="'auth_form.sign_in'" @click="submit()" :disabled="!user.password" v-if="user.hasPassword" :loading="user.password && loading"></v-btn>
        </v-card-actions>
      </div>
      <div class="auth-signin-form__no-password" v-if="!user.hasPassword">
        <v-card-actions class="justify-space-around">
          <v-btn class="auth-signin-form__submit" color="primary" @click="sendLoginLink()" v-t="'auth_form.sign_in_via_email'" :loading="loading"></v-btn>
        </v-card-actions>
      </div>
    </div>
  </v-sheet>
</v-card>
</template>

<style lang="sass">
.auth-signin-form__no-password .auth-signin-form__submit
  display: block

</style>
