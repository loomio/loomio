<script lang="coffee">
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import ModalService  from '@/shared/services/modal_service'
import LmoUrlService from '@/shared/services/lmo_url_service'

import _isEmpty     from 'lodash/isEmpty'

import { subscribeTo }     from '@/shared/helpers/cable'
import { myLastStanceFor } from '@/shared/helpers/poll'

export default
  data: ->
    poll: {}
  created: ->
    Records.polls.findOrFetchById(@$route.params.key, {}, true).then @init, (error) ->
      EventBus.$emit 'pageError', error
  methods:
    init: (poll) ->
      if poll and _isEmpty @poll?
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
    isEmptyPoll: ->
      _isEmpty @poll

</script>

<template>
  <div class="lmo-two-column-layout">
    <loading v-if="isEmptyPoll"></loading>
    <main v-if="!isEmptyPoll" class="poll-page lmo-row">
      <poll-common-example-card v-if="poll.example" :poll="poll"></poll-common-example-card>
      <group-theme v-if="poll.group()" :group="poll.group()" :discussion="poll.discussion()" :compact="true"></group-theme>
      <div class="poll-page__main-content">
        <membership-card :group="poll.guestGroup()"></membership-card>
        <membership-card :group="poll.guestGroup()" :pending="true"></membership-card>
        <poll-common-card :poll="poll" class="lmo-card--no-padding lmo-column-left"></poll-common-card>
      </div>
    </main>
  </div>
</template>
