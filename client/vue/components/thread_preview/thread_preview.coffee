ThreadService = require 'shared/services/thread_service'
LmoUrlService = require 'shared/services/lmo_url_service'

module.exports = Vue.component 'ThreadPreview',
  props:
    thread: Object
  methods:
    urlFor: (model) -> LmoUrlService.route(model: model)
    dismiss: -> ThreadService.dismiss(this.thread)
    muteThread: -> ThreadService.mute(this.thread)
    unmuteThread: -> ThreadService.unmute(this.thread)
  computed:
    threadUrl: -> "/d/#{this.thread.key}"
  template: """
<div class="thread-preview">
  <div md-colors="{'border-color': 'primary-500'}" :class="{'thread-preview__link--unread': thread.isUnread()}" class="thread-preview__link">
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
              <div v-if="thread.closedAt" md-colors="{color: 'warn-600', 'border-color': 'warn-600'}" translate="common.privacy.closed" class="lmo-badge lmo-pointer"></div>
          </div>
      </div>
      <div v-if="thread.pinned" :title="$t('context_panel.thread_status.pinned')" class="thread-preview__pin thread-preview__status-icon"><i class="mdi mdi-pin"></i></div>
  </div>
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
  """
