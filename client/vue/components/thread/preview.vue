<style lang="scss">
@import 'mixins';
@import 'boxes';

.thread-preview {
  @include md-body-1;
  @include listTransition;
  min-height: $boxMediumSize + ($thinPaddingSize * 2);
  border-bottom: 1px solid $border-color;
  &:hover .thread-preview__actions { opacity: 1; }
  &.loading-content { padding: 10px; }
  position: relative;
}

.thread-preview__link {
  display: flex;
  justify-content: space-between;
  padding: $thinPaddingSize;
  color: $primary-text-color;
  text-decoration: none;

  &.thread-preview__link--unread {
    border-left: 2px solid;
    padding-left: $thinPaddingSize - 2px;
  }
}

.thread-preview__status-icon {
  padding: 4px 8px;
}

.thread-preview__pin {
  width: 32px;
  font-size: 20px;
  color: $grey-on-white;
  text-align: center;
}

.thread-preview__actions {
  position: absolute;
  display: flex;
  right: 40px;
  transition: opacity 0.25s ease-in-out;
  top: 0;
  opacity: 0;
  margin: $thinPaddingSize $cardPaddingSize;
  .md-button {
    align-items: center;
    display: flex;
    justify-content: center;
    min-width: 40px;
    .mdi { font-size: 16px; }
  }
}

.thread-preview__mute,
.thread-preview__unmute { margin-left: 8px }


.thread-preview__link:hover {
  color: $primary-text-color;
  text-decoration: none;
}

.thread-preview__icon .user-avatar {
  pointer-events: none;
}

.thread-preview__text-container{
  display: flex;
}

.thread-preview__details {
  min-width: 0;
  flex-grow: 1;
}

.thread-preview__title{
  @include md-subhead;
  padding-left: $thinPaddingSize;
  vertical-align: top;
  @include truncateText;
}

.thread-preview__group-name{
  @include md-caption;
  @include truncateText;
  padding-left: $thinPaddingSize;
  color: $grey-on-white;
}

.thread-preview__unread-count {
  color: $grey-on-white;
  min-width: 33px;
  padding-left: 5px;
}

.thread-preview--unread {
  font-weight: 500;
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
ThreadService = require 'shared/services/thread_service'
urlFor        = require 'vue/mixins/url_for'

module.exports =
  mixins: [urlFor]
  props:
    thread: Object
  data: ->
    dthread: @thread
  methods:
    dismiss: -> ThreadService.dismiss(this.thread)
    muteThread: -> ThreadService.mute(this.thread)
    unmuteThread: -> ThreadService.unmute(this.thread)
  computed:
    threadUrl: -> "/d/#{this.thread.key}"
</script>

<template>
<div class="thread-preview">
  <a :href="urlFor(thread)" md-colors="{'border-color': 'primary-500'}" :class="{'thread-preview__link--unread': thread.isUnread()}" class="thread-preview__link">
      <div class="sr-only"><span>{{thread.authorName()}}: {{thread.title}}.</span><span v-if="thread.hasUnreadActivity()" v-t="{ path: 'dashboard_page.aria_thread.unread', args: { count: thread.unreadItemsCount() }}"></span></div>
      <div class="thread-preview__icon">
          <user-avatar v-if="!thread.activePoll()" :user="thread.author()" size="medium"></user-avatar>
          <poll-common-chart-preview v-if="thread.activePoll()" :poll="thread.activePoll()"></poll-common-chart-preview>
      </div>
      <div class="thread-preview__details">
          <div class="thread-preview__text-container">
              <div :class="{'thread-preview--unread': thread.isUnread() }" class="thread-preview__title">{{thread.title}}</div>
              <div v-if="thread.hasUnreadActivity()" class="thread-preview__unread-count">({{thread.unreadItemsCount()}})</div>
          </div>
          <div class="thread-preview__text-container">
              <div class="thread-preview__group-name">{{ thread.group().fullName }} ·
                  <time-ago :date="thread.lastActivityAt"></time-ago>
              </div>
              <div v-if="thread.closedAt" md-colors="{color: 'warn-600', 'border-color': 'warn-600'}" v-t="'common.privacy.closed'" class="lmo-badge lmo-pointer"></div>
          </div>
      </div>
      <div v-if="thread.pinned" :title="$t('context_panel.thread_status.pinned')" class="thread-preview__pin thread-preview__status-icon"><i class="mdi mdi-pin"></i></div>
  </a>
  <div v-if="thread.discussionReaderId" class="thread-preview__actions lmo-hide-on-xs">
      <button @click="dismiss()" :disabled="!thread.isUnread()" :class="{disabled: !thread.isUnread()}" :title="$t('dashboard_page.dismiss')" class="md-raised thread-preview__dismiss">
          <div class="mdi mdi-check"></div>
      </button>
      <button @click="muteThread()" v-show="!thread.isMuted()" :title="$t('volume_levels.mute')" class="md-raised thread-preview__mute">
          <div class="mdi mdi-volume-mute"></div>
      </button>
      <button @click="unmuteThread()" v-show="thread.isMuted()" :title="$t('volume_levels.unmute')" class="md-raised thread-preview__unmute">
          <div class="mdi mdi-volume-plus"></div>
      </button>
  </div>
</div>
</template>
