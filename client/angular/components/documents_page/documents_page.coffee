angular.module('loomioApp').controller 'DocumentsPageController', ($routeParams, $rootScope, Records, AbilityService, LoadingService, ModalService, DocumentModal, ConfirmModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'documentsPage'})

  @fetchDocuments = =>
    Records.documents.fetchByGroup(@group, @fragment)
  LoadingService.applyLoadingFunction @, 'fetchDocuments'

  @documents = (filter) ->
    _.filter @group.allDocuments(), (doc) =>
      _.isEmpty(@fragment) or doc.title.match(///#{@fragment}///i)

  @hasDocuments = ->
    _.any @documents()

  @addDocument = ->
    ModalService.open DocumentModal, doc: =>
      Records.documents.build
        modelId:   @group.id
        modelType: 'Group'

  @canAdministerGroup = ->
    AbilityService.canAdministerGroup(@group)

  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group
    @fetchDocuments()
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  return
