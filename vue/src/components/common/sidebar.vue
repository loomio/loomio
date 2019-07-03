<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import InboxService   from '@/shared/services/inbox_service'
import GroupModalMixin from '@/mixins/group_modal.coffee'
import DiscussionModalMixin from '@/mixins/discussion_modal.coffee'
import WatchRecords from '@/mixins/watch_records'

import { isUndefined, sortBy, filter, find, head, uniq, map, compact, concat } from 'lodash'

export default
  mixins: [
    GroupModalMixin,
    DiscussionModalMixin,
    WatchRecords
  ]

  data: ->
    groups: []
    open: null
    version: AppConfig.version.split('.').slice(-1)[0]

  created: ->
    EventBus.$on 'toggleSidebar', => @open = !@open

    @watchRecords
      collections: ['groups', 'memberships']
      query: (store) =>
        groups = Session.user().formalGroups()
        parentGroups = uniq compact concat(groups, map(groups, (group) -> group.parent()))
        @groups = sortBy parentGroups, 'fullName'

    InboxService.load()

  watch:
    open: (val) ->
      EventBus.$emit("sidebarOpen", val)

  methods:
    availableGroups: -> Session.user().formalGroups()

    currentGroup: ->
      return head(@availableGroups()) if @availableGroups().length == 1
      find(@availableGroups(), (g) => g.id == (AppConfig.currentGroup or {}).id) || Records.groups.build()

    groupUrl: (group) ->
      LmoUrlService.group(group)

    unreadThreadCount: ->
      InboxService.unreadCount()

    canViewPublicGroups: -> AbilityService.canViewPublicGroups()

  computed:
    user: -> Session.user()
    siteName: -> AppConfig.theme.site_name
    logoUrl: -> AppConfig.theme.app_logo_src

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.sidenav-left(app width="250" v-model="open")
  v-toolbar
    img(style="height: 50%" :src="logoUrl" :alt="siteName")
    v-spacer
    .caption
      a(href="/beta") beta {{version}}
    v-btn.navbar__sidenav-toggle(icon @click="open = !open")
      v-avatar(tile size="36px")
        v-icon mdi-menu
  v-list
    v-expansion-panels(accordion :elevation="0")
      v-expansion-panel
        v-expansion-panel-header
          v-layout.sidebar__user-dropdown
            user-avatar.mr-2(:user="user" size="medium")
            v-flex
              .body-2 {{user.name}}
              .body-2 @{{user.username}}
        v-expansion-panel-content
          user-dropdown
    v-list-item.sidebar__list-item-button--recent(shaped to='/dashboard')
      v-list-item-avatar
        v-icon mdi-forum
      v-list-item-content
        v-list-item-title(v-t="'sidebar.recent_threads'")
    v-list-item.sidebar__list-item-button--unread(to='/inbox')
      v-list-item-avatar
        v-icon mdi-inbox
      v-list-item-content
        v-list-item-title(v-t="{ path: 'sidebar.unread_threads', args: { count: unreadThreadCount() } }")
    v-list-item.sidebar__list-item-button--muted(to='/dashboard/show_muted')
      v-list-item-avatar
        v-icon mdi-volume-mute
      v-list-item-content
        v-list-item-title(v-t="'sidebar.muted_threads'")
    v-list-item.sidebar__list-item-button--decisions(to='/polls')
      v-list-item-avatar
        v-icon mdi-thumbs-up-down
      v-list-item-content
        v-list-item-title(v-t="'common.decisions'")
    v-list-item.sidebar__list-item-button--start-thread(v-if='canStartThreads()', @click='openStartDiscussionModal(currentGroup())')
      v-list-item-avatar
        v-icon mdi-plus
      v-list-item-content
        v-list-item-title(v-t="'sidebar.start_thread'")
    v-divider.sidebar__divider
    div.sidebar__groups(v-for='group in groups', :key='group.id')
      v-list-item(:to='groupUrl(group)', v-if='group.isParent()')
        v-list-item-avatar(tile)
          v-avatar(tile size="28px")
            img.sidebar__list-item-group-logo(:src='group.logoUrl()')
        v-list-item-content
          v-list-item-title.font-weight-medium {{group.name}}
      v-list-item(:to='groupUrl(group)', v-if='!group.isParent()')
        v-list-item-avatar
        v-list-item-content
          v-list-item-title.body-2 {{group.name}}
    v-list-item.sidebar__list-item-button--start-group(v-if="canStartGroup()", @click="openStartGroupModal()")
      v-list-item-action
        v-icon mdi-plus
      v-list-item-content
        span(v-t="'sidebar.start_group'")
</template>
