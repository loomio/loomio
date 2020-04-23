<script lang="coffee">
import ThreadService from '@/shared/services/thread_service'
import AbilityService from '@/shared/services/ability_service'
import { pick, some } from 'lodash-es'

export default
  props:
    thread: Object

    groupPage:
      type: Boolean
      default: false

    showGroupName:
      type: Boolean
      default: true

  computed:
    dockActions: ->
      pick(ThreadService.actions(@thread, @), ['dismiss_thread'])

    menuActions: ->
      actions = if @groupPage
        if @$vuetify.breakpoint.smAndDown
          ['dismiss_thread','pin_thread', 'unpin_thread', "edit_tags", 'move_thread', 'close_thread', 'reopen_thread', 'delete_thread']
        else
          ['pin_thread', 'unpin_thread', "edit_tags", 'move_thread', 'close_thread', 'reopen_thread', 'delete_thread']
      else
        if @$vuetify.breakpoint.smAndDown
          ['dismiss_thread', "edit_tags", 'close_thread', 'reopen_thread']
        else
          ["edit_tags", 'close_thread', 'reopen_thread']
      pick(ThreadService.actions(@thread, @), actions)

    canPerformAny: ->
      some @menuActions, (action) -> action.canPerform()

</script>

<template lang="pug">
v-list-item.thread-preview.thread-preview__link(:class="{'thread-preview--unread-border': thread.isUnread()}" :to='urlFor(thread)')
  v-list-item-avatar
    user-avatar(v-if='!thread.activePoll()', :user='thread.author()', size='medium' no-link)
    poll-common-chart-preview(v-if='thread.activePoll()', :poll='thread.activePoll()')
  v-list-item-content
    v-list-item-title(style="align-items: center")
      span(v-if='thread.pinned' :title="$t('context_panel.thread_status.pinned')")
        v-icon mdi-pin
      span.thread-preview__title(:class="{'thread-preview--unread': thread.isUnread() }") {{thread.title}}
      v-chip.ml-1(small label outlined color="warning" v-if='thread.closedAt' v-t="'common.privacy.closed'")
      v-chip.thread-preview__tag.ml-1(small outlined v-for="tag in thread.tagNames" :key="tag") {{tag}}
    v-list-item-subtitle
      span.thread-preview__group-name(v-if="showGroupName") {{ thread.group().name }}
      mid-dot(v-if="showGroupName")
      span.thread-preview__items-count(v-t="{path: 'thread_preview.replies_count', args: {count: thread.itemsCount}}")
      space
      span.thread-preview__unread-count(v-if='thread.hasUnreadActivity()' v-t="{path: 'thread_preview.unread_count', args: {count: thread.unreadItemsCount()}}")
      mid-dot
      active-time-ago(:date="thread.lastActivityAt")
  v-list-item-action(v-if='$vuetify.breakpoint.mdAndUp')
    action-dock(:actions="dockActions")
  v-list-item-action(v-if='canPerformAny')
    action-menu(:actions="menuActions")
</template>

<style lang="sass">
.thread-preview
  .v-list-item__avatar
    overflow: visible

.v-list-item__action:last-of-type:not(:only-child), .v-list-item__icon:last-of-type:not(:only-child)
  margin-left: 0

.thread-preview__status-icon
  padding: 4px 8px
.thread-preview__pin
  width: 32px
  font-size: 20px
  text-align: center
.thread-preview--unread
  font-weight: 500
.thread-preview
  border-left: 2px solid #fff
.thread-preview--unread-border
  border-color: var(--v-primary-base)
.thread-preview__position-icon-container
  width: 23px
  height: 23px
  position: absolute
  left: 15px
  top: 43px
  background-color: white
  border-radius: 100%
  box-shadow: 0 2px 1px rgba(0,0,0,.15)
.thread-preview__position-icon
  background-repeat: no-repeat
  height: 21px
  margin: 1px 0 0 1px
  width: 21px
.thread-preview__undecided-icon
  font-size: 14px
  line-height: 24px
  text-align: center

</style>
