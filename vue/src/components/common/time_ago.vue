<script lang="coffee">
import { approximate, exact } from '@/shared/helpers/format_time'

export default
  functional: true
  props:
    date: Date
  render: (createElement, context) ->
    createElement('abbr', {class: 'time-ago', attrs: {title: exact(context.props.date)}}, [approximate(context.props.date)])
</script>

<style lang="css">
.time-ago{ white-space: nowrap; }
abbr[title] { border-bottom: none; }
</style>
