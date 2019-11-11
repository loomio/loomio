<script lang="coffee">
import Records  from '@/shared/services/records'
import AppConfig  from '@/shared/services/app_config'
import EventBus from '@/shared/services/event_bus'
import { submitPoll } from '@/shared/helpers/form'
import PollModalMixin from '@/mixins/poll_modal'
import {uniq, without, isEqual} from 'lodash'

export default
  mixins: [PollModalMixin]
  props:
    poll: Object
    close: Function

  data: ->
    isDisabled: false
    submit: null

  created: ->
    @submit = submitPoll @, @poll,
      submitFn: @poll.addOptions
      prepareFn: =>
        @poll.addOption()
      successCallback: =>
        @close()
      flashSuccess: "poll_common_add_option.form.options_added"
</script>

<template lang="pug">
v-card.poll-common-modal
  submit-overlay(:value='poll.processing')
  v-card-title
    h1.headline(v-t="'poll_common_add_option.modal.title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    poll-common-form-options-field(:poll="poll" v-if="poll.pollType != 'meeting'" add-options-only)
    poll-meeting-form-options-field(:poll="poll" v-if="poll.pollType == 'meeting'" add-options-only)
  v-card-actions
    v-spacer
    v-btn(color="primary" :disabled="!poll.isModified()" @click='submit()' v-t="'poll_common_add_option.form.add_options'")
</template>
