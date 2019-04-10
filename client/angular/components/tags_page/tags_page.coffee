Records            = require 'shared/services/records.coffee'
EventBus           = require 'shared/services/event_bus.coffee'
ThreadQueryService = require 'shared/services/thread_query_service.coffee'

$controller = ($rootScope, $routeParams) ->
  EventBus.broadcast $rootScope, 'currentComponent', page: 'tagsPage'

  Records.discussions.fetch(path: "tags/#{$routeParams.id}")
  Records.tags.findOrFetchById($routeParams.id).then (tag) =>
    @tag = Records.tags.find(parseInt($routeParams.id))
    @view = ThreadQueryService.queryFor group: @tag.group()
    EventBus.broadcast $rootScope, 'currentComponent',
      group: @tag.group()
      page: 'tagsPage'

    # WARNING: hack because applyWhere doesn't seem to live update here.
    oldThreads = @view.threads
    @view.threads = =>
      _.filter oldThreads(), (thread) =>
        _.some Records.discussionTags.find(tagId: @tag.id, discussionId: thread.id)

  return

$controller.$inject = ['$rootScope', '$routeParams']
angular.module('loomioApp').controller 'TagsPageController', $controller
