<script lang="coffee">
import Session      from '@/shared/services/session'
import EventBus     from '@/shared/services/event_bus'
import ModalService from '@/shared/services/modal_service'

export default
  created: ->
    EventBus.$emit 'currentComponent', { page: 'installSlackPage' }
    ModalService.open('InstallSlackModal', group: (-> null), preventClose: (-> true)) if Session.user().identityFor('slack')
</script>

<template>
  <div class="install-slack-page"></div>
</template>
