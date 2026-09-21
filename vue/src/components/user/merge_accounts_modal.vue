<script setup>
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';

const { t } = useI18n();
const targetEmail = ref('');
const loading = ref(false);

const sendVerification = async () => {
  if (!targetEmail.value || Session.user().email === targetEmail.value) return;

  loading.value = true;
  try {
    await Records.users.sendMergeVerificationEmail(targetEmail.value);
    Flash.success('merge_accounts.modal.generic_flash_and_signout');
    EventBus.$emit('closeModal');
    Session.signOut();
  } finally {
    loading.value = false;
  }
};
</script>

<template lang="pug">
v-card
  v-card-title
    h1.text-headline-small {{ t('merge_accounts.modal.title') }}
    v-spacer
    dismiss-modal-button
  v-card-text
    p {{ t('merge_accounts.modal.generic_helptext') }}
    v-text-field(v-model="targetEmail" type="email" :label="t('merge_accounts.modal.email_label')")
  v-card-actions
    v-spacer
    v-btn(color="primary" :loading="loading" :disabled="!targetEmail || Session.user().email === targetEmail" @click="sendVerification") {{ t('merge_accounts.modal.send_verification') }}
</template>
