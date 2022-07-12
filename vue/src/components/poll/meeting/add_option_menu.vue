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
    value: Date

  created: ->
    Records.users.fetchTimeZones().then (data) => @zoneCounts = data

  data: ->
    min: new Date
    zoneCounts: []
    showTimeZones: false

  computed:
    currentTimeZone: -> Session.user().timeZone

  methods:
    timeInZone: (zone) -> exact(@value, zone)

</script>
<template lang="pug">
.poll-meeting-add-option-menu
  p.text-caption
    span(v-t="{path: 'poll_common_form.your_in_zone', args: {zone: currentTimeZone}}")
    space
    a(v-if="!showTimeZones" @click="showTimeZones = true" v-t="'poll_common_form.show_other_zones'")
    a(v-if="showTimeZones" @click="showTimeZones = false" v-t="'poll_common_form.hide_other_zones'")
  v-simple-table(v-show="showTimeZones" dense style="max-height: 110px; overflow-y: auto;")
    tbody
      tr(:key="z[0]" v-for="z in zoneCounts")
        template(v-if="z[0] != currentTimeZone")
          td {{z[0].replace('_',' ')}}
          td {{timeInZone(z[0])}}
</template>
