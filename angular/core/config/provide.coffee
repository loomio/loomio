angular.module('loomioApp').config ($provide) ->
  # polyfill for closest for ie11
  # from https://developer.mozilla.org/en-US/docs/Web/API/Element/closest
  if !Element::matches
    Element::matches = Element::msMatchesSelector or Element::webkitMatchesSelector
    
  if !Element::closest
    Element::closest = (s) ->
      el = this
      if !document.documentElement.contains(el)
        return null
      loop
        if el.matches(s)
          return el
        el = el.parentElement or el.parentNode
        unless el != null
          break
      null
  # a decorator to allow mentio to work within modals
  # https://github.com/jeff-collins/ment.io/issues/68#issuecomment-200746901
  $provide.decorator 'mentioMenuDirective', ($delegate) ->
    directive = _.first($delegate)
    directive.compile = ->
      (scope, elem) ->
        directive.link.apply(this, arguments)
        if modal = scope.parentMentio.targetElement[0].closest('.modal')
          modal.appendChild(elem[0])
    $delegate
