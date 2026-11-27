<script setup lang="js">
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { differenceInDays, parseISO } from 'date-fns';
import AppConfig from '@/shared/services/app_config';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import SubscriptionService from '@/shared/services/subscription_service';

const { group } = defineProps({ group: Object });
const { t } = useI18n();

const REQUIRED_MEMBERS = 3;

const parentGroup = computed(() => (
  typeof group.parentOrSelf === 'function' ? (group.parentOrSelf() || group) : group
));
const subscription = computed(() => parentGroup.value.subscription);
const isLoggedIn = computed(() => Session.isSignedIn());
const isMember = computed(() => (
  typeof group.membersInclude === 'function' ? group.membersInclude(Session.user()) : false
));
const isAdmin = computed(() => (
  typeof parentGroup.value.adminsInclude === 'function' ? parentGroup.value.adminsInclude(Session.user()) : false
));
const isFree = computed(() => subscription.value?.plan === 'free');
const isTrial = computed(() => subscription.value?.plan === 'trial');
const isDisabled = computed(() => (
  typeof group.isEnabled === 'function' ? !group.isEnabled() : false
));
const trialExtended = computed(() => Boolean(subscription.value?.trial_extended_at));
const showExtendedBanner = computed(() => (
  isTrial.value && !isDisabled.value && trialExtended.value
));
const daysRemaining = computed(() => (
  subscription.value?.expires_at ? Math.max(0, differenceInDays(parseISO(subscription.value.expires_at), new Date()) + 1) : null
));
const isNearingExpiry = computed(() => isDisabled.value || (daysRemaining.value !== null && daysRemaining.value <= 3));
const upgradeUrl = computed(() => SubscriptionService.upgradeUrl(parentGroup.value));
const trainingCallUrl = computed(() => AppConfig.features?.app?.training_call_url);
const upgradeLabel = computed(() => (
  isNearingExpiry.value ? t('onboarding_card.upgrade_now') : t('onboarding_card.view_plans')
));
const emailInvitationsAllowed = computed(() => (
  Session.user().emailInvitationsAllowed() || parentGroup.value.emailInvitationsAllowed()
));
const acceptedMembersCount = computed(() => {
  if (trialExtended.value) { return REQUIRED_MEMBERS; }
  const count = parentGroup.value.acceptedMembershipsCount ??
    Math.max(0, (parentGroup.value.membershipsCount || 0) - (parentGroup.value.pendingMembershipsCount || 0));
  return Math.min(REQUIRED_MEMBERS, count);
});
const membersRemaining = computed(() => Math.max(0, REQUIRED_MEMBERS - acceptedMembersCount.value));
const extendTrialText = computed(() => (
  acceptedMembersCount.value <= 1
    ? t('onboarding_card.extend_trial_initial', { count: membersRemaining.value })
    : t('onboarding_card.extend_trial_remaining', { count: membersRemaining.value }, membersRemaining.value)
));
const alertColor = computed(() => {
  if (isDisabled.value) { return 'warning'; }
  if (showExtendedBanner.value) { return 'success'; }
  return 'info';
});
const visible = computed(() => (
  Boolean(subscription.value) && isLoggedIn.value && isMember.value && (isDisabled.value || (isTrial.value && isAdmin.value))
));

function inviteByEmail() {
  EventBus.$emit('openModal', { component: 'GroupInvitationForm', props: { group } });
}
</script>

<template lang="pug">
v-alert.plan-banner.my-4(
  v-if="visible"
  variant="tonal"
  :color="alertColor"
  density="compact"
)
  .d-flex.align-center.justify-space-between.flex-wrap.ga-2
    .d-flex.align-center.flex-wrap.ga-2.pr-1
      template(v-if="isTrial && !isDisabled")
        .text-title-medium(v-if="showExtendedBanner") {{ t('onboarding_card.trial_extended_title') }}
        .text-title-medium(v-else-if="daysRemaining !== null") {{ t('current_plan_button.free_trial', { days: daysRemaining }) }}
        .text-title-medium(v-else) {{ t('onboarding_card.extend_trial_title') }}
      span(v-else-if="isTrial && isDisabled") {{ t('current_plan_button.trial_expired') }}
      span(v-else-if="isFree" v-html="t('current_plan_button.was_gift_expired_or_mistake')")
      span(v-else v-html="t('current_plan_button.subscription_ended')")
    .d-flex.align-center.ga-2
      v-btn.plan-banner__training-call(
        v-if="showExtendedBanner && trainingCallUrl"
        color="success"
        variant="elevated"
        :href="trainingCallUrl"
        target="_blank"
        rel="noopener"
      )
        common-icon.mr-1(name="mdi-calendar-clock" color="currentColor")
        span {{ t('onboarding_card.book_training_call') }}
      v-btn.plan-banner__upgrade(
        :color="alertColor"
        :variant="isNearingExpiry ? 'elevated' : 'outlined'"
        :href="upgradeUrl"
        target="_blank"
        :title="t('current_plan_button.tooltip')"
      )
        common-icon.mr-1(name="mdi-rocket" color="currentColor")
        span {{ upgradeLabel }}

  template(v-if="isTrial && !isDisabled")
    p.text-body-medium.mt-2.mb-0(v-if="showExtendedBanner") {{ t('onboarding_card.trial_extended_description') }}
    template(v-else-if="!trialExtended")
      p.text-body-medium.mt-2(:class="emailInvitationsAllowed ? 'mb-1' : 'mb-0'") {{ extendTrialText }}
      p.plan-banner__verification.text-body-small.mb-0(v-if="emailInvitationsAllowed")
        i18n-t(keypath="onboarding_card.trial_approved" tag="span")
          template(#link)
            a.plan-banner__invite-link.text-decoration-underline(href="#" @click.prevent="inviteByEmail") {{ t('onboarding_card.invite_people_via_email') }}
</template>
