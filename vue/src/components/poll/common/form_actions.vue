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
          @$router.push("/p/#{pollKey}")
          @openAnnouncementModal(Records.announcements.buildFromModel(poll))
</script>

<template>
  <div class="poll-common-form-actions lmo-md-actions">
    <span v-if="!poll.isNew()"></span>
    <v-btn v-if="poll.isNew()" @click="$emit('previousStep')" v-t="'common.action.back'" aria-label="$t('common.action.back')" class="md-accent"></v-btn>
    <div class="lmo-md-actions">
      <!-- <outlet name="before-poll-submit" model="poll"></outlet> -->
      <v-btn @click="submit()" v-if="!poll.isNew()" v-t="'poll_common_form.update'" aria-label="$t('poll_common_form.update')" class="md-primary md-raised poll-common-form__submit"></v-btn>
      <v-btn @click="submit()" v-if="poll.isNew() && poll.groupId" v-t="'poll_common_form.start'" aria-label="$t('poll_common_form.start')" class="md-primary md-raised poll-common-form__submit"></v-btn>
      <v-btn @click="submit()" v-if="poll.isNew() && !poll.groupId" v-t="'common.action.next'" aria-label="$t('common.action.next')" class="md-primary md-raised poll-common-form__submit"></v-btn>
    </div>
  </div>
</template>
