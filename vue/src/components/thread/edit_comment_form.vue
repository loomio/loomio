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
v-card.edit-comment-form.pb-4(:title="$t('comment_form.edit_comment')")
  template(v-slot:append)
    dismiss-modal-button
  comment-form.mx-4(:comment="comment" @comment-submitted="close()" autofocus)
</template>
