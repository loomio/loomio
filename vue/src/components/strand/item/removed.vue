<script lang="coffee">
import CommentService from '@/shared/services/comment_service'
import PollService from '@/shared/services/poll_service'
import { pick } from 'lodash'
export default
  props:
    event: Object
    eventable: Object

  computed:
    menuActions: ->
      if @event.kind == 'new_comment'
        pick(CommentService.actions(@eventable, @), 'undiscard_comment', 'delete_comment')
      else if @event.kind == 'poll_created'
        pick(PollService.actions(@eventable, @), 'undiscard_poll', 'delete_poll')
      else
        {}
</script>

<template lang="pug">
section.strand-item__removed
  h3.strand-item__headline.body-2.pb-1.d-flex.align-center.text--secondary
    span(v-t="'thread_item.removed'")
    mid-dot
    time-ago(:date='eventable.discardedAt')
  action-dock(:model='eventable' :menu-actions='menuActions' small)
</template>
