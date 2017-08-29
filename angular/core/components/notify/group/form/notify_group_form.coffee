angular.module('loomioApp').directive 'notifyGroupForm', ($translate) ->
  scope: {group: '=', notified: '='}
  restrict: 'E'
  templateUrl: 'generated/components/notify/group/form/notify_group_form.html'
  controller: ($scope) ->
    $scope.updateVisible = ->
      _.map $scope.group.members(), (user) ->
        user.showInNotifyGroup = _.isEmpty($scope.fragment) or
                                 user.name.match(///#{$scope.fragment}///) or
                                 user.username.match(///#{$scope.fragment}///)
    $scope.updateVisible()

    $scope.userIds = {}
    _.each $scope.notified.notified_ids, (id) -> $scope.userIds[id] = true

    $scope.selectedUserIds = ->
      _.map _.keys(_.pick($scope.userIds, _.identity)), (num) -> Number(num)

    $scope.submit = ->
      $scope.notified.notified_ids = $scope.selectedUserIds()
      $scope.notified.subtitle     = $translate.instant "notify_group.group_subtitle", count: $scope.notified.notified_ids.length
      $scope.$emit '$close'
