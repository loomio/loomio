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

<template>
  <v-list class="decision-tools-card__poll-types">
    <v-list-tile
      class="decision-tools-card__poll-type"
      :class="'decision-tools-card__poll-type--' + pollType"
      @click="openPollModal(pollType)"
      v-for="(pollType, index) in pollTypes()"
      :key=index
      :aria-label="getAriaLabelForPollType(pollType)"
    >
      <v-dialog
        v-model="modals[pollType]"
        lazy
      >
        <poll-common-start-modal :poll="newPoll(pollType)"></poll-common-start-modal>
        <!-- <discussion-start :discussion="newThread()" :close="closeThreadModal"></discussion-start> -->
      </v-dialog>
      <i
        class="mdi mdi-24px decision-tools-card__icon"
        :class="callFieldFromTemplate(pollType, 'material_icon')"
      ></i>
      <div class="decision-tools-card__content">
        <div v-t="'poll_types.' + pollType" class="decision-tools-card__poll-type-title md-body-1"></div>
        <div v-t="'poll_' + pollType + '_form.tool_tip_collapsed'" class="decision-tools-card__poll-type-subtitle md-caption"></div>
      </div>
    </v-list-tile>
  </v-list>
</template>
