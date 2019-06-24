<script lang="coffee">
import AbilityService from '@/shared/services/ability_service'
import { iconFor } from '@/shared/helpers/poll'
import UrlFor         from '@/mixins/url_for'
import { map, compact } from 'lodash'
export default
  mixins: [UrlFor]
  props:
    poll: Object

  computed:
    pollHasActions: ->
      AbilityService.canEditPoll(@poll)  ||
      AbilityService.canClosePoll(@poll) ||
      AbilityService.canDeletePoll(@poll)||
      AbilityService.canExportPoll(@poll)

    icon: ->
      iconFor(@poll)

    groups: ->
      map compact([@poll.group().parent(), @poll.group(), @poll.discussion()]), (model) =>
        text: model.name || model.title
        disabled: false
        to: @urlFor(model)
</script>

<template lang="pug">
v-layout.poll-common-card-header(align-center mx-2 pt-2)
  //- v-icon {{'mdi ' + icon()}}
  v-breadcrumbs(:items="groups" divider=">")
  v-spacer
  poll-common-actions-dropdown(:poll="poll", v-if="pollHasActions")
</template>
