<script lang="coffee">
import CommentService from '@/shared/services/comment_service'
import { pick } from 'lodash'
export default
  props:
    event: Object
    eventable: Object

  computed:
    menuActions: ->
      if @event.kind == 'new_comment'
        pick(CommentService.actions(@eventable, @), 'undiscard_comment', 'delete_comment')
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
