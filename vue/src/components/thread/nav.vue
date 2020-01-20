<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import { debounce, truncate, first, last, some, drop, min, compact } from 'lodash'

export default

  data: ->
    topDate: Date
    bottomDate: Date
    discussion: null
    open: null
    knobOffset: 0
    knobHeight: 32
    trackHeight: 400
    position: 1
    minUnitHeight: 24
    presets: []

  mounted: ->
    EventBus.$on 'toggleThreadNav', => @open = !@open

    EventBus.$on 'currentComponent', (options) =>
      @discussion = options.discussion
      return unless @discussion

      @watchRecords
        key: 'thread-nav'+@discussion.id
        collections: ["events", "discussions"]
        query: =>
          return unless @discussion
          @presets = Records.events.collection.chain()
            .find({pinned: true, discussionId: @discussion.id})
            .simplesort('position').data()
          @setHeight()
          if @discussion.newestFirst
            @topPosition = @childCount
            @topDate = @discussion.lastActivityAt

            @bottomPosition = 1
            @bottomDate = @discussion.createdAt
          else
            @topPosition = 1
            @topDate = @discussion.createdAt

            @bottomDate = @discussion.lastActivityAt
            @bottomPosition = @childCount

      # move this to activity panel.
      Records.events.fetch
        params:
          discussion_id: @discussion.id
          pinned: true
          per: 200

    EventBus.$on 'visibleSlots', (slots) =>
      unless slots.length == 0
        if @discussion && @discussion.newestFirst
          @position = last(slots) || 1
        else
          @position = first(slots) || 1
        @knobOffset = @offsetFor(@position)
        @knobHeight = @unitHeight * (last(slots) - first(slots) + 1)

  methods:
    setHeight: ->
      @trackHeight = 400
      while ((@minOffset() || @minUnitHeight) < @minUnitHeight) && (@trackHeight < 100000)
        @trackHeight = @trackHeight * 1.25

    minOffset: ->
      distances = [2..@presets.length].map (i) =>
        if @presets[i] && @presets[i-1]
          parseInt (@presets[i].position * @unitHeight) - (@presets[i-1].position * @unitHeight)
      min compact distances

    onTrackClicked: (event) ->
      @moveKnob(event)
      @goToPosition(@position)

    moveKnob: (event) ->
      event.preventDefault()
      event.stopImmediatePropagation()
      adjust = if @knobHeight < 64
           32
        else
          parseInt(@knobHeight / 2)

      @knobOffset = @getEventOffset(event)
      @position = @positionFor(@getEventOffset(event))

    getEventOffset: (event) ->
      # touch event structure differs from that of mouse event
      clientY = if event.touches
        event.touches[0].clientY
      else
        event.clientY

      offset = clientY - @$refs.slider.getBoundingClientRect().top
      if offset < 0
        0
      else if offset > @trackHeight
        @trackHeight
      else
        offset

    onMouseDown: ->
      onMouseMove = @moveKnob

      onMouseUp = =>
        document.removeEventListener 'mousemove', onMouseMove
        document.removeEventListener 'mouseup', onMouseUp
        @goToPosition(@position)

      document.addEventListener 'mousemove', onMouseMove
      document.addEventListener 'mouseup', onMouseUp

    onTouchStart: ->
      onTouchMove = @moveKnob

      onTouchEnd = =>
        document.removeEventListener 'touchmove', onTouchMove
        document.removeEventListener 'touchend', onTouchEnd
        @goToPosition(@position)

      document.addEventListener 'touchmove', onTouchMove, { passive: false }
      document.addEventListener 'touchend', onTouchEnd

    goToPosition: (position) ->
      unless (@$route.query && @$route.query.p == position)
        @$router.replace(query: {p: position}, params: {sequence_id: null, comment_id: null}).catch (err) => {}

    offsetFor: (position) ->
      if @discussion && @discussion.newestFirst
          @trackHeight - ((position) * @unitHeight)
        else
          (position - 1) * @unitHeight

    positionFor: (offset) ->
      return 1 unless @discussion
      position = parseInt(offset / @unitHeight) + 1
      position = if position < 1
          1
        else if position > @childCount
          @childCount
        else
          position

      if @discussion.newestFirst
        @childCount - position + 1
      else
        position

  watch:
    'discussion.newestFirst':
      immediate: true
      handler: ->
        return unless @discussion

  computed:
    unitHeight: ->
      @trackHeight / @childCount

    childCount: ->
      if @discussion
        @discussion.createdEvent().childCount
      else
        10

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select.thread-sidebar(v-if="discussion" v-model="open" :permanent="$vuetify.breakpoint.mdAndUp" width="230px" app fixed right clipped color="background" floating)
  a.thread-nav__date(:to="urlFor(discussion)" @click="scrollTo('#context')" v-t="'activity_card.context'")
  router-link.thread-nav__date(:to="{query:{p: topPosition}, params: {sequence_id: null}}") {{approximateDate(topDate)}}
  .thread-nav(:style="{height: trackHeight+'px'}")
    .thread-nav__track(ref="slider" :style="{height: trackHeight+'px'}" @click="onTrackClicked")
      .thread-nav__track-line
    .thread-nav__presets
      router-link.thread-nav__preset(v-for="event in presets" :key="event.id" :to="urlFor(event)" :style="{top: offsetFor(event.position)+'px'}")
        .thread-nav__preset--line
        .thread-nav__preset--title {{event.pinnedTitle || event.suggestedTitle()}}
    .thread-nav__knob(:style="{top: knobOffset+'px', height: knobHeight+'px'}" ref="knob" @mousedown="onMouseDown" v-touch:start="onTouchStart")
  router-link.thread-nav__date(:to="{query:{p: bottomPosition}, params: {sequence_id: null}}") {{approximateDate(bottomDate)}}
</template>

<style lang="sass">
.thread-nav
  position: relative

.thread-nav__date
  font-size: 12px
  display: block
  margin: 8px 8px
  // text-align: right
  color: var(--text-primary) !important

.thread-nav__preset
  display: flex
  position: absolute
  align-items: flex-start
  width: 220px

// .thread-nav__preset:last-child
//   margin-top: 4px
//   align-items: flex-end

.thread-nav__preset--title
  font-size: 12px
  margin-top: -10px
  white-space: nowrap
  overflow: hidden
  text-overflow: ellipsis

.thread-nav__preset--position
  font-size: 12px
  margin-top: -8px
  color: #bbb

.thread-nav__preset--title:hover
  overflow: visible !important
  white-space: normal !important
  // text-overflow: inherit
  // overflow: visible
  // white-space: normal
  background-color: #eee
  z-index: 1000

.thread-nav__preset--line
  height: 2px
  width: 18px
  min-width: 24px
  background-color: #aaa
  margin-right: 4px
  // margin-left: 10px
  // margin-left: 12px
  // margin-right: 8px
  // margin-left: 11px
  // left: 11px

.thread-nav__track
  position: absolute
  width: 24px
  cursor: pointer
  z-index: 1000

.thread-nav__track-line
  height: 100%
  position: absolute
  background-color: var(--v-accent-base)
  width: 2px
  margin: 0 11px

// 123456789012345678901234
// ------------------------ track 24
// -----------||----------- track-line 11 2 11
// --------########-------- knob 8 8 8
// ------############------ knob:hover 6 12 6
// ######################## preset-line 0 24 0

.thread-nav__knob
  position: absolute
  display: flex
  flex-direction: column
  width: 8px
  background-color: var(--v-accent-base)
  cursor: ns-resize
  border-radius: 4px
  transition: top 0.1s linear, height 0.3s linear
  margin: 0 8px
  z-index: 1001
  min-height: 16px

.thread-nav__knob:hover
  transition: none
  width: 12px
  margin: 0 6px

.disable-select
  user-select: none
  -webkit-user-select: none
  -khtml-user-select: none
  -moz-user-select: none
  -ms-user-select: none
</style>
