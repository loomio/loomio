<script lang="coffee">
import Records from '@/shared/services/records'
import { iconFor }                from '@/shared/helpers/poll'
import { applyPollStartSequence } from '@/shared/helpers/apply'

export default
  props:
    poll: Object
    close: Function
  data: ->
    announcement: {}
  created: ->
    applyPollStartSequence @,
      afterSaveComplete: (event) =>
        @announcement = Records.announcements.buildFromModel(event)

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
v-card.poll-common-modal
  // <div ng-show="isDisabled" class="lmo-disabled-form"></div>
  submit-overlay(:value="poll.processing")
  v-card-title
    h1.headline(v-t="title_key")
    v-spacer
    dismiss-modal-button(:close='close')
  v-card-text
    poll-common-directive(:poll='poll', name='form', :modal='true')
  poll-common-form-actions(:poll='poll', :close='close')
</template>
