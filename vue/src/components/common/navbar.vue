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
    searchOpen: false
    activeTab: ''
    showTitle: true
    page: null
    searchQuery: ''
    search: null

  methods:
    toggleSidebar: -> EventBus.$emit 'toggleSidebar'
    toggleThreadNav: -> EventBus.$emit 'toggleThreadNav'
    signIn: -> @openAuthModal()
    last: last

  watch:
    '$route':
      immediate: true
      handler: (newVal, oldVal) ->
        if newVal.query.q
          @searchQuery = newVal.query.q
          @searchOpen = true
        else
          @searchQuery = ''

    searchQuery: debounce (val, old)->
      @$router.replace(query: {q: val, subgroups: @$route.query.subgroups})
    ,
      200


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

      @search = data.search

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
    coverImageSrc: ->
      if @group
        @group.coverUrl()
      else
        ''
    tabs: ->
      return unless @group
      query = ''
      query = '?subgroups='+@$route.query.subgroups if @$route.query.subgroups

      [
        {id: 0, name: 'threads',   route: @urlFor(@group, null)+query}
        {id: 1, name: 'polls',     route: @urlFor(@group, 'polls')+query},
        {id: 2, name: 'members',   route: @urlFor(@group, 'members')+query},
        {id: 4, name: 'files',     route: @urlFor(@group, 'files')+query}
        {id: 5, name: 'settings',  route: @urlFor(@group, 'settings')}
      ].filter (obj) => !(obj.name == "subgroups" && @group.isSubgroup())

    logo: ->
      AppConfig.theme.app_logo_src
    icon: ->
      AppConfig.theme.icon_src
</script>

<template lang="pug">
v-app-bar(app clipped-right prominent dark color="accent" elevate-on-scroll shrink-on-scroll :src="coverImageSrc")
  template(v-slot:img="{ props }")
    v-img(v-bind="props" gradient="rgba(0,0,0,.3), rgba(0,0,0, .3), rgba(0,0,0,.8)")

  v-btn.navbar__sidenav-toggle(icon @click="toggleSidebar()")
    v-avatar(tile size="36px")
      v-icon mdi-menu

  template(v-if="groupPage" v-slot:extension)
    v-layout(align-center)
      v-tabs(background-color="transparent" v-model="activeTab" show-arrows)
        v-tab(v-for="tab of tabs" :key="tab.id" :to="tab.route" :class="'group-page-' + tab.name + '-tab' " exact)
          span(v-t="'group_page.'+tab.name")
      join-group-button(v-if="groupPage" :group='group')
      //- group-actions-dropdown(v-if="groupPage" :group='group')

  v-text-field(v-if="search && searchOpen" solo autofocus v-model="searchQuery" append-icon='mdi-close' @click:append="searchOpen = false; searchQuery = ''" :placeholder="search.placeholder")

  v-toolbar-title(v-if="!searchOpen && groupPage")
    span {{group.name}}
    //- group-privacy-button(v-if="groupPage" :group='group')

  v-toolbar-title(v-if="!searchOpen && showTitle && !groupPage" @click="$vuetify.goTo('head', {duration: 0})") {{title}}

  v-spacer(v-if="!searchOpen")
  v-btn(icon v-if="search && !searchOpen" @click="searchOpen = true")
    v-icon mdi-magnify

  notifications(v-if='isLoggedIn')
  v-toolbar-items
    v-btn.navbar__sign-in(text v-if='!isLoggedIn' v-t="'navbar.sign_in'" @click='signIn()')
</template>
