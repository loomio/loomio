I18n = require 'shared/services/i18n'

angular.module('loomioApp').directive 'pollCommonFormFields', ->
  scope: {poll: '='}
  template: require('./poll_common_form_fields.haml')
  controller: ['$scope', ($scope) ->
    $scope.titlePlaceholder = ->
      I18n.t("poll_#{$scope.poll.pollType}_form.title_placeholder")

    $scope.detailsPlaceholder = ->
      I18n.t("poll_#{$scope.poll.pollType}_form.details_placeholder")
  ]
