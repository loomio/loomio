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
<template>

<div class="auth-email-form" @keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()" @keydown.enter="submit()">
  <div class="auth-email-form__email">
    <v-text-field class="lmo-primary-form-input" id="email" outlined="outlined" name="email" type="email" :placeholder="$t('auth_form.email_placeholder')" :label="$t('common.email_address')" v-model="email" autocomplete="username email"></v-text-field>
    <validation-errors :subject="user" field="email"></validation-errors>
    <v-btn class="auth-email-form__submit" color="primary" @click="submit()" :disabled="!email" v-t="'auth_form.continue_with_email'" :loading="loading"></v-btn>
  </div>
</div>
</template>

<style lang="sass">
.auth-email-form
  max-width: 400px
  margin: 0 auto
.auth-email-form__submit
  margin: 0 auto
  display: block
</style>
