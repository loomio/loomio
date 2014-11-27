angular.module('loomioApp').controller 'DiscussionFormController', ($scope, $modalInstance, FormService, DiscussionService, discussion, UserAuthService, MembershipService) ->
  currentUser = UserAuthService.currentUser
  $scope.discussion = discussion

  FormService.applyForm $scope, DiscussionService, discussion, $modalInstance

  $scope.saveSuccess = ->
    $location.path "/discussions/#{$scope.discussion.key}"

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
