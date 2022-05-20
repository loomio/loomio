<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Session from '@/shared/services/session'
import Flash  from '@/shared/services/flash'
import PollCommonForm from '@/components/poll/common/form'
import PollCommonChooseTemplate from '@/components/poll/common/choose_template'

export default
  components: {PollCommonForm, PollCommonChooseTemplate}

  data: ->
    poll: null

  methods:
    setPoll: (poll) -> @poll = poll

</script>
<template lang="pug">
.poll-common-start-form
  div.pa-4
    poll-common-form(:poll="poll" v-if="poll" @setPoll="setPoll")
    poll-common-choose-template(v-if="!poll" @setPoll="setPoll")
</template>
