<style lang="scss">
</style>

<script lang="coffee">
AppConfig    = require 'shared/services/app_config'
Records      = require 'shared/services/records'
ModalService = require 'shared/services/modal_service'

{ fieldFromTemplate } = require 'shared/helpers/poll'

_map = require 'lodash/map'
_reduce = require 'lodash/reduce'

module.exports =
  data: ->
    # isPollModalOpen: false
    modals: _reduce(@pollTypes(), (modals, poll) =>
      modals[poll] = false
      modals
    , {})
  props:
    discussion:
      type: Object
      default: () => ({})
    group:
      type: Object
      default: () => ({})
  methods:
    openPollModal: (pollType) ->
      @modals[pollType] = true
    closePollModal: (pollType) ->
      => @modals[pollType] = false # N.B: this must be a closure to be passed down to sub-component @click

    pollTypes: -> AppConfig.pollTypes

    newPoll: (pollType) ->
      Records.polls.build
        pollType:              pollType
        discussionId:          @discussion.id
        groupId:               @discussion.groupId or @group.id
        pollOptionNames:       _map @callFieldFromTemplate(pollType, 'poll_options_attributes'), 'name'

    # startPoll: (pollType) ->
    #   # ModalService.open 'PollCommonStartModal', poll: =>
    #   Records.polls.build
    #     pollType:              pollType
    #     discussionId:          @discussion.id
    #     groupId:               @discussion.groupId or @group.id
    #     pollOptionNames:       _map @callFieldFromTemplate(pollType, 'poll_options_attributes'), 'name'

    callFieldFromTemplate: (pollType, field) ->
      fieldFromTemplate(pollType, field)

    getAriaLabelForPollType: (pollType) ->
      @$t("poll_types.#{pollType}")

</script>

<template lang="pug">
v-list.decision-tools-card__poll-types
  v-list-tile.decision-tools-card__poll-type(:class="'decision-tools-card__poll-type--' + pollType", @click='openPollModal(pollType)', v-for='(pollType, index) in pollTypes()', :key='index', :aria-label='getAriaLabelForPollType(pollType)')
    v-dialog(v-model='modals[pollType]', lazy='')
      poll-common-start-modal(:poll='newPoll(pollType)', :close="closePollModal(pollType)")
    v-list-tile-avatar
      v-icon {{callFieldFromTemplate(pollType, 'material_icon')}}
    v-list-tile-content
      v-list-tile-title(v-t="'poll_types.' + pollType")
      v-list-tile-sub-title(v-t="'poll_' + pollType + '_form.tool_tip_collapsed'")
</template>
