<script lang="coffee">
import AbilityService from '@/shared/services/ability_service'
import { map, compact, pick } from 'lodash-es'

export default
  props:
    poll: Object

  computed:
    groups: ->
      map compact([@poll.group(), @poll.discussion()]), (model) =>
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
v-layout.poll-common-card-header(align-center mr-3 ml-2 pt-2 wrap)
  v-breadcrumbs(:items="groups" divider=">")
  v-spacer
  span.grey--text.body-2
    time-ago(:date='poll.createdAt')
</template>

<style lang="sass">
.poll-common-card-header
  .v-breadcrumbs
    padding: 0px 10px
</style>
