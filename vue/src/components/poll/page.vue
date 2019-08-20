<script lang="coffee">
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import ModalService  from '@/shared/services/modal_service'
import LmoUrlService from '@/shared/services/lmo_url_service'

import {compact, isEmpty}  from 'lodash'

import { subscribeTo }     from '@/shared/helpers/cable'
import { myLastStanceFor } from '@/shared/helpers/poll'

export default
  data: ->
    poll: null

  created: ->
    Records.polls.findOrFetchById(@$route.params.key, {}, true).then @init, (error) ->
      EventBus.$emit 'pageError', error
    EventBus.$on 'signedIn', =>
      Records.polls.findOrFetchById(@$route.params.key, {}, true).then @init, (error) ->
        EventBus.$emit 'pageError', error

  methods:
    init: (poll) ->
      if poll and isEmpty @poll?
        @poll = poll

        EventBus.$emit 'currentComponent',
          group: poll.group()
          poll:  poll
          title: poll.title
          page: 'pollPage'
          skipScroll: true

        subscribeTo(@poll)

        if @$route.params.set_outcome
          ModalService.open 'PollCommonOutcomeModal', outcome: => Records.outcomes.build(pollId: @poll.id)

        if @$route.params.change_vote
          ModalService.open 'PollCommonEditVoteModal', stance: => myLastStanceFor(@poll)

  computed:
    isEmptyPoll: -> isEmpty @poll

</script>

<template lang="pug">
loading(:until="poll")
  div(v-if="poll")
    v-container.poll-page.max-width-800
      loading(v-if='isEmptyPoll')
      v-layout(column v-if='!isEmptyPoll')
        poll-common-example-card(v-if='poll.example', :poll='poll')
        poll-common-card.mb-3(:poll='poll')
        membership-card(:group='poll.guestGroup()')
        membership-card(:group='poll.guestGroup()', :pending='true')
</template>
