<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Flash  from '@/shared/services/flash'
import { last } from 'lodash'

export default
  props:
    comment: Object
    autofocus: Boolean

  data: ->
    actor: Session.user()
    canSubmit: true
    shouldReset: false

  computed:
    placeholder: ->
      if @comment.parentId
        @$t('comment_form.in_reply_to', {name: @comment.parent().authorName()})
      else
        @$t('comment_form.aria_label')

  methods:
    handleIsUploading: (val) ->
      @canSubmit = !val

    submit: ->
      @comment.save()
      .then =>
        @$emit('comment-submitted')
        @shouldReset = !@shouldReset
        flashMessage = if !@comment.isNew()
                        'comment_form.messages.updated'
                      else if @comment.isReply()
                        'comment_form.messages.replied'
                      else
                        'comment_form.messages.created'
        Flash.success flashMessage, {name: @comment.parent().authorName() if @comment.isReply()}
      .catch => true

</script>

<template lang="pug">
v-layout.comment-form(:class="{'px-3': !comment.parentId}")
  .thread-item__avatar.mr-3.ml-1
    user-avatar(:user='comment.author() || actor' :size='comment.parentId ? 24 : 40')
  form.thread-item__body.comment-form__body(v-on:submit.prevent='submit()' @keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()")
    submit-overlay(:value='comment.processing')
    lmo-textarea(
      :model='comment'
      @is-uploading="handleIsUploading"
      field="body"
      :placeholder="placeholder"
      :autofocus="autofocus"
      :shouldReset="shouldReset")
      template(v-slot:actions)
        v-btn.comment-form__submit-button(
          :disabled="!canSubmit"
          color="primary"
          type='submit'
          v-t="comment.isNew() ? 'comment_form.post_comment' : 'common.action.save' ")
</template>

<style lang="sass">
.comment-form__body
  flex-grow: 1
</style>
