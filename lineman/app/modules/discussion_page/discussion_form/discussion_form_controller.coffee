angular.module('loomioApp').controller 'DiscussionFormController', ($scope, $controller, $location, discussion, UserAuthService) ->
  currentUser = window.Loomio.currentUser
  $scope.discussion = discussion

  $controller('FormController', {$scope: $scope, record: discussion });

  $scope.onCreateSuccess = (records) ->
    $scope.onSuccess 'created'
    discussion = records.discussions[0]
    $location.path "/d/#{discussion.key}"

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
