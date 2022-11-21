<script lang="coffee">
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import LmoUrlService from '@/shared/services/lmo_url_service'

import {compact, isEmpty}  from 'lodash'

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
        window.location.host = @poll.group().newHost if @poll.group().newHost

        EventBus.$emit 'currentComponent',
          group: poll.group()
          poll:  poll
          title: poll.title
          page: 'pollPage'

        if @$route.query.set_outcome
          EventBus.$emit 'openModal',
            component: 'PollCommonOutcomeModal'
            props:
              outcome: Records.outcomes.build(pollId: poll.id)

        if @$route.query.change_vote
          EventBus.$emit 'openModal',
            component: 'PollCommonEditVoteModal'
            props:
              stance: myLastStanceFor(poll)

      .catch (error) ->
        EventBus.$emit 'pageError', error
        EventBus.$emit 'openAuthModal' if error.status == 403 && !Session.isSignedIn()

</script>

<template lang="pug">
.poll-page
  v-main
    v-container.max-width-800.pa-sm-3.pa-0
      loading(:until="poll")
        poll-common-card(:poll='poll' is-page)
</template>
