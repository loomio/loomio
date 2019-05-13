<script lang="coffee">
import PollModalMixin from '@/mixins/poll_modal'

export default
  mixins: [PollModalMixin]
  props:
    outcome: Object
  created: ->
    @submit = submitOutcome @, @outcome,
      successCallback: => @closeModal()
</script>
<template lang="pug">
.lmo-md-actions
  v-btn.md-raised.md-primary.poll-common-outcome-form__submit(@click='submit()', v-t="'poll_common_outcome_form.submit'")
</template>
