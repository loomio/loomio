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
    v-btn(icon, @click="toggleSidebar()")
      v-avatar(tile size="36px")
        img(:src='icon')
    v-toolbar-title {{title}}
    v-spacer
    v-toolbar-items(v-if='isLoggedIn')
      v-btn(icon)
        v-icon mdi-magnify
      //- v-btn(icon)
      //-   v-icon mdi-bell
      //- | hello
      notifications
      user-dropdown
      //- v-btn(icon)
      //-   v-icon mdi-dots-vertical
    v-toolbar-items(v-if='!isLoggedIn')
      v-btn.navbar__sign-in(flat v-t="'navbar.sign_in'" @click='signIn()')
    //- .navbar__left
    //-   v-toolbar-side-icon.navbar__sidenav-toggle(v-show='isLoggedIn()', @click='toggleSidebar()', aria-label="$t('navbar.toggle_sidebar')")
    //-     v-icon mdi-menu
    //- .navbar__middle.lmo-flex.lmo-flex__horizontal-center
    //-   router-link.lmo-pointer(to='/dashboard')
    //-     img(:src='logo')
    //- .navbar__right
    //-   .lmo-flex--row(v-if='isLoggedIn')
    //-     user-dropdown
          //- <navbar_search></navbar_search>
          //- <notifications></notifications>
      v-btn.md-primary.md-raised.navbar__sign-in(v-if='!isLoggedIn', @click='signIn()')
        span(v-t="'navbar.sign_in'")
</template>
