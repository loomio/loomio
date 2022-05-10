<script lang="coffee">
import Records from '@/shared/services/records'
import Flash   from '@/shared/services/flash'
import { exact }   from '@/shared/helpers/format_time'

import { format, utcToZonedTime } from 'date-fns-tz'
import { isSameYear, startOfHour }  from 'date-fns'

export default
  props:
    poll: Object

  created: ->
    Records.users.fetchTimeZones().then (data) => @zoneCounts = data

  data: ->
    value: startOfHour(new Date)
    min: new Date
    zoneCounts: []

  methods:
    addOption: ->
      if @poll.addOption(@value.toJSON())
        Flash.success('poll_meeting_form.time_slot_added')
      else
        Flash.error('poll_meeting_form.time_slot_already_added')

    timeInZone: (zone) -> exact(@value, zone)

</script>
<template lang="pug">
.poll-meeting-add-option-menu
  v-subheader.mx-0.px-0(v-t="'poll_poll_form.add_option_placeholder'")
  .d-flex.align-center
    date-time-picker(:min="min" v-model="value")
    v-btn.poll-meeting-form__option-button.ml-4(
      :title="$t('poll_meeting_time_field.add_time_slot')"
      icon outlined color="primary"
      @click='addOption()'
    )
      v-icon mdi-plus
  v-simple-table(dense style="max-height: 100px; overflow-y: scroll;")
    tbody
      tr(:key="z[0]" v-for="z in zoneCounts")
        td {{z[0].replace('_',' ')}}
        td {{timeInZone(z[0])}}

</template>
