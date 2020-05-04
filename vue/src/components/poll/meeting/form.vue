<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import EventBus  from '@/shared/services/event_bus'
import { addDays, addMinutes, formatDistanceToNowStrict } from 'date-fns'
import { pull } from 'lodash-es'

export default
  props:
    poll: Object
    back: Boolean

  data: ->
    durations:
      [5, 10, 15, 20, 30, 45, 60, 120, 180, 240, null].map (minutes) =>
        if minutes
          {text: formatDistanceToNowStrict(addMinutes(new Date, minutes)), value: minutes}
        else
          {text: @$t('common.all_day'), value: null}
    menu: false

  created: ->
    @poll.customFields.meeting_duration = @poll.customFields.meeting_duration or 60
    if @poll.isNew()
      @poll.canRespondMaybe = true
      @poll.closingAt = addDays(new Date, 3)
      @poll.notifyOnParticipate = true
    # EventBus.listen $scope, 'timeZoneSelected', (e, zone) ->
    #   $scope.poll.customFields.time_zone = zone
</script>

<template lang="pug">
.poll-meeting-form
  poll-common-form-fields(:poll="poll")
  poll-meeting-form-options-field(:poll="poll")
  v-select(v-model="poll.customFields.meeting_duration" :label="$t('poll_meeting_form.meeting_duration')" :items="durations")
  poll-common-closing-at-field(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
