<style lang="scss">
</style>
<script lang="coffee">
export default
  props:
    comment: Object
    submit: Function
</script>
<template lang="pug">
.lmo-md-actions
  .comment-form__actions--left(v-if="comment.isNew() && !submitIsDisabled")
    v-btn.comment-form-button(v-t="'comment_form.cancel_reply'", v-show="comment.parentId && !eventWindow.useNesting", @click="comment.parentId = null", tabindex="-1")
    v-btn#post-comment-cancel(v-t="'common.action.cancel'", @click="console.log('wtf')", v-if="!comment.isNew()")
    router-link.comment-form__formatting.md-button.md-accent.lmo-hide-on-xs(to="/markdown", v-if="!comment.parentId", :title="$t('common.formatting_help.title')")
      span(v-t="'common.formatting_help.label'")
  .comment-form__actions--right
    //- outlet(name="before-comment-submit", model="comment")
    v-btn.comment-form__submit-button(v-if="comment.isNew()", @click="submit()", v-t="'comment_form.submit_button.label'", primary, raised)
    v-btn.comment-form__submit-button(v-if="!comment.isNew()", @click="submit()", v-t="'common.action.save_changes'", primary, raised)
</template>
