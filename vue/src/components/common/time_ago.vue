<style lang="scss">
.time-ago { border: 0; }
</style>

<script lang="coffee">
export default
  functional: true
  props:
    date: Object
  render: (createElement, context) ->
    createElement('abbr', {class: 'timeago'}, [moment(context.props.date).fromNow()])
</script>
