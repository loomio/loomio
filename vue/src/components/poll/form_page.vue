<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Session from '@/shared/services/session'
import Flash  from '@/shared/services/flash'
import PollCommonForm from '@/components/poll/common/form'

export default
  components: {PollCommonForm}

  data: ->
    poll: null

  created: -> @init()

  methods:
    init: ->
      if @$route.params.key
        Records.polls.findOrFetchById(@$route.params.key)
        .then (poll) =>
          @poll = poll.clone()

          EventBus.$emit 'currentComponent',
            group: poll.group()
            poll:  poll
            title: poll.title
            page: 'pollFormPage'

        .catch (error) ->
          EventBus.$emit 'pageError', error
          EventBus.$emit 'openAuthModal' if error.status == 403 && !Session.isSignedIn()
      else
        console.log "hi"
        @poll = Records.polls.build()

  computed:
    title_key: ->
      mode = if @poll.isNew()
        'polls_panel.new_poll'
      else
        'actions_dock.edit_poll'


</script>
<template lang="pug">
.poll-form-page
  v-main
    v-container.max-width-800
      loading(:until="poll")
        v-card.poll-common-modal(@keyup.ctrl.enter="submit()" @keydown.meta.enter.stop.capture="submit()" v-if="poll")
          submit-overlay(:value="poll.processing")
          v-card-title
            h1.headline(tabindex="-1" v-t="title_key")
            v-spacer
            v-btn(icon :to="urlFor(poll)" aria-hidden='true')
              v-icon mdi-close
          div.pa-4
            poll-common-form(:poll='poll')
</template>
