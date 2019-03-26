Records = require 'shared/services/records'

angular.module('loomioApp').directive 'searchResult', ->
  scope: {result: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/search_result.html'
  replace: true
  controller: ['$scope', ($scope) ->

    # removes all characters which will muck up a regex match
    escapeForRegex = (str) ->
      str.replace(/\/|\?|\*|\.|\(|\)/g, '')

    $scope.rawDiscussionBlurb = ->
      escapeForRegex $scope.result.blurb.replace(/\<\/?b\>/g, '')

    $scope.showBlurbLeader = ->
      !escapeForRegex($scope.result.description).match ///^#{$scope.rawDiscussionBlurb()}///

    $scope.showBlurbTrailer = ->
      !escapeForRegex($scope.result.description).match ///#{$scope.rawDiscussionBlurb()}$///

    return
  ]
