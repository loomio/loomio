angular.module('loomioApp').controller 'DiscussionFormController', ($scope, $modalInstance, DiscussionService, discussion, UserAuthService, MembershipService) ->
  currentUser = UserAuthService.currentUser
  $scope.discussion = discussion

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

  $scope.saveSuccess = ->
    $modalInstance.close()

  $scope.saveError = (error) ->
    console.log error

  $scope.cancel = ($event) ->
    $event.preventDefault()
    $modalInstance.dismiss('cancel')

  $scope.submit = ->
    DiscussionService.save($scope.discussion, $scope.saveSuccess, $scope.saveError)
