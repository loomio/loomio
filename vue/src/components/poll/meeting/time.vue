<script lang="coffee">
import { exact, day } from '@/shared/helpers/format_time'
import { parseISO } from 'date-fns'

export default
  props:
    name: String
    zone: String
  computed:
    time: -> exact(parseISO(@name), @zone)
    day: -> day(parseISO(@name), @zone)
</script>

<template lang="pug">
span.poll-meeting-time {{day}} {{time}}
</template>

<style lang="sass">
.poll-meeting-time
	white-space: nowrap

</style>
