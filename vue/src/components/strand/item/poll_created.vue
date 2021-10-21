<script lang="coffee">
import PollService    from '@/shared/services/poll_service'
import AbilityService from '@/shared/services/ability_service'
import EventBus       from '@/shared/services/event_bus'
import EventService from '@/shared/services/event_service'
import { pick, assign } from 'lodash'

export default
  props:
    event: Object
    isReturning: Boolean
    collapsed: Boolean

  created: ->
    EventBus.$on 'stanceSaved', => EventBus.$emit 'refreshStance'
    @watchRecords
      collections: ["stances"]
      query: (records) =>
        @myStance = @poll.myStance()

  beforeDestroy: ->
    EventBus.$off 'showResults'
    EventBus.$off 'stanceSaved'

  data: ->
    buttonPressed: false
    myStance: null

  computed:
    eventable: -> @event.model()
    poll: -> @eventable
    showResults: -> @poll.showResults()

    menuActions: ->
      assign(
        pick EventService.actions(@event, @), ['pin_event', 'unpin_event', 'move_event', 'copy_url']
      ,
        pick PollService.actions(@poll, @), ['edit_poll', 'notification_history', 'show_history', 'export_poll', 'print_poll', 'discard_poll', 'add_poll_to_thread']
      )
    dockActions: ->
      pick PollService.actions(@poll, @), ['reopen_poll', 'show_results', 'hide_results', 'translate_poll', 'edit_stance', 'announce_poll', 'remind_poll', 'close_poll']

</script>

<template lang="pug">
section.strand-item.poll-created
  v-layout(justify-space-between)
    h1.poll-common-card__title.headline.pb-1(tabindex="-1")
      poll-common-type-icon.mr-2(:poll="poll")
      router-link(:to="urlFor(poll)" v-if='!poll.translation.title') {{poll.title}}
      translation(v-if="poll.translation.title" :model='poll', field='title')
      tags-display(:tags="poll.tags()")
  poll-common-closing-at(:poll='poll')
  .pt-2(v-if="!collapsed")
    poll-common-set-outcome-panel(:poll='poll' v-if="!poll.outcome()")
    poll-common-outcome-panel(:outcome='poll.outcome()' v-if='poll.outcome()')
    formatted-text.poll-common-details-panel__details(:model="poll" column="details")
    link-previews(:model="poll")
    attachment-list(:attachments="poll.attachments")
    document-list(:model='poll')
    //- p.caption(v-if="!poll.pollOptionNames.length" v-t="'poll_common.no_voting'")
    div.body-2(v-if="poll.pollOptionNames.length")
      .poll-common-card__results-shown(v-if='showResults')
        poll-common-chart-panel(:poll='poll')
      poll-common-action-panel(:poll='poll')
    .caption(v-t="{path: 'poll_common_action_panel.draft_mode', args: {poll_type: poll.pollType}}" v-if='!poll.closingAt')
    action-dock.my-2(small :actions="dockActions" :menu-actions="menuActions")
    poll-common-votes-panel(v-if="!poll.stancesInDiscussion && poll.showResults()" :poll="poll")
</template>
