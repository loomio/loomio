node = null

export initContent = ->
  node = document.querySelector('#ssr .v-main')
  document.querySelector('#ssr').style.display = 'none' if node

export hasContent = ->
  node != null

export insertContent = (selector) ->
  document.querySelector(selector).appendChild(node) if node

export removeContent = (selector) ->
  node.parentElement.removeChild(node) if node
  node = null
