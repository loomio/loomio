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
    isPublicDemo: -> !!@group.handle
    isDemo: ->
      @group.subscription.plan == 'demo'
    daysRemaining: ->
      differenceInDays(parseISO(@group.subscription.expires_at), new Date) + 1
    createdDate: ->
      format(new Date(@group.createdAt), 'do LLLL yyyy')
</script>
<template lang="pug">
v-alert(outlined color="primary" dense v-if="isDemo")
  .d-flex.align-center
    template(v-if="!isLoggedIn")
      span Welcome to the demo! To try voting and other features, please sign in. It only takes a few seconds.
      v-spacer
      v-btn(color="primary" @click="signIn" target="_blank")
        span(v-t="'auth_form.sign_in'")
    template(v-if="isLoggedIn && isPublicDemo")
      span Welcome to the demo! To test out voting and other Loomio features, click start demo.
      v-spacer
      v-btn(color="primary" @click="signIn" target="_blank")
        span Start demo
      //- v-spacer
      //- v-btn(color="primary" to="/g/new" target="_blank")
      //-   v-icon mdi-rocket
      //-   span(v-t="'templates.start_trial'")
</template>
