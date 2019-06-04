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

  mounted: ->
    listenForTranslations(@)

  data: ->
    actions:  [
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
</script>

<template lang="pug">
.outcome-created
  p(v-if="!eventable.translation" v-marked="eventable.statement" class="thread-item__body lmo-markdown-wrapper")
  translation(v-if="eventable.translation" :model="eventable" field="statement" class="thread-item__body")
  .lmo-md-actions
    reaction-display(:model="eventable")
    action-dock(:model="eventable" :actions="actions")
</template>
