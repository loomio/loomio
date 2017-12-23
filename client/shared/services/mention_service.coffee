Session = require 'shared/services/session.coffee'
Records = require 'shared/services/records.coffee'

angular.module('loomioApp').factory 'MentionService', ->
  new class MentionService
    applyMentions: (scope, model) ->
      scope.unmentionableIds = [model.authorId, Session.user().id]
      scope.fetchByNameFragment = (fragment) ->
        Records.memberships.fetchByNameFragment(fragment, model.group().key).then (response) ->
          userIds = _.without(_.pluck(response.users, 'id'), scope.unmentionableIds...)
          scope.mentionables = Records.users.find(userIds)
