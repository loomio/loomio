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
    isLoggedIn() { return Session.isSignedIn(); },
    isWasGift() {
      return this.group.subscription.plan === 'was-gift';
    },
    isTrialing() {
      return this.group.membersInclude(Session.user()) && (this.group.subscription.plan === 'trial');
    },
    isExpired() {
      return this.isTrialing && !this.group.subscription.active;
    },
    daysRemaining() {
      return differenceInDays(parseISO(this.group.subscription.expires_at), new Date) + 1;
    },
    createdDate() {
      return format(new Date(this.group.createdAt), 'do LLLL yyyy');
    }
  }
};
</script>
<template>

<v-alert outlined="outlined" color="primary" dense="dense" v-if="isTrialing">
  <div class="d-flex align-center">
    <div class="pr-1" v-if="isWasGift"><span v-if="isExpired" v-html="$t('current_plan_button.was_gift_expired')"></span><span v-if="!isExpired" v-html="$t('current_plan_button.was_gift_remaining', { days: daysRemaining } )"></span>
      <space></space><span v-html="$t('current_plan_button.was_gift_trial', {createdDate: createdDate })"></span>
    </div>
    <div class="pr-1" v-if="!isWasGift"><span v-if="!isExpired" v-t="{ path: 'current_plan_button.free_trial', args: { days: daysRemaining }}"></span><span v-if="isExpired" v-t="'current_plan_button.trial_expired'"></span></div>
    <v-spacer></v-spacer>
    <v-btn color="primary" :href="'/upgrade/'+group.id" target="_blank" :title="$t('current_plan_button.tooltip')">
      <common-icon name="mdi-rocket"></common-icon><span v-t="'current_plan_button.view_plans'"></span>
    </v-btn>
  </div>
</v-alert>
</template>
