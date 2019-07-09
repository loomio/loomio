<style lang="css">
/* // @import 'mixins';
// @import 'boxes';

// .thread-preview {
//   @include md-body-1;
//   @include listTransition;
//   min-height: $boxMediumSize + ($thinPaddingSize * 2);
//   border-bottom: 1px solid $border-color;
//   &:hover .thread-preview__actions { opacity: 1; }
//   &.loading-content { padding: 10px; }
//   position: relative;
// }

// .thread-preview__link {
//   display: flex;
//   justify-content: space-between;
//   padding: $thinPaddingSize;
//   color: $primary-text-color;
//   text-decoration: none;
//
//   &.thread-preview__link--unread {
//     border-left: 2px solid;
//     padding-left: $thinPaddingSize - 2px;
//   }
// } */

.thread-preview__status-icon {
  padding: 4px 8px;
}

.thread-preview__pin {
  width: 32px;
  font-size: 20px;
  /* // color: $grey-on-white; */
  text-align: center;
}

.thread-preview__mute,
.thread-preview__unmute { margin-left: 8px }

/* // .thread-preview__group-name{
//   @include md-caption;
//   @include truncateText;
//   padding-left: $thinPaddingSize;
//   color: $grey-on-white;
// } */

.thread-preview--unread {
  font-weight: 500;
}

.thread-preview {
  border-left: 2px solid #fff;
}

.thread-preview--unread-border {
  border-color: var(--v-primary-base);
}

.thread-preview__position-icon-container {
  width: 23px;
  height: 23px;
  position: absolute;
  left: 15px;
  top: 43px;
  background-color: white;
  border-radius: 100%;
  box-shadow: 0 2px 1px rgba(0,0,0,.15);
}

.thread-preview__position-icon {
  background-repeat: no-repeat;
  height: 21px;
  margin: 1px 0 0 1px;
  width: 21px;
}

.thread-preview__undecided-icon {
  font-size: 14px;
  line-height: 24px;
  text-align: center;
}

</style>

<script lang="coffee">
import ThreadService from '@/shared/services/thread_service'
import UrlFor        from '@/mixins/url_for'

export default
  mixins: [UrlFor]
  props:
    thread: Object
    showGroupName:
      type: Boolean
      default: true
  data: ->
    dthread: @thread
  methods:
    dismiss: -> ThreadService.dismiss(@thread)
    muteThread: -> ThreadService.mute(@thread)
    unmuteThread: -> ThreadService.unmute(@thread)
</script>

<template lang="pug">
v-list-item.thread-preview.thread-preview__link(:class="{'thread-preview--unread-border': thread.isUnread()}" :to='urlFor(thread)')
  v-list-item-avatar
    user-avatar(v-if='!thread.activePoll()', :user='thread.author()', size='medium' no-link)
    poll-common-chart-preview(v-if='thread.activePoll()', :poll='thread.activePoll()')
  v-list-item-content
    v-list-item-title(style="align-items: center")
      span.thread-preview__title(:class="{'thread-preview--unread': thread.isUnread() }") {{thread.title}}
      v-chip.ml-1(small outlined color="warning" v-if='thread.closedAt' v-t="'common.privacy.closed'")
      v-chip.thread-preview__tag.ml-1(small outlined v-for="tag in thread.tagNames" :key="tag") {{tag}}
    v-list-item-subtitle
      span.thread-preview__group-name(v-if="showGroupName") {{ thread.group().name }}
      mid-dot(v-if="showGroupName")
      span.thread-preview__items-count(v-t="{path: 'thread_preview.replies_count', args: {count: thread.itemsCount}}")
      space
      span.thread-preview__unread-count(v-if='thread.hasUnreadActivity()' v-t="{path: 'thread_preview.unread_count', args: {count: thread.unreadItemsCount()}}")
      mid-dot
      active-time-ago(:date="thread.lastActivityAt")

  v-list-item-action
    .thread-preview__pin.thread-preview__status-icon(v-if='thread.pinned', :title="$t('context_panel.thread_status.pinned')")
      v-icon mdi-pin

  v-list-item-action
    v-menu
      template(v-slot:activator="{on}")
        v-btn(icon v-on="on" @click.prevent)
          v-icon mdi-dots-vertical
      v-list
        v-list-item(v-if='thread.isUnread()')
          v-list-item-avatar
            v-icon mdi-check
          v-list-item-title.thread-preview__dismiss(@click.prevent='dismiss()' :class='{disabled: !thread.isUnread()}' v-t="'dashboard_page.dismiss'")
        v-list-item(v-if='!thread.isMuted()')
          v-list-item-avatar
            v-icon mdi-volume-mute
          v-list-item-title.thread-preview__mute(@click.prevent='muteThread()' icon v-t="'volume_levels.mute'")
        v-list-item(v-if='thread.isMuted()' )
          v-list-item-avatar
            v-icon mdi-volume-plus
          v-list-item-title.thread-preview__unmute(@click.prevent='unmuteThread()' icon v-t="'volume_levels.unmute'")

</template>
