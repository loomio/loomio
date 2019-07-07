<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import RevisionHistoryModalMixin from '@/mixins/revision_history_modal'
import PollModal from '@/mixins/poll_modal'
import UrlFor         from '@/mixins/url_for'

import { listenForTranslations } from '@/shared/helpers/listen'

export default
  components:
    ThreadItem: -> import('@/components/thread/item.vue')

  mixins: [RevisionHistoryModalMixin, PollModal, UrlFor]
  props:
    event: Object
    eventWindow: Object
  computed:
    eventable: -> @event.model()
    choiceInHeadline: -> @eventable.poll().hasOptionIcons() && @eventable.stanceChoices().length == 1
    canEdit: -> @eventable.latest && @eventable.participant() == Session.user()
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
thread-item.stance-created(:event="event" :event-window="eventWindow")
  template(v-if="choiceInHeadline" v-slot:headline)
    v-layout(align-center)
      router-link(:to="urlFor(event.actor())") {{event.actor().name}}
      space
      poll-common-stance-choice(:stance-choice="eventable.stanceChoices()[0]")
      v-btn(icon v-if="canEdit" color='accent', @click='openEditVoteModal(eventable)')
        v-icon mdi-pencil
  poll-common-stance(:stance="eventable" :reason-only="choiceInHeadline")
  .lmo-md-actions
    reaction-display(:model="eventable")
    action-dock(:model="eventable" :actions="actions")
</template>
