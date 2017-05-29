angular.module('loomioApp').directive 'installSlackInstallForm', ($location, KeyEventService, FormService, Session, Records, LmoUrlService) ->
  templateUrl: 'generated/components/install_slack/install_form/install_slack_install_form.html'
  controller: ($scope) ->
    $scope.groups = ->
      _.filter _.sortBy(Session.user().adminGroups(), 'fullName'), (group) -> !group.identityId

    newGroup = Records.groups.build(name: Session.user().slackIdentity().customFields.slack_team_name)

    $scope.toggleExistingGroup = ->
      $scope.setSubmit(if $scope.group.id then newGroup else _.first($scope.groups()))

    $scope.setSubmit = (group) ->
      $scope.group = group
      $scope.submit = FormService.submit $scope, $scope.group,
        prepareFn: ->
          $scope.$emit 'processing'
          $scope.group.identityId = Session.user().slackIdentity().id
        flashSuccess: 'install_slack.install.slack_installed'
        skipClose: true
        successCallback: (response) ->
          g = Records.groups.find(response.groups[0].key)
          $location.path LmoUrlService.group(g)
          $scope.$emit 'installComplete', g
    $scope.setSubmit(_.first($scope.groups() or newGroup))

    KeyEventService.submitOnEnter $scope, anyEnter: true
    $scope.$on 'focus',  $scope.focus

    return
