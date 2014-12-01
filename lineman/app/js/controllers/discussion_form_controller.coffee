angular.module('loomioApp').controller 'DiscussionFormController', ($scope, $modalInstance, $location, FormService, DiscussionService, discussion, UserAuthService) ->
  currentUser = UserAuthService.currentUser
  $scope.discussion = discussion

  FormService.applyForm $scope, DiscussionService.save, discussion, $modalInstance

  $scope.successCallback = (result) ->
    $modalInstance.dismiss('success')
    $location.path "/d/#{result.key}"

  $scope.availableGroups = ->
    _.filter currentUser.groups(), (group) ->
      group.membersCanStartDiscussions or group.admins().include? currentUser

  $scope.getCurrentPrivacy = ->
    $scope.discussion.group().discussionPrivacyOptions

  $scope.setCurrentPrivacy = ->
    if $scope.discussion.isNew()
      $scope.discussion.private = $scope.getCurrentPrivacy() == 'private_only'
  $scope.setCurrentPrivacy()

  $scope.showPrivacyForm = ->
    $scope.getCurrentPrivacy() == 'public_or_private'
