node = null

export initContent = ->
  node = document.querySelector('#ssr .v-content')
  document.querySelector('#ssr').style.display = 'none' if node

export hasContent = ->
  node != null

export insertContent = (selector) ->
  document.querySelector(selector).appendChild(node)

export removeContent = (selector) ->
  node.parentElement.removeChild(node)
  node = null
