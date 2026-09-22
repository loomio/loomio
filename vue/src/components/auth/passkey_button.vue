<script setup>
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import AuthService from '@/shared/services/auth_service';
import Flash from '@/shared/services/flash';

const { t } = useI18n();
const loading = ref(false);
const supported = AuthService.passkeysSupported();

const signIn = async () => {
  loading.value = true;
  try {
    await AuthService.signInWithPasskey();
  } catch (error) {
    if (error?.name !== 'NotAllowedError') {
      Flash.error('auth_form.passkey_authentication_failed');
    }
  } finally {
    loading.value = false;
  }
};
</script>

<template lang="pug">
v-btn.auth-passkey-button__submit(
  v-if="supported"
  block
  variant="tonal"
  :loading="loading"
  @click="signIn")
  common-icon(name="mdi-key-variant")
  space
  span {{ t('auth_form.use_a_passkey') }}
</template>
