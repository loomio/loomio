<script lang="js">
import AuthService from '@/shared/services/auth_service';
import EventBus    from '@/shared/services/event_bus';

export default {
  props: {
    user: Object
  },
  data() {
    return {
      email: this.user.email,
      loading: false
    };
  },
  watch: {
    'user.email'() {
      this.email = this.user.email;
    }
  },
  methods: {
    submit() {
      if (!this.validateEmail()) { return; }
      this.user.email = this.email;
      this.loading = true;
      AuthService.emailStatus(this.user).finally(() => { this.loading = false; });
    },
    validateEmail() {
      this.user.errors = {};
      if (!this.email) {
        this.user.errors.email = [this.$t('auth_form.email_not_present')];
      } else if (!this.email.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)) {
        this.user.errors.email = [this.$t('auth_form.invalid_email')];
      }
      return (this.user.errors.email == null);
    }
  }
};
</script>
<template lang="pug">
.auth-email-form.mx-auto.max-width-400.text-center(
  @keyup.ctrl.enter="submit()"
  @keydown.meta.enter.stop.capture="submit()"
  @keydown.enter="submit()")
    v-text-field.auth-email-form__email#email(
      variant="outlined"
      name='email'
      type='email'
      :placeholder="$t('auth_form.email_placeholder')"
      :label="$t('common.email_address')"
      v-model='email'
      autocomplete="username email")
    validation-errors(:subject='user' field='email')
    v-btn.auth-email-form__submit( color="primary" @click='submit()' :disabled='!email' :loading="loading")
      span( v-t="'auth_form.continue_with_email'")
</template>
