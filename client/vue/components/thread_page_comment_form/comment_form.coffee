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
    comment: Records.comments.build
      discussionId: @eventWindow.discussion.id
      authorId: Session.user().id
    isDisabled: null
  methods:
    commentHelptext: ->
      helptext = if @eventWindow.discussion.private
        @$t('comment_form.private_privacy_notice', groupName: @comment.group().fullName)
      else
        @$t('comment_form.public_privacy_notice')
      helptext.replace('&amp;', '&')
              .replace('&lt;', '<')
              .replace('&gt;', '>')

    commentPlaceholder: ->
      if @comment.parentId
        @$t('comment_form.in_reply_to', name: @comment.parent().authorName())
      else
        @$t('comment_form.aria_label')
    init: ->
      @submit = submitForm @, @comment,
        submitFn: @comment.save
        flashSuccess: =>
          EventBus.emit @, 'commentSaved'
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

  template:
    """
    <div class="comment-form lmo-relative">
      <form v-on:submit.prevent="submit()">
        <div v-show="isDisabled" class="lmo-disabled-form"></div>
        <textarea v-model="comment.body"></textarea>
        <button type="submit">Submit</button>
        <!-- <lmo_textarea model="comment" field="body" placeholder="commentPlaceholder()" helptext="commentHelptext()"></lmo_textarea> -->
        <!-- <comment_form_actions comment="comment" submit="submit"></comment_form_actions> -->
        <!-- <validation_errors subject="comment" field="file"></validation_errors> -->
      </form>
    </div>
    """
