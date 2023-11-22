<script lang="js">
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import Flash   from '@/shared/services/flash';

export default {
  props: {
    user: Object,
    close: Function
  },
  data() {
    return {processing: false};
  },

  created() {
    this.user.password = '';
    this.user.passwordConfirmation = '';
  },

  methods: {
    submit() {
      Records.users.updateProfile(this.user).then(() => {
        Flash.success("change_password_form.password_changed");
        this.close();
      }).catch(() => true);
    }
  }
};

</script>
<template>

<v-card class="change-password-form" @keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()" @keydown.enter="submit()">
  <v-card-title>
    <h1 class="headline" tabindex="-1" v-t="'change_password_form.set_password_title'"></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button :close="close"></dismiss-modal-button>
  </v-card-title>
  <v-card-text>
    <p class="text--secondary" v-t="'change_password_form.set_password_helptext'"></p>
    <div class="change-password-form__password-container">
      <v-text-field class="change-password-form__password" :label="$t('sign_up_form.password_label')" required="required" type="password" v-model="user.password"></v-text-field>
      <validation-errors :subject="user" field="password"></validation-errors>
    </div>
    <div class="change-password-form__password-confirmation-container">
      <v-text-field class="change-password-form__password-confirmation" :label="$t('sign_up_form.password_confirmation_label')" required="true" type="password" v-model="user.passwordConfirmation" autocomplete="new-password"></v-text-field>
      <validation-errors :subject="user" field="passwordConfirmation"></validation-errors>
    </div>
  </v-card-text>
  <v-card-actions>
    <v-spacer></v-spacer>
    <v-btn class="change-password-form__submit" :loading="processing" color="primary" @click="submit()" v-t="'change_password_form.set_password'"></v-btn>
  </v-card-actions>
</v-card>
</template>
