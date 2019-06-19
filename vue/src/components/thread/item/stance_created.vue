<style lang="scss">
</style>

<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import RevisionHistoryModalMixin from '@/mixins/revision_history_modal'

import { listenForTranslations } from '@/shared/helpers/listen'

export default
  mixins: [RevisionHistoryModalMixin]
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
      perform:    => @openRevisionHistoryModal @eventable
    ]
  # mounted: ->
  #   listenForTranslations($scope)
</script>

<template lang="pug">
.stance-created
  poll-common-directive(name='stance-choice', :stance-choice='choice', v-if='choice.score > 0', v-for='choice in eventable.stanceChoices()', :key='choice.id')
  div(v-if="eventable.stanceChoices().length == 0" v-t="'poll_common_votes_panel.none_of_the_above'" class="lmo-hint-text")
  .lmo-markdown-wrapper(v-marked="eventable.reason" v-if="eventable.reasonFormat == 'md' && eventable.reason && !eventable.translation")
  .lmo-markdown-wrapper(v-html="eventable.reason" v-if="eventable.reasonFormat == 'html' && eventable.reason && !eventable.translation")
  translation(v-if="eventable.translation" :model="eventable" field="reason" class="thread-item__body")
  .lmo-md-actions
    reaction-display(:model="eventable")
    action-dock(:model="eventable" :actions="actions")
</template>
