angular.module('loomioApp').factory 'AnnouncementModal', ->
  template: require('./announcement_modal.haml')
  controller: ['$scope', 'announcement', ($scope, announcement) ->
    $scope.announcement = announcement
  ]
