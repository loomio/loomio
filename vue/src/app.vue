<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import AuthModalMixin from '@/mixins/auth_modal'
import EventBus from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Session from '@/shared/services/session'

export default
  mixins: [AuthModalMixin]
  created: ->
    console.log "okokok"
    EventBus.$on('currentComponent', @setCurrentComponent)

  methods:
    setCurrentComponent: (options) ->
      title = _.truncate(options.title or @$t(options.titleKey), {length: 300})
      document.querySelector('title').text = _.compact([title, AppConfig.theme.site_name]).join(' | ')

      AppConfig.currentGroup      = options.group
      AppConfig.currentDiscussion = options.discussion
      AppConfig.currentPoll       = options.poll

      @openAuthModal() if @shouldForceSignIn(options)

      # scrollTo(options.scrollTo or 'h1') unless options.skipScroll
      # updateCover()

    shouldForceSignIn: (options = {}) ->
      # return false if options.page == "pollPage" and Session.user() !AbilityService.isEmailVerified()
      # return false if AbilityService.isEmailVerified()
      return false if AbilityService.isLoggedIn() && AppConfig.pendingIdentity.identity_type != "loomio"
      return true  if AppConfig.pendingIdentity.identity_type?

      switch options.page
        when 'emailSettingsPage' then !Session.user().restricted?
        when 'dashboardPage',      \
             'inboxPage',          \
             'profilePage',        \
             'authorizedAppsPage', \
             'registeredAppsPage', \
             'registeredAppPage',  \
             'pollsPage',          \
             'pollPage',           \
             'startPollPage',      \
             'upgradePage',        \
             'startGroupPage' then true


</script>

<template lang="pug">
v-app
  navbar
  sidebar
  v-content
    router-view(:key="$route.path")
  modal-launcher
</template>
