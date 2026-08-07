<script setup lang="js">
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import { computed, ref } from 'vue';

const { membership: membershipProp } = defineProps({membership: Object});
const membership = membershipProp;
const saving = ref(false);
const canManageWeight = computed(() => AbilityService.canAdminister(membership.group()));
const weightValid = computed(() => Number.isInteger(Number(membership.weight)) && membership.weight >= 0 && membership.weight <= 1000000);

function submit() {
  saving.value = true;
  membership.save()
    .then(() => {
      if (!canManageWeight.value) { return; }
      return Records.memberships.remote.patchMember(membership.id, 'set_weight', {weight: membership.weight});
    })
    .then(() => {
      Flash.success("membership_form.membership_updated");
      EventBus.$emit('closeModal');
    })
    .catch(error => Flash.fromServer(error))
    .finally(() => { saving.value = false; });
}

</script>
<template lang="pug">
v-card.membership-modal(:title="$t(canManageWeight ? 'membership_form.modal_title.membership' : 'membership_form.modal_title.group')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text.membership-form
    p.text-medium-emphasis.membership-form__helptext(v-t="{ path: 'membership_form.title_helptext.group', args: { name: membership.user().name } }")
    label(for='membership-title', v-t="'membership_form.title_label'")
    v-text-field#membership-title.membership-form__title-input(autofocus v-on:keyup.enter="submit" :placeholder="$t('membership_form.title_placeholder')" v-model='membership.title', maxlength='255')
    validation-errors(:subject='membership', field='title')
    template(v-if="canManageWeight")
      p.text-medium-emphasis.mt-4(v-t="'membership_form.weight_helptext'")
      v-text-field#membership-weight.membership-form__weight-input(
        v-model.number="membership.weight"
        type="number"
        min="0"
        max="1000000"
        step="1"
        :label="$t('membership_form.weight_label')"
        :error-messages="weightValid ? [] : [$t('membership_form.weight_invalid')]"
        @keyup.enter="submit")
  v-card-actions.membership-form-actions
    v-spacer
    v-btn.membership-form__submit(color="primary" :disabled="!weightValid" :loading="saving" @click='submit()' v-t="'common.action.save'")
</template>
