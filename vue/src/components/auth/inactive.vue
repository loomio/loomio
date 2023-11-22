<script lang="js">
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import AuthModalMixin from '@/mixins/auth_modal';
import openModal      from '@/shared/helpers/open_modal';
import AuthService from '@/shared/services/auth_service';
import AppConfig from '@/shared/services/app_config';

export default {
  mixins: [AuthModalMixin],
  props: {
    user: Object
  },
  data() {
    return {siteName: AppConfig.theme.site_name};
  }
}

</script>
<template>

<v-card class="auth-inactive text-center">
  <v-card-title>
    <h1 class="headline" tabindex="-1" role="status" aria-live="assertive" v-t="'profile_page.messages.deactivated'"></h1>
    <v-spacer></v-spacer>
    <v-btn class="back-button" icon="icon" :title="$t('common.action.back')" @click="user.authForm = null">
      <common-icon name="mdi-close"></common-icon>
    </v-btn>
  </v-card-title>
  <v-sheet class="mx-4 pb-4">
    <p class="title">{{user.email}}</p>
    <p v-t="'devise.failure.inactive'"></p>
    <v-btn to="/contact" v-t="{path: 'user_dropdown.contact_site_name', args: {site_name: siteName}}"></v-btn>
  </v-sheet>
</v-card>
</template>
