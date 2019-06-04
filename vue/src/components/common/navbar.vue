<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import AuthModalMixin from '@/mixins/auth_modal'
import Session        from '@/shared/services/session'

export default
  mixins: [ AuthModalMixin ]
  data: ->
    title: AppConfig.theme.site_name
    isLoggedIn: Session.isSignedIn()
  methods:
    toggleSidebar: -> EventBus.$emit 'toggleSidebar'
    signIn: -> @openAuthModal()
  mounted: ->
    EventBus.$on 'signedIn', (user) =>
      @isLoggedIn = true
    EventBus.$on 'currentComponent', (data) =>
      console.log "currentComponent set", data
      if data.title?
        @title = data.title
      else if data.titleKey?
        @title = @$t(data.titleKey)
  computed:
    logo: ->
      AppConfig.theme.app_logo_src
    icon: ->
      AppConfig.theme.icon_src
</script>

<template lang="pug">
  v-toolbar(app)
    //- v-toolbar-side-icon
    .navbar__left
      v-btn.navbar__sidenav-toggle(icon, @click="toggleSidebar()")
        v-avatar(tile size="36px")
          img(:src='icon')
    v-toolbar-title {{title}}
    v-spacer
    .navbar__right
      v-toolbar-items(v-if='isLoggedIn')
        v-btn(icon)
          v-icon mdi-magnify
        notifications
        user-dropdown
      v-toolbar-items(v-if='!isLoggedIn')
        v-btn.navbar__sign-in(flat v-t="'navbar.sign_in'" @click='signIn()')
</template>
