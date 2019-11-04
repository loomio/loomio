<script lang="coffee">
import AppConfig           from '@/shared/services/app_config'
import EventBus            from '@/shared/services/event_bus'
import AbilityService      from '@/shared/services/ability_service'
import AuthModalMixin      from '@/mixins/auth_modal'
import Session             from '@/shared/services/session'
import {tail, map, last, debounce}   from 'lodash'

export default
  mixins: [ AuthModalMixin ]
  data: ->
    title: AppConfig.theme.site_name
    isLoggedIn: Session.isSignedIn()
    group: null
    breadcrumbs: null
    sidebarOpen: false
    activeTab: ''
    showTitle: true
    page: null

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

    EventBus.$on 'content-title-visible', (val) =>
      @showTitle = !val

    EventBus.$on 'currentComponent', (data) =>
      if data.title?
        @title = data.title
      else if data.titleKey?
        @title = @$t(data.titleKey)

      @group = data.group
      @discussion = data.discussion
      @page = data.page

  computed:
    groupName: ->
      return unless @group
      @group.name
    parentName: ->
      return unless @group
      @group.parentOrSelf().name
    groupPage: -> @page == 'groupPage'
    threadPage: -> @page == 'threadPage'
    logo: ->
      AppConfig.theme.app_logo_src
    icon: ->
      AppConfig.theme.icon_src
</script>

<template lang="pug">
v-app-bar(app clipped-right elevate-on-scroll color="background")
  //- template(v-slot:img="{ props }")
  //-   v-img(v-bind="props" gradient="rgba(0,0,0,.3), rgba(0,0,0, .3), rgba(0,0,0,.8)")

  v-btn.navbar__sidenav-toggle(icon @click="toggleSidebar()")
    v-avatar(tile size="36px")
      v-icon mdi-menu


  //- v-toolbar-title.group-cover-name(v-if="groupPage")
  //-   span {{group.name}}

  v-toolbar-title(v-if="showTitle" @click="$vuetify.goTo('head', {duration: 0})") {{title}}
  v-spacer
  notifications(v-if='isLoggedIn')
  v-toolbar-items
  v-btn.navbar__sign-in(text v-if='!isLoggedIn' v-t="'navbar.sign_in'" @click='signIn()')
</template>
