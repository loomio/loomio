AppConfig = require 'shared/services/app_config.coffee'
Session   = require 'shared/services/session.coffee'
Records   = require 'shared/services/records.coffee'

angular.module('loomioApp').factory 'HotkeyService', (ModalService, KeyEventService, InvitationModal, GroupModal, DiscussionModal, PollCommonStartModal) ->
  new class HotkeyService

    keyboardShortcuts:
      pressedI:
        execute: -> ModalService.open InvitationModal, group: -> Session.currentGroup or Records.groups.build()
      pressedG:
        execute: -> ModalService.open GroupModal, group: -> Records.groups.build()
      pressedT:
        execute: -> ModalService.open DiscussionModal, discussion: -> Records.discussions.build(groupId: (Session.currentGroup or {}).id)
      pressedP:
        execute: -> ModalService.open PollCommonStartModal, poll: -> Records.polls.build(authorId: Session.user().id)

    init: (scope) ->
      _.each @keyboardShortcuts, (args, key) =>
        KeyEventService.registerKeyEvent scope, key, args.execute, (event) ->
          KeyEventService.defaultShouldExecute(event) and !AppConfig.currentModal
