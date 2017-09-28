angular.module('loomioApp').controller 'DocumentsPageController', ($routeParams, $rootScope, Records, AbilityService, ModalService, DocumentModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'documentsPage'})

  @fetchDocuments = =>
    Records.documents.fetchByNameFragment(@fragment, @group.key) if @fragment

  @documents = ->
    @group.documents()

  @addDocument = ->
    ModalService.open DocumentModal, doc: =>
      Records.documents.build
        modelId:   @group.id
        modelType: 'Group'

  @canAdministerGroup = ->
    AbilityService.canAdministerGroup(@group)

  @edit = (doc) ->
    ModalService.open DocumentModal, doc: -> doc

  @remove = (doc) ->
    doc.destroy()

  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  return
