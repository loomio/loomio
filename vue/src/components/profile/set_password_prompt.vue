<script setup>
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';

const { user, close } = defineProps({
  user: Object,
  close: Function
});

const setPassword = () => {
  EventBus.$emit('openModal', {
    component: 'ChangePasswordForm',
    props: { user }
  });
};

const noThanks = () => {
  Records.users.saveExperience('passwordPromptDismissed').then(() => {
    user.experiences.passwordPromptDismissed = true;
    close();
  });
};
</script>

<template lang="pug">
v-card.set-password-prompt(:title="$t('set_password_prompt.title')")
  template(v-slot:append)
    dismiss-modal-button(:close="close")
  v-card-text
    p.text-medium-emphasis(v-t="'set_password_prompt.helptext'")
  v-card-actions
    v-btn.set-password-prompt__dismiss(variant="text" @click="noThanks")
      span(v-t="'set_password_prompt.no_thanks'")
    v-spacer
    v-btn.set-password-prompt__submit(variant="elevated" color="primary" @click="setPassword")
      span(v-t="'common.action.ok'")
</template>
