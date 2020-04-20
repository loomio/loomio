<script lang="coffee">
import RecordLoader from '@/shared/services/record_loader'
import Records from '@/shared/services/records'
import EventBus     from '@/shared/services/event_bus'
import { fieldFromTemplate } from '@/shared/helpers/poll'

export default
  components:
    PollCommonDirective: -> import('@/components/poll/common/directive')

  props:
    poll: Object

  data: ->
    stances: []
    order: 'newest_first'
    sortOptions:
      [
        {text: @$t('poll_common_votes_panel.newest_first'), value: "newest_first"}
        {text: @$t('poll_common_votes_panel.undecided_first'), value: "undecided_first"}
      ]

  created: ->
    @refresh()

    @watchRecords
      collections: ['stances']
      query: => @findRecords()

  computed:
    latestStances: ->
      @stances.filter (stance) -> stance.latest

  methods:
    findRecords: ->
      chain = Records.stances.collection.chain().find(pollId: @poll.id).find(latest: true)
      chain = switch @order
        when 'newest_first'
          chain.simplesort('castAt', true)
        when 'undecided_first'
          chain.simplesort('castAt', false)
      @stances = chain.limit(@loader.limit()).data()

    refresh: ->
      @initLoader().fetchRecords()

    initLoader: ->
      @loader = new RecordLoader
        collection: 'stances'
        params:
          poll_key: @poll.key
          order: {
            newest_first: "cast_at DESC NULLS LAST"
            undecided_first: "cast_at DESC NULLS FIRST"
          }[@order]

</script>

<template lang="pug">
.poll-common-votes-panel
  v-layout.poll-common-votes-panel__header
    v-subheader(v-t="'poll_common.votes'")
    v-spacer
    v-select(style="max-width: 200px" small solo v-model='order' :items="sortOptions" @change='refresh()' aria-label="$t('poll_common_votes_panel.change_results_order')")
  .poll-common-votes-panel__no-votes(v-if='!poll.stancesCount' v-t="'poll_common_votes_panel.no_votes_yet'")
  .poll-common-votes-panel__has-votes(v-if='poll.stancesCount')
    v-list
      .poll-common-votes-panel__stance(v-for='stance in latestStances' :key='stance.id')
        v-list-item-avatar
          user-avatar.lmo-flex__no-shrink(:user='stance.participant()' size='thirtysix')
        .poll-common-votes-panel__stance-content
          .poll-common-votes-panel__stance-name-and-option
            v-layout(align-center)
              strong.pr-2 {{ stance.participantName() }}
              poll-common-stance-choice(v-if="stance.castAt && poll.singleChoice()" :poll="poll" :stance-choice="stance.stanceChoice()")
              span.caption(v-if='!stance.castAt' v-t="'poll_common_votes_panel.undecided'" )
          .poll-common-stance(v-if="stance.castAt")
            span.caption(v-if='stance.totalScore() == 0' v-t="'poll_common_votes_panel.none_of_the_above'" )
            v-layout(v-if="!poll.singleChoice()" wrap align-center)
              poll-common-stance-choice(:stance-choice='choice' :poll='poll' v-if='choice.show()' v-for='choice in stance.orderedStanceChoices()' :key='choice.id')
            formatted-text.poll-common-stance-created__reason(:model="stance" column="reason")
    v-btn(v-if='loader.limit() < poll.stancesCount' v-t="'common.action.load_more'" @click='loader.fetchRecords()')
</template>

<style lang="sass">
.poll-common-votes-panel__stance
	display: flex
	align-items: flex-start
	margin: 7px 0

</style>
