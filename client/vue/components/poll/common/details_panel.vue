<style lang="scss">
.poll-common-details-panel__started-by {
  @include fontSmall;
  color: $grey-on-white;
}

.poll-common-details-panel__details {
  margin-top: 10px;
}
</style>

<script lang="coffee">
Records        = require 'shared/services/records'
Session        = require 'shared/services/session'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
LmoUrlService  = require 'shared/services/lmo_url_service'
FlashService   = require 'shared/services/flash_service'

{ listenForTranslations, listenForReactions } = require 'shared/helpers/listen'

module.exports =
  props:
    poll: Object
  created: ->
    @actions = [
      name: 'translate_poll'
      icon: 'mdi-translate'
      canPerform: => AbilityService.canTranslate(@poll)
      perform:    => @poll.translate(Session.user().locale)
    ,
      name: 'announce_poll'
      icon: 'mdi-account-plus'
      canPerform: => AbilityService.canAdministerPoll(@poll) and @poll.isActive()
      perform:    => ModalService.open 'AnnouncementModal', announcement: =>
        Records.announcements.buildFromModel(@poll)
    ,
      name: 'edit_poll'
      icon: 'mdi-pencil'
      canPerform: => AbilityService.canEditPoll(@poll)
      perform:    => ModalService.open 'PollCommonEditModal', poll: => @poll
    ,
      name: 'show_history'
      icon: 'mdi-history'
      canPerform: => @poll.edited()
      perform:    => ModalService.open 'RevisionHistoryModal', model: => @poll
    ]
  # mounted: ->
  #   listenForTranslations(@)
  #   listenForReactions(@, @poll)
</script>

<template>
    <div class="poll-common-details-panel lmo-action-dock-wrapper">
      <h3 v-t="'poll_common.details'" v-if="poll.outcome()" class="lmo-card-subheading"></h3>
      <div class="poll-common-details-panel__started-by">
        <span v-t="{ path: 'poll_card.started_by', args: { name: poll.authorName() } }"></span>
        <span aria-hidden="true">·</span>
        <poll-common-closing-at :poll="poll"></poll-common-closing-at>
        <span v-if="poll.anonymous">·</span>
        <span v-if="poll.anonymous" md-colors="{color: 'primary-600', 'border-color': 'primary-600'}" v-t="'common.anonymous'" class="lmo-badge lmo-pointer"></span>
      </div>
      <div v-if="!poll.translation" v-marked="poll.cookedDetails()" class="poll-common-details-panel__details lmo-markdown-wrapper"></div>
      <div v-if="poll.translation" class="poll-common-details-panel__details">
        <translation :model="poll" :field="details" class="lmo-markdown-wrapper"></translation>
      </div>
      <document-list :model="poll"></document-list>
      <div class="lmo-md-actions">
        <!-- <reactions_display model="poll" load="true"></reactions_display> -->
        <action-dock :model="poll" :actions="actions"></action-dock>
      </div>
    </div>
</template>
