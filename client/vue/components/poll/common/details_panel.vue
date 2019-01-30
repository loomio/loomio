<style lang="scss">
@import 'mixins';
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
  data: ->
    isPollCommonEditModalOpen: false
    isAnnouncementModalOpen: false
    isRevisionHistoryModalOpen: false
  methods:
    openPollCommonEditModal: ->
      @isPollCommonEditModalOpen = true
    openRevisionHistoryModal: ->
      @isRevisionHistoryModalOpen = true
    openAnnouncementModal: ->
      @isAnnouncementModalOpen = true
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
      perform:    =>
        console.log('open modal')
        @openPollCommonEditModal()
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

<template lang="pug">
.poll-common-details-panel
  v-subheader(v-t="'poll_common.details'", v-if='poll.outcome()')
  .poll-common-details-panel__started-by
    span(v-t="{ path: 'poll_card.started_by', args: { name: poll.authorName() } }")
    span(aria-hidden='true') ·
    poll-common-closing-at(:poll='poll')
    span(v-if='poll.anonymous') ·
    span(v-if='poll.anonymous', md-colors="{color: 'primary-600', 'border-color': 'primary-600'}", v-t="'common.anonymous'")
  .poll-common-details-panel__details(v-if='!poll.translation', v-marked='poll.cookedDetails()')
  .poll-common-details-panel__details(v-if='poll.translation')
    translation(:model='poll', :field='details')
  document-list(:model='poll')
  v-card-actions.lmo-md-actions
    // <reactions_display model="poll" load="true"></reactions_display>
    v-spacer
    action-dock(:model='poll', :actions='actions')
  v-dialog(v-model='isPollCommonEditModalOpen' lazy persistent)
    poll-common-edit-modal(:poll='poll')
  //- v-dialog(v-model='isThreadModalOpen' lazy persistent)
  //-   discussion-start(:discussion='newThread()', :close='closeThreadModal')
  //- v-dialog(v-model='isThreadModalOpen' lazy persistent)
  //-   discussion-start(:discussion='newThread()', :close='closeThreadModal')
</template>
