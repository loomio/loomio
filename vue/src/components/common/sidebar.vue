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

import { isUndefined, sortBy, filter, find, head, uniq, map, compact, concat, intersection, difference } from 'lodash'

export default
  mixins: [
    GroupModalMixin,
    DiscussionModalMixin,
    WatchRecords
  ]

  data: ->
    organization: null
    open: null
    group: null
    version: AppConfig.version.split('.').slice(-1)[0]
    myGroups: []
    organizations: []
    unreadCounts: {}

  created: ->
    EventBus.$on 'toggleSidebar', => @open = !@open

    EventBus.$on 'currentComponent', (data) =>
      @group = data.group
      if @group
        @organization = data.group.parentOrSelf()
      else
        @organization = null

    @watchRecords
      collections: ['groups', 'memberships']
      query: (store) =>
        @organizations = Session.user().parentGroups().concat(Session.user().orphanParents())

        if @group
          @myGroups = intersection Session.user().formalGroups(), @organization.subgroups()

    @watchRecords
      collections: ['groups', 'discussions']
      query: (store) =>
        return unless @organization
        @unreadCounts = {}
        @myGroups.forEach (group) =>
          @unreadCounts[group.id] = filter(group.discussions(), (discussion) -> discussion.isUnread()).length
        @unreadCounts[@organization.id] = filter(@organization.discussions(), (discussion) -> discussion.isUnread()).length

    InboxService.load()

  watch:
    open: (val) ->
      EventBus.$emit("sidebarOpen", val)

    '$route': ->
      console.log '$route', @$route


  methods:
    unreadThreadCount: ->
      InboxService.unreadCount()

    canViewPublicGroups: -> AbilityService.canViewPublicGroups()

  computed:
    user: -> Session.user()
    canStartSubGroup: -> true

</script>

<template lang="pug">
v-navigation-drawer.sidenav-left(app v-model="open")

  v-layout(fill-height)
    v-navigation-drawer(stateless mini-variant mini-variant-width="56" :value="open")
      v-list-item(to="/dashboard")
        v-list-item-avatar(:size="28")
          user-avatar(no-link :user="user" v-on="on")
      v-list-item(v-for='group in organizations' :key='group.id' :to='urlFor(group)' dense)
        v-list-item-avatar(size="28px")
          v-tooltip
            template(v-slot:activator="{ on }")
              v-avatar(tile size="28px" v-on="on")
                img.sidebar__list-item-group-logo(:src='group.logoUrl()')
            span {{group.name}}
      v-list-item
        v-list-item-avatar(:size="28")
          v-icon(:size="28" tile) mdi-plus

    v-navigation-drawer(stateless v-if="!organization" :value="open")
      v-list-item(dense)
        v-list-item-content
          v-list-item-title {{user.name}}
          v-list-item-subtitle {{user.email}}
      v-divider
      v-list-item(dense to="/dashboard")
        v-list-item-title(v-t="'sidebar.recent_threads'")
      v-list-item(dense to="/inbox")
        v-list-item-title(v-t="{ path: 'sidebar.unread_threads', args: { count: unreadThreadCount() } }")
      v-divider
      user-dropdown

    v-navigation-drawer(stateless v-if="organization" :value="open")
      v-list-item.sidebar__list-item-button--recent(dense exact :to='urlFor(organization)')
        v-list-item-title(v-if="unreadCounts[organization.id]") {{organization.name}} ({{ unreadCounts[organization.id] }})
        v-list-item-title(v-if="!unreadCounts[organization.id]") {{organization.name}}
      div(v-if="myGroups.length > 0")
        v-divider
        v-list-item.sidebar__list-item-button--recent(dense exact :to='urlFor(organization, null, {subgroups: "mine"})')
          v-list-item-title(v-t="'sidebar.my_groups'")
        v-list-item(dense v-for="group in myGroups" :key="group.id" :to="urlFor(group)")
          v-list-item-title(v-if="unreadCounts[group.id]") {{ group.name }} ({{ unreadCounts[group.id] }})
          v-list-item-title(v-if="!unreadCounts[group.id]") {{ group.name }}
      v-divider
      v-list-item.sidebar__list-item-button--recent(dense exact :to="urlFor(organization, 'subgroups')")
        v-list-item-title(v-t="'sidebar.more_groups'")

      div(v-if="organization.subscriptionPlan == 'trial'")
        v-divider
        v-subheader(v-t="'plan_names.trial'")
        v-list-item(href="/upgrade" dense)
          v-list-item-title(v-t="'current_plan_button.upgrade'")
          v-list-item-icon
            v-icon(color="primary") mdi-rocket
      v-divider
      v-list-item(href="/beta" dense)
        v-list-item-title Loomio 2 - beta {{version}}
</template>
