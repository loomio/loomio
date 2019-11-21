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

import { isUndefined, sortBy, filter, find, head, uniq, map, sum, compact, concat, intersection, difference, orderBy } from 'lodash'

export default
  mixins: [ GroupModalMixin, DiscussionModalMixin, ]

  data: ->
    organization: null
    open: false
    group: null
    version: AppConfig.version.split('.').slice(-1)[0]
    tree: []
    myGroups: []
    otherGroups: []
    organizations: []
    unreadCounts: {}
    expandedGroupIds: []

  created: ->
    EventBus.$on 'toggleSidebar', => @open = !@open

    EventBus.$on 'currentComponent', (data) =>
      @open = Session.isSignedIn() && Session.user().experiences['sidebar'] || false
      @group = data.group
      if @group
        @organization = data.group.parentOrSelf()
        @expandedGroupIds = [@organization.id]
      else
        @organization = null

    @watchRecords
      collections: ['groups', 'memberships', 'discussions']
      query: (store) => @updateGroups()

    EventBus.$on 'signedIn', (user) =>
      @fetchData()
      @open = Session.user().experiences['sidebar'] || false

    @fetchData() if Session.isSignedIn()

  watch:
    organization: 'updateGroups'

    open: (val) ->
      EventBus.$emit("sidebarOpen", val)

  methods:
    fetchData: ->
      Records.users.fetchGroups().then =>
        if @$router.history.current.path == "/dashboard" && Session.user().membershipsCount == 1
          @$router.replace("/g/#{Session.user().memberships()[0].group().key}")

      InboxService.load()

    unreadCountFor: (group, isOpen) ->
      if !isOpen
        (@unreadCounts[group.id] || 0) + sum(compact(group.subgroups().map((g) => @unreadCounts[g.id])))
      else
        @unreadCounts[group.id] || 0

    updateGroups: ->
      @organizations = compact(Session.user().parentGroups().concat(Session.user().orphanParents()))
      @unreadCounts = {}
      Session.user().formalGroups().forEach (group) =>
        @unreadCounts[group.id] = filter(group.discussions(), (discussion) -> discussion.isUnread()).length

      groupAsItem = (group) ->
        id: group.id
        name: group.name
        group: group
        member: Session.user().membershipFor(group)?
        children: if group.subgroups
          orderBy(group.subgroups().map(groupAsItem), ['member', 'name'], ['desc', 'asc'])
        else
          []

      @tree = orderBy( @organizations.map((group) -> groupAsItem(group)), ['name'], ['asc'])

    startOrganization: ->
      @canStartGroup() && @openStartGroupModal()

    unreadThreadCount: ->
      InboxService.unreadCount()

    canViewPublicGroups: -> AbilityService.canViewPublicGroups()

  computed:
    user: -> Session.user()
    activeGroup: -> if @group then [@group.id] else []
    logoUrl: -> AppConfig.theme.app_logo_src

</script>

<template lang="pug">
v-navigation-drawer.sidenav-left.lmo-no-print(app disable-resize-watcher v-model="open")
  template(v-slot:prepend)
  template(v-slot:append)
    div.text-center
      a(href="/dashboard?old_client=1" v-t="'vue_upgraded_modal.use_old_loomio'")
    v-layout.ma-2(style="width: 50%")
      v-img(:src="logoUrl")
      v-layout(align-center)
        span.ml-4 {{version}}

  v-list-group.sidebar__user-dropdown
    template(v-slot:activator)
      v-list-item-content
        v-list-item-title {{user.name}}
        v-list-item-subtitle {{user.email}}
    user-dropdown
  v-divider
  v-list-item.sidebar__list-item-button--recent(dense to="/dashboard")
    v-list-item-title(v-t="'sidebar.recent_threads'")
  v-list-item(dense to="/inbox")
    v-list-item-title(v-t="{ path: 'sidebar.unread_threads', args: { count: unreadThreadCount() } }")
  v-divider

  v-treeview.sidebar__groups(hoverable dense :items="tree" :active="activeGroup" :open="expandedGroupIds" style="width: 100%")
    template(v-slot:append="{item, open}")
      div(v-if="item.click")
        v-icon(v-if="item.icon" @click="item.click") {{item.icon}}
    template(v-slot:prepend="{item, open}")
      router-link(v-if="!item.click" :to="urlFor(item.group)")
        group-avatar(:group="item.group"  v-if="item.group.isParent()")
    template(v-slot:label="{item, open}")
      div(v-if="item.click")
        a.body-2.sidebar-item.text-almost-black(text @click="item.click" :class="{ 'sidebar-start-subgroup': item.isStartSubgroupButton }") {{item.name}}
      router-link(v-if="!item.click" :to="urlFor(item.group)")
        span.body-2.sidebar-item.text-almost-black
          span {{item.group.name}}
          span(v-if='unreadCountFor(item.group, open)')
            space
            span ({{unreadCountFor(item.group, open)}})

  v-list-item.sidebar__list-item-button--start-group(@click="startOrganization()" dense)
    v-list-item-title(v-t="'sidebar.start_group'")
    v-list-item-avatar(:size="28")
      v-icon(:size="28" tile) mdi-plus
  v-divider
  v-list-item(dense to="/explore")
    v-list-item-title(v-t="'sidebar.explore_groups'")
</template>
<style lang="sass">
.sidebar-item
	display: block
	width: 100%

</style>
