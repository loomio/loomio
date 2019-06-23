<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import AuthModalMixin from '@/mixins/auth_modal'
import Session        from '@/shared/services/session'
import UrlFor         from '@/mixins/url_for'
import {tail, map, last}         from 'lodash'

export default
  mixins: [ AuthModalMixin, UrlFor ]
  data: ->
    title: AppConfig.theme.site_name
    isLoggedIn: Session.isSignedIn()
    group: null
    breadcrumbs: null
    sidebarOpen: false

  methods:
    toggleSidebar: -> EventBus.$emit 'toggleSidebar'
    toggleThreadNav: -> EventBus.$emit 'toggleThreadNav'
    signIn: -> @openAuthModal()
    last: last


  mounted: ->
    EventBus.$on 'sidebarOpen', (val) =>
      @sidebarOpen = val

    EventBus.$on 'signedIn', (user) =>
      @isLoggedIn = true

    EventBus.$on 'currentComponent', (data) =>
      if data.title?
        @title = data.title
      else if data.titleKey?
        @title = @$t(data.titleKey)

      @group = data.group
      @discussion = data.discussion
      @breadcrumbs = data.breadcrumbs

      if data.breadcrumbs
        if data.breadcrumbs[0].isA?('group')
          @group = data.breadcrumbs[0]
          if data.breadcrumbs.length > 1
            data.breadcrumbs = tail(@breadcrumbs)

        @breadcrumbs = map data.breadcrumbs, (model, i) =>
          i: i
          text: model.title || model.name
          to: @urlFor(model)
        last(@breadcrumbs).last = true
        @title = last(@breadcrumbs).text

  computed:
    logo: ->
      AppConfig.theme.app_logo_src
    icon: ->
      AppConfig.theme.icon_src
</script>

<template lang="pug">
v-app-bar(app)
  v-btn.navbar__sidenav-toggle(icon v-if="!sidebarOpen" @click="toggleSidebar()")
    v-avatar(tile size="36px")
      v-icon mdi-menu
  v-btn.navbar__group-toggle(icon v-if="group" :to="urlFor(group)")
    v-avatar(tile size="36px")
      img(:src='group.logoUrlMedium')
  v-toolbar-title
    span(v-if="breadcrumbs" v-for="crumb in breadcrumbs" :key="crumb.i")
      router-link(v-if="!crumb.last" :to="crumb.to") {{crumb.text}}
      span(v-if="crumb.last") {{crumb.text}}
      span(v-if="!crumb.last")
        | &nbsp;
        | &gt;
        | &nbsp;
    span(v-if="!breadcrumbs") {{title}}
  //- v-spacer
  notifications(v-if='isLoggedIn')
  v-toolbar-items
    v-btn.navbar__sign-in(text v-if='!isLoggedIn' v-t="'navbar.sign_in'" @click='signIn()')
</template>
