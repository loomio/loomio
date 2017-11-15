angular.module('loomioApp').factory 'AnnouncementModal', ->
  templateUrl: 'generated/components/announcement/modal/announcement_modal.html'
  controller: ($scope, model) ->
    $scope.model = model
