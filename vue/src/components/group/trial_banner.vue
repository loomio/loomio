<script lang="coffee">
import { differenceInDays, format } from 'date-fns'
export default
  props:
    group: Object
  computed:
    isWasGift: ->
      @group.subscriptionPlan == 'was-gift'
    isTrialing: ->
      @group.subscriptionState == 'trialing'
    isExpired: ->
      @isTrialing && !@group.subscriptionActive
    daysRemaining: ->
      differenceInDays(@group.subscriptionExpiresAt, new Date) + 1
    createdDate: ->
      format(new Date(@group.createdAt), 'do LLLL yyyy')
</script>
<template lang="pug">
v-alert(outlined color="accent" dense v-if="isTrialing")
  v-layout(align-center)
    div.pr-1(v-if="isWasGift")
      span(v-if="isExpired" v-html="$t('current_plan_button.was_gift_expired')")
      span(v-if="!isExpired" v-html="$t('current_plan_button.was_gift_remaining', { days: daysRemaining } )")
      space
      span(v-html="$t('current_plan_button.was_gift_trial', {createdDate: createdDate })")
    div.pr-1(v-if="!isWasGift")
      span(v-if="!isExpired" v-t="{ path: 'current_plan_button.free_trial', args: { days: daysRemaining }}")
      span(v-if="isExpired" v-t="'current_plan_button.trial_expired'")
    v-spacer
    v-btn(color="accent" href="/upgrade" target="_blank" :title="$t('current_plan_button.tooltip')")
      v-icon mdi-rocket
      span(v-t="'current_plan_button.upgrade'")
</template>
