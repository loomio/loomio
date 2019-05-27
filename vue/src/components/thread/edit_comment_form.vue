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
import Records from '@/shared/services/records'

import { submitForm }    from '@/shared/helpers/form'
import { submitOnEnter } from '@/shared/helpers/keyboard'

import _invokeMap from 'lodash/invokeMap'

export default
  props:
    comment: Object
    close: Function
  data: ->
    isDisabled: false
  created: ->
    @submit = submitForm @, @comment,
      flashSuccess: 'comment_form.messages.updated'
      successCallback: =>
        _invokeMap Records.documents.find(@comment.removedDocumentIds), 'remove'
        @close()
</script>
<template lang="pug">
v-card.edit-comment-form
  v-card-title
    h1(v-t="'comment_form.edit_comment'")
    dismiss-modal-button(:close="close")
  v-card-text
    .lmo-disabled-form(v-show='isDisabled')
    lmo-textarea(:model='comment' field="body" :placeholder="'comment_form.say_something'")
  v-card-actions
    comment-form-actions(:comment="comment", :submit="submit")
</template>
