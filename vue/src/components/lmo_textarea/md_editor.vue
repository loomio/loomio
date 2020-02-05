<script lang="coffee">
import { convertToHtml } from '@/shared/services/format_converter'
import getCaretCoordinates from 'textarea-caret'
import Mentioning from './mentioning.coffee'
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

  methods:
    convertToHtml: convertToHtml

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
      coords = getCaretCoordinates(@textarea(), @textarea().selectionStart)
      rect = @textarea().getBoundingClientRect();
      # console.log coords, rect,
      #   scrollTop: @textarea().scrollTop
      #   scrollHeight: @textarea().scrollHeight
      #   scrollHeightMinusScrollTop: @textarea().scrollHeight - @textarea().scrollTop
      #   clientHeight: @textarea().clientHeight
      #   top_minus_scrolltop: coords.top - @textarea().scrollTop
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
      rect = @textarea().getBoundingClientRect();
      offset = "#{coords.left}, -#{coords.top - @textarea().scrollTop} "

      @suggestionListStyles =
        position: 'absolute'
        top: ((coords.top - @textarea().scrollTop) + coords.height + 16) + 'px'
        left: coords.left + 'px'
</script>

<template lang="pug">
div(style="position: relative")
  v-textarea(v-model="model[field]" @keyup="onKeyUp" @keydown="onKeyDown" ref="field")
  v-btn(@click="convertToHtml(model, field)") HTML
  slot(name="actions")
  suggestion-list(:query="query" :filtered-users="filteredUsers" :positionStyles="suggestionListStyles" :navigatedUserIndex="navigatedUserIndex" showUsername)
</template>
