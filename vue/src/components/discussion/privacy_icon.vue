<style lang="scss">
.discussion-privacy-icon i {
  font-size: 16px;
  width: 16px;
  position: relative;
  top: 3px;
}
</style>
<script lang="coffee">
import { discussionPrivacy } from '@/shared/helpers/helptext'

export default
  props:
    discussion: Object
  computed:
    translateKey: ->
      if @discussion.private then 'private' else 'public'

    privacyDescription: ->
      @$t discussionPrivacy(@discussion, @discussion.private),
        group:  @discussion.group().name
        parent: @discussion.group().parentName()
</script>
<template lang="pug">
span.discussion-privacy-icon
  .discussion-privacy-icon__title
    strong(v-t="'common.privacy.' + translateKey")
  .discussion-privacy-icon__subtitle(v-html='privacyDescription')
</template>
