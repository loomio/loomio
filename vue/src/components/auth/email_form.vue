<script setup>
import { computed, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import AppConfig from '@/shared/services/app_config';
import AuthService from '@/shared/services/auth_service';
import TurnstileWidget from '@/components/auth/turnstile_widget.vue';

const { user } = defineProps({ user: Object });
const { t } = useI18n();
const email = ref(user.email || '');
const password = ref('');
const turnstileToken = ref('');
const loadingPassword = ref(false);
const loadingEmail = ref(false);
const turnstileSiteKey = AppConfig.turnstileSiteKey;
const captchaMissing = computed(() => Boolean(turnstileSiteKey) && !turnstileToken.value);
const emailPattern = /[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/;

watch(() => user.email, value => {
  if (value && !email.value) email.value = value;
});

watch(email, value => {
  user.email = value;
});

const emailValid = () => {
  user.errors = {};
  if (!email.value) {
    user.errors.email = [t('auth_form.email_not_present')];
  } else if (!email.value.match(emailPattern)) {
    user.errors.email = [t('auth_form.invalid_email')];
  }
  return !user.errors.email;
};

const prepare = () => {
  if (!emailValid() || captchaMissing.value) return false;
  user.email = email.value;
  user.turnstileToken = turnstileToken.value;
  return true;
};

const signIn = async () => {
  if (!prepare() || !password.value) return;
  user.password = password.value;
  loadingPassword.value = true;
  try {
    await AuthService.signIn(user);
  } finally {
    loadingPassword.value = false;
  }
};

const sendLoginLink = async () => {
  if (!email.value.match(emailPattern)) {
    user.email = '';
    user.errors = {};
    user.authForm = 'emailCode';
    return;
  }
  if (!prepare()) return;
  loadingEmail.value = true;
  try {
    await AuthService.sendLoginLink(user);
  } finally {
    loadingEmail.value = false;
  }
};

</script>

<template lang="pug">
form.auth-email-form.mx-auto.max-width-400(@submit.prevent="signIn" novalidate)
  v-text-field.auth-email-form__email(
    id="email"
    variant="outlined"
    name="email"
    type="email"
    required
    :label="t('common.email_address')"
    v-model="email"
    autocomplete="username")
  validation-errors(:subject="user" field="email")
  v-text-field.auth-email-form__password(
    id="current-password"
    variant="outlined"
    name="password"
    type="password"
    :label="t('auth_form.password')"
    v-model="password"
    autocomplete="current-password")
  validation-errors(:subject="user" field="password")
  turnstile-widget(v-model="turnstileToken")
  validation-errors(:subject="user" field="turnstile")
  v-btn.auth-email-form__submit(
    type="submit"
    block
    color="primary"
    variant="elevated"
    :disabled="!email || !password || captchaMissing"
    :loading="loadingPassword"
  )
    span {{ t('auth_form.sign_in') }}
  v-btn.auth-email-form__login-link.mt-2(
    type="button"
    block
    variant="text"
    :disabled="Boolean(email) && captchaMissing"
    :loading="loadingEmail"
    @click="sendLoginLink")
    span {{ t('auth_form.email_me_a_sign_in_code') }}
</template>
