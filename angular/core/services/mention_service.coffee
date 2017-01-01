angular.module('loomioApp').factory 'MentionService', (Records, Session) ->
  new class MentionService
    applyMentions: (scope, model) ->
      scope.unmentionableIds = [model.authorId, Session.user().id]
      scope.fetchByNameFragment = (fragment) ->
        # NB: will need to apply mentions differently for communities, or not use them altogether
        Records.memberships.fetchByNameFragment(fragment, model.group().key).then (response) ->
          userIds = _.without(_.pluck(response.users, 'id'), scope.unmentionableIds...)
          scope.mentionables = Records.users.find(userIds)
