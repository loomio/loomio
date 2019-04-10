import Fuse from 'fuse.js'

module.exports = {
  # a list of all suggested items
  items: => [
    { id: 1, name: 'Philipp Kühn' }
    { id: 2, name: 'Hans Pagel' }
    { id: 3, name: 'Kris Siepert' }
    { id: 4, name: 'Justin Schueler' }
    { id: 5, name: 'Robert Guthrie' }
  ]

  # is called when a suggestion starts
  onEnter: ({ items, query, range, command, virtualNode }) =>
    @query = query
    @filteredUsers = items
    @suggestionRange = range
    @renderPopup(virtualNode)
    # // we save the command for inserting a selected mention
    # // this allows us to call it inside of our custom popup
    # // via keyboard navigation and on click
    @insertMention = command

  # is called when a suggestion has changed
  onChange: ({items, query, range, virtualNode}) =>
    @query = query
    @filteredUsers = items
    @suggestionRange = range
    @navigatedUserIndex = 0
    @renderPopup(virtualNode)

  # is called when a suggestion is cancelled
  onExit: =>
    # // reset all saved values
    @query = null
    @filteredUsers = []
    @suggestionRange = null
    @navigatedUserIndex = 0
    @destroyPopup()

  # is called on every keyDown event while a suggestion is active
  onKeyDown: ({ event }) =>
    # // pressing up arrow
    if (event.keyCode == 38)
      @upHandler()
      return true

    # // pressing down arrow
    if (event.keyCode == 40)
      @downHandler()
      return true

    # // pressing enter
    if (event.keyCode == 13)
      @enterHandler()
      return true

    return false

  # // is called when a suggestion has changed
  # // this function is optional because there is basic filtering built-in
  # // you can overwrite it if you prefer your own filtering
  # // in this example we use fuse.js with support for fuzzy search
  onFilter: (items, query) =>
    return items if (!query)
    fuse = new Fuse(items, {
      threshold: 0.2,
      keys: ['name'],
    })
    fuse.search(query)
}
