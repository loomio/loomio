<script lang="coffee">
export default
  props:
    discussion: Object
</script>

<template lang='pug'>
v-alert(v-if="discussion.template && discussion.id" color="info" outlined)
  .d-flex.align-center
    div(v-t="'templates.this_thread_is_a_template'")
    v-spacer
    v-btn(:to="'/d/new?template_id='+discussion.id")
      span(v-t="'templates.make_a_copy'") 
</template>

