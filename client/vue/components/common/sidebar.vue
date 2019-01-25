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
    # EventBus.listen @, 'toggleSidebar', (event, show) =>
    #   if !_isUndefined(show)
    #     @showSidebar = show
    #   else
    #     @showSidebar = !@showSidebar
    #
    # EventBus.listen @, 'currentComponent', (el, component) =>
    #   @currentState = component
  computed:
    orderedGroups: ->
      _sortBy @groups(), 'fullName'
  methods:
    canStartThreads: ->
      _some Session.user().groups(), (group) => AbilityService.canStartThread(group)

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

<template>
  <v-navigation-drawer app permanent role="navigation" md-component-id="left" :md-is-open="showSidebar" :md-is-locked-open="canLockSidebar() && showSidebar" md-whiteframe="4" aria-label="$t('sidebar.aria_labels.heading')" aria-hidden="!showSidebar" class="md-sidenav-left lmo-no-print">
    <div md_content layout="column" @click="sidebarItemSelected()" role="navigation" class="sidebar__content lmo-no-print">
      <v-divider class="sidebar__divider"></v-divider>
      <v-list layout="column" aria-label="$t('sidebar.aria_labels.threads_list')" class="sidebar__list sidebar__threads">
        <router-link to="/polls">
          <v-list-tile aria-label="$t('sidebar.my_decisions')" :class="{'sidebar__list-item--selected': onPage('pollsPage')}" class="sidebar__list-item-button sidebar__list-item-button--decisions">
            <v-list-tile-action class="sidebar__list-item-icon mdi mdi-thumbs-up-down"></v-list-tile-action>
            <span v-t="'common.decisions'"></span>
          </v-list-tile>
        </router-link>
        <router-link to="/dashboard">
          <v-list-tile aria-label="$t('sidebar.recent')" :class="{'sidebar__list-item--selected': onPage('dashboardPage')}" class="sidebar__list-item-button sidebar__list-item-button--recent">
            <i class="sidebar__list-item-icon mdi mdi-forum"></i>
            <span v-t="'sidebar.recent_threads'"></span>
          </v-list-tile>
        </router-link>
        <router-link to="/inbox">
          <v-list-tile aria-label="$t('sidebar.unread')" :class="{'sidebar__list-item--selected': onPage('inboxPage')}" class="sidebar__list-item-button sidebar__list-item-button--unread">
            <i class="sidebar__list-item-icon mdi mdi-inbox"></i>
            <span v-t="{ path: 'sidebar.unread_threads', args: { count: unreadThreadCount() } }"></span>
          </v-list-tile>
        </router-link>
        <router-link to="/dashboard/show_muted">
          <v-list-tile aria-label="$t('sidebar.muted')" :class="{'sidebar__list-item--selected': onPage('dashboardPage', null, 'show_muted')}" class="sidebar__list-item-button sidebar__list-item-button--muted">
            <i class="sidebar__list-item-icon mdi mdi-volume-mute"></i>
            <span v-t="'sidebar.muted_threads'"></span>
          </v-list-tile>
        </router-link>
        <v-list-tile v-if="canStartThreads()" @click="openThreadModal()" aria-label="$t('sidebar.start_thread')" class="sidebar__list-item-button sidebar__list-item-button--start-thread">
          <i class="sidebar__list-item-icon mdi mdi-plus"></i>
          <span v-t="'sidebar.start_thread'"></span>
        </v-list-tile>
        <v-dialog
          v-model="isThreadModalOpen"
          lazy
        >
          <discussion-start :discussion="newThread()" :close="closeThreadModal"></discussion-start>
        </v-dialog>
      </v-list>
      <v-divider class="sidebar__divider"></v-divider>
      <v-list-tile v-t="'common.groups'" class="sidebar__list-subhead"></v-list-tile>
      <v-list :class="{'sidebar__no-groups': groups().length < 1}" aria-label="$t('sidebar.aria_labels.groups_list')" class="sidebar__list sidebar__groups">
        <div v-for="group in orderedGroups" :key="group.id">
          <router-link :to="groupUrl(group)" v-if="group.isParent()">
            <v-list-tile :aria-label="group.name" :class="{'sidebar__list-item--selected': onPage('groupPage', group.key)}" class="sidebar__list-item-button sidebar__list-item-button--group">
              <img :src="group.logoUrl()" class="md-avatar lmo-box--tiny sidebar__list-item-group-logo">
              <span>{{group.name}}</span>
            </v-list-tile>
          </router-link>
          <router-link :to="groupUrl(group)" v-if="!group.isParent()" >
            <v-list-tile :class="{'sidebar__list-item--selected': onPage('groupPage', group.key)}" class="sidebar__list-item-button--subgroup lmo-flex">{{group.name}}</v-list-tile>
          </router-link>
          <div class="sidebar__list-item-padding"></div>
        </div>
        <router-link v-if="canViewPublicGroups()" to="/explore">
          <v-list-tile aria-label="$t('sidebar.explore')" :class="{'sidebar__list-item--selected': onPage('explorePage')}" class="sidebar__list-item-button sidebar__list-item-button--explore">
            <i class="sidebar__list-item-icon mdi mdi-earth"></i>
            <span v-t="'sidebar.explore'"></span>
          </v-list-tile>
        </router-link>
        <v-list-tile v-if="canStartGroup()" @click="openGroupModal()" aria-label="$t('sidebar.start_group')" class="sidebar__list-item-button sidebar__list-item-button--start-group">
          <i class="sidebar__list-item-icon mdi mdi-plus"></i>
          <span v-t="'sidebar.start_group'"></span>
        </v-list-tile>
        <v-dialog
          v-model="isGroupModalOpen"
          lazy
        >
          <group-start :group="newGroup()"></group-start>
        </v-dialog>
      </v-list>
    </div>
  </v-navigation-drawer>
</template>

<style>
</style>
