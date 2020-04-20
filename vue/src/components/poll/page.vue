<script lang="coffee">
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import LmoUrlService from '@/shared/services/lmo_url_service'

import {compact, isEmpty}  from 'lodash'

import { subscribeTo }     from '@/shared/helpers/cable'
import { myLastStanceFor } from '@/shared/helpers/poll'

export default
  data: ->
    poll: null

  created: -> @init()

  methods:
    init: ->
      Records.polls.findOrFetchById(@$route.params.key)
      .then (poll) =>
        @poll = poll
        subscribeTo(@poll)

        # if @poll.discussionId
        #   discussion = @poll.discussion()
        #   discussionUrl = @urlFor(discussion)+'/'+@poll.createdEvent().sequenceId
        #   @$router.replace(discussionUrl).catch (err) => {}

        EventBus.$emit 'currentComponent',
          group: poll.group()
          poll:  poll
          title: poll.title
          page: 'pollPage'

        # if @$route.params.set_outcome
          # ModalService.open 'PollCommonOutcomeModal', outcome: => Records.outcomes.build(pollId: @poll.id)

        # if @$route.params.change_vote
          # ModalService.open 'PollCommonEditVoteModal', stance: => myLastStanceFor(@poll)
      .catch (error) ->
        EventBus.$emit 'pageError', error
        EventBus.$emit 'openAuthModal' if error.status == 403 && !Session.isSignedIn()

</script>

<template lang="pug">
.poll-page
  v-content
    v-container.max-width-800
      loading(:until="poll")
        poll-common-card(:poll='poll' is-page)
</template>
