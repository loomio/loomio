<style lang="scss">
.poll-meeting-form__closing-at {
  margin-top: 24px;
}

.poll-meeting-form__options {
  margin-top: -20px;
}

.poll-meeting-form__poll-option-names {
  padding: 0 0 0 6px !important;
}

.poll-meeting-form__poll-option-names .poll-meeting-form__option-button {
  margin-right: 0;
}

.poll-meeting-form__option-button {
  margin: 0 16px;
  font-size: 24px;
}

.poll-meeting-form__label-and-timezone {
  margin-bottom: 16px;
  display: flex;
  justify-content: space-between;
  align-items: baseline;
}

.poll-meeting-form__datepicker input {
  max-width: 100%;
}
</style>

<script lang="coffee">
AppConfig = require 'shared/services/app_config'
EventBus  = require 'shared/services/event_bus'

_pull = require('lodash/pull')

module.exports =
  props:
    poll: Object
    back: Boolean
  data: ->
    durations: AppConfig.durations
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

  .md-block
    v-select(v-model="poll.customFields.meeting_duration", :label="$t('poll_meeting_form.meeting_duration')", :items="durations", item-text="label", item-value="minutes")
  poll-common-form-options(:poll="poll")
  poll-common-closing-at-field.md-block(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
