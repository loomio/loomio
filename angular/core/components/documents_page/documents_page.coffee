angular.module('loomioApp').controller 'DocumentsPageController', ($routeParams, $rootScope, Records, AbilityService, LoadingService, ModalService, DocumentModal, ConfirmModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'documentsPage'})

  @fetchDocuments = =>
    Records.documents.fetchByGroup(@group, @fragment)
  LoadingService.applyLoadingFunction @, 'fetchDocuments'

  @documents = ->
    _.filter @group.documents(), (doc) =>
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

  @edit = (doc) ->
    ModalService.open DocumentModal, doc: -> doc

  @remove = (doc) ->
    ModalService.open ConfirmModal,
      forceSubmit: -> false
      submit:      -> doc.destroy
      text:        ->
        title:    'documents_page.confirm_remove_title'
        helptext: 'documents_page.confirm_remove_helptext'
        flash:    'documents_page.document_removed'

  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group
    @fetchDocuments()
  , (error) ->
    $rootScope.$broadcast('pageError', error)

  return
