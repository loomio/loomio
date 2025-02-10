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
        });
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
<template lang="pug">
v-card.auth-signin-form(
  :title="$t('auth_form.welcome_back', { name: user.name })"
  @keyup.ctrl.enter="submit()"
  @keydown.meta.enter.stop.capture="submit()"
  @keydown.enter="submit()")
  template(v-slot:append)
    v-btn.back-button(icon variant="text" :title="$t('common.action.back')" @click='user.authForm = null')
      common-icon(name="mdi-close")

  .max-width-400.mx-auto
    .d-flex.justify-center.mb-4
      user-avatar(:user='user' :size='128')
    .auth-signin-form__token.text-center(v-if='user.hasToken')
      validation-errors(:subject='user', field='token')
      v-btn.my-4.auth-signin-form__submit(color="primary" @click='submit()' v-if='!user.errors.token' :loading="loading")
        span(v-t="{ path: 'auth_form.sign_in_as', args: {name: user.name}}")
      v-btn.my-4.auth-signin-form__submit(color="primary" @click='sendLoginLink()' v-if='user.errors.token' :loading="loading")
        span(v-t="'auth_form.login_link'")
      p.mb-4.text-medium-emphasis
        span(v-t="'auth_form.set_password_helptext'").mr-1
        a.lmo-pointer(@click='signInAndSetPassword()' v-t="'auth_form.set_password'")
    .auth-signin-form__no-token(v-if='!user.hasToken')
      .auth-signin-form__password(v-if='user.hasPassword')
        p.text-center.my-2(v-t="'auth_form.enter_your_password'")
        v-text-field#password(
          :label="$t('auth_form.password')"
          name='password'
          type='password'
          variant="outlined"
          autofocus
          required
          v-model='user.password'
          autocomplete="current-password")
        validation-errors(:subject='user' field='password')

  v-card-actions(v-if='!user.hasToken')
    v-btn.auth-signin-form__login-link(
      v-if='user.hasPassword'
      variant="tonal"
      :color="user.hasPassword ? '' : 'primary'"
      @click='sendLoginLink()'
      :loading="!user.password && loading"
    )
      span(v-t="user.hasPassword ? 'auth_form.forgot_password' : 'auth_form.login_link'")
    v-spacer
    v-btn.auth-signin-form__submit(
      v-if='user.hasPassword'
      @click='submit()'
      variant="elevated"
      :color="user.hasPassword ? 'primary' : ''"
      :disabled='!user.password'
      :loading="user.password && loading")
      span(v-t="'auth_form.sign_in'")

    v-btn.auth-signin-form__submit(
      v-if='!user.hasPassword'
      variant="elevated"
      color="primary"
      @click='sendLoginLink()'
      :loading="loading"
    )
      span(v-t="'auth_form.login_link'")
</template>
