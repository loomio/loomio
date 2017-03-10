angular.module('loomioApp').factory 'FacebookService', ($facebook, AppConfig) ->
  new class FacebookService
    init: ->
      return if document.querySelector('#facebook-jssdk')
      existingScript = document.querySelector('script')
      script = document.createElement('script')
      script.id  = 'facebook-jssdk'
      script.src = '//connect.facebook.net/en_US/all.js'
      existingScript.parentNode.insertBefore(script, existingScript)

    login: ->
      $facebook.api('/me').then (response) =>
        @userId = response.id

    fetchGroups: ->
      if @userId
        $facebook.api("/#{@userId}/groups").then console.log
      else
        console.log('not logged in!')
