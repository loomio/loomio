angular.module('loomioApp').controller 'DiscussionFormController', ($scope, $modalInstance, $location, FlashService, discussion, UserAuthService) ->
  currentUser = UserAuthService.currentUser

  $scope.discussion = discussion

  onCreateSuccess = (records) ->
    $modalInstance.close()
    discussion = records.discussions[0]
    FlashService.success 'discussion_form.messages.created'
    $location.path "/d/#{discussion.key}"

  onUpdateSuccess = (records) ->
    FlashService.success 'discussion_form.messages.updated'
    $modalInstance.close()

  onFailure = (errors) ->
    console.log 'i am an errorconda:', errors

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

  $scope.cancel = ->
    $modalInstance.dismiss()

  $scope.submit = ->
    if discussion.isNew()
      discussion.save().then(onCreateSuccess, onFailure)
    else
      discussion.save().then(onUpdateSuccess, onFailure)
