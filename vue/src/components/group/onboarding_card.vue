<script setup lang="js">
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { differenceInDays, parseISO } from 'date-fns';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import SubscriptionService from '@/shared/services/subscription_service';

const { group } = defineProps({ group: Object });
const { t } = useI18n();
const dismissed = ref(false);

const REQUIRED_PARTICIPANTS = 3;

const parentGroup = computed(() => group.parentOrSelf() || group);
const subscription = computed(() => parentGroup.value.subscription || {});
const isTrial = computed(() => subscription.value.plan === 'trial');
const trialExtended = computed(() => Boolean(subscription.value.trial_extended_at));
const daysRemaining = computed(() => (
  subscription.value.expires_at ? Math.max(0, differenceInDays(parseISO(subscription.value.expires_at), new Date()) + 1) : null
));
const upgradeUrl = computed(() => SubscriptionService.upgradeUrl(parentGroup.value));
const emailInvitationsAllowed = computed(() => (
  Session.user().emailInvitationsAllowed() || parentGroup.value.emailInvitationsAllowed()
));
const participantsCount = computed(() => (
  trialExtended.value ? REQUIRED_PARTICIPANTS : Math.min(REQUIRED_PARTICIPANTS, parentGroup.value.trialParticipantsCount || 0)
));
const participantsRemaining = computed(() => Math.max(0, REQUIRED_PARTICIPANTS - participantsCount.value));
const extendTrialText = computed(() => (
  participantsCount.value === 0
    ? t('onboarding_card.extend_trial_initial', { count: participantsRemaining.value })
    : t('onboarding_card.extend_trial_remaining', { count: participantsRemaining.value }, participantsRemaining.value)
));

const visible = computed(() => {
  if (!isTrial.value || !group.isEnabled() || !group.membersInclude(Session.user())) { return false; }
  if (trialExtended.value && (dismissed.value || Session.user().hasExperienced('hideOnboarding'))) { return false; }
  return true;
});

function dismiss() {
  dismissed.value = true;
  Records.users.saveExperience('hideOnboarding', true);
}
</script>

<template lang="pug">
v-card.group-onboarding-card.mb-3(v-if="visible" :color="trialExtended ? 'success' : 'info'" variant="tonal")
  v-card-text
    .d-flex.align-center.justify-space-between.flex-wrap.ga-2.mb-2
      .d-flex.align-center.flex-wrap.ga-2
        .text-title-medium(v-if="trialExtended") {{ t('onboarding_card.trial_extended_title') }}
        .text-title-medium(v-else-if="daysRemaining !== null") {{ t('current_plan_button.free_trial', { days: daysRemaining }) }}
        .text-title-medium(v-else) {{ t('onboarding_card.extend_trial_title') }}
        v-chip.group-onboarding-card__verified-badge(
          v-if="emailInvitationsAllowed"
          size="small"
          variant="flat"
          color="success"
        )
          common-icon.mr-1(name="mdi-check-circle" size="small")
          span {{ t('onboarding_card.verified_badge') }}
      .d-flex.align-center.ga-2
        v-btn.group-onboarding-card__upgrade(
          :color="trialExtended ? 'success' : 'info'"
          variant="elevated"
          size="small"
          :href="upgradeUrl"
          target="_blank"
          :title="t('current_plan_button.tooltip')"
        )
          common-icon.mr-1(name="mdi-rocket" size="small" color="currentColor")
          span {{ t('current_plan_button.upgrade') }}
        v-btn.group-onboarding-card__dismiss(
          v-if="trialExtended"
          variant="text"
          size="small"
          @click="dismiss"
        ) {{ t('common.action.close') }}

    template(v-if="trialExtended")
      p.text-body-medium.mb-0 {{ t('onboarding_card.trial_extended_description') }}

    template(v-else)
      p.text-body-medium(:class="emailInvitationsAllowed ? 'mb-2' : 'mb-0'") {{ extendTrialText }}
      .group-onboarding-card__verification.d-flex.align-start.ga-2.text-body-small(v-if="emailInvitationsAllowed")
        common-icon.flex-shrink-0(name="mdi-checkbox-marked-circle-outline" size="small")
        span {{ t('onboarding_card.trial_verified') }}
</template>
