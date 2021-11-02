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
    items: []
    visibleKeys: []
    baseUrl: ''

  computed:
    selectedSequenceId: -> parseInt(@$route.params.sequence_id)
    selectedCommentId: -> parseInt(@$route.params.comment_id)

  methods:
    buildItems: (bootData) ->
      itemsHash = {}

      @baseUrl = @urlFor(@discussion)
      # parser = new DOMParser()
      # doc = parser.parseFromString(@context, 'text/html')
      # headings = Array.from(doc.querySelectorAll('h1,h2,h3')).map (el) =>
      #   {id: el.id, name: el.textContent}
      bootData.forEach (row) =>
        # row indexes
        # 0 positionKey,
        # 1 sequenceId,
        # 2 createdAt,
        # 3 userId,
        # 4 depth,
        # 5 descendantCount
        itemsHash[row[0]] =
          key: row[0]
          title: null
          headings: []
          sequenceId: row[1]
          createdAt: row[2]
          actorId: row[3]
          visible: false
          depth: row[4]
          descendantCount: row[5]
          unread: @loader.sequenceIdIsUnread(row[1])
          poll: null
          stance: null
          visible: @visibleKeys.includes(row[0])

      Records.events.collection.chain()
             .find({discussionId: @discussion.id})
             .simplesort('positionKey', @discussion.newestFirst)
             .data().forEach (event) =>
        if event.kind == "poll_created"
          poll = event.model().poll()

        itemsHash[event.positionKey] =
          key: event.positionKey
          commentId: if event.eventableType == 'Comment' then event.eventableId else null
          sequenceId: event.sequenceId
          createdAt: event.createdAt
          actorId: event.actorId
          title: if event.pinned then (event.pinnedTitle || event.fillPinnedTitle()) else null
          visible: false
          unread: @loader.sequenceIdIsUnread(event.sequenceId)
          headings: []
          depth: event.depth
          descendantCount: event.descendantCount
          visible: @visibleKeys.includes(event.positionKey)
          poll: poll
          stance: (poll && poll.myStance()) || null

      itemsArray = Object.values(itemsHash)

      if @discussion.newestFirst
        newItems = []
        parentIndexes = []

        itemsArray.forEach (item, index) =>
          parentIndexes.push index if item.depth == 1

        parentIndexes.reverse()

        parentIndexes.forEach (index) =>
          item = itemsArray[index]
          slice = itemsArray.slice(index, index + item.descendantCount + 1)
          Array.prototype.push.apply(newItems, slice)

        @items = newItems
      else
        @items = itemsArray

      createdEvent = @discussion.createdEvent()
      @items.unshift
        key: createdEvent.positionKey
        title: @$t('activity_card.context')
        headings: []
        sequenceId: 0
        visible: @visibleKeys.includes(createdEvent.positionKey)
        unread: false
        event: createdEvent
        poll: null
        stance: null
        depth: 1
        descendantCount: 0

  mounted: ->
    EventBus.$on 'toggleThreadNav', => @open = !@open

    Records.events.fetch
      params:
        exclude_types: 'group discussion'
        discussion_id: @discussion.id
        pinned: true
        per: 200

    bootData = []
    Records.events.remote.fetch
      path: 'timeline'
      params:
        discussion_id: @discussion.id
    .then (data) =>
      bootData = data
      @buildItems bootData

    @watchRecords
      key: 'thread-nav'+@discussion.id
      collections: ["events", "discussions"]
      query: =>
        @buildItems(bootData) if bootData.length

    EventBus.$on 'visibleKeys', (keys) =>
      @visibleKeys = keys
      @items.forEach (item) =>
        item.visible = @visibleKeys.includes(item.key)

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.thread-sidebar(v-if="discussion" v-model="open" :permanent="$vuetify.breakpoint.mdAndUp" width="230px" app fixed right clipped color="background" floating)
  div.mt-12
  div.strand-nav__toc
    //- | {{items}}
    router-link.strand-nav__entry.text-caption(
      :class="{'strand-nav__entry--visible': item.visible, 'strand-nav__entry--selected': (item.sequenceId == selectedSequenceId || item.commentId == selectedCommentId), 'strand-nav__entry--unread': item.unread}"
      v-for="item in items"
      :key="item.key"
      :to="baseUrl+'/'+item.sequenceId")
        .strand-nav__stance-icon-container(v-if="item.poll")
          poll-common-icon-panel.poll-proposal-chart-panel__chart.mr-1(:poll="item.poll" show-my-stance :size="18" :stanceSize="12")
        //- span {{item.key}}
        span {{item.title}}
</template>

<style lang="sass">
.strand-nav__stance-icon-container
  display: inline-block

.strand-nav__toc
  display: flex
  flex-direction: column
  min-height: 70%

.strand-nav__entry
  display: block
  flex-grow: 1
  border-left: 2px solid #eee
  padding-left: 8px
  padding-right: 8px
  margin-left: 8px
  min-height: 1px

.strand-nav__entry--unread
  border-color: var(--v-accent-lighten1)!important

.strand-nav__entry--selected
  border-color: var(--v-primary-darken1)!important
// .strand-nav__entry--visible
//   border-color: var(--v-primary-darken1)!important

.strand-nav__entry:hover
  border-color: var(--v-primary-darken1)!important

.theme--dark
  .strand-nav__entry:hover, .strand-nav__entry--visible
    background-color: #222

.theme--light
  .strand-nav__entry:hover, .strand-nav__entry--visible
    background-color: #f8f8f8

</style>
