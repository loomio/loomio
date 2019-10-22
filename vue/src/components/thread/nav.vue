<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import { debounce, truncate, first, last } from 'lodash'
import { approximate } from '@/shared/helpers/format_time'

export default
  mixins: [ChangeVolumeModalMixin]

  data: ->
    discussion: null
    open: null
    offset: 0
    max: 300
    thumbSize: 32
    dragging: false
    position: 0

  mounted: ->
    EventBus.$on 'currentComponent', (options) =>
      @discussion = options.discussion
      return unless @discussion

    EventBus.$on 'visibleSlots', (slots) =>
      unless slots.length == 0
        totalSlots = @discussion.createdEvent.childCount
        if @discussion.newestFirst
          @position = last(slots)
        else
          @position = first(slots)

        if @discussion.newestFirst
          @offset =  @max - (@position * @positionSize)
        else
          @offset =  (@position - 1) * @positionSize

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
        offset = event.clientY - @$refs.slider.getBoundingClientRect().top;

        if offset < 0
          @offset = 0
        else if offset > @max
          @offset = @max
        else
          @offset = offset

        @position = Math.round(@offset / @positionSize) + 1
        if @discussion.newestFirst
          @position = (@discussion.createdEvent().childCount + 1) - @position

      onMouseUp = =>
        document.removeEventListener('mousemove', onMouseMove);
        document.removeEventListener('mouseup', onMouseUp);
        @$router.replace(query: {p: @position})

      document.addEventListener 'mousemove', onMouseMove
      document.addEventListener 'mouseup', onMouseUp

  computed:
    positionSize: -> @max / (@discussion.createdEvent().childCount - 1)
    thumbLabel: -> "#{@position} / #{@childCount}"
    topLabel: -> approximate(@topDate)
    bottomLabel: -> approximate(@bottomDate)
    topDate: -> if @discussion.newestFirst then @discussion.lastActivityAt else @discussion.createdAt
    bottomDate: -> if @discussion.newestFirst then @discussion.createdAt else @discussion.lastActivityAt

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.disable-select(v-if="discussion" :permanent="$vuetify.breakpoint.mdAndUp" width="210px" app fixed right clipped color="transparent" floating)
  //- p offset {{offset}}
  //- p max {{max}}
  //- p position {{position}}
  .thread-nav
    .thread-nav__inner
      span.thread-nav__label {{topLabel}}
      .thread-nav__track(ref="slider" :style="{height: max+thumbSize+'px'}")
        .thread-nav__knob(:style="{top: offset+'px', height: thumbSize+'px'}" :class="{'thread-nav__knob-hide': dragging}" ref="knob" @mousedown="onMouseDown")
          span {{position}} / {{discussion.createdEvent().childCount}}
      span.thread-nav__label {{bottomLabel}}
</template>

<style lang="sass">
.thread-nav
  margin-top: 32px

.thread-nav__label
  margin-left: 16px

.thread-nav__track
  border: 1px solid var(--v-accent-base)
  width: 0
  margin: 16px

.thread-nav__knob
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
