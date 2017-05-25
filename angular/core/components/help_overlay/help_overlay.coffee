angular.module('loomioApp').directive 'helpOverlay', ->
  scope: {tutorial: '='}
  restrict: 'E'
  templateUrl: 'generated/components/help_overlay/help_overlay.html'
  controller: ($scope) ->

    target = document.querySelector($scope.tutorial.target)
    rect   = if target then target.getBoundingClientRect() else {}

    $scope.highlightStyle = ->
      position: 'relative'
      top:    rect.top-10     + 'px'
      left:   rect.left-10    + 'px'
      bottom: rect.bottom-10  + 'px'
      right:  rect.right-10   + 'px'
      width:  rect.width+20   + 'px'
      height: rect.height+20  + 'px'

    $scope.tooltipStyle = ->
      left:     'auto !important'
      right:    rect.right-10 + 'px !important'
      top:      rect.top + rect.height + 20 + 'px'

    $scope.close = ->
      $scope.tutorial = null
