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
    max: 300
    thumbSize: 32
    dragging: false
    position: 0
    mouseY: null
    boxY: null

  mounted: ->
    EventBus.$on 'currentComponent', (options) =>
      @discussion = options.discussion
      return unless @discussion

    EventBus.$on 'visibleSlots', (slots) =>
      unless slots.length == 0 && @discussion
        totalSlots = @discussion.createdEvent().childCount
        @knobOffset = @offsetFor(first(slots))

      # Records.events.fetch
      #   params:
      #     discussion_id: @discussion.id
      #     pinned: true
      #     per: 200

  methods:
    title: (model) ->
      if model.title or model.statement
        truncate (model.title || model.statement || model.body).replace(///<[^>]*>?///gm, ''), 50
      else
        parser = new DOMParser()
        doc = parser.parseFromString(model.statement || model.body, 'text/html')
        if el = doc.querySelector('h1,h2,h3')
          el.textContent
        else
          truncate (model.body).replace(///<[^>]*>?///gm, ''), 50

    updateThreadPosition: ->

    onMouseDown: ->
      onMouseMove = (event) =>
        @mouseY = event.clientY
        @boxY = @$refs.slider.getBoundingClientRect().top
        offset = event.clientY - @$refs.slider.getBoundingClientRect().top

        if offset < 0
          @knobOffset = 0
        else if offset > @max
          @knobOffset = @max
        else
          @knobOffset = offset

        @position = @positionFor(@knobOffset)

      onMouseUp = =>
        document.removeEventListener('mousemove', onMouseMove);
        document.removeEventListener('mouseup', onMouseUp);
        @$router.replace(query: {p: @position})

      document.addEventListener 'mousemove', onMouseMove
      document.addEventListener 'mouseup', onMouseUp

    offsetFor: (position) ->
      parseInt if @discussion.newestFirst
          @max - ((position) * @positionSize)
        else
          (position - 1) * @positionSize

    positionFor: (offset) ->
      if @discussion.newestFirst
        Math.round(offset / @positionSize) + 1
      else
        @discussion.createdEvent().childCount - Math.round(offset / @positionSize) + 1

  computed:
    # presets: -> [
    #   position: @bottomPosition
    #   title: timeline(@bottomDate)
    # ,
    #   position: @topPosition
    #   title: timeline(@topDate)
    # ]
    presets: -> []
    positionSize: -> @max / (@discussion.createdEvent().childCount - 1)
    thumbLabel: -> "#{@position} / #{@childCount}"

  watch:
    'discussion.newestFirst':
      immediate: true
      handler: ->
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

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select(v-if="discussion" :permanent="$vuetify.breakpoint.mdAndUp" width="210px" app fixed right clipped color="transparent" floating)
  div
    //- | mouseY {{mouseY}}
    //- | boxY {{boxY}}
    //- | offset {{knobOffset}}
    //- | max {{max}}
    //- | position {{position}}
  .thread-nav
    .thread-nav__inner
      .thread-nav__track(ref="slider" :style="{height: max+thumbSize+'px'}")
      .thread-nav__preset(v-for="preset in presets" :style="{top: offsetFor(preset.position)+'px'}")
        .thread-nav__preset--line
        .thread-nav__preset--title {{preset.title}}
      .thread-nav__knob(:style="{top: knobOffset+'px', height: thumbSize+'px'}" :class="{'thread-nav__knob-hide': dragging}" ref="knob" @mousedown="onMouseDown")
          span {{knobOffset}} / {{position}} / {{discussion.createdEvent().childCount}}
</template>

<style lang="sass">
.thread-nav
  margin-top: 32px

.thread-nav__preset
  float: left
  display: flex
  position: relative
  width: 160px
  left: -12px
  align-items: center

.thread-nav__preset--line
  border: 1px solid black
  height: 1px
  min-width: 24px
  margin-right: 16px

.thread-nav__track
  float: left
  position: relative
  border: 1px solid var(--v-accent-base)
  width: 0
  margin: 0 16px
  left: 16px

.thread-nav__knob
  float: left
  position: relative
  display: flex
  flex-direction: column
  align-items: center
  justify-content: center
  left: -4px
  width: 100px
  border-left: 8px solid var(--v-accent-base)
  background-color: var(--v-accent-lighten5)
  cursor: ns-resize
  border-top-right-radius: 16px
  border-bottom-right-radius: 16px

.disable-select
  user-select: none
  -webkit-user-select: none
  -khtml-user-select: none
  -moz-user-select: none
  -ms-user-select: none
</style>
