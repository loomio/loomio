Session       = require 'shared/services/session'
Records       = require 'shared/services/records'
EventBus      = require 'shared/services/event_bus'
LmoUrlService = require 'shared/services/lmo_url_service'

{ submitForm }    = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'installSlackInstallForm', ->
  templateUrl: 'generated/components/install_slack/install_form/install_slack_install_form.html'
  controller: ['$scope', ($scope) ->
    $scope.groups = ->
      _.filter _.sortBy(Session.user().adminGroups(), 'fullName')

    newGroup = Records.groups.build(name: Session.user().identityFor('slack').customFields.slack_team_name)

    $scope.toggleExistingGroup = ->
      $scope.setSubmit(if $scope.group.id then newGroup else _.head($scope.groups()))

    $scope.setSubmit = (group) ->
      $scope.group = group
      $scope.submit = submitForm $scope, $scope.group,
        prepareFn: ->
          EventBus.emit $scope, 'processing'
          $scope.group.identityId = Session.user().identityFor('slack').id
        flashSuccess: 'install_slack.install.slack_installed'
        skipClose: true
        successCallback: (response) ->
          g = Records.groups.find(response.groups[0].key)
          LmoUrlService.goTo LmoUrlService.group(g)
          EventBus.emit $scope, 'nextStep', g
    $scope.setSubmit(_.head($scope.groups()) or newGroup)

    submitOnEnter $scope, anyEnter: true
    EventBus.listen $scope, 'focus',  $scope.focus

    return
  ]
