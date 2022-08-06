<script lang="coffee">
export default
  props:
    discussion: Object
    smaller: Boolean
</script>

<template lang='pug'>
v-chip(
  v-if="discussion.template"
  :x-small="smaller" 
  :small="!smaller" outlined
  :title="$t('templates.this_is_a_template_for_new_threads')"
)
  i.mdi.mdi-content-copy.mr-1
  span(v-t="'common.template'")
</template>


