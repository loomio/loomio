export default
  methods:
    # // navigate to the previous item
    # // if it's the first item, navigate to the last one
    upHandler: ->
      @navigatedUserIndex = ((@navigatedUserIndex + @filteredUsers.length) - 1) % @filteredUsers.length

    # // navigate to the next item
    # // if it's the last item, navigate to the first one
    downHandler: ->
      @navigatedUserIndex = (@navigatedUserIndex + 1) % @filteredUsers.length

    enterHandler: ->
      user = @filteredUsers[@navigatedUserIndex]
      @selectUser(user) if user

    # // we have to replace our suggestion text with a mention
    # // so it's important to pass also the position of your suggestion text
    selectUser: (user) ->
      @insertMention
        range: @suggestionRange
        attrs:
          id: user.id,
          label: user.name
      @editor.focus()

     # // renders a popup with suggestions
     # // tiptap provides a virtualNode object for using popper.js (or tippy.js) for popups
     renderPopup: (node) ->
       return if @popup
       @popup = tippy(node, {
         content: ['hi there', "yo whaddup?"], # @$refs.suggestions,
         trigger: 'mouseenter',
         interactive: true,
         theme: 'dark',
         placement: 'top-start',
         performance: true,
         inertia: true,
         duration: [400, 200],
         showOnInit: true,
         arrow: true,
         arrowType: 'round'
       })

     destroyPopup: ->
       if (@popup)
         @popup.destroyAll()
         @popup = null
