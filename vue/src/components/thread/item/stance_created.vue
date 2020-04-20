<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import openModal from '@/shared/helpers/open_modal'

export default
  components:
    ThreadItem: -> import('@/components/thread/item.vue')

  props:
    event: Object
    isReturning: Boolean

  computed:
    eventable: -> @event.model()
    poll: -> @eventable.poll()
    canEdit: ->

    componentType:  ->
      if @event.actor()
        'router-link'
      else
        'div'

  created: ->
    @actions =
      edit_stance:
        name: 'poll_common.change_vote'
        icon: 'mdi-pencil'
        canPerform: =>
          (Session.user() && @eventable.participant()) &&
          @eventable.latest && @eventable.poll().isActive() && @eventable.participant() == Session.user()
        perform: =>
          openModal
            component: 'PollCommonEditVoteModal',
            props:
              stance: @eventable.clone()

      translate_stance:
        icon: 'mdi-translate'
        canPerform: =>
          (@eventable.author() && Session.user()) &&
          @eventable.author().locale != Session.user().locale &&
          @eventable.reason && AbilityService.canTranslate(@eventable)
        perform: =>
          @eventable.translate(Session.user().locale)

      show_history:
        name: 'action_dock.edited'
        icon: 'mdi-history'
        canPerform: => @eventable.edited()
        perform: =>
          openModal
            component: 'RevisionHistoryModal'
            props:
              model: @eventable
</script>

<template lang="pug">
thread-item.stance-created(:event="event" :is-returning="isReturning")
  template(v-slot:actions)
    action-dock(:model="eventable" :actions="actions")
  template(v-if="eventable.singleChoice()" v-slot:headline)
    component(:is="componentType" :to="event.actor() && urlFor(event.actor())") {{event.actorName()}}
    space
    poll-common-stance-choice(:poll="poll" :stance-choice="eventable.stanceChoice()")
  .poll-common-stance
    span.caption(v-if='eventable.castAt && eventable.totalScore() == 0' v-t="'poll_common_votes_panel.none_of_the_above'" )
    v-layout(v-if="!eventable.singleChoice()" wrap align-center)
      poll-common-stance-choice(:poll="poll" :stance-choice='choice' v-if='choice.show()' v-for='choice in eventable.orderedStanceChoices()' :key='choice.id')
    formatted-text.poll-common-stance-created__reason(:model="eventable" column="reason")
  attachment-list(:attachments="eventable.attachments")
</template>
