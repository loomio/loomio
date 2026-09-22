<script lang="js">
import Records       from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import AuthModalMixin from '@/mixins/auth_modal';
import openModal      from '@/shared/helpers/open_modal';
import AuthService from '@/shared/services/auth_service';
import EventBus from '@/shared/services/event_bus';
import AppConfig from '@/shared/services/app_config';

export default {
  mixins: [AuthModalMixin],
  props: {
    user: Object
  },
  data() {
    return {
      attempts: 0,
      loading: false,
      revealEmailAccountStatus: AppConfig.features.app.reveal_email_account_status
    };
  },
  methods: {
    submitAndSetPassword() {
      this.loading = true;
      AuthService.signIn(this.user).then(() => {
        EventBus.$emit('openModal', {
          component: 'ChangePasswordForm',
          props: {
            user: Session.user()
          }
        }
        );
      }).finally(() => {
        this.attempts += 1;
        this.loading = false;
      });
    },
    submit() {
      this.loading = true;
      AuthService.signIn(this.user).finally(() => {
        this.attempts += 1;
        this.loading = false;
      });
    },
    back() {
      this.user.code = null;
      this.user.errors = {};
      this.user.sentLoginLink = false;
      this.user.authForm = null;
    }
  }
};
</script>
<template lang="pug">
v-card.auth-complete(
  :title="$t('auth_form.check_your_email')"
  v-submit-on-mod-enter="submit"
  @keydown.enter.exact="submit()")
  template(v-slot:append)
    auth-back-button(@click="back")
  v-sheet.mx-4.text-center
    p.my-6(v-if='user.sentLoginLink')
      span(v-if='revealEmailAccountStatus' v-t="{ path: 'auth_form.login_link_sent', args: { email: user.email }}")
      span(v-else v-t="{ path: 'auth_form.login_link_sent_if_account_exists', args: { email: user.email }}")
      br
      span(v-t="'auth_form.instructions_code'", v-if='attempts < 3')
    .lmo-validation-error(v-t="'auth_form.too_many_attempts'", v-if='attempts >= 3')
    .auth-complete__code-input.mb-4(v-if='user.sentLoginLink && attempts < 3')
      .auth-complete__code.mx-auto(style="max-width: 256px")
        v-text-field.text-headline-small(
          variant="outlined"
          label="Code"
          :placeholder="$t('auth_form.code')"
          type='integer'
          maxlength='6'
          v-model='user.code'
        )
        validation-errors(:subject='user' field='code')
      p.text-body-small
        | &nbsp;
        span(v-show="user.code")
          span(v-show="!user.hasPassword" v-t="'auth_form.want_to_set_password'")
          span(v-show="user.hasPassword" v-t="'auth_form.change_your_password'")
          space
          a(@click='submitAndSetPassword()' v-t="'auth_form.set_password'")
  v-card-actions
    v-spacer
    v-btn.auth-complete__submit(
      variant="elevated"
      color="primary"
      :loading="loading"
      @click='submit()'
      :disabled='!user.code || loading')
      span(v-t="'auth_form.sign_in'")
</template>
<style>
.auth-complete__code input {
  letter-spacing: 0.5em;
  text-align: center;
}
</style>
