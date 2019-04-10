Records      = require 'shared/services/records.coffee'
ModalService = require 'shared/services/modal_service.coffee'

_ = require 'lodash'

angular.module('loomioApp').config ['$provide', ($provide) ->
  $provide.decorator 'contextPanelDirective', ['$delegate', ($delegate) ->
    $delegate[0].compile = ->
      (scope) ->
        Records.tags.fetchByGroup(scope.discussion.group().parentOrSelf())
        scope.actions.unshift
          name: 'tag_thread'
          icon: 'mdi-tag'
          canPerform: -> _.some Records.tags.find(groupId: scope.discussion.group().parentOrSelf().id)
          perform:    -> ModalService.open 'TagApplyModal', discussion: -> scope.discussion
        $delegate[0].link.apply(this, arguments) if $delegate[0].link
    $delegate
  ]
]
