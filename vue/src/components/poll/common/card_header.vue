<script lang="coffee">
import AbilityService from '@/shared/services/ability_service'
import { map, compact, pick } from 'lodash'

export default
  props:
    poll: Object

  computed:
    groups: ->
      map compact([(@poll.groupId && @poll.group()), (@poll.discussionId && @poll.discussion())]), (model) =>
        if model.isA('discussion')
          text: model.name || model.title
          disabled: false
          to: @urlFor(model)+'/'+@poll.createdEvent().sequenceId
        else
          text: model.name || model.title
          disabled: false
          to: @urlFor(model)
</script>

<template lang="pug">
.poll-common-card-header.d-flex.align-center.mr-3.ml-2.pb-2.pt-4.flex-wrap
  v-breadcrumbs(:items="groups")
    template(v-slot:divider)
      v-icon mdi-chevron-right
  v-spacer
  span.text--secondary.text-body-2
    time-ago(:date='poll.createdAt')
</template>

<style lang="sass">
.poll-common-card-header
  .v-breadcrumbs
    padding: 0px 10px
</style>
