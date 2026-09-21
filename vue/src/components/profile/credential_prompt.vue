<script setup>
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import AuthService from '@/shared/services/auth_service';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import Records from '@/shared/services/records';

const { user, close } = defineProps({
  user: Object,
  close: Function
});

const { t } = useI18n();
const passkeyLoading = ref(false);
const passkeySupported = AuthService.passkeysSupported();

const rememberChoice = async () => {
  await Records.users.saveExperience('credentialPromptDismissed');
  user.experiences.credentialPromptDismissed = true;
};

const addPasskey = async () => {
  passkeyLoading.value = true;
  try {
    await AuthService.createPasskey(AuthService.suggestedPasskeyName());
    await rememberChoice();
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

const notNow = async () => {
  await rememberChoice();
  close();
};
</script>

<template lang="pug">
v-card.credential-prompt(:title="t('credential_prompt.title')")
  template(v-slot:append)
    dismiss-modal-button(:close="close")
  v-card-text
    p.text-medium-emphasis {{ t('credential_prompt.helptext') }}
  v-card-actions.flex-wrap
    v-btn.credential-prompt__dismiss(variant="text" @click="notNow")
      span {{ t('credential_prompt.not_now') }}
    v-spacer
    v-btn.credential-prompt__password(variant="tonal" @click="setPassword")
      span {{ t('credential_prompt.set_password') }}
    v-btn.credential-prompt__passkey(
      v-if="passkeySupported"
      variant="elevated"
      color="primary"
      :loading="passkeyLoading"
      @click="addPasskey")
      span {{ t('credential_prompt.add_passkey') }}
</template>
