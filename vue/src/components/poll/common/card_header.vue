<script lang="coffee">
import AbilityService from '@/shared/services/ability_service'
import PollService from '@/shared/services/poll_service'
import { map, compact, pick } from 'lodash'

export default
  props:
    poll: Object

  computed:
    menuActions: ->
      pick PollService.actions(@poll, @), ['edit_poll', 'close_poll', 'reopen_poll', 'export_poll', 'delete_poll']

    dockActions: ->
      pick PollService.actions(@poll, @), ['announce_poll']

    groups: ->
      map compact([@poll.group().parent(), @poll.group(), @poll.discussion()]), (model) =>
        text: model.name || model.title
        disabled: false
        to: @urlFor(model)
</script>

<template lang="pug">
v-layout.poll-common-card-header(align-center mx-2 pt-2)
  v-breadcrumbs(:items="groups" divider=">")
  v-spacer
  action-dock(:actions="dockActions")
  action-menu(:actions="menuActions")
</template>

<style lang="sass">
.poll-common-card-header
  .v-breadcrumbs
    padding: 0px 10px
</style>
