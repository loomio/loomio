<script lang="coffee">
export default
  props:
    discussion: Object
    noGroup: Boolean

</script>

<template lang="pug">
v-tooltip(bottom)
  template(v-slot:activator="{ on, attrs }")
    v-chip.context-panel__discussion-privacy(v-bind="attrs" v-on="on" label outlined aria-label="$t('discussion_form.visible_to')")
      template(v-if='discussion.visibleTo == "discussion"')
        v-avatar(left tile)
          v-icon(color="grey darken-2") mdi-lock-outline
        span(v-t="'discussion_form.visible_to_discussion'")
      template(v-if='discussion.visibleTo == "group"')
        v-avatar(left tile)
          v-icon(color="grey darken-2") mdi-account-group
        span(v-t="{path: 'discussion_form.visible_to_group', args: {group: discussion.group().name}}")
      template.mr-1(v-if='discussion.visibleTo == "parent_group"')
        v-avatar(left tile)
          v-icon(color="grey darken-2") mdi-domain
        span(v-t="{path: 'discussion_form.visible_to_parent_group', args: {group: discussion.group().parent().name}}")
      template.mr-1(v-if='discussion.visibleTo == "public"')
        v-avatar(left tile)
          v-icon(color="grey darken-2") mdi-earth
        span(v-t="'discussion_form.visible_to_public'")
      template(v-if='!noGroup && discussion.visibleTo != "discussion"')
        mid-dot
        router-link(:to="urlFor(discussion.group())") {{discussion.group().name}}
  span(v-t="'discussion_form.visible_to_'+discussion.visibleTo+'_tooltip'")
</template>

<style lang="sass">

</style>
