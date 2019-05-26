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
    eventWindow: Object
  data: ->
    actions:  [
      name: 'edit_poll'
      icon: 'mdi-pencil'
      canPerform: => AbilityService.canEditPoll(@eventable)
      perform:    => ModalService.open 'PollCommonEditModal', poll: => @eventable
    ,
      name: 'translate_outcome'
      icon: 'mdi-translate'
      canPerform: => AbilityService.canTranslate(@eventable)
      perform:    => @eventable.translate(Session.user().locale)
    ]
  mounted: ->
    listenForTranslations @
</script>

<template lang="pug">
.outcome-created
  thread-item-headline(:event="event" :actions="actions" :eventWindow="eventWindow")
  .thread-item__body
    p(v-if="!eventable.translation" v-marked="eventable.statement" class="thread-item__body lmo-markdown-wrapper")
    translation(v-if="eventable.translation" :model="eventable" field="statement" class="thread-item__body")
  .thread-item__reactions
    reaction-display(:model="eventable")
</template>
