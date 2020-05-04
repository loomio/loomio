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
v-sheet
  v-card-title
    v-subheader(v-t="'poll_meeting_form.add_option_placeholder'")
    v-spacer
    v-btn.dismiss-modal-button(icon :aria-label="$t('common.action.cancel')" @click='$emit("close")')
      v-icon mdi-window-close
  v-card-text
    date-time-picker(v-model="value" :min="min")
    v-simple-table(dense style="max-height: 100px; overflow-y: scroll;")
      tbody
        tr(v-for="z in zoneCounts" :key="z[0]")
          td {{z[0].replace('_',' ')}}
          td {{timeInZone(z[0])}}

  v-card-actions
    v-spacer
    v-btn.poll-meeting-form__option-button(color="accent" @click='addOption()' v-t="'common.add'")

</template>
