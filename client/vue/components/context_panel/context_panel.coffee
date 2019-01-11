Records        = require 'shared/services/records'
Session        = require 'shared/services/session'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
ThreadService  = require 'shared/services/thread_service'
LmoUrlService  = require 'shared/services/lmo_url_service'
FlashService   = require 'shared/services/flash_service'
I18n           = require 'shared/services/i18n'
urlFor         = require 'vue/mixins/url_for'

{ listenForTranslations, listenForReactions } = require 'shared/helpers/listen'
{ scrollTo }                                  = require 'shared/helpers/layout'

module.exports =
  mixins: [urlFor]
  props:
    discussion: Object
  created: ->
    @actions = [
      name: 'react'
      canPerform: => AbilityService.canAddComment(@discussion)
    ,
      name: 'translate_thread'
      icon: 'mdi-translate'
      canPerform: => AbilityService.canTranslate(@discussion)
      perform:    => @discussion.translate(Session.user().locale)
    ,
      name: 'add_comment'
      icon: 'mdi-reply'
      canPerform: => AbilityService.canAddComment(@discussion)
      perform:    => scrollTo('.comment-form textarea')
    ,
      name: 'pin_thread'
      icon: 'mdi-pin'
      canPerform: => AbilityService.canPinThread(@discussion)
      perform:    => ThreadService.pin(@discussion)
    ,
      name: 'unpin_thread'
      icon: 'mdi-pin-off'
      canPerform: => AbilityService.canUnpinThread(@discussion)
      perform:    => ThreadService.unpin(@discussion)
    ,
      name: 'show_history',
      icon: 'mdi-history'
      canPerform: => @discussion.edited()
      perform:    => ModalService.open 'RevisionHistoryModal', model: => @discussion
    ,
      name: 'edit_thread'
      icon: 'mdi-pencil'
      canPerform: => AbilityService.canEditThread(@discussion)
      perform:    => ModalService.open 'DiscussionEditModal', discussion: => @discussion
    ]

  # mounted: ->
    # listenForTranslations(@)
    # listenForReactions(@, @discussion)

  computed:
    status: ->
      return 'pinned' if @discussion.pinned
    statusTitle: ->
      @$t("context_panel.thread_status.#{@status}")

  methods:
    # showLintel: (bool) ->
    #   EventBus.broadcast $rootScope, 'showThreadLintel', bool
    showRevisionHistory: ->
      ModalService.open 'RevisionHistoryModal', model: => @discussion

  template:
    """
    <section aria-label="$t('thread_context.aria_label')" class="context-panel lmo-card-padding lmo-action-dock-wrapper">
      <div class="context-panel__top">
          <div v-if="status" :title="statusTitle" class="context-panel__status">
            <i v-if="status == 'pinned'" class="mdi mdi-pin"></i>
          </div>
          <div class="context-panel__h1 lmo-flex__grow">
            <h1 v-if="!discussion.translation" class="lmo-h1 context-panel__heading">{{discussion.title}}</h1>
            <h1 v-if="discussion.translation" class="lmo-h1">
              <translation :model="discussion" field="title"></translation>
            </h1>
          </div>
          <!-- <context_panel_dropdown discussion="discussion"></context_panel_dropdown> -->
      </div>
      <div class="context-panel__details md-body-1 lmo-flex--row">
          <user-avatar :user="discussion.author()" size="small" class="lmo-margin-right"></user-avatar>
          <span>
            <strong>{{discussion.authorName()}}</strong>
            <span aria-hidden="true">·</span>
            <time-ago :date="discussion.createdAt" class="nowrap"></time-ago>
            <span aria-hidden="true">·</span>
            <span v-show="discussion.private" class="nowrap context-panel__discussion-privacy context-panel__discussion-privacy--private">
              <i class="mdi mdi-lock-outline"></i>
              <span v-t="'common.privacy.private'"></span>
            </span>
            <span v-show="!discussion.private" class="nowrap context-panel__discussion-privacy context-panel__discussion-privacy--public">
              <i class="mdi mdi-earth"></i>
              <span v-t="'common.privacy.public'"></span>
            </span>
            <span v-show="discussion.seenByCount > 0">
              <span aria-hidden="true">·</span>
              <span
                v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }"
                class="context-panel__seen_by_count"
              ></span>
            </span>
            <span v-if="discussion.forkedEvent() && discussion.forkedEvent().discussion()">
              <span aria-hidden="true">·</span>
              <span v-t="'thread_context.forked_from'"></span>
              <a :href="urlFor(discussion.forkedEvent())">{{discussion.forkedEvent().discussion().title}}</a>
            </span>
          </span>
          <div v-t="'common.privacy.closed'" v-if="discussion.closedAt" md-colors="{color: 'warn-600', 'border-color': 'warn-600'}" class="lmo-badge lmo-pointer">
              <!-- <md-tooltip>{{ discussion.closedAt | exactDateWithTime }}</md-tooltip> -->
          </div>
          <!-- <outlet name="after-thread-title" model="discussion" class="lmo-flex"></outlet> -->
      </div>
      <div
        v-if="!discussion.translation"
        v-marked="discussion.cookedDescription()"
        class="context-panel__description lmo-markdown-wrapper"
      ></div>
      <translation
        v-if="discussion.translation"
        :model="discussion"
        field="description"
        class="lmo-markdown-wrapper"
      ></translation>
      <document-list :model="discussion" :skip-fetch="true"></document-list>
      <div class="lmo-md-actions">
        <!-- <reactions_display model="discussion" load="true" class="context-panel__actions-left"></reactions_display> -->
        <action-dock :model="discussion" :actions="actions"></action-dock>
      </div>
    </section>
    """
