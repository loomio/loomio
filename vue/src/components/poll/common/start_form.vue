<script lang="coffee">
import AppConfig    from '@/shared/services/app_config'
import Session      from '@/shared/services/session'
import Records      from '@/shared/services/records'
import EventBus     from '@/shared/services/event_bus'
import { fieldFromTemplate } from '@/shared/helpers/poll'
import {map, without} from 'lodash-es'

export default
  props:
    isModal:
      type: Boolean
      default: false
    discussion:
      type: Object
      default: => {}
    group: Object
  methods:
    openPollModal: (pollType) ->
      EventBus.$emit 'openModal',
        component: 'PollCommonModal'
        props:
          poll: @newPoll(pollType)

    pollTypes: ->
      if @isModal
        AppConfig.pollTypes
      else
        without AppConfig.pollTypes, 'proposal'

    newPoll: (pollType) ->
      Records.polls.build
        pollType: pollType
        discussionId: @discussion.id
        groupId: @discussion.groupId or @group.id
        pollOptionNames: map @callFieldFromTemplate(pollType, 'poll_options_attributes'), 'name'
        detailsFormat: Session.defaultFormat()

    callFieldFromTemplate: (pollType, field) ->
      fieldFromTemplate(pollType, field)

    getAriaLabelForPollType: (pollType) ->
      @$t("poll_types.#{pollType}")

</script>

<template lang="pug">
.poll-common-start-form
  v-list.decision-tools-card__poll-types(two-line dense)
    v-card-title(v-if="isModal")
      v-layout(justify-space-between style="align-items: center")
        .group-form__group-title
          h1.headline Choose poll type
        dismiss-modal-button
    v-list-item.decision-tools-card__poll-type(:class="'decision-tools-card__poll-type--' + pollType", @click='openPollModal(pollType)', v-for='(pollType, index) in pollTypes()', :key='index', :aria-label='getAriaLabelForPollType(pollType)')
      v-list-item-avatar
        v-icon {{callFieldFromTemplate(pollType, 'material_icon')}}
      v-list-item-content
        v-list-item-title.text-capitalize(v-t="'poll_types.' + pollType")
        v-list-item-subtitle(v-t="'poll_' + pollType + '_form.tool_tip_collapsed'")
</template>
