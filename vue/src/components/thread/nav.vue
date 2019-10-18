<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import ChangeVolumeModalMixin from '@/mixins/change_volume_modal'
import { debounce, truncate } from 'lodash'
import { approximate } from '@/shared/helpers/format_time'

export default
  mixins: [ChangeVolumeModalMixin]
  data: ->
    discussion: null
    open: null
    offset: 0
    max: 300
    thumbSize: 64
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

  computed:
    topDate: -> approximate(@discussion.createdAt)
    bottomDate: -> approximate(@discussion.lastActivityAt)

</script>

<template lang="pug">
v-navigation-drawer.thread-nav.lmo-no-print(v-if="discussion" :permanent="$vuetify.breakpoint.mdAndUp" width="210px" app fixed right clipped)
  p offset {{offset}}
  span {{topDate}}
  .thread-nav__track(ref="slider" :style="{height: max+thumbSize+'px'}")
    .thread-nav__knob(:style="{top: offset+'px', height: thumbSize+'px'}" :class="{'thread-nav__knob-hide': dragging}" ref="knob" @mousedown="onMouseDown")
  span {{bottomDate}}
</template>

<style lang="sass">
.thread-nav__track
  border: 1px solid black
  width: 0
  margin: 16px

.thread-nav__knob
  position: relative
  left: -8px
  width: 16px
  background-color: #999
  cursor: ns-resize
</style>
