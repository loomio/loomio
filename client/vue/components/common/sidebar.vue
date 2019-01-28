<script lang="coffee">
AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
LmoUrlService  = require 'shared/services/lmo_url_service'
InboxService   = require 'shared/services/inbox_service'
ModalService   = require 'shared/services/modal_service'

_isUndefined = require 'lodash/isUndefined'
_sortBy = require 'lodash/sortBy'
_some = require 'lodash/some'
_filter = require 'lodash/filter'
_find = require 'lodash/find'
_head = require 'lodash/head'

module.exports =
  data: ->
    currentState: ""
    showSidebar: true
    isGroupModalOpen: false
    isThreadModalOpen: false

  created: ->
    InboxService.load()
    EventBus.$on 'toggleSidebar', (event, show) =>
      console.log "toggling"
      @showSidebar = !@showSidebar

  computed:
    orderedGroups: ->
      _sortBy @groups(), 'fullName'

  methods:
    canStartThreads: ->
      Session.user().id &&
      _some(Session.user().groups(), (group) => AbilityService.canStartThread(group))

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
      # $mdMedia("gt-sm")

    sidebarItemSelected: ->
      $mdSidenav('left').close() if !@canLockSidebar()

    groups: ->
      _filter Session.user().groups().concat(Session.user().orphanParents()), (group) =>
        group.type == "FormalGroup"

    currentUser: ->
      Session.user()

    canStartGroup: -> AbilityService.canStartGroups()
    canViewPublicGroups: -> AbilityService.canViewPublicGroups()

    openGroupModal: ->
      @isGroupModalOpen = true

    openThreadModal: ->
      @isThreadModalOpen = true
    closeThreadModal: ->
      @isThreadModalOpen = false

    newGroup: ->
      Records.groups.build()

    newThread: ->
      Records.discussions.build(groupId: @currentGroup().id)

    # startThread: ->
    #   ModalService.open 'DiscussionStartModal', discussion: => Records.discussions.build(groupId: @currentGroup().id)
</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print(app, permanent, dark, width="250", v-model="showSidebar")
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
    v-list-tile.sidebar__list-item-button--start-thread(v-if='canStartThreads()', @click='openThreadModal()')
      v-list-tile-action
        v-icon mdi-plus
      v-list-tile-content
        v-list-tile-title(v-t="'sidebar.start_thread'")
  v-dialog(v-model='isThreadModalOpen' lazy persistent)
    discussion-start(:discussion='newThread()', :close='closeThreadModal')
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
</template>
