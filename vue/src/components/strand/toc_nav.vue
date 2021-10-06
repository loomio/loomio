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
    initialKeys: []

  methods:
    buildItems: ->
      console.log "building items"
      @items = {}

      # parser = new DOMParser()
      # doc = parser.parseFromString(@context, 'text/html')
      # headings = Array.from(doc.querySelectorAll('h1,h2,h3')).map (el) =>
      #   {id: el.id, name: el.textContent}
      @$set @items, @discussion.createdEvent().positionKey,
        title: @$t('activity_card.context')
        # headings: headings
        href: @urlFor(@discussion)+"#context"
        visible: false
        unread: false

      @initialKeys.forEach (key) =>
        @$set @items, key,
          title: null
          href: "?k=#{key}"
          visible: false
          unread: false

      Records.events.collection.chain()
             .find({discussionId: @discussion.id})
             .simplesort('positionKey')
             .data().forEach (event) =>
        @$set @items, event.positionKey,
          title: event.pinned && (event.pinnedTitle || event.fillPinnedTitle()) || null
          headings: {}
          href: @urlFor(@discussion)+"/#{event.sequenceId}"
          visible: false
          unread: @loader.isUnread(event)
          event: event
          #
          # eventable: event.model()
          # stance:

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
      path: 'position_keys'
      params:
        discussion_id: @discussion.id
    .then (data) =>
      @initialKeys = data.position_keys
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

  router-link.strand-nav__entry.text-caption(
    :class="{'strand-nav__entry--visible': item.visible && !item.unread, 'strand-nav__entry--unread': item.unread}"
    v-for="item, key in items"
    :key="key"
    :to="item.href") {{item.title}}
    //- .thread-nav__stance-icon-container(v-if="item.model().isA('poll') && event.model().iCanVote()")
    //-   poll-common-stance-icon.thread-nav__stance-icon(:poll="event.model()" :stance="event.model().myStance()" :size='18')
    //- span.text-caption {{item.href}}
</template>

<style lang="sass">
.strand-nav__entry
  display: block
  min-height: 2px
  border-left: 2px solid grey
  padding-left: 2px

.strand-nav__entry--unread
  border-left: 3px solid orange
  border-color: var(--v-primary-base)!important

.strand-nav__entry--visible
  border-left: 3px solid blue
  border-color: var(--v-primary-accent)!important

.strand-nav__entry:hover
  border-left: 2px solid red
  background-color: #eee

</style>
