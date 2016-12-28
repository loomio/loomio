angular.module('loomioApp').directive 'mentionField', (LmoUrlService) ->
  restrict: 'A'
  priority: 1000
  compile: (elem, attrs) ->
    console.log(attrs)
    elem.attr 'mentio', true
    elem.attr 'mentio-trigger-char': '@'
    elem.attr 'mentio-items': 'mentionables'
    elem.attr 'mentio-template-url': 'generated/components/thread_page/comment_form.mentio_menu.html'
    elem.attr 'mentio-search': 'fetchByNameFragment(term)'
    elem.attr 'ng-model-options': "{debounce: #{elem.attr('mention-debounce') || 150}}"
    elem.removeAttr 'mention-field'
    elem.removeAttr 'data-mention-field'
    elem.removeAttr 'mention-debounce'
