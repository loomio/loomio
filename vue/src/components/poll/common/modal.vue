<script lang="coffee">
import Records from '@/shared/services/records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
import { submitPoll }    from '@/shared/helpers/form'
import { iconFor }                from '@/shared/helpers/poll'
import { applyPollStartSequence } from '@/shared/helpers/apply'

export default
  mixins: [AnnouncementModalMixin]
  props:
    poll: Object
    close: Function
  data: ->
    announcement: {}
  created: ->
    applyPollStartSequence @,
      afterSaveComplete: (event) =>
        @announcement = Records.announcements.buildFromModel(event)

    @submit = submitPoll @, @poll,
      broadcaster: @
      successCallback: (data) =>
        pollKey = data.polls[0].key
        Records.polls.findOrFetchById(pollKey, {}, true).then (poll) =>
          @close()
          @openAnnouncementModal(Records.announcements.buildFromModel(poll))

  computed:
    title_key: ->
      mode = if @poll.isNew()
        'start'
      else
        'edit'
      'poll_' + @poll.pollType + '_form.'+mode+'_header'

  methods:
    icon: ->
      iconFor(@poll)

</script>
<template lang="pug">
v-card.poll-common-modal(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
  submit-overlay(:value="poll.processing")
  v-card-title
    h1.headline(v-t="title_key")
    v-spacer
    dismiss-modal-button(:close='close')
  v-card-text
    poll-common-directive(:poll='poll', name='form', :modal='true')
  v-card-actions.poll-common-form-actions
    v-spacer
    v-btn.poll-common-form__submit(color="primary" @click='submit()', v-if='!poll.isNew()', v-t="'poll_common_form.update'", aria-label="$t('poll_common_form.update')")
    v-btn.poll-common-form__submit(color="primary" @click='submit()', v-if='poll.isNew() && poll.groupId', v-t="'poll_common_form.start'", aria-label="$t('poll_common_form.start')")
    v-btn.poll-common-form__submit(color="primary" @click='submit()', v-if='poll.isNew() && !poll.groupId', v-t="'common.action.next'", aria-label="$t('common.action.next')")
</template>
