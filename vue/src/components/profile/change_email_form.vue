<script setup lang="js">
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';

const { close } = defineProps({close: Function});
const { t } = useI18n();
const email = ref('');
const processing = ref(false);
const errorMessage = ref('');

async function submit() {
  processing.value = true;
  errorMessage.value = '';
  try {
    await Records.users.requestEmailChange(email.value);
    Flash.success('profile_page.email_confirmation_sent');
    EventBus.$emit('updateProfile');
    close();
  } catch (error) {
    errorMessage.value = error.errors?.email_change_pending?.[0] || error.error || t('profile_page.email_change_failed');
  } finally {
    processing.value = false;
  }
}
</script>

<template lang="pug">
v-card.change-email-form(:title="t('profile_page.change_email')")
  template(v-slot:append)
    dismiss-modal-button(:close="close")
  v-card-text
    p.text-medium-emphasis {{ t('profile_page.change_email_help') }}
    v-text-field.change-email-form__email(
      v-model="email"
      :label="t('profile_page.new_email_address')"
      type="email"
      autocomplete="email"
      required)
    v-alert.my-2(v-if="errorMessage" type="error") {{ errorMessage }}
  v-card-actions
    v-spacer
    v-btn.change-email-form__submit(color="primary" variant="elevated" :loading="processing" @click="submit") {{ t('profile_page.send_confirmation_email') }}
</template>
