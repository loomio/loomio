<script lang="coffee">
export default
  props:
    discussion: Object

</script>

<template lang="pug">
v-chip.context-panel__discussion-privacy(label outlined)
  template(v-if='discussion.private')
    v-avatar(left tile)
      v-icon(small color="grey darken-2") mdi-lock-outline
    span(v-t="'common.privacy.private'")
  template.mr-1(v-else='!discussion.private == "public"')
    v-avatar(left tile)
      v-icon(small color="grey darken-2") mdi-earth
    span(v-t="'common.privacy.public'")
  template(v-if='discussion.groupId')
    mid-dot
    router-link(:to="urlFor(discussion.group())") {{discussion.group().name}}
</template>
