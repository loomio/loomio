<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import EventBus  from '@/shared/services/event_bus'

import { pull } from 'lodash'

export default
  props:
    poll: Object
    back: Boolean

  data: ->
    durations: AppConfig.durations
    menu: false

  created: ->
    @poll.customFields.meeting_duration = @poll.customFields.meeting_duration or 60
    if @poll.isNew()
      @poll.canRespondMaybe = true
      @poll.closingAt = moment().add(2, 'day')
      @poll.notifyOnParticipate = true
    # EventBus.listen $scope, 'timeZoneSelected', (e, zone) ->
    #   $scope.poll.customFields.time_zone = zone
</script>

<template lang="pug">
.poll-meeting-form
  poll-common-form-fields(:poll="poll")

  v-menu(ref="menu" v-model="menu" :close-on-content-click="false" offset-y full-width min-width="290px")
    template(v-slot:activator="{ on }" )
      v-combobox(v-on="on" v-model="poll.pollOptionNames" multiple chips small-chips deletable-chips :label="$t('poll_meeting_form.timeslots')")
        template(v-slot:selection="data")
          v-chip
            poll-meeting-time(:name="data.item")
    poll-meeting-add-option-menu(@close="menu = false" :poll="poll")
  validation-errors(:subject="poll" field="pollOptions")

  v-select(v-model="poll.customFields.meeting_duration" :label="$t('poll_meeting_form.meeting_duration')" :items="durations", item-text="label", item-value="minutes")
  poll-common-closing-at-field(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
