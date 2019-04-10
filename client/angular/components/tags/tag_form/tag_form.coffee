Records      = require 'shared/services/records.coffee'
EventBus     = require 'shared/services/event_bus.coffee'
ModalService = require 'shared/services/modal_service.coffee'
AppConfig    = require 'shared/services/app_config.coffee'

{ submitForm }      = require 'shared/helpers/form.coffee'
{ submitOnEnter }   = require 'shared/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'tagForm', ->
  scope: {tag: '='}
  restrict: 'E'
  replace: true
  templateUrl: 'generated/components/tags/tag_form/tag_form.html'
  controller: ['$scope', ($scope) ->
    $scope.tagColors = _.uniq(AppConfig.pollColors.poll)

    $scope.closeForm = ->
      EventBus.emit $scope, 'closeTagForm'

    $scope.openDestroyForm = ->
      ModalService.open 'DestroyTagModal', tag: -> $scope.tag

    $scope.submit = submitForm $scope, $scope.tag,
      flashSuccess: 'loomio_tags.tag_created'
      successCallback: $scope.closeForm

    submitOnEnter $scope, anyEnter: true

    return
  ]
