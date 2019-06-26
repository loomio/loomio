<script lang="coffee">
import { submitOnEnter } from '@/shared/helpers/keyboard'
import { submitPoll }    from '@/shared/helpers/form'
import Records from '@/shared/services/records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'

export default
  mixins: [AnnouncementModalMixin]
  props:
    poll: Object
    close: Function
  created: ->
    @submit = submitPoll @, @poll,
      broadcaster: @
      successCallback: (data) =>
        pollKey = data.polls[0].key
        Records.polls.findOrFetchById(pollKey, {}, true).then (poll) =>
          @close()
          @openAnnouncementModal(Records.announcements.buildFromModel(poll))
</script>

<template lang="pug">
v-card-actions.poll-common-form-actions
  v-spacer
  v-btn.poll-common-form__submit(color="primary" @click='submit()', v-if='!poll.isNew()', v-t="'poll_common_form.update'", aria-label="$t('poll_common_form.update')")
  v-btn.poll-common-form__submit(color="primary" @click='submit()', v-if='poll.isNew() && poll.groupId', v-t="'poll_common_form.start'", aria-label="$t('poll_common_form.start')")
  v-btn.poll-common-form__submit(color="primary" @click='submit()', v-if='poll.isNew() && !poll.groupId', v-t="'common.action.next'", aria-label="$t('common.action.next')")
</template>
