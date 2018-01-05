Records        = require 'shared/services/records.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ applyLoadingFunction } = require 'angular/helpers/apply.coffee'

$controller = ($routeParams, $rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', { page: 'documentsPage'}

  @fetchDocuments = =>
    Records.documents.fetchByGroup(@group, @fragment)
  applyLoadingFunction @, 'fetchDocuments'

  @documents = (filter) ->
    _.filter @group.allDocuments(), (doc) =>
      _.isEmpty(@fragment) or doc.title.match(///#{@fragment}///i)

  @hasDocuments = ->
    _.any @documents()

  @addDocument = ->
    ModalService.open 'DocumentModal', doc: =>
      Records.documents.build
        modelId:   @group.id
        modelType: 'Group'

  @canAdministerGroup = ->
    AbilityService.canAdministerGroup(@group)

  Records.groups.findOrFetchById($routeParams.key).then (group) =>
    @group = group
    @fetchDocuments()
  , (error) ->
    EventBus.broadcast $rootScope, 'pageError', error

  return

$controller.$inject = ['$routeParams', '$rootScope']
angular.module('loomioApp').controller 'DocumentsPageController', $controller
