angular.module('loomioApp').factory 'MentionLinkService', ->
  new class MentionLinkService
    cook: (mentionedUsernames, text) ->
      text
      _.each mentionedUsernames, (username) ->
        text = text.replace(///@#{username}///g, "[[@#{username}]]")
      text
