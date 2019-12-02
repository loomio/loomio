<script lang="coffee">
import OutcomeService from '@/shared/services/outcome_service'
import parseISO from 'date-fns/parseISO'
export default
  props:
    poll: Object
  data: ->
    outcome: @poll.outcome()
  methods:
    parseISO: parseISO
  computed:
    actions: -> OutcomeService.actions(@outcome, @)
  created: ->
    @watchRecords
      collections: ['outcome']
      query: (records) =>
        @outcome = @poll.outcome()

</script>

<template lang="pug">
v-sheet.pa-4.my-4.poll-common-outcome-panel(v-if="outcome" color="primary lighten-5" elevation="2")
  .title(v-t="'poll_common.outcome'")
  .poll-common-outcome-panel__authored-by.caption.my-2
    span(v-t="{ path: 'poll_common_outcome_panel.authored_by', args: { name: outcome.authorName() } }")
    space
    time-ago(:date="outcome.createdAt")
  .poll-common-outcome__event-info(v-if="outcome.poll().datesAsOptions() && outcome.pollOption()")
    .title {{outcome.eventSummary}}
    span {{exactDate(parseISO(outcome.pollOption().name))}}
    p {{outcome.eventLocation}}
  formatted-text(:model="outcome" column="statement")
  document-list(:model="outcome")
  v-layout(align-center)
    v-spacer
    action-dock(:model="outcome" :actions="actions")
</template>
