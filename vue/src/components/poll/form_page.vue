<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import Flash  from '@/shared/services/flash'
import { onError } from '@/shared/helpers/form'

export default
  data: ->
    poll: null

  created: -> @init()

  methods:
    init: ->
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

    submit: ->
      actionName = if @poll.isNew() then 'created' else 'updated'
      @poll.customFields.can_respond_maybe = @poll.canRespondMaybe if @poll.pollType == 'meeting'
      @poll.setErrors({})
      @poll.save()
      .then (data) =>
        pollKey = data.polls[0].key
        Records.polls.findOrFetchById(pollKey, {}, true).then (poll) =>
          @$router.replace(@urlFor(poll))
          Flash.success "poll_#{poll.pollType}_form.#{poll.pollType}_#{actionName}"
      .catch onError(@poll)

  computed:
    title_key: ->
      mode = if @poll.isNew()
        'start'
      else
        'edit'
      'poll_' + @poll.pollType + '_form.'+mode+'_header'


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
            poll-common-directive(:poll='poll' name='form')
          v-card-actions.poll-common-form-actions
            v-spacer
            v-btn.poll-common-form__submit(color="primary" @click='submit()' v-if='!poll.isNew()' :loading="poll.processing")
              span(v-t="'common.action.save_changes'")
            v-btn.poll-common-form__submit(color="primary" @click='submit()' v-if='poll.closingAt && poll.isNew() && poll.groupId' :loading="poll.processing")
              span(v-t="{path: 'poll_common_form.start_poll_type', args: {poll_type: poll.translatedPollType()}}")
            v-btn.poll-common-form__submit(color="primary" @click='submit()' v-if='!poll.closingAt && poll.isNew() && poll.groupId' :loading="poll.processing")
              span(v-t="{path: 'poll_common_form.start_poll_type', args: {poll_type: poll.translatedPollType()}}")
</template>
