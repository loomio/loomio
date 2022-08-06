<script lang="coffee">
export default
  props:
    poll: Object
    smaller: Boolean
</script>

<template lang='pug'>
v-chip(
  v-if="poll.template"
  :x-small="smaller" 
  :small="!smaller" outlined
  :title="$t('templates.this_is_a_template_for_new_poll')"
)
  i.mdi.mdi-content-copy.mr-1
  span(v-t="'common.template'")
</template>


