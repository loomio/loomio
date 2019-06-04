<script lang="coffee">
import moment from 'moment'
import { submitForm } from '@/shared/helpers/form'

export default
  props:
    poll: Object
    close: Function
  created: ->
    @poll.closingAt = moment().add(1, 'day')
    @submit = submitForm @, @poll,
      submitFn: @poll.reopen
      flashSuccess: "poll_common_reopen_form.#{@poll.pollType}_reopened"
      successCallback: =>
        @close()
  # data: ->
  # methods:
</script>
<template lang="pug">
.lmo-md-action
  v-btn.md-raised.md-primary.poll-common-reopen-form__submit(@click='submit()', v-t="'common.action.reopen'")
</template>
<style lang="scss">
</style>
