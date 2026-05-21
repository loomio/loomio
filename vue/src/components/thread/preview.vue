<script setup lang="js">
import TopicService from '@/shared/services/topic_service';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { pick, some } from 'lodash-es';
import { computed } from 'vue';
import { useDisplay } from 'vuetify';

const props = defineProps({
  topic: Object,
  groupPage: { type: Boolean, default: false },
  showGroupName: { type: Boolean, default: true }
});

const { smAndDown, mdAndUp } = useDisplay();

const urlFor = (model) => LmoUrlService.route({ model });

const topicable = props.topic.topicable();
const isPoll = props.topic.topicableType === 'Poll';
const isUnread = computed(() => props.topic.isUnread());

const dockActions = computed(() =>
  pick(TopicService.actions(props.topic), ['dismiss_thread'])
);

const menuActions = computed(() => {
  const actions = props.groupPage
    ? smAndDown.value
      ? ['dismiss_thread', 'pin_thread', 'unpin_thread', 'edit_thread', 'move_thread', 'lock_thread', 'unlock_thread', 'discard_thread']
      : ['pin_thread', 'unpin_thread', 'edit_thread', 'move_thread', 'lock_thread', 'unlock_thread', 'discard_thread']
    : smAndDown.value
      ? ['dismiss_thread', 'lock_thread', 'unlock_thread']
      : ['lock_thread', 'unlock_thread'];
  return pick(TopicService.actions(props.topic), actions);
});

const canPerformAny = computed(() => some(menuActions.value, action => action.canPerform()));
</script>

<template lang="pug">
v-list-item.thread-preview.thread-preview__link(
  :class="{'thread-preview--unread-border': isUnread}"
  :to='urlFor(topic)'
)
  template(v-slot:prepend)
    poll-common-icon-panel.mr-3(v-if="isPoll" :poll="topicable" show-my-stance :size="36")
    user-avatar.mr-3(v-else :user='topic.author()' :size='36' no-link)
  v-list-item-title(style="align-items: center")
    span(v-if='topic.pinnedAt', :title="$t('context_panel.thread_status.pinned')")
      common-icon(size="x-small" name="mdi-pin-outline")
    plain-text.thread-preview__title(:model="topicable" field="title" :class="{'text-medium-emphasis': !isUnread, 'font-weight-medium': isUnread }")
    v-chip.ml-1(size="x-small" label outlined color="warning" v-if='topic.closedAt')
      span(v-t="'discussions_panel.locked'")
    tags-display.ml-1(:tags="topic.tags" :group="topic.group()" size="x-small")
  v-list-item-subtitle
    span.thread-preview__group-name(v-if="showGroupName") {{ topic.group().name }}
    mid-dot(v-if="showGroupName")
    template(v-if="isPoll")
      poll-common-closing-at(:poll="topicable" approximate)
    template(v-else)
      span.thread-preview__items-count(v-t="{path: 'thread_preview.items_count', args: {count: topic.itemsCount}}")
      space
      span.thread-preview__unread-count(v-if='topic.hasUnreadActivity()' v-t="{path: 'thread_preview.unread_count', args: {count: topic.unreadItemsCount()}}")
      mid-dot
      active-time-ago(:date="topic.lastActivityAt")
  template(v-slot:append)
    action-dock(v-if='mdAndUp' :actions="dockActions")
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
