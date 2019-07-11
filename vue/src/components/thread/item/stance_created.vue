<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import openModal from '@/shared/helpers/open_modal'
import UrlFor         from '@/mixins/url_for'

import { listenForTranslations } from '@/shared/helpers/listen'

export default
  components:
    ThreadItem: -> import('@/components/thread/item.vue')

  mixins: [UrlFor]
  props:
    event: Object
    eventWindow: Object
  computed:
    eventable: -> @event.model()
    choiceInHeadline: ->
      @eventable.poll().hasOptionIcons() &&
      @eventable.stanceChoices().length == 1
    canEdit: ->
  created: ->
    @actions =
      edit_stance:
        icon: 'mdi-pencil'
        canPerform: =>
          @eventable.latest && @eventable.participant() == Session.user()
        perform: =>
          openModal
            component: 'PollCommonEditVoteModal',
            props:
              stance: @eventable.clone()
      translate_stance:
        icon: 'mdi-translate'
        canPerform: =>
          @eventable.reason && AbilityService.canTranslate(@eventable)
        perform: =>
          @eventable.translate(Session.user().locale)

      show_history:
        icon: 'mdi-history'
        canPerform: => @eventable.edited()
        perform: =>
          openModal
            component: 'RevisionHistoryModal'
            props:
              model: @eventable
  # mounted: ->
  #   listenForTranslations($scope)
</script>

<template lang="pug">
thread-item.stance-created(:event="event" :event-window="eventWindow")
  template(v-slot:top-right)
    action-dock(:model="eventable" :actions="actions")
  template(v-if="choiceInHeadline" v-slot:headline)
    v-layout(align-center)
      router-link(:to="urlFor(event.actor())") {{event.actor().name}}
      space
      poll-common-stance-choice(:stance-choice="eventable.stanceChoices()[0]")
  poll-common-stance(:stance="eventable" :reason-only="choiceInHeadline")
</template>
