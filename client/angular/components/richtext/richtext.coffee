AppConfig      = require 'shared/services/app_config'
# unindent = require('./strip-indent');

angular.module('loomioApp').directive 'richtext', ['marked', '$compile', (marked, $compile) ->
  restrict: 'AE',
  replace: true,
  scope:
    opts: '='
    richtext: '='
    format: '='

  link: (scope, element, attrs) ->
    set = (text) ->
      return unless text
      if scope.format == "html"
        element.html(text)
      else
        element.html(marked(text, scope.opts || null));

      if scope.$eval(attrs.compile)
        $compile(element.contents())(scope.$parent);
    set(scope.richtext)
    scope.$watch('richtext', set);
]
