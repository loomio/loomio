I18n = require 'shared/services/i18n'

angular.module('loomioApp').directive 'pollCommonFormFields', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/form_fields/poll_common_form_fields.html'
  controller: ['$scope', ($scope) ->
    $scope.titlePlaceholder = ->
      I18n.t("poll_#{$scope.poll.pollType}_form.title_placeholder")

    $scope.detailsPlaceholder = ->
      I18n.t("poll_#{$scope.poll.pollType}_form.details_placeholder")
  ]
