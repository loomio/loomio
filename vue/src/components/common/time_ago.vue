<script lang="coffee">
import { approximate, exact } from '@/shared/helpers/format_time'
import { parseISO } from 'date-fns'
import {isString} from 'lodash'

export default
  props:
    date: [Date, String]

  data: ->
    parsedDate: null

  created: ->
    if isString(@date)
      @parsedDate = parseISO(@date)
    else
      @parsedDate = @date

  computed:
    approximateDate: -> approximate(@parsedDate)
    exactDate: -> exact(@parsedDate)

</script>

<template lang="pug">
abbr.time-ago(:title='exactDate') {{approximateDate}}
</template>

<style lang="css">
.time-ago{ white-space: nowrap; }
abbr[title] { border-bottom: none; }
</style>
