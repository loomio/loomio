<script lang="coffee">
{ listenForTranslations } = require 'shared/helpers/listen'
{ participantName }       = require 'shared/helpers/poll'

module.exports =
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
