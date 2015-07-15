angular.module('loomioApp').factory 'DiscussionForm', ->
  templateUrl: 'generated/components/discussion_form/discussion_form.html'
  controller: ($scope, $controller, $location, discussion, CurrentUser, Records, FlashService) ->
    $scope.discussion = discussion.clone()

    $scope.submit = ->
      newDiscussion = $scope.discussion.isNew()
      $scope.discussion.save().then (records) ->
        $scope.discussion = records.discussions[0]
        $scope.$close()
        if newDiscussion
          $location.path "/d/#{$scope.discussion.key}"
          FlashService.success 'discussion_form.messages.created'
        else
          FlashService.success 'discussion_form.messages.updated'


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
