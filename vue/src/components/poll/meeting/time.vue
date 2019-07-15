<script lang="coffee">
import { exact } from '@/shared/helpers/format_time'
import { parseISO } from 'date-fns'

export default
  props:
    name: String
    zone: String
  computed:
    time: -> exact(parseISO(@name), @zone)
</script>

<template lang="pug">
span.poll-meeting-time {{time}}
</template>
