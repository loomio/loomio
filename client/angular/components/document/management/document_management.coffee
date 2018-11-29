AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'documentManagement', ->
  scope: {group: '=', fragment: '=', filter: '@', header: '@'}
  templateUrl: 'generated/components/document/management/document_management.html'
  controller: ['$scope', ($scope) ->

    $scope.documents = ->
      _.filter $scope.group.allDocuments(), (doc) ->
        return false  if $scope.filter == 'group'   and doc.model() != $scope.group
        return false  if $scope.filter == 'content' and doc.model() == $scope.group
        _.isEmpty($scope.fragment) or doc.title.match(///#{$scope.fragment}///i)

    $scope.hasDocuments = ->
      _.some $scope.documents()

    $scope.canAdministerGroup = ->
      AbilityService.canAdministerGroup(@group)

    $scope.edit = (doc) ->
      ModalService.open 'DocumentModal', doc: -> doc

    $scope.remove = (doc) ->
      ModalService.open 'ConfirmModal', confirm: ->
        submit:      doc.destroy
        text:
          title:    'documents_page.confirm_remove_title'
          helptext: 'documents_page.confirm_remove_helptext'
          flash:    'documents_page.document_removed'
  ]
