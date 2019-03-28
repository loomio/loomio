<script lang="coffee">
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
I18n           = require 'shared/services/i18n'

{ submitForm }    = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

module.exports =
  props:
    eventWindow: Object

  data: ->
    shouldReset: false
    comment: @buildComment()
    isDisabled: null

  methods:
    commentHelptext: ->
      helptext = if @eventWindow.discussion.private
        {path: 'comment_form.private_privacy_notice', groupName: @comment.group().fullName}
      else
        {path: 'comment_form.public_privacy_notice'}

    commentPlaceholder: ->
      if @comment.parentId
        ['comment_form.in_reply_to', {name: @comment.parent().authorName()}]
      else
        'comment_form.aria_label'

    preSave: ->
      @shouldUpdateModel = !@shouldUpdateModel

    buildComment: ->
      Records.comments.build
        bodyFormat: "html"
        body: ""
        discussionId: @eventWindow.discussion.id
        authorId: Session.user().id

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
        successCallback: @init

      # EventBus.listen @, 'setParentComment', (e, parentComment) =>
      #   @comment.parentId = parentComment.id
      #
      # submitOnEnter @, element: $element
      #
      # EventBus.broadcast @, 'reinitializeForm', @comment
  mounted: ->
    @init()

</script>

<template lang="pug">
.comment-form.lmo-relative
  form(v-on:submit.prevent='submit()')
    .lmo-disabled-form(v-show='isDisabled')
    lmo-textarea(:model='comment' field="body" :placeholder="commentPlaceholder()" :helptext="commentHelptext()" :shouldReset="shouldReset")
    v-card-actions
      v-spacer
      v-btn(flat color="primary" type='submit' v-t="'comment_form.submit_button.label'")

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
