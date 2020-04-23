<script lang="coffee">
import Records from '@/shared/services/records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
import EventBus                 from '@/shared/services/event_bus'
import Flash  from '@/shared/services/flash'
import Session from '@/shared/services/session'
import { iconFor }                from '@/shared/helpers/poll'
import { fieldFromTemplate } from '@/shared/helpers/poll'
import { map } from 'lodash'
import { onError } from '@/shared/helpers/form'
import AppConfig from '@/shared/services/app_config'

export default
  mixins: [AnnouncementModalMixin]
  props:
    discussion: Object
    close: Function

  data: ->
    poll: null
    shouldReset: false

  created: ->
    @init()

  computed:
    title_key: ->
      mode = if @poll.isNew()
        'start'
      else
        'edit'
      'poll_' + @poll.pollType + '_form.'+mode+'_header'

  methods:
    submit: ->
      @poll.customFields.deanonymize_after_close = @poll.deanonymizeAfterClose if @poll.anonymous
      @poll.customFields.can_respond_maybe = @poll.canRespondMaybe if @poll.pollType == 'meeting'
      @poll.setErrors({})
      @poll.save()
      .then (data) =>
        @init()
        @reset()
        pollKey = data.polls[0].key
        Records.polls.findOrFetchById(pollKey, {}, true).then (poll) =>
          EventBus.$emit 'pollSaved', poll
          Flash.success "poll_#{poll.pollType}_form.#{poll.pollType}_created"
          @openAnnouncementModal(Records.announcements.buildFromModel(poll))
      .catch onError(@poll)

    init: ->
      @poll = @newPoll()

    reset: ->
      @shouldReset = !@shouldReset

    newPoll: ->
      pollOptionNames = if AppConfig.features.app.proposal_consent_default
        ['consent', 'abstain', 'objection']
      else
        map fieldFromTemplate('proposal', 'poll_options_attributes'), 'name'

      Records.polls.build
        pollType: 'proposal'
        discussionId: @discussion.id
        groupId: @discussion.groupId
        pollOptionNames: pollOptionNames
        detailsFormat: Session.defaultFormat()

    icon: ->
      iconFor(@poll)

</script>
<template lang="pug">
.poll-proposal-complete-form.pa-2(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value="poll && poll.processing")
  v-card-title
    h1.headline(v-t="title_key")
    v-spacer
  v-card-text
    poll-common-directive(:poll='poll', name='form' :should-reset="shouldReset")
  v-card-actions.poll-common-form-actions
    v-spacer
    v-btn.poll-common-form__submit(color="primary" @click='submit()' v-t="'poll_common_form.start'")
</template>
