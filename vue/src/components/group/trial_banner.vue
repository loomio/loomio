<script lang="coffee">
import { differenceInDays } from 'date-fns'
export default
  props:
    group: Object
  computed:
    isTrialing: ->
      @group.subscriptionState == 'trialing'
    isExpired: ->
      @isTrialing && !@group.subscriptionActive
    daysRemaining: ->
      differenceInDays(@group.subscriptionExpiresAt, new Date) + 1
</script>
<template lang="pug">
v-alert.white--text(color="accent" dense v-if="isTrialing")
  v-layout(align-center)
    span(v-if="!isExpired" v-t="{ path: 'current_plan_button.free_trial', args: { days: daysRemaining }}")
    span(v-if="isExpired" v-t="'current_plan_button.trial_expired'")
    v-spacer
    v-btn(href="/upgrade" target="_blank")
      v-icon mdi-rocket
      span(v-t="'current_plan_button.upgrade'")
</template>
