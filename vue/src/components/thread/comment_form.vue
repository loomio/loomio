<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'

import { submitForm }    from '@/shared/helpers/form'
import { submitOnEnter } from '@/shared/helpers/keyboard'
import { last } from 'lodash'

export default
  props:
    comment: Object
    autoFocus: Boolean

  data: ->
    actor: Session.user()
    shouldReset: false
    isDisabled: null
    canSubmit: true

  computed:
    helptext: ->
      helptext = if @comment.discussion().private
        {path: 'comment_form.private_privacy_notice', args: {groupName: @comment.discussion().group().fullName}}
      else
        'comment_form.public_privacy_notice'

    placeholder: ->
      if @comment.parentId
        {path: 'comment_form.in_reply_to', args: {name: @comment.parent().authorName()}}
      else
        'comment_form.aria_label'

  methods:
    handleIsUploading: (val) ->
      @canSubmit = !val

    reset: ->
      @shouldReset = !@shouldReset

    init: ->
      @newComment = @comment.isNew()
      @submit = submitForm @, @comment,
        submitFn: =>
          @comment.save()
        flashSuccess: =>
          EventBus.$emit 'commentSaved'
          if !@newComment
            'comment_form.messages.updated'
          else if @comment.isReply()
            'comment_form.messages.replied'
          else
            'comment_form.messages.created'
        flashOptions:
          name: =>
            @comment.parent().authorName() if @comment.isReply()
        successCallback: (data) =>
          @$emit('comment-submitted')
          @reset()
          @init()

      # submitOnEnter @, element: $element
  mounted: ->
    @init()


</script>

<template lang="pug">
v-layout.comment-form.mx-3
  .thread-item__avatar.mr-2
    user-avatar(:user='actor', size='medium')
  .thread-item__body.lmo-flex--column.lmo-flex__horizontal-center
    form(v-on:submit.prevent='submit()')
      .lmo-disabled-form(v-show='isDisabled')
      lmo-textarea(:model='comment' @is-uploading="handleIsUploading" field="body" :placeholder="placeholder" :helptext="helptext" :shouldReset="shouldReset" :autoFocus="autoFocus")
      v-card-actions
        v-spacer
        v-btn.comment-form__submit-button(:disabled="!canSubmit" color="primary" type='submit' v-t="'comment_form.submit_button.label'")
</template>
