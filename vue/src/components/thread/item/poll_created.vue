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
  p(v-if="!eventable.translation" v-marked="eventable.statement" class="thread-item__body lmo-markdown-wrapper")
  translation(v-if="eventable.translation" :model="eventable" field="statement" class="thread-item__body")
  .lmo-md-actions
    reaction-display(:model="eventable")
    action-dock(:model="eventable" :actions="actions")
</template>
