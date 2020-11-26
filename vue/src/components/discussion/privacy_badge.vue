<script lang="coffee">
export default
  props:
    discussion: Object
    noLink: Boolean

</script>

<template lang="pug">
v-chip.context-panel__discussion-privacy(label outlined)
  template(v-if='discussion.private')
    v-avatar(left tile :title="$t('common.privacy.private')")
      v-icon(small color="grey darken-2") mdi-lock-outline
  template.mr-1(v-else)
    v-avatar(left tile :title="$t('common.privacy.public')")
      v-icon(small color="grey darken-2") mdi-earth
  template(v-if='discussion.groupId && noLink')
    span {{discussion.group().name}}
  template(v-if='discussion.groupId && !noLink')
    router-link(:to="urlFor(discussion.group())") {{discussion.group().name}}
  template(v-if='!discussion.groupId')
    span(v-t="'common.privacy.private'")
</template>
