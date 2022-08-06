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
  p.text-caption.text--secondary
    span(v-t="{path: 'poll_common_form.your_in_zone', args: {zone: currentTimeZone}}")
    br
    span(v-t="'poll_meeting_form.participants_see_local_times'")
</template>
