<script lang="js">
import Records from '@/shared/services/records';

export default {
  props: {
    comment: Object,
    close: Function
  },

  data() {
    return {isDisabled: false};
  }
};

</script>

<template lang="pug">
v-card.edit-comment-form
  submit-overlay(:value='comment.processing')
  v-card-title
    h1.text-h5(tabindex="-1" v-t="'comment_form.edit_comment'")
    v-spacer
    dismiss-modal-button(:model="comment")
  comment-form.mx-4(:comment="comment" @comment-submitted="close()" autofocus)
</template>
