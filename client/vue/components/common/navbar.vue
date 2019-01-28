<script lang="coffee">
AppConfig      = require 'shared/services/app_config'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

module.exports =
  data: ->
    title: AppConfig.theme.site_name

  mounted: ->
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

    isLoggedIn: ->
      AbilityService.isLoggedIn()

</script>

<template lang="pug">
  v-toolbar(app)
    //- v-toolbar-side-icon
    v-btn(icon)
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
      v-btn(flat v-t="'navbar.sign_in'")
    //- .navbar__left
    //-   v-toolbar-side-icon.navbar__sidenav-toggle(v-show='isLoggedIn()', @click='toggleSidebar()', aria-label="$t('navbar.toggle_sidebar')")
    //-     v-icon mdi-menu
    //- .navbar__middle.lmo-flex.lmo-flex__horizontal-center
    //-   router-link.lmo-pointer(to='/dashboard')
    //-     img(:src='logo()')
    //- .navbar__right
    //-   .lmo-flex--row(v-if='isLoggedIn()')
    //-     //
    //-       <navbar_search></navbar_search>
    //-       <notifications></notifications>
    //-       <user_dropdown></user_dropdown>
    //-   v-btn.md-primary.md-raised.navbar__sign-in(v-if='!isLoggedIn()', @click='signIn()')
    //-     span(v-t="'navbar.sign_in'")
</template>

<style lang="scss">
// @import '~settings/elevations';
@import 'variables';

.lmo-navbar {
  .navbar__logo-bg {
    background-repeat: no-repeat;
    background-position: center;
    background-size: auto 32px;
  }

  .md-toolbar-tools {
    background-color: #fff;
    // box-shadow: elevation(4dp)$whiteframe-shadow-4dp;

    max-height: 48px;
    justify-content: space-between;
  }

  .md-sidenav-left.md-closed, md-sidenav.md-closed {
    box-shadow: none;
  }

  .md-toolbar-tools a { color: $primary-text-color; }

  .navbar__left, .navbar__right {
    display: flex;
    align-items: center;
    flex-grow: 0;
  }
  .navbar__middle{
    flex-grow: 1;
    height: 100%;
    a, img { height: 100%; }
    img { padding: 8px; }
  }

  .navbar__left {
    justify-content: flex-start;
  }
  .navbar__right {
    justify-content: flex-end;
  }

  .navbar__sidenav-toggle {
    cursor: pointer;
    color: black;
    margin-right: 16px;
  }
  .navbar__logo {
    height: 30px;
  }

  @media (max-width: $tiny-max-px) {
    .navbar__middle { display: none; }
    .navbar__right { flex-grow: 1; }
  }
}
</style>
