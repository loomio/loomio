Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

{ applyLoadingFunction } = require 'shared/helpers/apply'

$controller = ($routeParams, $rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', { page: 'documentsPage'}

  @fetchDocuments = =>
    Records.documents.fetchByGroup(@group, @fragment)
  applyLoadingFunction @, 'fetchDocuments'

  @documents = (filter) ->
    _.filter @group.allDocuments(), (doc) =>
      _.isEmpty(@fragment) or doc.title.match(///#{@fragment}///i)

  @hasDocuments = ->
    _.some @documents()

  @addDocument = ->
    ModalService.open 'DocumentModal', doc: =>
      Records.documents.build
        modelId:   @group.id
        modelType: 'Group'

  @canAdministerGroup = ->
    AbilityService.canAdministerGroup(@group)

  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group
    EventBus.broadcast $rootScope, 'currentComponent',
      group: @group
      page: 'documentsPage'
    @fetchDocuments()
  , (error) ->
    EventBus.broadcast $rootScope, 'pageError', error

  return

$controller.$inject = ['$routeParams', '$rootScope']
angular.module('loomioApp').controller 'DocumentsPageController', $controller
