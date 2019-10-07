<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import AuthModalMixin from '@/mixins/auth_modal'
import EventBus from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import { each, compact, truncate } from 'lodash'

export default
  mixins: [AuthModalMixin]
  data: ->
    pageError: null

  created: ->
    Session.updateLocale(@$route.query.locale) if @$route.query.locale

    each AppConfig.theme.vuetify, (value, key) =>
      @$vuetify.theme.themes.light[key] = value if value
      true

  mounted: ->
    @openAuthModal() if !Session.isSignedIn() && @shouldForceSignIn()
    EventBus.$on('currentComponent', @setCurrentComponent)
    EventBus.$on 'pageError', (error) =>
      @openAuthModal() if !Session.isSignedIn() and error.status == 403
      @pageError = error
    EventBus.$on 'signedIn', =>
      @pageError = null

  watch:
    '$route': ->
      @pageError = null

  methods:
    setCurrentComponent: (options) ->
      @pageError = null
      title = truncate(options.title or @$t(options.titleKey), {length: 300})
      document.querySelector('title').text = compact([title, AppConfig.theme.site_name]).join(' | ')

      AppConfig.currentGroup      = options.group
      AppConfig.currentDiscussion = options.discussion
      AppConfig.currentPoll       = options.poll

    shouldForceSignIn: (options = {}) ->
      # return false if options.page == "pollPage" and Session.user() !AbilityService.isEmailVerified()
      # return false if AbilityService.isEmailVerified()
      return false if Session.isSignedIn() && AppConfig.pendingIdentity.identity_type != "loomio"
      return true  if AppConfig.pendingIdentity.identity_type?

      switch @$route.path
        when '/email_preferences' then !Session.user().restricted?
        when '/dashboard',      \
             '/inbox',          \
             '/profile',        \
             '/polls',          \
             '/p/new',      \
             '/g/new' then true
      # switch options.page
      #   when 'emailSettingsPage' then !Session.user().restricted?
      #   when 'dashboardPage',      \
      #        'inboxPage',          \
      #        'profilePage',        \
      #        'authorizedAppsPage', \
      #        'registeredAppsPage', \
      #        'registeredAppPage',  \
      #        'pollsPage',          \
      #        'pollPage',           \
      #        'startPollPage',      \
      #        'upgradePage',        \
      #        'startGroupPage' then true


</script>

<template lang="pug">
v-app
  navbar
  sidebar
  v-content.pb-12
    router-view(v-if="!pageError")
    common-error(v-if="pageError" :error="pageError")
    v-spacer
  common-footer
  thread-nav
  modal-launcher
  common-flash
</template>

<style lang="sass">
$mdi-font-path: '/fonts/mdi'
@import '@mdi/font/scss/materialdesignicons.scss'

a
  text-decoration: none

.text-almost-black
  color: rgba(0, 0, 0, 0.87)

.max-width-800
  max-width: 800px
.max-width-1024
  max-width: 1024px

</style>
