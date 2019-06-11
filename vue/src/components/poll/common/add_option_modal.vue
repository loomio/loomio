<script lang="coffee">
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import { listenForLoading } from '@/shared/helpers/listen'
import { applySequence }    from '@/shared/helpers/apply'
import { submitPoll } from '@/shared/helpers/form'
import PollModalMixin from '@/mixins/poll_modal'

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
  .lmo-disabled-form(v-show='isDisabled')
  v-card-title
    v-icon mdi-lightbulb-on-outline
    h1.lmo-h1
      span(v-t="'poll_common_add_option.modal.title'")
  v-card-text
    .poll-common-add-option-form
      poll-common-form-options(:poll='poll')
  v-card-actions
      v-btn(@click='submit()', v-t="'poll_common_add_option.form.add_options'")
</template>
