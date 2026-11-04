<script setup lang="js">
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';

const { membership } = defineProps({membership: Object});
const { t } = useI18n();
const saving = ref(false);

function submit() {
  if (saving.value) return;
  saving.value = true;
  Records.memberships.remote.update(membership.id, {membership: {title: membership.title}})
    .then(() => {
      Flash.success("membership_form.updated");
      EventBus.$emit('closeModal');
    })
    .catch(error => Flash.fromServer(error))
    .finally(() => { saving.value = false; });
}

</script>
<template lang="pug">
v-card.membership-modal(:title="t('membership_form.modal_title.group')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text.membership-form
    p.text-medium-emphasis.membership-form__helptext {{ t('membership_form.title_helptext.group', { name: membership.user().name }) }}
    label(for='membership-title') {{ t('membership_form.title_label') }}
    v-text-field#membership-title.membership-form__title-input(autofocus v-on:keyup.enter="submit" :placeholder="t('membership_form.title_placeholder')" v-model='membership.title', maxlength='255')
    validation-errors(:subject='membership', field='title')
  v-card-actions.membership-form-actions
    v-spacer
    v-btn.membership-form__submit(color="primary" :loading="saving" @click='submit()') {{ t('common.action.save') }}
</template>
