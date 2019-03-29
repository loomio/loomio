angular.module('loomioApp').factory 'TagApplyModal', ->
  templateUrl: 'generated/components/tags/tag_apply_modal/tag_apply_modal.html'
  controller: ['$scope', 'discussion', ($scope, discussion) ->
    $scope.discussion = discussion
  ]
