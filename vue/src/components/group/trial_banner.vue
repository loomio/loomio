<script lang="coffee">
import { differenceInDays, format, parseISO } from 'date-fns'
import Session         from '@/shared/services/session'
import AuthModalMixin      from '@/mixins/auth_modal'
export default
  mixins: [ AuthModalMixin ]
  props:
    group: Object

  methods:
    signIn: -> @openAuthModal()

  computed:
    isLoggedIn: -> Session.isSignedIn()
    isDemo: ->
      @group.subscription.plan == 'demo'
    isWasGift: ->
      @group.subscription.plan == 'was-gift'
    isTrialing: ->
      @group.membersInclude(Session.user()) && @group.subscription.plan == 'trial'
    isExpired: ->
      @isTrialing && !@group.subscription.active
    daysRemaining: ->
      differenceInDays(parseISO(@group.subscription.expires_at), new Date) + 1
    createdDate: ->
      format(new Date(@group.createdAt), 'do LLLL yyyy')
</script>
<template lang="pug">
v-alert(outlined color="primary" dense v-if="isTrialing || isDemo")
  .d-flex.align-center(v-if="isDemo")
    template(v-if="isLoggedIn")
      span This is a demo! Try voting or leaving a comment.
      v-spacer
      v-btn(color="primary" @click="signIn" target="_blank")
        span Start a free trial
      //- v-spacer
      //- v-btn(color="primary" to="/g/new" target="_blank")
      //-   v-icon mdi-rocket
      //-   span(v-t="'templates.start_trial'")
    template(v-else)
      span This is a demo! To try voting and other features, please sign in. It only takes a few seconds.
      v-spacer
      v-btn(color="primary" @click="signIn" target="_blank")
        span(v-t="'auth_form.sign_in'")
  .d-flex(v-else)
    div.pr-1(v-if="isWasGift")
      span(v-if="isExpired" v-html="$t('current_plan_button.was_gift_expired')")
      span(v-if="!isExpired" v-html="$t('current_plan_button.was_gift_remaining', { days: daysRemaining } )")
      space
      span(v-html="$t('current_plan_button.was_gift_trial', {createdDate: createdDate })")
    div.pr-1(v-if="!isWasGift")
      span(v-if="!isExpired" v-t="{ path: 'current_plan_button.free_trial', args: { days: daysRemaining }}")
      span(v-if="isExpired" v-t="'current_plan_button.trial_expired'")
    v-spacer
    v-btn(color="primary" :href="'/upgrade/'+group.id" target="_blank" :title="$t('current_plan_button.tooltip')")
      v-icon mdi-rocket
      span(v-t="'current_plan_button.view_plans'")
</template>
