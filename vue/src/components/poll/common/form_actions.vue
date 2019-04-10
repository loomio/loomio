<script lang="coffee">
{ submitOnEnter } = require 'shared/helpers/keyboard'
{ submitPoll }    = require 'shared/helpers/form'

module.exports =
  props:
    poll: Object
    close: Function
  created: ->
    @submit = submitPoll @, @poll,
      broadcaster: @
      successCallback: =>
        @close()
    # submitOnEnter $scope
</script>

<template>
  <div class="poll-common-form-actions lmo-md-actions">
    <span v-if="!poll.isNew()"></span>
    <v-btn v-if="poll.isNew()" @click="$emit('previousStep')" v-t="'common.action.back'" aria-label="$t('common.action.back')" class="md-accent"></v-btn>
    <div class="lmo-md-actions">
      <!-- <outlet name="before-poll-submit" model="poll"></outlet> -->
      <v-btn @click="submit()" v-if="!poll.isNew()" v-t="'poll_common_form.update'" aria-label="$t('poll_common_form.update')" class="md-primary md-raised poll-common-form__submit"></v-btn>
      <v-btn @click="submit()" v-if="poll.isNew() && poll.groupId" v-t="'poll_common_form.start'" aria-label="$t('poll_common_form.start')" class="md-primary md-raised poll-common-form__submit"></v-btn>
      <v-btn @click="submit()" v-if="poll.isNew() && !poll.groupId" v-t="'common.action.next'" aria-label="$t('common.action.next')" class="md-primary md-raised poll-common-form__submit"></v-btn>
    </div>
  </div>
</template>
