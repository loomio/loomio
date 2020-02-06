import {sortBy, isString, filter, uniq, map} from 'lodash'
import Records from '@/shared/services/records'
import getCaretCoordinates from 'textarea-caret'

export CommonMentioning =
  data: ->
    mentionableUserIds: []
    query: ''
    navigatedUserIndex: 0
    suggestionListStyles: {}

  methods:
    fetchMentionable: ->
      Records.users.fetchMentionable(@query, @model).then (response) =>
        @mentionableUserIds.concat(uniq @mentionableUserIds + map(response.users, 'id'))

  computed:
    filteredUsers: ->
      unsorted = filter Records.users.collection.chain().find(@mentionableUserIds).data(), (u) =>
        isString(u.username) &&
        ((u.name || '').toLowerCase().startsWith(@query) or
        (u.username || '').toLowerCase().startsWith(@query) or
        (u.name || '').toLowerCase().includes(" #{@query}"))
      sortBy(unsorted, (u) -> (0 - Records.events.find(actorId: u.id).length))

export MdMentioning =
  methods:
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

export HtmlMentioning =
  data: ->
    suggestionRange: null

  created:->
    @insertMention = -> {}

  methods:
    upHandler: ->
      @navigatedUserIndex = ((@navigatedUserIndex + @filteredUsers.length) - 1) % @filteredUsers.length

    downHandler: ->
      @navigatedUserIndex = (@navigatedUserIndex + 1) % @filteredUsers.length

    enterHandler: ->
      user = @filteredUsers[@navigatedUserIndex]
      @selectUser(user) if user

    selectUser: (user) ->
      @insertMention
        range: @suggestionRange
        attrs:
          id: user.username,
          label: user.name
      @editor.focus()

    updatePopup: (node) ->
      coords = node.getBoundingClientRect()
      @suggestionListStyles =
        position: 'fixed'
        top: coords.y + 24 + 'px'
        left: coords.x + 'px'

export MentionPluginConfig = ->
  # is called when a suggestion starts
  onEnter: ({ query, range, command, virtualNode }) =>
    @query = query.toLowerCase()
    @suggestionRange = range
    @insertMention = command
    @updatePopup(virtualNode)
    @fetchMentionable()

  # is called when a suggestion has changed
  onChange: ({query, range, virtualNode}) =>
    @query = query.toLowerCase()
    @suggestionRange = range
    @navigatedUserIndex = 0
    @updatePopup(virtualNode)
    @fetchMentionable()

  # is called when a suggestion is cancelled
  onExit: =>
    @query = null
    @suggestionRange = null
    @navigatedUserIndex = 0

  # is called on every keyDown event while a suggestion is active
  onKeyDown: ({ event }) =>
    # pressing up arrow
    if (event.keyCode == 38)
      @upHandler()
      return true

    # pressing down arrow
    if (event.keyCode == 40)
      @downHandler()
      return true

    # pressing enter or tab
    if [13,9].includes(event.keyCode)
      @enterHandler()
      return true

    return false
