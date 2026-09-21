<script setup>
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import AuthService from '@/shared/services/auth_service';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import Records from '@/shared/services/records';

const { user, close, promptType } = defineProps({
  user: Object,
  close: Function,
  promptType: {
    type: String,
    required: true
  }
});

const { t } = useI18n();
const passkeyLoading = ref(false);
const titleKey = promptType === 'passkey' ? 'passkey_settings.title' : 'set_password_prompt.title';
const helptextKey = promptType === 'passkey' ? 'passkey_settings.helptext' : 'set_password_prompt.helptext';

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
  const experience = promptType === 'passkey' ? 'passkeyPromptDismissed' : 'passwordPromptDismissed';
  await Records.users.saveExperience(experience);
  user.experiences[experience] = true;
  close();
};
</script>

<template lang="pug">
v-card.credential-prompt(:title="t(titleKey)")
  template(v-slot:append)
    dismiss-modal-button(:close="close")
  v-card-text
    p.text-medium-emphasis {{ t(helptextKey) }}
  v-card-actions.flex-wrap
    v-btn.credential-prompt__dismiss(variant="text" @click="dismissOffer")
      span {{ t('set_password_prompt.no_thanks') }}
    v-spacer
    v-btn.credential-prompt__password(v-if="promptType === 'password'" color="primary" variant="elevated" @click="setPassword")
      span {{ t('credential_prompt.set_password') }}
    v-btn.credential-prompt__passkey(
      v-if="promptType === 'passkey'"
      variant="elevated"
      color="primary"
      :loading="passkeyLoading"
      @click="addPasskey")
      span {{ t('credential_prompt.add_passkey') }}
</template>
