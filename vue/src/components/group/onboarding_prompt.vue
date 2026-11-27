<script setup lang="js">
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import Flash from '@/shared/services/flash';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';

const PAIN_KEYS = [
  'too_many_meetings',
  'confusing_email_or_chat',
  'decisions_get_stuck',
  'not_everyone_can_participate',
  'poor_decision_records',
  'few_voices_dominate',
  'unclear_who_decides',
  'voting_without_discussion'
];

const { group } = defineProps({ group: Object });
const { t } = useI18n();

const painPoints = ref([]);
const description = ref('');
const trialIntent = ref('');
const saving = ref(false);
const completedLocally = ref(false);

const isParentTrial = computed(() => (
  Boolean(group) && !group.parentId && group.subscription?.plan === 'trial'
));
const isDisabled = computed(() => (
  typeof group?.isEnabled === 'function' ? !group.isEnabled() : false
));
const isAdmin = computed(() => (
  typeof group?.adminsInclude === 'function' ? group.adminsInclude(Session.user()) : false
));
const acceptedMembersCount = computed(() => (
  group?.acceptedMembershipsCount ?? group?.membershipsCount ?? 0
));
const visible = computed(() => (
  Session.isSignedIn() &&
  isParentTrial.value &&
  !isDisabled.value &&
  isAdmin.value &&
  !group.onboardingCompleted &&
  !completedLocally.value &&
  acceptedMembersCount.value < 3
));

const painOptions = computed(() => (
  PAIN_KEYS.map(key => ({ value: key, label: t(`onboarding_prompt.pains.${key}`) }))
));

function submit(payload) {
  if (saving.value) { return; }
  saving.value = true;
  Records.remote.post(`groups/${group.id}/onboarding`, payload).then(data => {
    if (data && typeof Records.importREADY === 'function') { Records.importREADY(data); }
    completedLocally.value = true;
    if (payload.pain_points?.length || payload.description || payload.trial_intent) {
      Flash.success('onboarding_prompt.saved');
    }
  }).catch(() => {
    Flash.error('common.please_try_again');
  }).finally(() => {
    saving.value = false;
  });
}

function save() {
  submit({
    pain_points: painPoints.value.slice(0, 2),
    description: description.value.trim() || undefined,
    trial_intent: trialIntent.value.trim() || undefined
  });
}

function skip() {
  submit({});
}
</script>

<template lang="pug">
v-card.onboarding-prompt.my-4(v-if="visible" variant="outlined")
  v-card-item
    v-card-title.text-title-medium {{ t('onboarding_prompt.title') }}
    v-card-subtitle {{ t('onboarding_prompt.subtitle') }}
  v-card-text.pt-2
    .mb-4
      .text-body-medium.font-weight-medium.mb-1 {{ t('onboarding_prompt.pain_points_label') }}
      .text-body-small.text-medium-emphasis.mb-2 {{ t('onboarding_prompt.pain_points_hint') }}
      v-chip-group.onboarding-prompt__pains(
        v-model="painPoints"
        multiple
        :max="2"
        column
        selected-class="text-primary"
      )
        v-chip(
          v-for="option in painOptions"
          :key="option.value"
          :value="option.value"
          :class="'onboarding-prompt__pain--' + option.value"
          filter
          variant="tonal"
          size="small"
        ) {{ option.label }}

    v-textarea.onboarding-prompt__description.mb-3(
      v-model="description"
      :label="t('onboarding_prompt.description_label')"
      :hint="t('onboarding_prompt.description_hint')"
      persistent-hint
      rows="2"
      auto-grow
      variant="outlined"
      density="comfortable"
    )

    v-text-field.onboarding-prompt__intent(
      v-model="trialIntent"
      :label="t('onboarding_prompt.trial_intent_label')"
      :placeholder="t('onboarding_prompt.trial_intent_placeholder')"
      variant="outlined"
      density="comfortable"
      hide-details
    )
  v-card-actions.px-4.pb-4
    v-spacer
    v-btn.onboarding-prompt__skip(variant="text" :disabled="saving" @click="skip") {{ t('onboarding_prompt.skip') }}
    v-btn.onboarding-prompt__save(color="primary" variant="elevated" :loading="saving" @click="save") {{ t('onboarding_prompt.save') }}
</template>
