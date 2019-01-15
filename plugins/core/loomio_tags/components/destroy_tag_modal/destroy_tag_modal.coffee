Records = require 'shared/services/records.coffee'

_ = require 'lodash'

{ submitForm } = require 'shared/helpers/form.coffee'

angular.module('loomioApp').factory 'DestroyTagModal', ->
  template: require('./destroy_tag_modal.haml')
  controller: ['$scope', 'tag', ($scope, tag) ->
    $scope.tag = Records.tags.find(tag.id)

    $scope.submit = submitForm $scope, $scope.tag,
      submitFn: $scope.tag.destroy
      flashSuccess: 'loomio_tags.tag_destroyed'
      successCallback: ->
        $scope.tag.remove()
        _.each Records.discussionTags.find(tagId: tag.id), (dtag) -> dtag.remove()
  ]
