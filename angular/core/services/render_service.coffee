angular.module('loomioApp').factory 'render', ->
  createRenderer: ->
    renderer = new marked.Renderer()
    renderer.paragraph = @cook('p')
    renderer.listitem  = @cook('li')
    renderer.tablecell = @cook('td')
    renderer

  cook: (tag) ->
    (text) ->
      text = emojione.shortnameToImage(text)
      text = text.replace(/\[\[@([a-zA-Z0-9]+)\]\]/g, "<a class='lmo-user-mention' href='/u/$1'>@$1</a>")
      "<#{tag}>#{text}</#{tag}>"
