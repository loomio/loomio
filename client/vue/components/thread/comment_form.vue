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
    shouldUpdateModel: false
    comment: Records.comments.build
      body_format: "html"
      body: ""
      discussionId: @eventWindow.discussion.id
      authorId: Session.user().id
    isDisabled: null

  methods:
    commentHelptext: ->
      helptext = if @eventWindow.discussion.private
        {path: 'comment_form.private_privacy_notice', groupName: @comment.group().fullName}
      else
        {path: 'comment_form.public_privacy_notice'}

    commentPlaceholder: ->
      if @comment.parentId
        {path: 'comment_form.in_reply_to', name: @comment.parent().authorName()}
      else
        {path: 'comment_form.aria_label'}

    preSave: ->
      @shouldUpdateModel = !@shouldUpdateModel

    callSubmit: -> @submit()
    init: ->
      @submit = submitForm @, @comment,
        submitFn: =>
          console.log 'comment', @comment
          console.log 'comment.body', @comment.body
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
  form(v-on:submit.prevent='preSave()')
    .lmo-disabled-form(v-show='isDisabled')
    lmo-textarea(:model='comment' @modelUpdated="callSubmit" :shouldUpdateModel="shouldUpdateModel" field="body" :placeholder="commentPlaceholder()" :helptext="commentHelptext()")
    v-btn(flat color="primary" type='submit' v-t="'comment_form.submit_button.label'")
    // <lmo_textarea model="comment" field="body" placeholder="commentPlaceholder()" helptext="commentHelptext()"></lmo_textarea>
    // <comment_form_actions comment="comment" submit="submit"></comment_form_actions>
    // <validation_errors subject="comment" field="file"></validation_errors>

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
