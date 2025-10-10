<script lang="js">
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import { I18n } from '@/i18n';
import Flash  from '@/shared/services/flash';

export default {
  props: {
    comment: Object,
    autofocus: Boolean
  },

  data() {
    return {
      actor: Session.user(),
      canSubmit: true,
      shouldReset: false,
      processing: false
    };
  },

  computed: {
    placeholder() {
      if (this.comment.parent()) {
        return this.$t('comment_form.in_reply_to', {name: this.comment.parent().author().nameOrUsername()});
      } else {
        return this.$t('comment_form.aria_label');
      }
    }
  },

  methods: {
    discardDraft() {
      if (confirm(I18n.global.t('formatting.confirm_discard'))) {
        EventBus.$emit('resetDraft', 'comment', this.comment.id, 'body', this.comment.body);
      }
    },

    handleIsUploading(val) {
      return this.canSubmit = !val;
    },

    submit() {
      this.processing = true;
      this.comment.save().then(() => {
        const flashMessage = !this.comment.isNew() ?
                        'comment_form.messages.updated'
                      : this.comment.isReply() ?
                        'comment_form.messages.replied'
                      :
                        'comment_form.messages.created';
        Flash.success(flashMessage, {name: this.comment.isReply() ? this.comment.parent().author().nameOrUsername() : undefined});
        setTimeout(() => {
          this.$emit('comment-submitted');
          this.shouldReset = !this.shouldReset;
        });
      }).catch(err => {
        Flash.error('common.something_went_wrong');
      }).finally(() => this.processing = false);
    }
  }
};

</script>

<template lang="pug">
.d-flex.comment-form
  .thread-item__avatar.mr-3
    user-avatar(
      :user='comment.author() || actor'
      :size='comment.parentId ? 28 : 32'
    )
  form.thread-item__body.comment-form__body(v-on:submit.prevent='submit()' @keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
    lmo-textarea.ml-n1(
      :model='comment'
      @is-uploading="handleIsUploading"
      field="body"
      :placeholder="placeholder"
      :autofocus="autofocus"
      :should-reset="shouldReset")
      template(v-slot:actions)
        v-btn.mr-2(
          variant="text"
          v-if="comment.id"
          @click="discardDraft"
        )
          span(v-t="'common.reset'")
        v-btn.comment-form__submit-button(
          variant="elevated"
          :loading="processing"
          :disabled="!canSubmit"
          color="primary"
          type='submit'
        )
          span(v-t="comment.isNew() ? 'comment_form.post_comment' : 'common.action.save' ")
    v-alert(color="error" v-if="comment.saveFailed")
      span(v-t="'common.something_went_wrong'")
      space
      span(v-t="'common.please_try_again'")
</template>

<style lang="sass">
.comment-form__body
  flex-grow: 1
</style>
