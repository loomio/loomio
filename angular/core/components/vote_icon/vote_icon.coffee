angular.module('loomioApp').directive 'voteIcon', ->
  scope: {position: '='}
  restrict: 'E'
  templateUrl: 'generated/components/vote_icon/vote_icon.html'
  replace: true
  controller: ($scope) ->
    $scope.positionImg = ->
      switch $scope.position
        when 'yes' then '/img/green_thumb_22'
        when 'abstain' then '/img/yellow_thumb_22'
        when 'no' then '/img/pink_thumb_22'
        when 'block' then '/img/red_flag_22'
