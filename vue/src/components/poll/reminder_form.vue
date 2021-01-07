<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import Flash from '@/shared/services/flash'
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete'
import StanceService from '@/shared/services/stance_service'
import {map, debounce, without, filter, uniq, uniqBy, some, find, compact} from 'lodash'

export default
  components:
    RecipientsAutocomplete: RecipientsAutocomplete

  props:
    poll: Object

  data: ->
    users: []
    userIds: []
    isMember: {}
    isMemberAdmin: {}
    isStanceAdmin: {}
    reset: false
    saving: false
    loading: false
    initialRecipients: []
    actionNames: []
    service: StanceService
    query: ''

  computed:
    someRecipients: ->
      @poll.recipientAudience ||
      @poll.recipientUserIds.length ||
      @poll.recipientEmails.length

  methods:
    submit: ->
      @saving = true
      Records.remote.post "polls/#{@poll.id}/remind",
        poll:
          recipient_audience: @poll.recipientAudience
          recipient_user_ids: @poll.recipientUserIds
          recipient_message: @poll.recipientMessage
      .then (data) =>
        count = data.count
        Flash.success('announcement.flash.success', { count: count })
        EventBus.$emit('closeModal')
      .finally =>
        @saving = false

</script>

<template lang="pug">
.poll-remind
  .pa-4
    .d-flex.justify-space-between
      h1.headline(v-t="'announcement.form.poll_reminder.title'")
      dismiss-modal-button
    recipients-autocomplete(
      existingOnly
      :label="$t('announcement.form.poll_reminder.helptext')"
      :placeholder="$t('announcement.form.placeholder')"
      :model="poll"
      :reset="reset"
      :excludedUserIds="userIds"
      :excludedAudiences="['group', 'discussion_group']"
      :initialRecipients="initialRecipients"
      @new-query="newQuery")

    v-text-field(
      :label="$t('announcement.form.poll_reminder.message_label')"
      :placeholder="$t('announcement.form.poll_reminder.message_placeholder')"
      v-model="poll.recipientMessage")

    .d-flex
      v-spacer
      v-btn.poll-members-list__submit(color="primary" :disabled="!someRecipients" :loading="saving" @click="submit" )
        span(v-t="'common.action.remind'")
</template>
