Session      = require 'shared/services/session.coffee'
Records      = require 'shared/services/records.coffee'
ModalService = require 'shared/services/modal_service.coffee'
I18n         = require 'shared/services/i18n.coffee'

_      = require 'lodash'
moment = require 'moment'

angular.module('loomioApp').directive 'groupProgressCard', ->
  scope: { group: '=?', discussion: '=?' }
  restrict: 'E'
  templateUrl: 'generated/components/group_progress_card/group_progress_card.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.group = $scope.group || $scope.discussion.group()

    $scope.show = ->
      $scope.group.createdAt.isAfter(moment("2016-10-18")) &&
      $scope.group.isParent() &&
      Session.user().isAdminOf($scope.group) &&
      !Session.user().hasExperienced("dismissProgressCard", $scope.group)

    $scope.activities = [
      translate: "set_description"
      complete:  -> $scope.group.description
      click:     -> ModalService.open 'GroupModal', group: -> $scope.group
    ,
      translate: "set_logo"
      complete:  -> $scope.group.logoUrl() != '/theme/icon.png'
      click:     -> ModalService.open 'LogoPhotoForm', group: -> $scope.group
    ,
      translate: "set_cover_photo"
      complete:  -> $scope.group.hasCustomCover
      click:     -> ModalService.open 'CoverPhotoForm', group: -> $scope.group
    ,
      translate: "invite_people_in"
      complete:  -> $scope.group.membershipsCount > 1 or $scope.group.invitationsCount > 0
      click:     -> ModalService.open 'AnnouncementModal', announcement: -> Records.announcements.buildFromModel($scope.group)
    ,
      translate: "start_thread"
      complete:  -> $scope.group.discussionsCount > 2
      click:     -> ModalService.open 'DiscussionStartModal', discussion: -> Records.discussions.build(groupId: $scope.group.id)
    ]

    $scope.translationFor = (key) ->
      I18n.t("loomio_onboarding.group_progress_card.activities.#{key}")

    $scope.$close = ->
      Records.memberships.saveExperience("dismissProgressCard", Session.user().membershipFor($scope.group))
      $scope.dismissed = true

    $scope.setupComplete = ->
      _.every _.invokeMap($scope.activities, 'complete')
  ]
