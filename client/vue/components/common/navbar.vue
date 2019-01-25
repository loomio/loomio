<script lang="coffee">
AppConfig      = require 'shared/services/app_config'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

module.exports =
  props:
  data: ->
  methods:
    toggleSidebar: ->
      # EventBus.broadcast $rootScope, 'toggleSidebar'

    signIn: ->
      ModalService.open 'AuthModal'
  computed:
    logo: ->
      AppConfig.theme.app_logo_src

    isLoggedIn: ->
      AbilityService.isLoggedIn()
</script>

<template>
  <v-toolbar app>
    <div class="md-toolbar-tools">
      <div class="navbar__left">
        <v-toolbar-side-icon v-show="isLoggedIn()" @click="toggleSidebar()" aria-label="$t('navbar.toggle_sidebar')" class="navbar__sidenav-toggle">
          <!-- <i class="mdi mdi-menu"></i> -->
        </v-toolbar-side-icon>
      </div>
      <div class="navbar__middle lmo-flex lmo-flex__horizontal-center">
        <router-link to="/dashboard" class="lmo-pointer">
          <img :src="logo()">
        </router-link>
      </div>
      <div class="navbar__right">
        <div v-if="isLoggedIn()" class="lmo-flex--row">
          <!-- <navbar_search></navbar_search>
          <notifications></notifications>
          <user_dropdown></user_dropdown> -->
        </div>
        <v-btn v-if="!isLoggedIn()" @click="signIn()" class="md-primary md-raised navbar__sign-in">
          <span v-t="'navbar.sign_in'"></span>
        </v-btn>
      </div>
    </div>
  </v-toolbar>
</template>

<style lang="scss">
@import '~settings/elevations';
@import 'variables';

.lmo-navbar {
  .navbar__logo-bg {
    background-repeat: no-repeat;
    background-position: center;
    background-size: auto 32px;
  }

  .md-toolbar-tools {
    background-color: #fff;
    box-shadow: elevation(4dp)$whiteframe-shadow-4dp;

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
