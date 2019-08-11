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
    search: ''

  methods:
    toggleSidebar: -> EventBus.$emit 'toggleSidebar'
    toggleThreadNav: -> EventBus.$emit 'toggleThreadNav'
    signIn: -> @openAuthModal()
    last: last

  watch:
    search: debounce (val, old)->
      @$router.replace(query: {q: val})
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

      @group = data.group
      @discussion = data.discussion
      @page = data.page


  computed:
    searchPath: ->
      page = last(@$route.path.split('/'))
      pages ='polls members subgroups files'.split(' ')
      if pages.includes(page)
        "navbar.search_#{page}"
      else
        "navbar.search_threads"

    groupName: -> @group.name
    parentName: -> @group.parentOrSelf().name
    groupPage: -> @page == 'groupPage'
    threadPage: -> @page == 'threadPage'
    coverImageSrc: ->
      if @group
        @group.coverUrl()
      else
        ''
    tabs: ->
      return unless @group
      [
        {id: 0, name: 'threads',   route: @urlFor(@group)}
        {id: 1, name: 'polls',     route: @urlFor(@group, 'polls')},
        {id: 2, name: 'members',   route: @urlFor(@group, 'members')},
        # {id: 3, name: 'subgroups', route: @urlFor(@group, 'subgroups')},
        {id: 4, name: 'files',     route: @urlFor(@group, 'files')}
      ].filter (obj) => !(obj.name == "subgroups" && @group.isSubgroup())

    logo: ->
      AppConfig.theme.app_logo_src
    icon: ->
      AppConfig.theme.icon_src
</script>

<template lang="pug">
v-app-bar(app clipped-right prominent dark color="accent" elevate-on-scroll shrink-on-scroll :src="coverImageSrc")
  template(v-slot:img="{ props }")
    v-img(v-bind="props" gradient="to top right, rgba(19,84,122,.3), rgba(128,208,199,.5)")

  v-btn.navbar__sidenav-toggle(icon v-if="!sidebarOpen" @click="toggleSidebar()")
    v-avatar(tile size="36px")
      v-icon mdi-menu

  template(v-if="groupPage" v-slot:extension)
    v-layout(align-center)
      v-tabs(background-color="transparent" v-model="activeTab" show-arrows)
        v-tab(v-for="tab of tabs" :key="tab.id" :to="tab.route" :class="'group-page-' + tab.name + '-tab' " exact)
          span(v-t="'group_page.'+tab.name")
      join-group-button(v-if="groupPage" :group='group')
      group-privacy-button(v-if="groupPage" :group='group')
      group-actions-dropdown(v-if="groupPage" :group='group')

  v-text-field(v-if="searchOpen" solo autofocus v-model="search" append-icon='mdi-close' @click:append="searchOpen = false; search = ''" :placeholder="$t(searchPath, {name: parentName})")

  v-toolbar-title.d-flex.align-center(v-if="!searchOpen && groupPage") {{group.name}}

  v-toolbar-title(v-if="!searchOpen && threadPage" @click="$vuetify.goTo('head')") {{title}}

  v-spacer(v-if="!searchOpen")
  v-btn(icon v-if="!searchOpen" @click="searchOpen = true")
    v-icon mdi-magnify

  notifications(v-if='isLoggedIn')
  v-toolbar-items
    v-btn.navbar__sign-in(text v-if='!isLoggedIn' v-t="'navbar.sign_in'" @click='signIn()')
</template>
