<script lang="coffee">
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
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
    showTimeZones: false

  computed:
    currentTimeZone: -> Session.user().timeZone
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
  p.text-caption
    span(v-t="{path: 'poll_common_form.your_in_zone', args: {zone: currentTimeZone}}")
    space
    a(v-if="!showTimeZones" @click="showTimeZones = true" v-t="'poll_common_form.show_other_zones'")
    a(v-if="showTimeZones" @click="showTimeZones = false" v-t="'poll_common_form.hide_other_zones'")
  v-simple-table(v-show="showTimeZones" dense style="max-height: 100px; overflow-y: scroll;")
    tbody
      tr(:key="z[0]" v-for="z in zoneCounts")
        td {{z[0].replace('_',' ')}}
        td {{timeInZone(z[0])}}

</template>
