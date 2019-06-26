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
    menuOpen: false
  created: ->
    @poll.customFields.meeting_duration = @poll.customFields.meeting_duration or 60
    if @poll.isNew()
      @poll.canRespondMaybe = false
      @poll.closingAt = moment().add(2, 'day')
      @poll.notifyOnParticipate = true
    # EventBus.listen $scope, 'timeZoneSelected', (e, zone) ->
    #   $scope.poll.customFields.time_zone = zone
  methods:
    removeOption: (name) ->
      _pull @poll.pollOptionNames, name
</script>

<template lang="pug">
.poll-meeting-form
  poll-common-form-fields(:poll="poll")

  v-menu(ref="menu" v-model="menuOpen" :close-on-content-click="false" :return-value.sync="poll.pollOptionNames" offset-y full-width min-width="290px")
    template(v-slot:activator="{ on }" )
      v-combobox(v-model="poll.pollOptionNames" multiple chips small-chips deletable-chips :label="$t('poll_meeting_form.timeslots')" readonly v-on="on")
        template(v-slot:selection="data")
          v-chip
            poll-meeting-time(:name="data.item")
    poll-meeting-time-field(@close="menuOpen = false" :poll="poll")
  v-select(v-model="poll.customFields.meeting_duration" :label="$t('poll_meeting_form.meeting_duration')" :items="durations", item-text="label", item-value="minutes")
  poll-common-closing-at-field.md-block(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
