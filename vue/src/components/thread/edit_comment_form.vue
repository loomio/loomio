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

<template>

<v-card class="edit-comment-form">
  <submit-overlay :value="comment.processing"></submit-overlay>
  <v-card-title>
    <h1 class="headline" tabindex="-1" v-t="'comment_form.edit_comment'"></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button :model="comment"></dismiss-modal-button>
  </v-card-title>
  <comment-form class="mx-4" :comment="comment" @comment-submitted="close()" autofocus="autofocus"></comment-form>
</v-card>
</template>
