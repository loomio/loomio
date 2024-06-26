<script lang="js">
import { differenceInDays, format, parseISO } from 'date-fns';
import Session         from '@/shared/services/session';
import AuthModalMixin      from '@/mixins/auth_modal';
export default
{
  mixins: [ AuthModalMixin ],
  props: {
    group: Object
  },

  methods: {
    signIn() { this.openAuthModal(); }
  },

  computed: {
    hasSubscription() { return this.group.subscription },
    isLoggedIn() { return Session.isSignedIn(); },
    isMember() { return this.group.membersInclude(Session.user()) },
    isFree() {return this.group.subscription.plan === 'free' },
    isTrial() { return this.group.subscription.plan === 'trial' },
    isExpired() { return !this.group.subscription.active },
    daysRemaining() {
      return differenceInDays(parseISO(this.group.subscription.expires_at), new Date) + 1;
    },
    createdDate() {
      return format(new Date(this.group.createdAt), 'do LLLL yyyy');
    }
  }
};
</script>
<template lang="pug">
v-alert(outlined color="primary" dense v-if="hasSubscription && isLoggedIn && isMember && (isTrial || isExpired)")
  .d-flex.align-center
    div.pr-1(v-if="isTrial")
      span(v-if="!isExpired" v-t="{ path: 'current_plan_button.free_trial', args: { days: daysRemaining }}")
      span(v-if="isExpired" v-t="'current_plan_button.trial_expired'")
    div.pr-1(v-if="isFree")
      span(v-html="$t('current_plan_button.was_gift_expired_or_mistake')")
    div.pr-1(v-if="!isFree && !isTrial")
      span(v-html="$t('current_plan_button.subscription_ended')")
    v-spacer
    v-btn(
      color="primary"
      :href="'/upgrade/'+group.id"
      target="_blank"
      :title="$t('current_plan_button.tooltip')"
    )
      common-icon(name="mdi-rocket")
      span(v-t="'current_plan_button.view_plans'")
</template>
