angular.module('loomioApp').factory 'MentionService', (Records, Session) ->
  new class MentionService
    applyMentions: (scope, model) ->
      scope.updateMentionables = (fragment) ->
        regex = new RegExp("(^#{fragment}| +#{fragment})", 'i')
        allMembers = _.filter model.group().members(), (member) ->
          return false if member.id == Session.user().id
          (regex.test(member.name) or regex.test(member.username))
        scope.mentionables = allMembers.slice(0, 5)

      scope.fetchByNameFragment = (fragment) ->
        scope.updateMentionables(fragment)
        Records.memberships.fetchByNameFragment(fragment, model.group().key).then ->
          scope.updateMentionables(fragment)
