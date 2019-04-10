<script lang="coffee">
Session      = require 'shared/services/session'
EventBus     = require 'shared/services/event_bus'
ModalService = require 'shared/services/modal_service'

module.exports =
  created: ->
    # EventBus.broadcast $rootScope, 'currentComponent', { page: 'installSlackPage' }
    ModalService.open('InstallSlackModal', group: (-> null), preventClose: (-> true)) if Session.user().identityFor('slack')
</script>

<template>
  <div class="install-slack-page"></div>
</template>
