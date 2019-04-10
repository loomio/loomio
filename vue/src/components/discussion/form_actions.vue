<style lang="scss">
</style>
<script lang="coffee">
Records       = require 'shared/services/records'
EventBus      = require 'shared/services/event_bus'
LmoUrlService = require 'shared/services/lmo_url_service'

{ submitDiscussion } = require 'shared/helpers/form'
{ submitOnEnter }    = require 'shared/helpers/keyboard'

module.exports =
  props:
    discussion: Object
    close: Function
  created: ->
    @submit = submitDiscussion @, @discussion,
      successCallback: => @close()
</script>
<template>
  <div class="discussion-form-actions lmo-md-actions">
      <!-- <outlet name="before-discussion-submit" model="discussion"></outlet> -->
    <v-btn @click="submit()" ng-disabled="submitIsDisabled || !discussion.groupId" v-t="'common.action.start'" v-if="discussion.isNew()" class="md-primary md-raised discussion-form__submit"></v-btn>
    <v-btn @click="submit()" ng-disabled="submitIsDisabled" v-t="'common.action.save'" v-if="!discussion.isNew()" class="md-primary md-raised discussion-form__submit"></v-btn>
  </div>
</template>
