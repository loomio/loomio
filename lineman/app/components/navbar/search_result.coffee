angular.module('loomioApp').directive 'searchResult', ->
  scope: {result: '='}
  restrict: 'E'
  templateUrl: 'generated/components/navbar/search_result.html'
  replace: true
  controller: ($scope, $rootScope, Records) ->

    # removes all characters which will muck up a regex match
    escapeForRegex = (str) ->
      str.replace(/\/|\?|\*|\.|\(|\)/g, '')

    $scope.rawDiscussionBlurb = ->
      escapeForRegex $scope.result.discussionBlurb.replace(/\<\/?b\>/g, '')

    $scope.showBlurbLeader = ->
      !escapeForRegex($scope.result.discussion().description).match ///^#{$scope.rawDiscussionBlurb()}///

    $scope.showBlurbTrailer = ->
      !escapeForRegex($scope.result.discussion().description).match ///#{$scope.rawDiscussionBlurb()}$///

    return
