<script lang="coffee">
import { listenForTranslations } from '@/shared/helpers/listen'
import { participantName }       from '@/shared/helpers/poll'

export default
  props:
    stance: Object
  created: ->
    # listenForTranslations $scope
  computed:
    participantName: -> participantName(@stance)
</script>

<template lang="pug">
.poll-common-votes-panel__stance(v-if="stance.reason")
  user-avatar(:user="stance.participant()", size="small")
  .poll-common-votes-panel__stance-content
    .poll-common-votes-panel__stance-name-and-option
      strong > {{ participantName }}
    .poll-common-votes-panel__stance-reason(v-if="stance.reason")
      span(v-if="!stance.translation", :marked="stance.reason")
      translation(v-if="stance.translation", :model="stance", field="reason")
</template>
