<script lang="js">
import Records from '@/services/records';
import Session from '@/services/session';
import Flash from '@/services/flash';
import AuthModalMixin from '@/mixins/auth_modal';
import openModal      from '@/helpers/open_modal';
import AuthService from '@/services/auth_service';
import AppConfig from '@/services/app_config';

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
<template lang="pug">
v-card.auth-inactive.text-center
  v-card-title
    h1.headline(tabindex="-1" role="status" aria-live="assertive" v-t="'profile_page.messages.deactivated'")
    v-spacer
    v-btn.back-button(icon :title="$t('common.action.back')" @click='user.authForm = null')
      v-icon mdi-close
  v-sheet.mx-4.pb-4
    p.title {{user.email}}
    p(v-t="'devise.failure.inactive'")
    v-btn(to="/contact" v-t="{path: 'user_dropdown.contact_site_name', args: {site_name: siteName}}")
</template>
