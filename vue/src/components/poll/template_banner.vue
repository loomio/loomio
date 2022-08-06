<script lang="coffee">
export default
  props:
    poll: Object
</script>

<template lang='pug'>
v-alert(v-if="poll.template && poll.id" color="info" outlined)
  .d-flex.align-center
    div(v-t="'templates.this_is_a_poll_template'")
    v-spacer
    v-btn(:to="'/p/new?template_id='+poll.id")
      span(v-t="'templates.make_a_copy'") 
</template>

