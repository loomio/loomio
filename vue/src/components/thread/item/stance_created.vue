<style lang="scss">
</style>

<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'

import { listenForTranslations } from '@/shared/helpers/listen'

export default
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

<template lang="pug">
.stance-created
  <!-- <poll_common_directive name="stance_choice" ng-repeat="choice in eventable.stanceChoices() | orderBy: \'rank\'" ng-if="choice.score &gt; 0" stance_choice="choice"></poll_common_directive> -->
  div(v-if="eventable.stanceChoices().length == 0" v-t="'poll_common_votes_panel.none_of_the_above'" class="lmo-hint-text")
  div(v-marked="eventable.reason" v-if="eventable.reason && !eventable.translation" class="lmo-markdown-wrapper")
  translation(v-if="eventable.translation" :model="eventable" field="reason" class="thread-item__body")
  .lmo-md-actions
    reaction-display(:model="eventable")
    action-dock(:model="eventable" :actions="actions")
</template>
