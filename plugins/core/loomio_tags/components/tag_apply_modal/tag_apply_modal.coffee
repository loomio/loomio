angular.module('loomioApp').factory 'TagApplyModal', ->
  template: require('./tag_apply_modal.haml')
  controller: ['$scope', 'discussion', ($scope, discussion) ->
    $scope.discussion = discussion
  ]
