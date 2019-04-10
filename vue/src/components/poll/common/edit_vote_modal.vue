<style lang="scss">
</style>
<script lang="coffee">
EventBus = require 'shared/services/event_bus'

{ listenForLoading } = require 'shared/helpers/listen'
{ iconFor }          = require 'shared/helpers/poll'
{ submitStance }  = require 'shared/helpers/form'

_sortBy = require 'lodash/sortBy'

module.exports =
  props:
    stance: Object
    close: Function
  data: ->
    isEditing: true
    dstance: @stance.clone()
  beforeCreate: ->
    @$options.components.PollCommonDirective = require('src/components/poll/common/directive.vue').default
  created: ->
    @submit = submitStance @, @stance,
      prepareFn: ->
        EventBus.emit 'processing'

    # EventBus.listen $scope, 'stanceSaved', ->
    #   $scope.$close()
    #   EventBus.broadcast $rootScope, 'refreshStance'
    #
    # listenForLoading $scope
  methods:
    toggleCreation: ->
      @isEditing = false
  computed:
    icon: ->
      iconFor(@stance.poll())
    orderedStanceChoices: ->
      _sortBy(@stance.stanceChoices(), 'rank')
</script>
<template lang="pug">
v-card.poll-common-modal
  v-card-title
    i.mdi(class="icon")
    h1.lmo-h1(v-if="stance.isNew()", v-t="'poll_common.your_response'")
    h1.lmo-h1(v-if="!stance.isNew()", v-t="'poll_common.change_your_response'")
    dismiss-modal-button(:close="close")

  v-card-text(v-if="!isEditing")
    poll-common-directive(name="vote-form", :stance="stance")

  v-card-text(v-if="isEditing")
    div
      poll-common-directive(:stance-choice="choice", name="stance-choice", v-if="choice.id && choice.score > 0", v-for="choice in orderedStanceChoices" :key="choice.id")
      v-btn(@click="toggleCreation()", v-t="'poll_common.change_vote'")
    .poll-common-stance-reason
      v-textarea.poll-common-vote-form__reason(lmo_textarea, :model="stance.reason", :label="$t('poll_common.reason')", :placeholder="$t('poll_common.reason_placeholder')", maxlength="500")
      v-btn(@click="submit()", v-t="'poll_common.save_changes'", primary)
</template>
