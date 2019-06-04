<script lang="coffee">
import Records        from '@/shared/services/records'
import Session        from '@/shared/services/session'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import ThreadService  from '@/shared/services/thread_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import Flash   from '@/shared/services/flash'
import urlFor         from '@/mixins/url_for'
import exactDate      from '@/mixins/exact_date'
import DiscussionModalMixin from '@/mixins/discussion_modal'

import { listenForTranslations } from '@/shared/helpers/listen'
import { scrollTo }                                  from '@/shared/helpers/layout'

export default
  mixins: [urlFor, exactDate, DiscussionModalMixin]
  props:
    discussion: Object

  mounted: ->
    listenForTranslations(@)

  data: ->
    actions: [
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
      perform:    => @openEditDiscussionModal(@discussion)
    ]

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
</script>

<template lang="pug">
//- section.context-panel.lmo-card-padding.lmo-action-dock-wrapper(aria-label="$t('thread_context.aria_label')")
v-card-text.context-panel
  .context-panel__top
    .context-panel__status(v-if='status', :title='statusTitle')
      i.mdi.mdi-pin(v-if="status == 'pinned'")
    .context-panel__h1.lmo-flex__grow
      h1.headline.context-panel__heading
        span(v-if='!discussion.translation') {{discussion.title}}
        span(v-if='discussion.translation')
          translation(:model='discussion', field='title')
    context-panel-dropdown(:discussion="discussion")
  v-layout.context-panel__details(align-center)
    user-avatar.lmo-margin-right(:user='discussion.author()', size='medium')
    span
      strong {{discussion.authorName()}}
      span.mx-1(aria-hidden='true') ·
      time-ago.nowrap(:date='discussion.createdAt')
      span.mx-1(aria-hidden='true') ·
      span.nowrap.context-panel__discussion-privacy.context-panel__discussion-privacy--private(v-show='discussion.private')
        i.mdi.mdi-lock-outline
        span(v-t="'common.privacy.private'")
      span.nowrap.context-panel__discussion-privacy.context-panel__discussion-privacy--public(v-show='!discussion.private')
        i.mdi.mdi-earth
        span(v-t="'common.privacy.public'")
      span(v-show='discussion.seenByCount > 0')
        span.mx-1(aria-hidden='true') ·
        span.context-panel__seen_by_count(v-t="{ path: 'thread_context.seen_by_count', args: { count: discussion.seenByCount } }")
      span.context-panel__fork-details(v-if='discussion.forkedEvent() && discussion.forkedEvent().discussion()')
        span.mx-1(aria-hidden='true') ·
        span(v-t="'thread_context.forked_from'")
        router-link(:to='urlFor(discussion.forkedEvent())') {{discussion.forkedEvent().discussion().title}}
    .lmo-badge.lmo-pointer(v-t="'common.privacy.closed'", v-if='discussion.closedAt', md-colors="{color: 'warn-600', 'border-color': 'warn-600'}")
      v-tooltip(bottom='') {{ exactDate(discussion.closedAt) }}
  .context-panel__description.lmo-markdown-wrapper(v-if="discussion.descriptionFormat == 'md'", v-marked='discussion.cookedDescription()')
  .context-panel__description.lmo-markdown-wrapper(v-if="discussion.descriptionFormat == 'html'", v-html='discussion.description')

  translation.lmo-markdown-wrapper(v-if='discussion.translation', :model='discussion', field='description')
  document-list(:model='discussion', :skip-fetch='true')
  attachment-list(:attachments="discussion.attachments")
  .lmo-md-actions
    reaction-display.context-panel__actions-left(:model="discussion" :load="true")
    action-dock(:model='discussion', :actions='actions')
</template>
<style lang="scss">
@import 'variables';
.context-panel {
  .lmo-card-heading { margin-top: 7px; }
  border-bottom: 1px solid $border-color;
}

.context-panel__top {
  display: flex;
}

.context-panel__status {
  font-size: 20px;
  line-height: 34px;
  margin-right: 8px;
}

.context-panel__before-thread-actions {
  order: 1;
}

.context-panel__thread-actions {
  margin-right: -10px;
  display: flex;
  flex-direction: column;
}

.context-panel__discussion-privacy i {
  position: relative;
  font-size: 14px;
  top: 2px;
}

.context-panel__details {
  color: $grey-on-white;
  align-items: center;
  margin-bottom: 16px;
}

.context-panel__description {
  margin-bottom: 16px;
  p:last-of-type { margin-bottom: 0; }
}

@media (min-width: $medium-max-px) {
  .context-panel__before-thread-actions {
    order: 0;
  }

  .context-panel__thread-actions {
    flex-direction: row;
  }
}
</style>
