<style lang="scss">
</style>

<script lang="coffee">
Session        = require 'shared/services/session'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

{ listenForTranslations, listenForReactions } = require 'shared/helpers/listen'

module.exports =
  props:
    event: Object
    eventable: Object
  created: ->
    @actions = [
      name: 'react'
      canPerform: => AbilityService.canReactToPoll(@eventable.poll())
    ,
      name: 'edit_outcome'
      icon: 'mdi-pencil'
      canPerform: => AbilityService.canSetPollOutcome(@eventable.poll())
      perform:    => ModalService.open 'PollCommonOutcomeModal', outcome: => @eventable
    ,
      name: 'translate_outcome'
      icon: 'mdi-translate'
      canPerform: => AbilityService.canTranslate(@eventable)
      perform:    => @eventable.translate(Session.user().locale)
    ]
  # mounted: ->
  #   listenForReactions $scope, $scope.eventable
  #   listenForTranslations $scope,
</script>

<template>
    <div class="outcome-created">
      <p v-if="!eventable.translation" v-marked="eventable.statement" class="thread-item__body lmo-markdown-wrapper"></p>
      <translation v-if="eventable.translation" :model="eventable" field="statement" class="thread-item__body"></translation>
      <div class="lmo-md-actions">
        <!-- <reactions_display model="eventable"></reactions_display> -->
        <action-dock :model="eventable" :actions="actions"></action-dock>
      </div>
    </div>
</template>
