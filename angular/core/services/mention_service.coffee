angular.module('loomioApp').factory 'MentionService', (Records, AbilityService) ->
  new class MentionService
    applyMentions: (scope, group) ->
      scope.fetchByNameFragment = (fragment) ->
        Records.memberships.fetchByNameFragment(fragment, group.key).then (response) ->
          scope.mentionables = Records.users.find(_.pluck(response.users, 'id'))
