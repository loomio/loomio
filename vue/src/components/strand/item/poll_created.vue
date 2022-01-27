<script lang="coffee">
import PollService    from '@/shared/services/poll_service'
import AbilityService from '@/shared/services/ability_service'
import EventBus       from '@/shared/services/event_bus'
import EventService from '@/shared/services/event_service'
import { pick, pickBy, assign } from 'lodash'

export default
  props:
    event: Object
    collapsed: Boolean
    eventable: Object

  created: ->
    EventBus.$on 'stanceSaved', => EventBus.$emit 'refreshStance'
    @watchRecords
      collections: ["stances", "polls"]
      query: (records) =>
        @pollActions = PollService.actions(@poll)
        @eventActions = EventService.actions(@event, @)
        @myStance = @poll.myStance()

  beforeDestroy: ->
    EventBus.$off 'stanceSaved'

  data: ->
    buttonPressed: false
    myStance: null
    pollActions: null
    eventActions: null

  computed:
    poll: -> @eventable

    menuActions: ->
      assign(
        pickBy @eventActions, (v) -> v.menu
      ,
        pickBy @pollActions, (v) -> v.menu
      )
    dockActions: ->
      pickBy @pollActions, (v) -> v.dock

</script>

<template lang="pug">
section.strand-item.poll-created
  v-layout(justify-space-between)
    .poll-common-card__title.headline.pb-1(tabindex="-1")
      poll-common-type-icon(:poll="poll")
      space
      router-link(:to="urlFor(poll)" v-if='!poll.translation.title') {{poll.title}}
      translation(v-if="poll.translation.title" :model='poll', field='title')
      tags-display(:tags="poll.tags()")
      space
      small.text-caption
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
      poll-common-chart-panel(:poll='poll')
      poll-common-action-panel(:poll='poll')
    .caption(v-t="{path: 'poll_common_action_panel.draft_mode', args: {poll_type: poll.pollType}}" v-if='!poll.closingAt')
    action-dock.my-2(:actions="dockActions" :menu-actions="menuActions")
    poll-common-votes-panel(v-if="!poll.stancesInDiscussion && poll.showResults" :poll="poll")
</template>
