<script lang="coffee">
import Records from '@/shared/services/records'

export default
  props:
    comment: Object
    close: Function

  data: ->
    isDisabled: false

</script>

<template lang="pug">
v-card.edit-comment-form
  submit-overlay(:value='comment.processing')
  v-card-title
    h1.headline(v-t="'comment_form.edit_comment'")
    v-spacer
    dismiss-modal-button(:close="close")
  comment-form(:comment="comment" @comment-submitted="close()")
</template>
