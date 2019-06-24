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
  poll-common-stance(:stance="eventable")
  .lmo-md-actions
    reaction-display(:model="eventable")
    action-dock(:model="eventable" :actions="actions")
</template>
