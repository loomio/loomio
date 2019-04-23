<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'

import { submitForm }    from '@/shared/helpers/form'
import { submitOnEnter } from '@/shared/helpers/keyboard'

export default
  props:
    discussion: Object
    parentComment: Object

  data: ->
    actor: Session.user()
    shouldReset: false
    comment: @buildComment()
    isDisabled: null
    canSubmit: true

  computed:
    helptext: ->
      helptext = if @discussion.private
        {path: 'comment_form.private_privacy_notice', args: {groupName: @discussion.group().fullName}}
      else
        'comment_form.public_privacy_notice'

    placeholder: ->
      if @parentComment
        {path: 'comment_form.in_reply_to', args: {name: @parentComment.authorName()}}
      else
        'comment_form.aria_label'

  methods:
    handleIsUploading: (val) ->
      @canSubmit = !val
    buildComment: ->
      Records.comments.build
        bodyFormat: "html"
        body: ""
        discussionId: @discussion.id
        authorId: Session.user().id
        parentId: if @parentComment then @parentComment.id else null

    reset: ->
      @shouldReset = !@shouldReset
      @comment = @buildComment()

    init: ->
      @reset()
      @submit = submitForm @, @comment,
        submitFn: =>
          @comment.save()
        flashSuccess: =>
          EventBus.$emit 'commentSaved'
          if @comment.isReply()
            'comment_form.messages.replied'
          else
            'comment_form.messages.created'
        flashOptions:
          name: =>
            @comment.parent().authorName() if @comment.isReply()
        successCallback: =>
          @$emit('comment-submitted')
          @init()

      # submitOnEnter @, element: $element
  mounted: ->
    @init()


</script>

<template lang="pug">
.comment-form.lmo-relative.lmo-flex--row
  .thread-item__avatar.lmo-margin-right
    user-avatar(:user='actor', size='medium')
  .thread-item__body.lmo-flex--column.lmo-flex__horizontal-center
    form(v-on:submit.prevent='submit()')
      .lmo-disabled-form(v-show='isDisabled')
      lmo-textarea(:model='comment' @is-uploading="handleIsUploading" field="body" :placeholder="placeholder" :helptext="helptext" :shouldReset="shouldReset")
      v-card-actions
        v-spacer
        v-btn.comment-form__submit-button(:disabled="!canSubmit" flat color="primary" type='submit' v-t="'comment_form.submit_button.label'")

</template>

<style lang="scss">

.comment-form .lmo-textarea md-input-container {
  margin-top: -2px;
}
.comment-form-attachments input {
  display: none;
}

.comment-form-button {
  margin-left: 10px;
  &:hover { cursor: pointer; }
}

.comment-form-container{
  width: 100%;
}
</style>
