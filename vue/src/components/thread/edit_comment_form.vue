<style lang="scss">
@import 'variables';
.edit-comment-form md-input-container {
  margin: 0;
}

.edit-comment-form md-input-container textarea {
  max-height: inherit;
}

.edit-comment-form .emoji-picker__menu {
  z-index: $z-low;
}

</style>
<script lang="coffee">
Records = require 'shared/services/records'

{ submitForm }    = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

_invokeMap = require 'lodash/invokeMap'

module.exports =
  props:
    comment: Object
    close: Function
  data: ->
    dcomment: @comment.clone()
  created: ->
    @submit = submitForm @, @dcomment,
      flashSuccess: 'comment_form.messages.updated'
      successCallback: =>
        _invokeMap Records.documents.find(@comment.removedDocumentIds), 'remove'
</script>
<template lang="pug">
v-card.edit-comment-form
  v-card-title
    h1(v-t="'comment_form.edit_comment'")
    dismiss-modal-button(:close="close")
  v-card-text
    .lmo-disabled-form(v-show='isDisabled')
    lmo-textarea(v-if="dcomment.bodyFormat =='html'" :model='dcomment' field="body" :placeholder="$t('comment_form.say_something')")
    v-textarea(v-if="dcomment.bodyFormat=='md'" lmo_textarea, v-model="comment.body", :placeholder="$t('comment_form.say_something')")
  v-card-actions
    comment-form-actions(:comment="comment", :submit="submit")
</template>
