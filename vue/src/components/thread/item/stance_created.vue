<style lang="scss">
</style>

<script lang="coffee">
Session        = require 'shared/services/session'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

{ listenForTranslations } = require 'shared/helpers/listen'

module.exports =
  props:
    event: Object
    eventable: Object
  created: ->
    @actions = [
      name: 'translate_stance'
      icon: 'mdi-translate'
      canPerform: => @eventable.reason && AbilityService.canTranslate(@eventable)
      perform:    => @eventable.translate(Session.user().locale)
      ,
      name: 'show_history',
      icon: 'mdi-history'
      canPerform: => @eventable.edited()
      perform:    => ModalService.open 'RevisionHistoryModal', model: => @eventable
    ]
  # mounted: ->
  #   listenForTranslations($scope)
</script>

<template>
    <div class="stance-created">
      <!-- <poll_common_directive name="stance_choice" ng-repeat="choice in eventable.stanceChoices() | orderBy: \'rank\'" ng-if="choice.score &gt; 0" stance_choice="choice"></poll_common_directive> -->
      <div v-if="eventable.stanceChoices().length == 0" v-t="'poll_common_votes_panel.none_of_the_above'" class="lmo-hint-text"></div>
      <div v-marked="eventable.reason" v-if="eventable.reason && !eventable.translation" class="lmo-markdown-wrapper"></div>
      <translation v-if="eventable.translation" :model="eventable" field="reason" class="thread-item__body"></translation>
      <div class="lmo-md-actions">
        <!-- <reactions_display model="eventable"></reactions_display> -->
        <action-dock :model="eventable" :actions="actions"></action-dock>
      </div>
    </div>
</template>
