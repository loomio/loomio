angular.module('loomioApp').config ($provide) ->
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
