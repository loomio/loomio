<style lang="scss">
.discussion-privacy-icon i {
  font-size: 16px;
  width: 16px;
  position: relative;
  top: 3px;
}
</style>
<script lang="coffee">
I18n = require 'shared/services/i18n'
{ discussionPrivacy } = require 'shared/helpers/helptext'

module.exports =
  props:
    discussion: Object
    private: Boolean
  computed:
    computedPrivate: ->
      if @private == 'undefined'
        return @discussion.private
      else
        @private

    translateKey: ->
      if @private then 'private' else 'public'

    privacyDescription: ->
      @$t discussionPrivacy(@discussion, @computedPrivate),
        group:  @discussion.group().name
        parent: @discussion.group().parentName()
</script>
<template>
  <span class="discussion-privacy-icon">
    <div class="discussion-privacy-icon__title">
      <strong v-t="'common.privacy.' + translateKey"></strong>
    </div>
    <div v-html="privacyDescription" class="discussion-privacy-icon__subtitle">
    </div>
  </span>
</template>
