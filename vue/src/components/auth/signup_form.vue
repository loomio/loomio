<script lang="js">
import EventBus    from '@/shared/services/event_bus';
import AuthService from '@/shared/services/auth_service';
import AppConfig from '@/shared/services/app_config';
import Session from '@/shared/services/session';
import AuthModalMixin from '@/mixins/auth_modal';
import Flash from '@/shared/services/flash';
import VueRecaptcha from 'vue-recaptcha';
import openModal      from '@/shared/helpers/open_modal';

export default {
  components: { VueRecaptcha },
  mixins: [AuthModalMixin],

  props: {
    user: Object
  },

  mounted() {
    EventBus.$emit('set-auth-modal-title', "auth_form.create_account");
  },

  data() {
    return {
      siteName: AppConfig.theme.site_name,
      vars: {name: this.user.name, site_name: AppConfig.theme.site_name},
      loading: false
    };
  },

  methods: {
    submit() {
      if (this.useRecaptcha) {
        this.$refs.invisibleRecaptcha.execute();
      } else {
        this.submitForm();
      }
    },

    submitForm(recaptcha) {
      this.user.recaptcha = recaptcha;
      if (AuthService.validSignup(this.vars, this.user)) {
        this.loading = true;
        AuthService.signUp(this.user).finally(() => {this.loading = false; });
      }
    }
  },
  computed: {
    recaptchaKey() { return AppConfig.recaptchaKey; },
    termsUrl() { return AppConfig.theme.terms_url; },
    privacyUrl() { return AppConfig.theme.privacy_url; },
    newsletterEnabled() { return AppConfig.newsletterEnabled; },
    allow() {
      return AppConfig.features.app.create_user || (AppConfig.pendingIdentity.identity_type != null);
    },
    useRecaptcha() { return this.recaptchaKey; }
  }
};

</script>
<template>

<v-card class="auth-signup-form" @keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()" @keydown.enter="submit()">
  <template v-if="!allow">
    <v-card-title v-if="!allow">
      <h1 class="headline" tabindex="-1" role="status" aria-live="assertive" v-t="'auth_form.invitation_required'"></h1>
      <v-spacer></v-spacer>
      <v-btn class="back-button" icon="icon" :title="$t('common.action.back')" @click="user.authForm = null">
        <common-icon name="mdi-close"></common-icon>
      </v-btn>
    </v-card-title>
  </template>
  <template v-else>
    <v-card-title>
      <h1 class="headline" tabindex="-1" role="status" aria-live="assertive" v-t="{ path: 'auth_form.welcome', args: { siteName: siteName } }"></h1>
      <v-spacer></v-spacer>
      <v-btn class="back-button" icon="icon" :title="$t('common.action.back')" @click="user.authForm = null">
        <common-icon name="mdi-close"></common-icon>
      </v-btn>
    </v-card-title>
    <v-sheet class="mx-4">
      <submit-overlay :value="loading"></submit-overlay>
      <div class="auth-signup-form__welcome text-center my-2">
        <p v-t="{path: 'auth_form.sign_up_as', args: {email: user.email}}"></p>
      </div>
      <div class="auth-signup-form__name">
        <v-text-field type="text" :label="$t('auth_form.name_placeholder')" :placeholder="$t('auth_form.enter_your_name')" outlined="outlined" v-model="vars.name" required="true"></v-text-field>
        <validation-errors :subject="user" field="legalAccepted"></validation-errors>
        <validation-errors :subject="user" field="email"></validation-errors>
        <validation-errors :subject="user" field="recaptcha"></validation-errors>
      </div>
      <div class="auth-signup-form__consent" v-if="termsUrl">
        <v-checkbox class="auth-signup-form__legal-accepted" v-model="vars.legalAccepted" hide-details="hide-details">
          <template v-slot:label="v-slot:label">
            <i18n path="auth_form.i_accept_all" tag="span">
              <template v-slot:termsLink="v-slot:termsLink"><a :href="termsUrl" target="_blank" @click.stop="@click.stop" v-t="'powered_by.terms_of_service'"></a></template>
              <template v-slot:privacyLink="v-slot:privacyLink"><a :href="privacyUrl" target="_blank" @click.stop="@click.stop" v-t="'powered_by.privacy_policy'"></a></template>
            </i18n>
          </template>
        </v-checkbox>
      </div>
      <div class="auth-signup-form__newsletter" v-if="newsletterEnabled">
        <v-checkbox class="auth-signup-form__newsletter-accepted" v-model="vars.emailNewsletter" hide-details="hide-details">
          <template v-slot:label="v-slot:label">
            <i18n path="auth_form.newsletter_label" tag="span">
              <template v-slot:link="v-slot:link"><span v-t="'email_settings_page.email_newsletter'"></span></template>
            </i18n>
          </template>
        </v-checkbox>
      </div>
    </v-sheet>
    <v-card-actions class="mt-8">
      <v-spacer></v-spacer>
      <v-btn class="auth-signup-form__submit" color="primary" :loading="loading" :disabled="!vars.name || (termsUrl && !vars.legalAccepted)" v-t="'auth_form.create_account'" @click="submit()"></v-btn>
    </v-card-actions>
    <vue-recaptcha v-if="useRecaptcha" ref="invisibleRecaptcha" :sitekey="recaptchaKey" :loadRecaptchaScript="true" size="invisible" @verify="submitForm"></vue-recaptcha>
  </template>
</v-card>
</template>
