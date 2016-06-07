angular.module('loomioApp').factory 'MentionService', (Records, AbilityService) ->
  new class MentionService
    applyMentions: (scope, model) ->
      scope.updateMentionables = (fragment) ->
        regex = new RegExp("(^#{fragment}| +#{fragment})", 'i')
        allMembers = _.filter model.group().members(), (member) ->
          return unless AbilityService.canMention(model, member)
          (regex.test(member.name) or regex.test(member.username))
        scope.mentionables = allMembers.slice(0, 5)

      scope.fetchByNameFragment = (fragment) ->
        scope.updateMentionables(fragment)
        Records.memberships.fetchByNameFragment(fragment, model.group().key).then ->
          scope.updateMentionables(fragment)
