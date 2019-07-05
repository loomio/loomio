<script lang="coffee">
import AppConfig    from '@/shared/services/app_config'
import Records      from '@/shared/services/records'
import ModalService from '@/shared/services/modal_service'
import { fieldFromTemplate } from '@/shared/helpers/poll'
import PollModalMixin from '@/mixins/poll_modal'
import AnnouncementModalMixin from '@/mixins/announcement_modal'

import _map from 'lodash/map'
import _reduce from 'lodash/reduce'

export default
  mixins: [ PollModalMixin ]
  props:
    discussion:
      type: Object
      default: () => ({})
    group:
      type: Object
      default: () => ({})
  methods:
    openAnnouncementModal: ->
      @openAnnouncementModal(Records.announcements.buildFromModel(@discussion))

    openPollModal: (pollType) ->
      @openStartPollModal(@newPoll(pollType))

    pollTypes: -> AppConfig.pollTypes

    newPoll: (pollType) ->
      Records.polls.build
        pollType:              pollType
        discussionId:          @discussion.id
        groupId:               @discussion.groupId or @group.id
        pollOptionNames:       _map @callFieldFromTemplate(pollType, 'poll_options_attributes'), 'name'

    callFieldFromTemplate: (pollType, field) ->
      fieldFromTemplate(pollType, field)

    getAriaLabelForPollType: (pollType) ->
      @$t("poll_types.#{pollType}")

</script>

<template lang="pug">
v-list.decision-tools-card__poll-types(two-line dense)
  //- v-list-item
  //-   v-list-item-avatar
  //-     v-icon
  //-   v-list-item-title Update the context
  //- v-list-item
  //-   v-list-item-avatar
  //-     v-icon
  //-   v-list-item-title Add an outcome
  //- v-list-item
  //-   v-list-item-avatar
  //-     v-icon
  //-   v-list-item-title Schedule review
  //- v-list-item(@click="openAnnouncementModal()")
  //-   v-list-item-avatar
  //-     v-icon mdi-bullhorn
  //-   v-list-item-content
  //-     v-list-item-title Add people
  //-     v-list-item-subtitle Let people know that you want them to participate
  v-list-item.decision-tools-card__poll-type(:class="'decision-tools-card__poll-type--' + pollType", @click='openPollModal(pollType)', v-for='(pollType, index) in pollTypes()', :key='index', :aria-label='getAriaLabelForPollType(pollType)')
    v-list-item-avatar
      v-icon {{callFieldFromTemplate(pollType, 'material_icon')}}
    v-list-item-content
      v-list-item-title(v-t="'new_poll_types.' + pollType")
      v-list-item-subtitle(v-t="'poll_' + pollType + '_form.tool_tip_collapsed'")
</template>
