<style lang="scss">
.poll-common-outcome-panel__authored-by {
  @include fontSmall;
  color: $grey-on-white;
}
</style>

<script lang="coffee">
Records        = require 'shared/services/records'
Session        = require 'shared/services/session'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

{ listenForTranslations, listenForReactions } = require 'shared/helpers/listen'

module.exports =
  props:
    poll: Object
  created: ->
    @actions = [
      name: 'react'
      canPerform: => AbilityService.canReactToPoll(@poll)
    ,
      name: 'announce_outcome'
      icon: 'mdi-account-plus'
      active:     => @poll.outcome().announcementsCount == 0
      canPerform: => AbilityService.canAdministerPoll(@poll)
      perform:    => ModalService.open 'AnnouncementModal', announcement: =>
        Records.announcements.buildFromModel(@poll.outcome())
    ,
      name: 'edit_outcome'
      icon: 'mdi-pencil'
      canPerform: => AbilityService.canSetPollOutcome(@poll)
      perform:    => ModalService.open 'PollCommonOutcomeModal', outcome: => @poll.outcome()
    ,
      name: 'translate_outcome'
      icon: 'mdi-translate'
      canPerform: => AbilityService.canTranslate(@poll.outcome())
      perform:    => @poll.outcome().translate(Session.user().locale)
    ]
  # mounted: ->
  #   listenForTranslations(@)
  #   listenForReactions(@, @poll.outcome())

</script>

<template>
      <div v-if="poll.outcome()" class="poll-common-outcome-panel lmo-action-dock-wrapper">
        <h3 v-t="'poll_common.outcome'" class="lmo-card-subheading"></h3>
        <div class="poll-common-outcome-panel__authored-by">
          <span v-t="{ path: 'poll_common_outcome_panel.authored_by', args: { name: poll.outcome().authorName() } }"></span>
          <time-ago :date="poll.outcome().createdAt"></time-ago>
        </div>
        <p v-marked="poll.outcome().statement" v-if="!poll.outcome().translation" class="lmo-markdown-wrapper"></p>
        <translation :model="poll.outcome()" :field="statement" v-if="poll.outcome().translation"></translation>
        <document-list :model="poll.outcome()"></document-list>
        <div class="lmo-md-actions">
          <!-- <reactions_display model="poll.outcome()" load="true"></reactions_display> -->
          <action-dock :model="poll.outcome()" :actions="actions"></action-dock>
        </div>
      </div>
</template>
