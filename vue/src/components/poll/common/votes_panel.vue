<script lang="coffee">
import RecordLoader from '@/shared/services/record_loader'
import Records from '@/shared/services/records'
import EventBus     from '@/shared/services/event_bus'
import { fieldFromTemplate } from '@/shared/helpers/poll'

export default
  props:
    poll: Object

  data: ->
    stances: []
    page: 1
    pageSize: 25
    loader: null

  created: ->
    @refresh()

    @watchRecords
      collections: ['stances']
      query: => @findRecords()

  computed:
    totalPages: ->
      Math.ceil(parseFloat(@loader.total) / parseFloat(@pageSize))

    latestStances: ->
      @stances.filter (stance) -> stance.latest

  watch:
    page: ->
      @loader.fetchRecords(from: @pageSize * (@page - 1))
      @findRecords()

  methods:
    findRecords: ->
      chain = Records.stances.collection.chain().
        find(pollId: @poll.id).
        find(latest: true).
        find(revokedAt: null)
        .simplesort('castAt', true)
      @stances = chain.offset((@page-1) * @pageSize).limit(@pageSize).data()

    refresh: ->
      @initLoader().fetchRecords()

    initLoader: ->
      @loader = new RecordLoader
        collection: 'stances'
        params:
          per: @pageSize
          poll_id: @poll.id
          order: "cast_at DESC NULLS LAST"

</script>

<template lang="pug">
.poll-common-votes-panel
  v-layout.poll-common-votes-panel__header
    .subtitle-1(v-t="'poll_common.votes'")
    v-spacer
    //- v-select(style="max-width: 200px" dense solo v-model='order' :items="sortOptions" @change='refresh()' aria-label="$t('poll_common_votes_panel.change_results_order')")
  .poll-common-votes-panel__no-votes(v-if='!poll.votersCount' v-t="'poll_common_votes_panel.no_votes_yet'")
  .poll-common-votes-panel__has-votes(v-if='poll.votersCount')
    .poll-common-votes-panel__stance(v-for='stance in latestStances' :key='stance.id')
      .poll-common-votes-panel__avatar.pr-3
        user-avatar(:user='stance.participant()' size='24')
      .poll-common-votes-panel__stance-content
        .poll-common-votes-panel__stance-name-and-option
          v-layout.body-2(align-center)
            .pr-2.text--secondary {{ stance.participantName() }}
            poll-common-stance-choice(v-if="poll.showResults() && stance.castAt && poll.singleChoice()" :poll="poll" :stance-choice="stance.stanceChoice()")
            span.caption(v-if='!stance.castAt' v-t="'poll_common_votes_panel.undecided'" )
            time-ago.text--secondary(v-if="stance.castAt" :date="stance.castAt")
        .poll-common-stance(v-if="poll.showResults() && stance.castAt")
          poll-common-stance-choices(:stance='stance')
          formatted-text.poll-common-stance-created__reason(:model="stance" column="reason")
    v-pagination(v-model="page" :length="totalPages" :disabled="totalPages == 1")
</template>

<style lang="sass">
.poll-common-votes-panel__stance
	display: flex
	align-items: flex-start
	margin: 7px 0

</style>
