angular.module('loomioApp').controller 'DiscussionFormController', ($scope, $controller, $location, discussion, UserAuthService, CurrentUser) ->
  $scope.discussion = discussion

  $controller('FormController', {$scope: $scope, record: discussion});

  $scope.onCreateSuccess = (records) ->
    $scope.onSuccess 'created'
    discussion = records.discussions[0]
    $location.path "/d/#{discussion.key}"

  $scope.availableGroups = ->
    groups = _.filter CurrentUser.groups(), (group) ->
      group.membersCanStartDiscussions or group.admins().include? CurrentUser
    _.sortBy groups, (g) -> g.fullName()


  $scope.getCurrentPrivacy = ->
    $scope.discussion.group().discussionPrivacyOptions if $scope.discussion.group()

  $scope.setCurrentPrivacy = ->
    if $scope.discussion.isNew()
      $scope.discussion.private = $scope.getCurrentPrivacy() == 'private_only'

  $scope.setCurrentPrivacy()

  $scope.showPrivacyForm = ->
    $scope.getCurrentPrivacy() == 'public_or_private'
