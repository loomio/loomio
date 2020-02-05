<script lang="coffee">
import { convertToHtml } from '@/shared/services/format_converter'
import getCaretCoordinates from 'textarea-caret'
import Mentioning from './mentioning.coffee'
import Records from '@/shared/services/records'
import SuggestionList from './suggestion_list'

export default
  mixins: [Mentioning]
  props:
    model: Object
    field: String
    label: String
    placeholder: String
    shouldReset: Boolean
    maxLength: Number
    autoFocus:
      type: Boolean
      default: false

  components:
    SuggestionList: SuggestionList

  data: ->
    mentionableUserIds: []
    query: ''
    navigatedUserIndex: 0
    suggestionListStyles: {}
    preview: false

  methods:
    convertToHtml: ->
      convertToHtml(@model, @field)
      Records.users.removeExperience('html-editor.uses-markdown')

    textarea: ->
      @$refs.field.$el.querySelector('textarea')

    onKeyUp: ->
      # find if the user is mentioning at cursor position
      res = @textarea().value.slice(0, @textarea().selectionStart).match(/@(\w+)$/)
      if res
        @query = res[1]
        @fetchMentionable()
        @updatePopup()
      else
        @query = ''

    onKeyDown: (e) ->
      if @query
        # up
        if (event.keyCode == 38)
          @navigatedUserIndex = ((@navigatedUserIndex + @filteredUsers.length) - 1) % @filteredUsers.length
          e.preventDefault()

        # down
        if (event.keyCode == 40)
          @navigatedUserIndex = (@navigatedUserIndex + 1) % @filteredUsers.length
          e.preventDefault()

        # enter or tab
        if [13,9].includes(event.keyCode)
          if user = @filteredUsers[@navigatedUserIndex]
            @selectUser(user)
            e.preventDefault()

    selectUser: (user) ->
      text = @textarea().value
      beforeText = @textarea().value.slice(0, @textarea().selectionStart - @query.length)
      afterText = @textarea().value.slice(@textarea().selectionStart)
      @textarea().value = beforeText + user.username + ' ' + afterText
      @textarea().selectionEnd = (beforeText + user.username).length + 1

    updatePopup: ->
      return unless @$refs.field
      coords = getCaretCoordinates(@textarea(), @textarea().selectionStart - @query.length)
      @suggestionListStyles =
        position: 'absolute'
        top: ((coords.top - @textarea().scrollTop) + coords.height + 16) + 'px'
        left: coords.left + 'px'
</script>

<template lang="pug">
div(style="position: relative")
  v-textarea(v-if="!preview" v-model="model[field]" @keyup="onKeyUp" @keydown="onKeyDown" ref="field")
  formatted-text(v-if="preview" :model="model" :column="field")
  v-sheet.pa-4.my-4.poll-common-outcome-panel(v-if="preview && model[field].trim().length == 0" color="primary lighten-5" elevation="2")
    p No content to preview

  v-layout(align-center)
    v-btn(text x-small @click="convertToHtml(model, field)" v-t="'formatting.use_wysiwyg'")
    v-btn(text x-small href="/markdown" target="_blank" v-t="'formatting.markdown_help'")
    v-spacer
    v-btn.mr-4(text @click="preview = !preview" v-t="preview ? 'common.action.edit' : 'common.action.preview' ")
    slot(name="actions")
  suggestion-list(:query="query" :filtered-users="filteredUsers" :positionStyles="suggestionListStyles" :navigatedUserIndex="navigatedUserIndex" showUsername)
</template>
