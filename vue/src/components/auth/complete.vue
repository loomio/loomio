<script lang="js">
import Records       from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import AuthModalMixin from '@/mixins/auth_modal';
import openModal      from '@/shared/helpers/open_modal';
import AuthService from '@/shared/services/auth_service';
import EventBus from '@/shared/services/event_bus';

export default {
  mixins: [AuthModalMixin],
  props: {
    user: Object
  },
  data() {
    return {
      attempts: 0,
      loading: false
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
    }
  }
};
</script>
<template>

<v-card class="auth-complete text-center" @keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()" @keydown.enter="submit()">
  <v-card-title>
    <h1 class="headline" tabindex="-1" role="status" aria-live="assertive" v-t="'auth_form.check_your_email'"></h1>
    <v-spacer></v-spacer>
    <v-btn class="back-button" icon="icon" :title="$t('common.action.back')" @click="user.authForm = null">
      <common-icon name="mdi-close"></common-icon>
    </v-btn>
  </v-card-title>
  <v-sheet class="mx-4">
    <submit-overlay :value="loading"></submit-overlay>
    <p class="mb-4" v-if="user.sentLoginLink"><span v-t="{ path: 'auth_form.login_link_sent', args: { email: user.email }}"></span><br/><span v-t="'auth_form.instructions_code'" v-if="attempts < 3"></span></p>
    <div class="lmo-validation-error" v-t="'auth_form.too_many_attempts'" v-if="attempts >= 3"></div>
    <p class="mb-4" v-if="user.sentPasswordLink" v-t="{ path: 'auth_form.password_link_sent', args: { email: user.email }}"></p>
    <div class="auth-complete__code-input mb-4" v-if="user.sentLoginLink && attempts < 3">
      <div class="auth-complete__code mx-auto" style="max-width: 256px">
        <v-text-field class="headline lmo-primary-form-input" outlined="outlined" label="Code" :placeholder="$t('auth_form.code')" type="integer" maxlength="6" v-model="user.code"></v-text-field>
      </div><span v-t="'auth_form.check_spam_folder'"></span>
    </div>
  </v-sheet>
  <v-card-actions>
    <v-spacer></v-spacer>
    <v-btn v-if="!user.hasPassword" :disabled="!user.code || loading" @click="submitAndSetPassword()" v-t="'auth_form.set_password'"></v-btn>
    <v-btn color="primary" :loading="loading" @click="submit()" :disabled="!user.code || loading" v-t="'auth_form.sign_in'"></v-btn>
  </v-card-actions>
</v-card>
</template>
<style lang="sass">
.auth-complete__code input
  letter-spacing: 0.5em
  text-align: center
</style>
