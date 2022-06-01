<script lang="coffee">
import { differenceInDays, format, parseISO } from 'date-fns'
import Session         from '@/shared/services/session'
import AuthModalMixin      from '@/mixins/auth_modal'
import Flash              from '@/shared/services/flash'
import Records            from '@/shared/services/records'
export default
  mixins: [ AuthModalMixin ]
  props:
    group: Object

  methods:
    signIn: -> @openAuthModal()
    cloneDemo: -> 
      Flash.wait('templates.generating_demo')
      Records.post
        path: 'demos/clone'
        params:
          group_id: @group.id
      .then (data) =>
        Flash.success('templates.demo_created')
        @$router.push @urlFor(Records.groups.find(data.groups[0].id))


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
    template(v-if="!isLoggedIn")
      .d-flex.align-center
        span(v-t="'templates.login_to_start_demo'")
        v-spacer
        v-btn.ml-2(color="primary" @click="signIn" target="_blank")
          span(v-t="'auth_form.sign_in'")
    template(v-if="isLoggedIn && isPublicDemo")
      .d-flex.align-center
        span(v-t="'templates.click_button_to_start_demo'")
        v-spacer
        v-btn.ml-2(color="primary" @click="cloneDemo" target="_blank")
          span(v-t="'templates.start_demo'")
    template(v-if="isLoggedIn && !isPublicDemo")
      p
        span(v-t="'templates.welcome_to_your_demo'")
        space
        span(v-t="'templates.try_voting_to_see_it_work'")
        br
        span(v-t="'templates.to_use_loomio_with_your_org_start_trial'")

      v-btn.ml-2(block color="primary" to="/g/new" target="_blank")
        span(v-t="'templates.start_free_trial'")
</template>
