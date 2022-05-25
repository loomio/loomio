<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import AuthModalMixin from '@/mixins/auth_modal'
import EventBus from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import Flash from '@/shared/services/flash'
import { each, compact, truncate } from 'lodash'
import openModal from '@/shared/helpers/open_modal'
import { initLiveUpdate, closeLiveUpdate } from '@/shared/helpers/message_bus'
import CustomCss from '@/components/custom_css'

export default
  components: {CustomCss}
  mixins: [AuthModalMixin]
  data: ->
    pageError: null

  created: ->
    Session.updateLocale(@$route.query.locale) if @$route.query.locale

    if Session.user().experiences.darkMode?
      @$vuetify.theme.dark = Session.user().experiences['darkMode']
    else
      @$vuetify.theme.dark = (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches)

    each AppConfig.theme.vuetify, (value, key) =>
      @$vuetify.theme.themes.light[key] = value if value
      @$vuetify.theme.themes.dark[key] = value if value
      true

  mounted: ->
    initLiveUpdate()
    @openAuthModal(true) if !Session.isSignedIn() && @shouldForceSignIn()
    EventBus.$on 'currentComponent',     @setCurrentComponent
    EventBus.$on 'openAuthModal',     => @openAuthModal()
    EventBus.$on 'pageError', (error) => @pageError = error
    EventBus.$on 'signedIn',          => @pageError = null
    EventBus.$on 'VueForceUpdate',    => 
      @$nextTick =>
        console.log("forceupdate")
        @$forceUpdate()
    Flash.success(AppConfig.flash.notice) if AppConfig.flash.notice

  destroyed: ->
    closeLiveUpdate()

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
      return true if @$route.query.sign_in
      return true if (AppConfig.pendingIdentity || {}).identity_type?
      return false if Session.isSignedIn()

      switch @$route.path
        when '/email_preferences' then !Session.user().restricted?
        when '/dashboard',      \
             '/inbox',          \
             '/profile',        \
             '/polls',          \
             '/p/new',      \
             '/g/new' then true

</script>

<template lang="pug">
v-app.app-is-booted
  system-notice
  navbar
  sidebar
  router-view(v-if="!pageError")
  common-error(v-if="pageError" :error="pageError")
  v-spacer
  common-footer
  modal-launcher
  common-flash
</template>

<style lang="sass">

// .strand-page [id]::before
//   content: ''
//   display: block
//   height:      72px
//   margin-top: -72px
//   visibility: hidden

.v-application .body-2
  font-size: 15px !important
  letter-spacing: normal !important

h1:focus, h2:focus, h3:focus, h4:focus, h5:focus, h6:focus
  outline: 0
a
  text-decoration: none

.text-almost-black
  color: rgba(0, 0, 0, 0.87)

.max-width-640
  max-width: 640px
.max-width-800
  max-width: 800px
.max-width-1024
  max-width: 1024px

@media (prefers-color-scheme: dark)
  body
    background-color: #000

@media print
  .lmo-no-print
    display: none !important

/* roboto-300 - latin
@font-face
  font-family: 'Roboto'
  font-style: normal
  font-weight: 300
  src: local(""), url('/fonts/roboto-v29-latin-300.woff2') format("woff2")

/* roboto-regular - latin
@font-face
  font-family: 'Roboto'
  font-style: normal
  font-weight: 400
  src: local(""), url('/fonts/roboto-v29-latin-regular.woff2') format("woff2")

/* roboto-italic - latin
@font-face
  font-family: 'Roboto'
  font-style: italic
  font-weight: 400
  src: local(""), url('/fonts/roboto-v29-latin-italic.woff2') format("woff2")

/* roboto-500 - latin
@font-face
  font-family: 'Roboto'
  font-style: normal
  font-weight: 500
  src: local(""), url('/fonts/roboto-v29-latin-500.woff2') format("woff2")

/* roboto-700 - latin
@font-face
  font-family: 'Roboto'
  font-style: normal
  font-weight: 700
  src: local(""), url('/fonts/roboto-v29-latin-700.woff2') format("woff2")

/* roboto-mono-regular - latin
@font-face
  font-family: 'Roboto Mono'
  font-style: normal
  font-weight: 400
  src: local(""), url('/fonts/roboto-mono-v13-latin-regular.woff2') format("woff2")
</style>
