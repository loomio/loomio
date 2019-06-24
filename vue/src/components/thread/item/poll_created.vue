<style lang="scss">
</style>

<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import PollModalMixin from '@/mixins/poll_modal'
import EventBus       from '@/shared/services/event_bus'
import WatchRecords   from '@/mixins/watch_records'
import { myLastStanceFor }  from '@/shared/helpers/poll'

import { listenForTranslations } from '@/shared/helpers/listen'

export default
  mixins: [PollModalMixin, WatchRecords]
  props:
    event: Object
    eventable: Object

  created: ->
    EventBus.$on 'showResults', => @buttonPressed = true
    EventBus.$on 'stanceSaved', => EventBus.$emit 'refreshStance'
    @watchRecords
      collections: ["stances"]
      query: (records) =>
        @myLastStance = myLastStanceFor(@poll)?

  data: ->
    buttonPressed: false
    myLastStance: null
    actions:  [
      name: 'edit_poll'
      icon: 'mdi-pencil'
      canPerform: => AbilityService.canEditPoll(@eventable)
      perform:    => @openEditPollModal @eventable
    ,
      name: 'translate_outcome'
      icon: 'mdi-translate'
      canPerform: => AbilityService.canTranslate(@eventable)
      perform:    => @eventable.translate(Session.user().locale)
    ]

  computed:
    poll: -> @eventable

    showResults: ->
      @buttonPressed || @myLastStance || @poll.isClosed()

    pollHasActions: ->
      AbilityService.canEditPoll(@poll)  ||
      AbilityService.canClosePoll(@poll) ||
      AbilityService.canDeletePoll(@poll)||
      AbilityService.canExportPoll(@poll)


  mounted: ->
    listenForTranslations @
</script>

<template lang="pug">
.poll-created
  v-layout(justify-space-between)
    h1.poll-common-card__title.headline
      span(v-if='!poll.translation') {{poll.title}}
      translation(v-if="poll.translation" :model='poll', :field='title')
    poll-common-actions-dropdown(:poll="poll", v-if="pollHasActions")
  poll-common-set-outcome-panel(:poll='poll')
  poll-common-outcome-panel(:poll='poll', v-if='poll.outcome()')
  formatted-text.poll-common-details-panel__details(:model="poll" column="details")
  attachment-list(:attachments="poll.attachments")
  .poll-common-card__results-shown(v-if='showResults')
    poll-common-directive(:poll='poll', name='chart-panel')
    poll-common-percent-voted(:poll='poll')
  poll-common-action-panel(:poll='poll')
  document-list(:model='poll')
  //- .lmo-md-actions
  //-   reaction-display(:model="eventable")
  //-   action-dock(:model="eventable" :actions="actions")
</template>
