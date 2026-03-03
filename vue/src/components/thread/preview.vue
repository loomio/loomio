<script lang="js">
import TopicService from '@/shared/services/topic_service';
import { pick, some } from 'lodash-es';
import UrlFor from '@/mixins/url_for'

export default {
  mixins: [UrlFor],
  props: {
    topic: Object,

    groupPage: {
      type: Boolean,
      default: false
    },

    showGroupName: {
      type: Boolean,
      default: true
    }
  },

  computed: {
    isPoll() {
      return this.topic.topicableType === 'Poll';
    },

    poll() {
      return this.isPoll ? this.topic.topicable() : null;
    },

    isUnread() {
      return this.topic.isUnread();
    },

    dockActions() {
      return pick(TopicService.actions(this.topic, this), ['dismiss_thread']);
    },

    menuActions() {
      const actions = this.groupPage ?
        this.$vuetify.display.smAndDown ?
          ['dismiss_thread','pin_thread', 'unpin_thread', 'edit_thread', 'move_thread', 'close_thread', 'reopen_thread', 'discard_thread']
        :
          ['pin_thread', 'unpin_thread', 'edit_thread', 'move_thread', 'close_thread', 'reopen_thread', 'discard_thread']
      :
        this.$vuetify.display.smAndDown ?
          ['dismiss_thread', 'close_thread', 'reopen_thread']
        :
          ['close_thread', 'reopen_thread'];
      return pick(TopicService.actions(this.topic, this), actions);
    },

    canPerformAny() {
      return some(this.menuActions, action => action.canPerform());
    }
  }
};

</script>

<template lang="pug">
v-list-item.thread-preview.thread-preview__link(
  :class="{'thread-preview--unread-border': isUnread}"
  :to='urlFor(topic)'
)
  template(v-slot:prepend)
    poll-common-icon-panel.mr-3(v-if="isPoll" :poll="poll" show-my-stance :size="36")
    user-avatar.mr-3(v-else :user='topic.author()' :size='36' no-link)
  v-list-item-title(style="align-items: center")
    span(v-if='topic.pinnedAt', :title="$t('context_panel.thread_status.pinned')")
      common-icon(size="x-small" name="mdi-pin-outline")
    plain-text.thread-preview__title(:model="topic" field="title" :class="{'text-medium-emphasis': !isUnread, 'font-weight-medium': isUnread }")
    v-chip.ml-1(size="x-small" label outlined color="warning" v-if='topic.closedAt')
      span(v-t="'poll_common_action_panel.custom_template'")
    tags-display.ml-1(:tags="topic.tags" :group="topic.group()" size="x-small")
  v-list-item-subtitle
    span.thread-preview__group-name(v-if="showGroupName") {{ topic.group().name }}
    mid-dot(v-if="showGroupName")
    template(v-if="isPoll")
      poll-common-closing-at(:poll="poll" approximate)
    template(v-else)
      span.thread-preview__items-count(v-t="{path: 'thread_preview.replies_count', args: {count: topic.repliesCount}}")
      space
      span.thread-preview__unread-count(v-if='topic.hasUnreadActivity()' v-t="{path: 'thread_preview.unread_count', args: {count: topic.unreadItemsCount()}}")
      mid-dot
      active-time-ago(:date="topic.lastActivityAt")
  template(v-slot:append)
    action-dock(v-if='$vuetify.display.mdAndUp' :actions="dockActions")
    action-menu(v-if='canPerformAny' :actions="menuActions" icon)
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
// .thread-preview__position-icon-container
//   width: 23px
//   height: 23px
//   position: absolute
//   left: 15px
//   top: 43px
//   background-color: white
//   border-radius: 100%
//   box-shadow: 0 2px 1px rgba(0,0,0,.15)
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
