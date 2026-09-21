<script setup>
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import AppConfig from '@/shared/services/app_config';
import AuthService from '@/shared/services/auth_service';
import TurnstileWidget from '@/components/auth/turnstile_widget.vue';

const { user } = defineProps({ user: Object });
const { t } = useI18n();
const email = ref(user.email || '');
const loading = ref(false);
const turnstileToken = ref('');
const captchaMissing = computed(() => Boolean(AppConfig.turnstileSiteKey) && !turnstileToken.value);

const submit = async () => {
  user.errors = {};
  if (!email.value) {
    user.errors.email = [t('auth_form.email_not_present')];
    return;
  }
  if (!email.value.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)) {
    user.errors.email = [t('auth_form.invalid_email')];
    return;
  }
  if (captchaMissing.value) return;

  user.email = email.value;
  user.turnstileToken = turnstileToken.value;
  loading.value = true;
  try {
    await AuthService.sendLoginLink(user);
  } finally {
    loading.value = false;
  }
};

const back = () => {
  user.errors = {};
  user.authForm = null;
};
</script>

<template lang="pug">
v-card.auth-email-code-form(:title="t('auth_form.sign_in_with_code')")
  template(v-slot:append)
    auth-back-button(@click="back")
  v-card-text
    form.max-width-400.mx-auto(@submit.prevent="submit" novalidate)
      p.text-body-medium.mb-4 {{ t('auth_form.email_code_help') }}
      v-text-field.auth-email-code-form__email(
        id="sign-in-code-email"
        name="email"
        type="email"
        autocomplete="username"
        required
        variant="outlined"
        :label="t('common.email_address')"
        v-model="email")
      validation-errors(:subject="user" field="email")
      turnstile-widget(v-model="turnstileToken")
      validation-errors(:subject="user" field="turnstile")
      .d-flex.mt-4.justify-end
        v-btn.auth-email-code-form__submit(
          type="submit"
          color="primary"
          variant="elevated"
          :disabled="!email || captchaMissing"
          :loading="loading") {{ t('auth_form.email_me_a_sign_in_code') }}
</template>
