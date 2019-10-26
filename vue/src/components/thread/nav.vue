<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import { debounce, truncate, first, last } from 'lodash'
import { approximate, timeline } from '@/shared/helpers/format_time'

export default
  mixins: [ChangeVolumeModalMixin]

  data: ->
    topDate: Date
    bottomDate: Date
    discussion: null
    open: null
    knobOffset: 0
    knobHeight: 32
    trackHeight: 400
    position: 1
    unitHeight: 1
    presets: []

  mounted: ->
    EventBus.$on 'currentComponent', (options) =>
      @discussion = options.discussion
      return unless @discussion

      if @discussion.newestFirst
        @topPosition = @discussion.createdEvent().childCount
        @topDate = @discussion.lastActivityAt

        @bottomPosition = 1
        @bottomDate = @discussion.createdAt
      else
        @topPosition = 1
        @topDate = @discussion.createdAt

        @bottomDate = @discussion.lastActivityAt
        @bottomPosition = @discussion.createdEvent().childCount

      @watchRecords
        key: 'thread-nav'+@discussion.id
        collections: ["events"]
        query: =>
          return unless @discussion
          @presets = Records.events.collection.chain()
            .find({pinned: true, parentId: @discussion.createdEvent().id})
            .simplesort('position').data().map (event) =>
              position: event.position
              title: @title(event.model())

      # move this to activity panel.
      Records.events.fetch
        params:
          discussion_id: @discussion.id
          pinned: true
          per: 200

    EventBus.$on 'visibleSlots', (slots) =>
      unless slots.length == 0 && @discussion
        if @discussion.newestFirst
          @position = last(slots) || 1
        else
          @position = first(slots) || 1

        @trackHeight = 400
        @unitHeight = @trackHeight / @discussion.createdEvent().childCount
        @knobOffset = @offsetFor(@position)
        @knobHeight = @unitHeight * (last(slots) - first(slots) + 1)

        # console.log 'knob position, offset, height. unit height', @position, @knobOffset, @knobHeight, @unitHeight
        # console.log 'visibleSlots', slots

  methods:
    title: (model) ->
      if model.title or model.statement
        (model.title || model.statement || model.body).replace(///<[^>]*>?///gm, '')
      else
        parser = new DOMParser()
        doc = parser.parseFromString(model.statement || model.body, 'text/html')
        if el = doc.querySelector('h1,h2,h3')
          el.textContent
        else
          (model.body || '').replace(///<[^>]*>?///gm, '')

    onTrackClicked: (event) ->
      @moveKnob(event)
      @goToPosition(@position)

    moveKnob: (event) ->
      adjust = if @knobHeight < 64
           32
        else
          parseInt(@knobHeight / 2)

      @knobOffset = @getEventOffset(event) - adjust
      @position = @positionFor(@getEventOffset(event))

    getEventOffset: (event) ->
      offset = event.clientY - @$refs.slider.getBoundingClientRect().top
      if offset < 0
        0
      else if offset > @trackHeight
        @trackHeight
      else
        offset

    onMouseDown: ->
      onMouseMove = @moveKnob

      onMouseUp = =>
        document.removeEventListener('mousemove', onMouseMove);
        document.removeEventListener('mouseup', onMouseUp);
        @goToPosition(@position)

      document.addEventListener 'mousemove', onMouseMove
      document.addEventListener 'mouseup', onMouseUp

    goToPosition: (position) ->
      # console.log 'going to posiiton', position
      @$router.replace(query: {p: position})
      @$vuetify.goTo("#position-#{position}", duration: 0)

    offsetFor: (position) ->
      return 0 unless @discussion
      parseInt if @discussion.newestFirst
          @trackHeight - ((position) * @unitHeight)
        else
          (position - 1) * @unitHeight

    positionFor: (offset) ->
      return 1 unless @discussion
      position = parseInt(offset / @unitHeight) + 1
      position = if position < 1
          1
        else if position > @discussion.createdEvent().childCount
          @discussion.createdEvent().childCount
        else
          position

      if @discussion.newestFirst
        @discussion.createdEvent().childCount - position
      else
        position

  computed:
    bookendedPresets: ->
      if !first(@presets) || (first(@presets).position != 1)
        @presets.unshift({position: @topPosition, title: timeline(@topDate)})

      if !last(@presets) || (last(@presets).position != @discussion.createdEvent().childCount)
        @presets.push({position: @bottomPosition, title: timeline(@bottomDate)})
      @presets

  watch:
    'discussion.newestFirst':
      immediate: true
      handler: ->
        return unless @discussion

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select(v-if="discussion" :permanent="$vuetify.breakpoint.mdAndUp" width="210px" app fixed right clipped color="transparent" floating)
  .thread-nav
    .thread-nav__track(ref="slider" :style="{height: trackHeight+'px'}" @click="onTrackClicked")
      .thread-nav__track-line
    .thread-nav__presets
      router-link.thread-nav__preset(v-for="preset in bookendedPresets"  :to="{query:{p: preset.position}}" :style="{top: offsetFor(preset.position)+'px'}")
        .thread-nav__preset--line
        .thread-nav__preset--title {{preset.title}}
        .thread-nav__preset--position {{preset.position}}
    .thread-nav__knob(:style="{top: knobOffset+'px', height: knobHeight+'px'}" ref="knob" @mousedown="onMouseDown")
</template>

<style lang="sass">
.thread-nav
  margin-top: 32px
  position: relative

.thread-nav__preset
  display: flex
  position: absolute
  width: 200px
  align-items: flex-start

// .thread-nav__preset:last-child
//   margin-top: 4px
//   align-items: flex-end

.thread-nav__preset--title
  font-size: 14px
  margin-top: -10px
  width: 250px
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
  width: 24px
  min-width: 24px
  background-color: #aaa
  margin-right: 8px
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
  min-height: 64px

.disable-select
  user-select: none
  -webkit-user-select: none
  -khtml-user-select: none
  -moz-user-select: none
  -ms-user-select: none
</style>
