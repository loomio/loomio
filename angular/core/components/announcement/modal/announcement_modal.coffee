angular.module('loomioApp').factory 'AnnouncementModal', (Records) ->
  templateUrl: 'generated/components/announcement/modal/announcement_modal.html'
  controller: ($scope, announcement) ->
    $scope.announcement = announcement
