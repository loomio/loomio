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
const canCreateAccount = computed(() => AppConfig.features.app.create_user || AppConfig.pendingIdentity?.identity_type);
const captchaMissing = computed(() => Boolean(turnstileSiteKey) && !turnstileToken.value);

watch(() => user.email, value => {
  if (value && !email.value) email.value = value;
});

const emailValid = () => {
  user.errors = {};
  if (!email.value) {
    user.errors.email = [t('auth_form.email_not_present')];
  } else if (!email.value.match(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/g)) {
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
  if (!prepare()) return;
  loadingEmail.value = true;
  try {
    await AuthService.sendLoginLink(user);
  } finally {
    loadingEmail.value = false;
  }
};

const createAccount = () => {
  if (!emailValid()) return;
  user.email = email.value;
  user.authForm = 'signUp';
};
</script>

<template lang="pug">
.auth-email-form.mx-auto.max-width-400(v-submit-on-mod-enter="signIn" @keydown.enter.exact="signIn")
  v-text-field.auth-email-form__email#email(
    variant="outlined"
    name="email"
    type="email"
    :label="t('common.email_address')"
    v-model="email"
    autocomplete="username email")
  validation-errors(:subject="user" field="email")
  v-text-field.auth-email-form__password(
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
    block
    color="primary"
    variant="elevated"
    :disabled="!email || !password || captchaMissing"
    :loading="loadingPassword"
    @click="signIn")
    span {{ t('auth_form.sign_in') }}
  v-btn.auth-email-form__login-link.mt-2(
    block
    variant="text"
    :disabled="!email || captchaMissing"
    :loading="loadingEmail"
    @click="sendLoginLink")
    span {{ t('auth_form.email_me_a_sign_in_code') }}
  .text-center.mt-4(v-if="canCreateAccount")
    span.text-medium-emphasis {{ t('auth_form.new_to_site') }}
    space
    a.auth-email-form__create-account.lmo-pointer(@click="createAccount") {{ t('auth_form.create_account') }}
</template>
