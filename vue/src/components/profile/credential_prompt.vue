<script setup>
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import AuthService from '@/shared/services/auth_service';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import Records from '@/shared/services/records';

const { user, close, promptType, passkeySupported } = defineProps({
  user: Object,
  close: Function,
  passkeySupported: Boolean,
  promptType: {
    type: String,
    required: true
  }
});

const { t } = useI18n();
const passkeyLoading = ref(false);
const showPasskey = passkeySupported;
const showPassword = promptType === 'code';
const titleKey = promptType === 'passkey' ? 'passkey_settings.title' :
  showPasskey ? 'credential_prompt.title' : 'set_password_prompt.title';
const helptextKey = showPasskey ?
  'credential_prompt.passkey_description' :
  user.hasPassword ? 'auth_form.change_your_password' : 'set_password_prompt.helptext';

const addPasskey = async () => {
  passkeyLoading.value = true;
  try {
    await AuthService.createPasskey(AuthService.suggestedPasskeyName());
    user.hasPasskey = true;
    Flash.success('passkey_settings.added');
    close();
  } catch (error) {
    if (error?.name !== 'NotAllowedError') {
      Flash.error('auth_form.passkey_registration_failed');
    }
  } finally {
    passkeyLoading.value = false;
  }
};

const setPassword = () => {
  EventBus.$emit('openModal', {
    component: 'ChangePasswordForm',
    props: { user }
  });
};

const dismissOffer = async () => {
  if (promptType === 'code') {
    close();
    return;
  }
  await Records.users.saveExperience('passkeyPromptDismissed');
  user.experiences.passkeyPromptDismissed = true;
  close();
};
</script>

<template lang="pug">
v-card.credential-prompt(:title="t(titleKey)")
  template(v-slot:append)
    dismiss-modal-button(:close="dismissOffer")
  v-card-text
    p.text-medium-emphasis {{ t(helptextKey) }}
  v-card-actions.flex-column.align-stretch.ga-2
    v-btn.credential-prompt__passkey(
      v-if="showPasskey"
      block
      variant="elevated"
      color="primary"
      :loading="passkeyLoading"
      @click="addPasskey")
      span {{ t('credential_prompt.add_passkey') }}
    v-btn.credential-prompt__password.ma-0(
      v-if="showPassword"
      block
      color="primary"
      :variant="showPasskey ? 'tonal' : 'elevated'"
      @click="setPassword")
      span {{ t(user.hasPassword ? 'credential_prompt.set_new_password' : 'credential_prompt.set_password') }}
    v-btn.credential-prompt__dismiss.ma-0(block variant="text" @click="dismissOffer")
      span {{ t('set_password_prompt.no_thanks') }}
</template>
