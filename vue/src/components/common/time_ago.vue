<script lang="coffee">
import { approximate, exact } from '@/shared/helpers/format_time'
import { parseISO } from 'date-fns'
import {isString} from 'lodash'

export default
  functional: true
  props:
    date: [Date, String]
  render: (createElement, context) ->
    date = if isString(context.props.date) then parseISO(context.props.date) else context.props.date
    createElement('abbr', {class: 'time-ago', attrs: {title: exact(date)}}, [approximate(date)])
</script>

<style lang="css">
.time-ago{ white-space: nowrap; }
abbr[title] { border-bottom: none; }
</style>
