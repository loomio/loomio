<script lang="coffee">
import Session  from '@/shared/services/session'
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import { listenForLoading } from '@/shared/helpers/listen'
import { myLastStanceFor }  from '@/shared/helpers/poll'
import PollCommonDirective from '@/components/poll/common/directive'
import WatchRecords from '@/mixins/watch_records'

export default
  mixins: [WatchRecords]
  components:
    PollCommonDirective: PollCommonDirective

  props:
    poll: Object

  created: ->
    # Records.polls.findOrFetchById(@poll.key)
    EventBus.$on 'showResults', => @buttonPressed = true
    EventBus.$on 'stanceSaved', => EventBus.$emit 'refreshStance'
    @watchRecords
      collections: ["stances"]
      query: (records) =>
        @myLastStance = myLastStanceFor(@poll)?
    # listenForLoading @

  data: ->
    buttonPressed: false
    myLastStance: null

  computed:
    showResults: ->
      @buttonPressed || @myLastStance || @poll.isClosed()
</script>

<template lang="pug">
v-card
  // <div v-if="isDisabled" class="lmo-disabled-form"></div>
  //- loading(v-if='!poll.complete')
  //- .lmo-blank(v-if='poll.complete')
  poll-common-card-header.px-4(:poll='poll')

  v-card-title
    h1.poll-common-card__title.headline
      span(v-if='!poll.translation') {{poll.title}}
      translation(v-if="poll.translation" :model='poll', :field='title')
  v-card-text
    poll-common-set-outcome-panel(:poll='poll')
    poll-common-outcome-panel(:poll='poll', v-if='poll.outcome()')
    poll-common-details-panel(:poll='poll')
    .poll-common-card__results-shown(v-if='showResults')
      poll-common-directive(:poll='poll', name='chart-panel')
      poll-common-add-option-button(:poll='poll')
      poll-common-percent-voted(:poll='poll')
    poll-common-action-panel(:poll='poll')
    .poll-common-card__results-shown(v-if='showResults')
      poll-common-votes-panel(:poll='poll')
</template>
