<script setup>
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import AppConfig from '@/shared/services/app_config';
import CredentialPromptService from '@/shared/services/credential_prompt_service';
import Records from '@/shared/services/records';
import AuthService from '@/shared/services/auth_service';

const { user, close, completed, authenticationPending } = defineProps({
  user: Object,
  close: Function,
  completed: Function,
  authenticationPending: Boolean
});

const { t } = useI18n();
const name = ref(user.name || '');
const legalAccepted = ref(Boolean(user.legalAcceptedAt));
const emailNewsletter = ref(Boolean(user.emailNewsletter));
const loading = ref(false);
const termsUrl = AppConfig.theme.terms_url;
const privacyUrl = AppConfig.theme.privacy_url;
const disabled = computed(() => !name.value.trim() || (termsUrl && !legalAccepted.value));

const submit = async () => {
  if (disabled.value || loading.value) return;
  loading.value = true;
  user.name = name.value.trim();
  user.legalAccepted = legalAccepted.value;
  user.emailNewsletter = emailNewsletter.value;
  try {
    if (authenticationPending) {
      await AuthService.completeAccount(user);
      return;
    }
    await Records.users.updateProfile(user);
    user.legalAcceptedAt ||= new Date().toISOString();
    completed();
    close();
    CredentialPromptService.maybeOpen();
  } finally {
    loading.value = false;
  }
};
</script>

<template lang="pug">
v-card.account-completion(:title="t('account_completion.complete_your_account')")
  form(@submit.prevent="submit" novalidate)
    v-card-text
      v-text-field.account-completion__name(
        v-model="name"
        name="name"
        autocomplete="name"
        :label="t('auth_form.name_placeholder')"
        required)
      validation-errors(:subject="user" field="name")
      v-checkbox.account-completion__legal-accepted(v-if="termsUrl" v-model="legalAccepted" hide-details)
        template(v-slot:label)
          i18n-t(keypath="auth_form.i_accept_all" tag="span")
            template(v-slot:termsLink)
              a.text-anchor(:href="termsUrl" target="_blank" @click.stop) {{ t('powered_by.terms_of_service') }}
            template(v-slot:privacyLink)
              a.text-anchor(:href="privacyUrl" target="_blank" @click.stop) {{ t('powered_by.privacy_policy') }}
      v-checkbox.account-completion__newsletter(v-if="AppConfig.newsletterEnabled" v-model="emailNewsletter" hide-details)
        template(v-slot:label)
          i18n-t(keypath="auth_form.newsletter_label" tag="span")
            template(v-slot:link)
              span {{ t('email_settings_page.email_newsletter') }}
    v-card-actions
      v-spacer
      v-btn.account-completion__submit(type="submit" color="primary" variant="elevated" :loading="loading" :disabled="disabled")
        span {{ t('account_completion.continue') }}
</template>
