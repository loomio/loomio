angular.module('loomioApp').directive 'groupsLoaded', ($timeout) ->
  restrict: 'A'
  replace: true
  link: (scope, element) ->
    $timeout ->
      leftHeight = rightHeight = 0
      _.each element.find('.groups-page__group'), (el) ->
        el = angular.element(el)
        if rightHeight < leftHeight
          el.addClass('clear-right')
          rightHeight += el.height()
        else
          el.addClass('clear-left')
          leftHeight += el.height()
    , 0
