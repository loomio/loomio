angular.module('loomioApp').factory 'DiscussionForm', ->
  templateUrl: 'generated/components/discussion_form/discussion_form.html'
  controller: ($scope, $controller, $location, discussion, CurrentUser, Records, FlashService) ->
    $scope.discussion = discussion

    $scope.submit = ->
      discussion.save().then (records) ->
        discussion = records.discussions[0]
        $location.path "/d/#{discussion.key}"
        $scope.$close()
        FlashService.success 'discussion_form.messages.created'

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
