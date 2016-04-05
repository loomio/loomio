angular.module('loomioApp').directive 'voteIcon', ->
  scope: {position: '='}
  restrict: 'E'
  templateUrl: 'generated/components/vote_icon/vote_icon.html'
  replace: true
  controller: ($scope) ->
    $scope.positionImg = ->
      switch $scope.position
        when 'yes' then '/img/agree.svg'
        when 'abstain' then '/img/abstain.svg'
        when 'no' then '/img/disagree.svg'
        when 'block' then '/img/block.svg'
