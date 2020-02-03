<script lang="coffee">
import { convertToHtml } from '@/shared/services/format_converter'
import Records from '@/shared/services/records'
import {concat, sortBy, isString, filter, uniq, map, forEach, isEmpty} from 'lodash'
import getCaretCoordinates from 'textarea-caret'

export default
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

  data: ->
    mentionableUserIds: []
    query: ''
    navigatedUserIndex: 0
    suggestionListStyle: {}

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
        @renderPopup()
      else
        @query = ''
        # @destroyPopup()

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

    fetchMentionable: ->
      return unless @query
      Records.users.fetchMentionable(@query, @model).then (response) =>
        @mentionableUserIds.concat(uniq @mentionableUserIds + map(response.users, 'id'))

    mentionPosition: ->

    renderPopup: ->
      return unless @$refs.field
      coords = getCaretCoordinates(@textarea(), @textarea().selectionStart - @query.length)
      rect = @textarea().getBoundingClientRect();
      offset = "#{coords.left}, -#{coords.top - @textarea().scrollTop} "

      @suggestionListStyle =
        position: 'absolute'
        top: "#{(coords.top - @textarea().scrollTop) + coords.height + 16}px"
        left: "#{coords.left}px"

  computed:
    showSuggestions: -> @query || @filteredUsers.length
    filteredUsers: ->
      return [] unless @query
      unsorted = filter Records.users.collection.chain().find(@mentionableUserIds).data(), (u) =>
        isString(u.username) &&
        ((u.name || '').toLowerCase().startsWith(@query) or
        (u.username || '').toLowerCase().startsWith(@query) or
        (u.name || '').toLowerCase().includes(" #{@query}"))
      sortBy(unsorted, (u) -> (0 - Records.events.find(actorId: u.id).length))

</script>

<template lang="pug">
div(style="position: relative")
  v-textarea(v-model="model[field]" @keyup="onKeyUp" @keydown="onKeyDown" ref="field")
  v-btn(@click="convertToHtml(model, field)") HTML
  slot(name="actions")
  v-card(outlined elevation=4 v-show='showSuggestions' ref='suggestions' :style="suggestionListStyle")
    template(v-if='filteredUsers.length')
      v-list(dense)
        v-list-item(dense v-for='(user, index) in filteredUsers', :key='user.id', :class="{ 'v-list-item--active': navigatedUserIndex === index }", @click='selectUser(user)')
          v-list-item-icon
            user-avatar(:user="user" size=36)
          v-list-item-content
            v-list-item-title
              | {{ user.name }}
            v-list-item-subtitle
              | {{ "@" + user.username }}
    v-card-subtitle(v-else v-t="'common.no_results_found'")
</template>
