angular.module('loomioApp').factory 'ConnectionService', ->
  new class ConnectionService
    onReconnect: (fn) ->
      PrivatePub.faye (client) ->
        client.on 'transport:up', fn
    onDisconnect: (fn) ->
      PrivatePub.faye (client) ->
        client.on 'transport:down', fn
