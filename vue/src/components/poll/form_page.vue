<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Session from '@/shared/services/session'
import Flash  from '@/shared/services/flash'
import PollCommonForm from '@/components/poll/common/form'
import PollCommonChooseTemplate from '@/components/poll/common/choose_template'

export default
  components: {PollCommonForm, PollCommonChooseTemplate}

  data: ->
    loading: false
    poll: null
    group: null
    discussion: null

  created: ->
    if templateId = parseInt(@$route.query.template_id)
      @loading = true
      Records.polls.findOrFetchById(templateId).then (poll) =>
        @poll = poll.cloneTemplate()
        if Session.user().groupIds().includes(poll.groupId)
          @poll.groupId = poll.groupId
          @group = @poll.group()
        @loading = false

    if discussionId = parseInt(@$route.query.discussion_id)
      @loading = true
      Records.discussions.findOrFetchById(discussionId).then (discussion) =>
        @discussion = discussion
        @group = discussion.group()
        @loading = false

    if groupId = parseInt(@$route.query.group_id)
      @loading = true
      Records.groups.findOrFetchById(groupId).then (group) =>
        @group = group
        @loading = false

    if @$route.params.key
      @loading = true
      Records.polls.findOrFetchById(@$route.params.key)
      .then (poll) =>
        @poll = poll.clone()
        EventBus.$emit 'currentComponent',
          group: poll.group()
          poll:  poll
          title: poll.title
          page: 'pollFormPage'
        @loading = false
      .catch (error) ->
        EventBus.$emit 'pageError', error
        if error.status == 403 && !Session.isSignedIn()
          EventBus.$emit 'openAuthModal'

  methods:
    setPoll: (poll) ->
      @poll = poll

</script>
<template lang="pug">
.poll-form-page
  v-main
    v-container.max-width-800.px-0.px-sm-3
      loading(:until="!loading")
        v-card.poll-common-modal
          div.pa-4
            poll-common-form(
              v-if="poll"
              :poll="poll"
              @setPoll="setPoll"
              redirect-on-save
            )
            poll-common-choose-template(
              v-if="!poll"
              @setPoll="setPoll"
              :discussion="discussion"
              :group="group"
            )
</template>
