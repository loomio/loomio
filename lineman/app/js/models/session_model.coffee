angular.module('loomioApp').factory 'SessionModel', ->
  class SessionModel
    constructor: (data = {}) ->
      @email = data.email
      @password = data.password
      @rememberMe = data.remember_me

    params: ->
      user:
        email: @email
        password: @password
        remember_me: @rememberMe

    plural: 'sessions'
