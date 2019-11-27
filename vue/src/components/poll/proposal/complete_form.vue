<script lang="coffee">
import Records from '@/shared/services/records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
import EventBus                 from '@/shared/services/event_bus'
import { submitPoll }    from '@/shared/helpers/form'
import { iconFor }                from '@/shared/helpers/poll'
import { applyPollStartSequence } from '@/shared/helpers/apply'
import { fieldFromTemplate } from '@/shared/helpers/poll'
import { map } from 'lodash'

export default
  mixins: [AnnouncementModalMixin]
  props:
    discussion: Object
    close: Function
  data: ->
    poll: null
  created: ->
    @poll = @newPoll()
    @submit = submitPoll @, @poll,
      successCallback: (data) =>
        @poll = @newPoll()
        pollKey = data.polls[0].key
        EventBus.$emit('pollSaved')
        Records.polls.findOrFetchById(pollKey, {}, true).then (poll) =>
          @openAnnouncementModal(Records.announcements.buildFromModel(poll))

  computed:
    title_key: ->
      mode = if @poll.isNew()
        'start'
      else
        'edit'
      'poll_' + @poll.pollType + '_form.'+mode+'_header'

  methods:
    newPoll: ->
      Records.polls.build
        pollType:              'proposal'
        discussionId:          @discussion.id
        groupId:               @discussion.groupId
        pollOptionNames:       map fieldFromTemplate('proposal', 'poll_options_attributes'), 'name'

    icon: ->
      iconFor(@poll)

</script>
<template lang="pug">
.poll-proposal-complete-form.pa-2(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value="poll.processing")
  v-card-title
    h1.headline(v-t="title_key")
    v-spacer
  v-card-text
    poll-common-directive(:poll='poll', name='form')
  v-card-actions.poll-common-form-actions
    v-spacer
    v-btn.poll-common-form__submit(color="primary" @click='submit()' v-t="'poll_common_form.start'")
</template>
