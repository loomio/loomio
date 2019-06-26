<script lang="coffee">
import PollModalMixin from '@/mixins/poll_modal'
import {sortBy} from 'lodash'

export default
  mixins: [ PollModalMixin ]
  props:
    stance: Object
</script>

<template lang="pug">
.poll-common-change-your-vote
  v-subheader(v-t="'poll_common.your_response'")
  poll-common-stance(:stance="stance")
</template>
