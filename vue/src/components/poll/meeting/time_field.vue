<script lang="coffee">
import moment from 'moment'
import TimeService from '@/shared/services/time_service'
import Records     from '@/shared/services/records'
export default
  props:
    poll: Object

  created: ->
    @poll.update(optionDate: moment().format('YYYY-MM-DD'))
    @poll.update(optionTime: "00:00")
    Records.users.fetchTimeZones().then (data) => @timeZones = data

  data: ->
    timeZones: {}
    datePickerOpen: false
    timePickerOpen: false
    dateToday: moment().format('YYYY-MM-DD')
    times: TimeService.meetingTimesOfDay()

  methods:
    timeInZone: (zone) ->
      @poll.handleDateOption().toLocaleString("en-US", {timeZone: "zone"});

</script>
<template lang="pug">
v-sheet
  v-card-title
    v-subheader(v-t="'poll_meeting_form.add_option_placeholder'")
    v-spacer
    v-btn.dismiss-modal-button(icon :aria-label="$t('common.action.cancel')" @click='$emit("close")')
      v-icon mdi-window-close
  v-card-text
    v-layout.poll-meeting-time-field
      v-menu(ref='dateMenu' v-model='datePickerOpen' :close-on-content-click='false' offset-y full-width min-width='290px')
        template(v-slot:activator='{ on }')
          v-text-field(v-model='poll.optionDate' readonly v-on='on' prepend-icon="mdi-calendar")
        v-date-picker.poll-common-closing-at-field__datepicker(v-model='poll.optionDate' no-title :min='dateToday' @input="datePickerOpen = false")
      v-spacer
      v-combobox.poll-common-closing-at-field__timepicker(v-model="poll.optionTime" :items="times" prepend-icon="mdi-clock-outline")
    v-simple-table(dense height="100px")
      tbody
        tr(v-for="z in timeZones" :key="z[0]")
          td {{z[0].replace('_',' ')}}
          td
            poll-meeting-time(:name="poll.handleDateOption()" :zone="z[0]")

  v-card-actions
    v-spacer
    v-btn.poll-meeting-form__option-button(color="accent" @click='poll.addOption()' v-t="'common.add'")



</template>
