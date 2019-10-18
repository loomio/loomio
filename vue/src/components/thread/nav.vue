<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import { debounce, truncate } from 'lodash'

export default
  mixins: [ChangeVolumeModalMixin]
  data: ->
    discussion: null
    open: null
    offset: 0
    max: 200
    dragging: false

  mounted: ->
    EventBus.$on 'currentComponent', (options) =>
      @discussion = options.discussion
      return unless @discussion

      # Records.events.fetch
      #   params:
      #     discussion_id: @discussion.id
      #     pinned: true
      #     per: 200

  methods:
    onMouseDown: ->
      onMouseMove = (event) =>
        offset = event.clientY - @$refs.slider.getBoundingClientRect().top;

        if offset < 0
          @offset = 0
        else if offset > @max
          @offset = @max
        else
          @offset = offset

      onMouseUp = ->
        document.removeEventListener('mousemove', onMouseMove);
        document.removeEventListener('mouseup', onMouseUp);

      document.addEventListener 'mousemove', onMouseMove
      document.addEventListener 'mouseup', onMouseUp

    dragend: ->
      @dragging = false

</script>

<template lang="pug">
v-navigation-drawer.thread-nav.lmo-no-print(v-if="discussion" :permanent="$vuetify.breakpoint.mdAndUp" width="210px" app fixed right clipped)
  | offset {{offset}}
  .thread-nav__track(ref="slider")
    .thread-nav__knob(:class="{'thread-nav__knob-hide': dragging}" ref="knob" @mousedown="onMouseDown" :style="{top: offset+'px'}")
</template>

<style lang="sass">
.thread-nav__knob-hide
  background-color: red !important
  transform: translateX(-9999px)

.thread-nav__track
  height: 200px
  border: 1px solid black
  width: 0
  margin: 16px

.thread-nav__knob
  position: relative
  height: 16px
  width: 24px
  background-color: #999
  cursor: ns-resize
</style>
