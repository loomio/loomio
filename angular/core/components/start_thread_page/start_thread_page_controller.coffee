angular.module('loomioApp').controller 'StartThreadPageController', ($scope, $location, $rootScope, Records, LoadingService) ->
  $rootScope.$broadcast('currentComponent', { page: 'startThreadPage', skipScroll: true })
  @discussion = Records.discussions.build
    title:       $location.search().title
    groupId:     $location.search().group_id
    customFields:
      pending_emails: _.compact(($location.search().pending_emails || "").split(','))

  LoadingService.listenForLoading $scope

  return
