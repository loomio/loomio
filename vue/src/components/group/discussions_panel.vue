<script lang="coffee">
import Records            from '@/shared/services/records'
import AbilityService     from '@/shared/services/ability_service'
import EventBus           from '@/shared/services/event_bus'
import RecordLoader       from '@/shared/services/record_loader'
import PageLoader         from '@/shared/services/page_loader'
import { map, debounce, orderBy, intersection, compact, omit, filter, concat, uniq} from 'lodash'
import Session from '@/shared/services/session'

export default
  created: ->
    @onQueryInput = debounce (val) =>
      @$router.replace(@mergeQuery(q: val))
    , 1000
    @init()
    EventBus.$on 'signedIn', @init

  beforeDestroy: ->
    EventBus.$off 'signedIn', @init

  data: ->
    group: null
    discussions: []
    loader: null
    groupIds: []
    per: 25
    dummyQuery: null

  methods:
    routeQuery: (o) ->
      @$router.replace(@mergeQuery(o))

    beforeDestroy: ->
      EventBus.$off 'joinedGroup'

    init: ->
      Records.groups.findOrFetch(@$route.params.key).then (group) =>
        @group = group

        EventBus.$emit 'currentComponent',
          page: 'groupPage'
          title: @group.name
          group: @group
          search:
            placeholder: @$t('navbar.search_threads', name: @group.parentOrSelf().name)

        EventBus.$on 'joinedGroup', (group) => @fetch()

        @refresh()

        @watchRecords
          key: @group.id
          collections: ['discussions', 'groups', 'memberships']
          query: => @query()

    refresh: ->
      @loader = new PageLoader
        path: 'discussions'
        order: 'lastActivityAt'
        params:
          group_id: @group.id
          exclude_types: 'group outcome poll'
          filter: @$route.query.t
          subgroups: @$route.query.subgroups || 'mine'
          tags: @$route.query.tag
          per: @per

      @fetch()
      @query()

    query: ->
      return unless @group
      @publicGroupIds = @group.publicOrganisationIds()

      @groupIds = switch (@$route.query.subgroups || 'mine')
        when 'mine' then uniq(concat(intersection(@group.organisationIds(), Session.user().groupIds()), @publicGroupIds, @group.id))
        when 'all' then @group.organisationIds()
        else [@group.id]

      chain = Records.discussions.collection.chain()
      chain = chain.find(discardedAt: null)
      chain = chain.find(groupId: {$in: @groupIds})

      switch @$route.query.t
        when 'unread'
          chain = chain.where (discussion) -> discussion.isUnread()
        when 'closed'
          chain = chain.find(closedAt: {$ne: null})
        when 'templates'
          chain = chain.find(template: true)
        when 'all'
          true # noop
        else
          chain = chain.find(closedAt: null)

      if @$route.query.tag
        tag = Records.tags.find(groupId: @group.parentOrSelf().id, name: @$route.query.tag)[0]
        chain = chain.find({tagIds: {'$contains': tag.id}})

      if @loader.pageWindow[@page]
        if @page == 1
          chain = chain.find(lastActivityAt: {$gte: @loader.pageWindow[@page][0]})
        else
          chain = chain.find(lastActivityAt: {$jbetween: @loader.pageWindow[@page]})
        @discussions = chain.simplesort('lastActivityAt', true).data()
      else
        @discussions = []

    fetch: ->
      @loader.fetch(@page).then( => @query())

    filterName: (filter) ->
      switch filter
        when 'unread' then 'discussions_panel.unread'
        when 'all' then 'discussions_panel.all'
        when 'closed' then 'discussions_panel.closed'
        when 'subscribed' then 'change_volume_form.simple.loud'
        else
          'discussions_panel.open'

    openSearchModal: ->
      initialOrgId = null
      initialGroupId = null
      
      if @group.isParent()
        initialOrgId = @group.id
      else
        initialOrgId = @group.parentId
        initialGroupId = @group.id

      EventBus.$emit 'openModal',
        component: 'SearchModal'
        persistent: false
        maxWidth: 900
        props:
          initialOrgId: initialOrgId
          initialGroupId: initialGroupId
          initialQuery: @dummyQuery

  watch:
    '$route.params': 'init'
    '$route.query': 'refresh'
    'page' : ->
      @fetch()
      @query()

  computed:
    page:
      get: -> parseInt(@$route.query.page) || 1
      set: (val) ->
        @$router.replace({query: Object.assign({}, @$route.query, {page: val})}) 

    totalPages: ->
      Math.ceil(parseFloat(@loader.total) / parseFloat(@per))

    pinnedDiscussions: ->
      orderBy(@discussions.filter((discussion) -> discussion.pinnedAt), ['pinnedAt'], ['desc'])

    regularDiscussions: ->
      orderBy(@discussions.filter((discussion) -> !discussion.pinnedAt), ['lastActivityAt'], ['desc'])

    groupTags: ->
      @group && @group.tags().filter (tag) -> tag.taggingsCount > 0

    loading: ->
      @loader.loading

    noThreads: ->
      !@loading && @discussions.length == 0

    canViewPrivateContent: ->
      AbilityService.canViewPrivateContent(@group)

    canStartThread: ->
      AbilityService.canStartThread(@group)

    isLoggedIn: ->
      Session.isSignedIn()

    unreadCount: ->
      filter(@discussions, (discussion) -> discussion.isUnread()).length

    suggestClosedThreads: ->
      ['undefined', 'open', 'unread'].includes(String(@$route.query.t)) && @group && @group.closedDiscussionsCount

</script>

<template lang="pug">
div.discussions-panel(v-if="group")
  v-layout.py-3(align-center wrap)
    v-menu
      template(v-slot:activator="{ on, attrs }")
        v-btn.mr-2.text-lowercase.discussions-panel__filters(v-on="on" v-bind="attrs" text)
          span(v-t="{path: filterName($route.query.t), args: {count: unreadCount}}")
          v-icon mdi-menu-down
      v-list
        v-list-item.discussions-panel__filters-open(@click="routeQuery({t: null})")
          v-list-item-title(v-t="'discussions_panel.open'")
        v-list-item.discussions-panel__filters-all(@click="routeQuery({t: 'all'})")
          v-list-item-title(v-t="'discussions_panel.all'")
        v-list-item.discussions-panel__filters-closed(@click="routeQuery({t: 'closed'})")
          v-list-item-title(v-t="'discussions_panel.closed'")
        v-list-item.discussions-panel__filters-unread(@click="routeQuery({t: 'unread'})")
          v-list-item-title(v-t="{path: 'discussions_panel.unread', args: { count: unreadCount }}")

    v-menu(offset-y)
      template(v-slot:activator="{ on, attrs }")
        v-btn.mr-2.text-lowercase(v-on="on" v-bind="attrs" text)
          span(v-if="$route.query.tag") {{$route.query.tag}}
          span(v-else v-t="'loomio_tags.tags'")
          v-icon mdi-menu-down
      v-sheet.pa-1
        tags-display(:tags="group.tagNames()" :group="group" :show-counts="!!group.parentId" :show-org-counts="!group.parentId")
    v-text-field.mr-2.flex-grow-1(
      v-model="dummyQuery"
      clearable solo hide-details
      @click="openSearchModal"
      @change="openSearchModal"
      @keyup.enter="openSearchModal"
      @click:append="openSearchModal"
      :placeholder="$t('navbar.search_threads', {name: group.name})"
      append-icon="mdi-magnify")
    v-btn.discussions-panel__new-thread-button(
      v-if='canStartThread'
      v-t="'navbar.start_thread'"
      :to="'/thread_templates/?group_id='+group.id"
      color='primary')

  v-alert(color="info" text outlined v-if="group.discussionsCount == 0")
    v-card-title(v-t="'discussions_panel.welcome_to_your_new_group'")
    p.px-4(v-t="'discussions_panel.lets_start_a_thread'")

  v-card.discussions-panel(v-else outlined)
    div(v-if="loader.status == 403")
      p.pa-4.text-center(v-t="'error_page.forbidden'")
    div(v-else)
      .discussions-panel__content
        .discussions-panel__list--empty.pa-4(v-if='noThreads')
          p.text-center(v-if='canViewPrivateContent' v-t="'group_page.no_threads_here'")
          p.text-center(v-if='!canViewPrivateContent' v-t="'group_page.private_threads'")
        .discussions-panel__list.thread-preview-collection__container(v-if="discussions.length")
          v-list.thread-previews(two-line)
            thread-preview(:show-group-name="groupIds.length > 1" v-for="thread in pinnedDiscussions", :key="thread.id", :thread="thread" group-page)
            thread-preview(:show-group-name="groupIds.length > 1" v-for="thread in regularDiscussions", :key="thread.id", :thread="thread" group-page)

        loading(v-if="loading && discussions.length == 0")

        v-pagination(v-model="page", :length="totalPages", :total-visible="7", :disabled="totalPages == 1")
        .d-flex.justify-center
          router-link.discussions-panel__view-closed-threads.text-center.pa-1(:to="'?t=closed'" v-if="suggestClosedThreads" v-t="'group_page.view_closed_threads'")

</template>

<style lang="sass">
.overflow-x-auto
  overflow-x: auto
</style>
