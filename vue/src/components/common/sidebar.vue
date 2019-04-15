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

import _isUndefined from 'lodash/isUndefined'
import _sortBy from 'lodash/sortBy'
import _filter from 'lodash/filter'
import _find from 'lodash/find'
import _head from 'lodash/head'

export default
  mixins: [
    GroupModalMixin,
    DiscussionModalMixin
  ]
  data: ->
    currentState: ""
    showSidebar: null
    isGroupModalOpen: false
    isThreadModalOpen: false

  created: ->
    InboxService.load()
    EventBus.$on 'toggleSidebar', (event, show) =>
      console.log "toggling #{@showSidebar}"
      @showSidebar = !@showSidebar

  computed:
    orderedGroups: ->
      _sortBy @groups(), 'fullName'

  methods:
    availableGroups: ->
      _filter Session.user().groups(), (group) => group.type == 'FormalGroup'

    currentGroup: ->
      return _head(@availableGroups()) if @availableGroups().length == 1
      _find(@availableGroups(), (g) => g.id == (AppConfig.currentGroup or {}).id) || Records.groups.build()

    onPage: (page, key, filter) ->
      switch page
        when 'groupPage' then @currentState.key == key
        when 'dashboardPage' then @currentState.page == page && @currentState.filter == filter
        else @currentState.page == page

    groupUrl: (group) ->
      LmoUrlService.group(group)

    unreadThreadCount: ->
      InboxService.unreadCount()

    canLockSidebar: ->
      true

    sidebarItemSelected: ->
      $mdSidenav('left').close() if !@canLockSidebar()

    groups: ->
      _filter Session.user().groups().concat(Session.user().orphanParents()), (group) =>
        group.type == "FormalGroup"

    currentUser: ->
      Session.user()

    canViewPublicGroups: -> AbilityService.canViewPublicGroups()

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print(app, dark, width="250", v-model="showSidebar")
  v-list
    v-list-tile.sidebar__list-item-button--decisions(to='/polls')
      v-list-tile-action
        v-icon mdi-thumbs-up-down
      v-list-tile-content
        v-list-tile-title(v-t="'common.decisions'")
    v-list-tile.sidebar__list-item-button--recent(to='/dashboard')
      v-list-tile-action
        v-icon mdi-forum
      v-list-tile-content
        v-list-tile-title(v-t="'sidebar.recent_threads'")
    v-list-tile.sidebar__list-item-button--unread(to='/inbox')
      v-list-tile-action
        v-icon mdi-inbox
      v-list-tile-content
        v-list-tile-title(v-t="{ path: 'sidebar.unread_threads', args: { count: unreadThreadCount() } }")
    v-list-tile.sidebar__list-item-button--muted(to='/dashboard/show_muted')
      v-list-tile-action
        v-icon mdi-volume-mute
      v-list-tile-content
        v-list-tile-title(v-t="'sidebar.muted_threads'")
    v-list-tile.sidebar__list-item-button--start-thread(v-if='canStartThreads()', @click='openStartDiscussionModal(currentGroup().id)')
      v-list-tile-action
        v-icon mdi-plus
      v-list-tile-content
        v-list-tile-title(v-t="'sidebar.start_thread'")
  v-divider.sidebar__divider
  v-list
    div(v-for='group in orderedGroups', :key='group.id')
      v-list-tile(:to='groupUrl(group)', v-if='group.isParent()')
        v-list-tile-action
          img.md-avatar.lmo-box--tiny.sidebar__list-item-group-logo(:src='group.logoUrl()')
        v-list-tile-content
          v-list-tile-title {{group.name}}
      v-list-tile(:to='groupUrl(group)', v-if='!group.isParent()')
        v-list-tile-action
          img.md-avatar.lmo-box--tiny.sidebar__list-item-group-logo(:src='group.logoUrl()')
        v-list-tile-content
          v-list-tile-title {{group.name}}
    v-list-tile.sidebar__list-item-button--start-group(v-if="canStartGroup()", @click="openStartGroupModal()")
      v-list-tile-action
        v-icon mdi-plus
      v-list-tile-content
        span(v-t="'sidebar.start_group'")
</template>
