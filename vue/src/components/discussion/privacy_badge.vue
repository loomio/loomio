<script lang="coffee">
export default
  props:
    discussion: Object

</script>

<template lang="pug">
div.context-panel__discussion-privacy.d-flex.align-center(aria-label="$t('discussion_form.visible_to')")
  template(v-if='discussion.visibleTo == "discussion"')
    v-icon.mr-1(small) mdi-lock-outline
    span(v-t="'discussion_form.visible_to_discussion'")
  template(v-if='discussion.visibleTo == "group"')
    v-icon.mr-1(small) mdi-account-group
    span(v-t="{path: 'discussion_form.visible_to_group', args: {group: discussion.group().name}}")
  template.mr-1(v-if='discussion.visibleTo == "parent_group"')
    v-icon(small) mdi-domain
    span(v-t="{path: 'discussion_form.visible_to_parent_group', args: {group: discussion.group().parent().name}}")
  template.mr-1(v-if='discussion.visibleTo == "public"')
    v-icon(small) mdi-earth
    span(v-t="'discussion_form.visible_to_public'")
</template>

<style lang="sass">

</style>
