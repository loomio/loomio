angular.module('loomioApp').factory 'AnnouncementModal', (Records) ->
  templateUrl: 'generated/components/announcement/modal/announcement_modal.html'
  controller: ($scope, model) ->
    $scope.announcement = Records.announcements.build
      announceableId:   model.id
      announceableType: _.capitalize(model.constructor.singular)
