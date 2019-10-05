<script lang="coffee">
import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import ModalService  from '@/shared/services/modal_service'
import LmoUrlService from '@/shared/services/lmo_url_service'

import {compact, map, isEmpty}  from 'lodash'

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

        # if @poll.discussionId
        #   discussion = @poll.discussion()
        #   discussionUrl = @urlFor(discussion)+'/'+@poll.createdEvent().sequenceId
        #   @$router.replace(discussionUrl)

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

    groups: ->
      map compact([@poll.group().parent(), @poll.group(), @poll.discussion()]), (model) =>
        text: model.name || model.title
        disabled: false
        to: @urlFor(model)

</script>

<template lang="pug">
loading(:until="poll")
  div(v-if="poll")
    v-container.poll-page.max-width-800
      v-card.pr-4
        v-breadcrumbs(:items="groups" divider=">")
        poll-created(:event="poll.createdEvent()")
</template>
