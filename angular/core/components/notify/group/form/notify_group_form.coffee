angular.module('loomioApp').directive 'notifyGroupForm', ($translate, Records, Session, LoadingService) ->
  scope: {notified: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notify/group/form/notify_group_form.html'
  controller: ($scope) ->
    $scope.search =
      fragment: ""

    $scope.init = ->
      Records.memberships.fetchByGroup($scope.notified.id, per: 1000).then ->
        Records.groups.findOrFetchById($scope.notified.id).then (group) ->
          $scope.group = group
          $scope.updateVisible()
    LoadingService.applyLoadingFunction $scope, 'init'
    $scope.init()

    $scope.updateVisible = ->
      _.map $scope.group.members(), (user) ->
        user.showInNotifyGroup = _.isEmpty($scope.search.fragment) or
                                 user.name.match(///#{$scope.search.fragment}///i) or
                                 user.username.match(///#{$scope.search.fragment}///i)

    $scope.userIds = {}
    _.each $scope.notified.notified_ids, (id) -> $scope.userIds[id] = true

    $scope.userIsMe = (user) ->
      Session.user() == user

    $scope.loudOrMute = (user) ->
      _.contains ['loud', 'mute'], user.membershipFor($scope.group).volume

    $scope.selectedUserIds = ->
      _.map _.keys(_.pick($scope.userIds, _.identity)), (num) -> Number(num)

    $scope.submit = ->
      $scope.notified.notified_ids = $scope.selectedUserIds()
      $scope.notified.subtitle     = $translate.instant "notify_group.group_subtitle", count: $scope.notified.notified_ids.length
      $scope.notified.editing      = false
