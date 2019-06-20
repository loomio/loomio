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
      name: 'translate_outcome'
      icon: 'mdi-translate'
      canPerform: => AbilityService.canTranslate(@eventable)
      perform:    => @eventable.translate(Session.user().locale)
    ]
</script>

<template lang="pug">
.outcome-created
  p.thread-item__body.lmo-markdown-wrapper(v-if="!eventable.translation && eventable.statementFormat =='html'" v-html="eventable.statement")
  p.thread-item__body.lmo-markdown-wrapper(v-if="!eventable.translation && eventable.statementFormat =='md'" v-marked="eventable.statement")
  translation(v-if="eventable.translation" :model="eventable" field="statement" class="thread-item__body")
  .lmo-md-actions
    reaction-display(:model="eventable")
    action-dock(:model="eventable" :actions="actions")
</template>
