<script lang="coffee">
import { participantName }       from '@/shared/helpers/poll'

export default
  props:
    stance: Object
  computed:
    participantName: -> participantName(@stance)
</script>

<template lang="pug">
.poll-common-votes-panel__stance(v-if="stance.reason")
  user-avatar(:user="stance.participant()", size="small")
  .poll-common-votes-panel__stance-content
    .poll-common-votes-panel__stance-name-and-option
      strong {{ participantName }}
    formatted-text.poll-common-votes-panel__stance-reason(:model="stance" column="reason")
</template>
