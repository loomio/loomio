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
</script>

<template lang="pug">
v-card.edit-comment-form
  v-card-title
    h1.headline(v-t="'comment_form.edit_comment'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    .lmo-disabled-form(v-show='isDisabled')
    comment-form(:comment="comment" @comment-submitted="close()")
    //- lmo-textarea(:model='comment' field="body" :placeholder="'comment_form.say_something'" :autoFocus="true")
</template>
