<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import {marked} from '@/shared/helpers/marked.coffee'
import { each, debounce, truncate, first, last, some, drop, min, compact, without, sortedUniq } from 'lodash'

export default
  props:
    discussion: Object
    loader: Object

  data: ->
    open: null
    items: {}
    visibleKeys: []
    bootData: []
    baseUrl: ''

  methods:
    buildItems: ->
      @items = {}

      @baseUrl = @urlFor(@discussion)
      # parser = new DOMParser()
      # doc = parser.parseFromString(@context, 'text/html')
      # headings = Array.from(doc.querySelectorAll('h1,h2,h3')).map (el) =>
      #   {id: el.id, name: el.textContent}
      @$set @items, @discussion.createdEvent().positionKey,
        title: @$t('activity_card.context')
        headings: []
        sequenceId: 0
        visible: false
        unread: false
        event: @discussion.createdEvent()
        poll: null
        stance: null

      @bootData.forEach (row) =>
        # row: 0 positionKey, 1 sequenceId, 2 createdAt, 3 userId
        @$set @items, row[0],
          title: null
          headings: []
          sequenceId: row[1]
          createdAt: row[2]
          actorId: row[3]
          visible: false
          unread: @loader.sequenceIdIsUnread(row[1])
          poll: null
          stance: null

      Records.events.collection.chain()
             .find({discussionId: @discussion.id, pinned: true})
             .simplesort('positionKey')
             .data().forEach (event) =>
        @$set @items, event.positionKey,
          sequenceId: event.sequenceId
          createdAt: event.createdAt
          actorId: event.actorId
          title: event.pinnedTitle || event.fillPinnedTitle()
          visible: false
          unread: @loader.sequenceIdIsUnread(event.sequenceId)
          poll: null
          stance: null
          headings: []

        if event.kind == "poll_created"
          poll = event.model().poll()
          @items[event.positionKey].poll = poll
          @items[event.positionKey].stance = poll.myStance()

      @visibleKeys.forEach (key) =>
        @items[key].visible = true if @items[key]

  mounted: ->
    EventBus.$on 'toggleThreadNav', => @open = !@open

    Records.events.fetch
      params:
        exclude_types: 'group discussion'
        discussion_id: @discussion.id
        pinned: true
        per: 200

    Records.events.remote.fetch
      path: 'timeline'
      params:
        discussion_id: @discussion.id
    .then (data) =>
      @bootData = data
      @buildItems()

    @watchRecords
      key: 'thread-nav'+@discussion.id
      collections: ["events", "discussions"]
      query: => @buildItems()

    EventBus.$on 'visibleKeys', (keys) =>
      @visibleKeys = keys
      Object.keys(@items).forEach (key) =>
        @items[key].visible = false
      @visibleKeys.forEach (key) =>
        @items[key].visible = true if @items[key]

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.thread-sidebar(v-if="discussion" v-model="open" :permanent="$vuetify.breakpoint.mdAndUp" width="230px" app fixed right clipped color="background" floating)
  div.mt-12
  div.strand-nav__toc
    router-link.strand-nav__entry.text-caption(
      :class="{'strand-nav__entry--visible': item.visible, 'strand-nav__entry--unread': item.unread}"
      v-for="item, key in items"
      :key="key"
      :to="baseUrl+'/'+item.sequenceId")
        .strand-nav__stance-icon-container(v-if="item.poll")
          poll-common-icon-panel.poll-proposal-chart-panel__chart.mr-1(:poll="item.poll" show-my-stance :size="18" :stanceSize="12")
          //- poll-common-stance-icon.thread-nav__stance-icon(:poll="item.poll" :stance="item.stance" :size='18')
        span {{item.title}}
</template>

<style lang="sass">
.strand-nav__stance-icon-container
  display: inline-block

.strand-nav__toc
  display: flex
  flex-direction: column
  height: 70%

.strand-nav__entry
  display: block
  flex-grow: 1
  border-left: 2px solid #eee
  padding-left: 4px
  padding-right: 4px

.strand-nav__entry--unread
  border-color: var(--v-accent-lighten1)!important

.strand-nav__entry--visible
  border-color: var(--v-primary-darken1)!important

.strand-nav__entry:hover
  border-color: var(--v-primary-darken1)!important
//
// .strand-nav__entry:hover::before

</style>
