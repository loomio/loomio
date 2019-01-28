<style lang="scss">
</style>

<script lang="coffee">
EventBus = require 'shared/services/event_bus'

{ submitOnEnter } = require 'shared/helpers/keyboard'
{ submitStance }  = require 'shared/helpers/form'
{ buttonStyle }   = require 'shared/helpers/style'

_compact = require 'lodash/compact'
_map = require 'lodash/map'
_sortBy = require 'lodash/sortBy'
_pull = require 'lodash/pull'
_includes = require 'lodash/includes'

module.exports =
  props:
    stance: Object
  data: ->
    selectedOptionIds: _compact @stance.pollOptionIds()
  created: ->
    @submit = submitStance @, @stance,
      prepareFn: =>
        EventBus.$emit @, 'processing'
        @stance.id = null
        @stance.stanceChoicesAttributes = _map @selectedOptionIds, (id) =>
          poll_option_id: id
  mounted: ->
    submitOnEnter @, element: @$el
  methods:
    orderedPollOptions: ->
      _sortBy @stance.poll().pollOptions(), 'priority'

    select: (option) ->
      if @stance.poll().multipleChoice
        if @isSelected(option)
          _pull(@selectedOptionIds, option.id)
        else
          @selectedOptionIds.push option.id
      else
        @selectedOptionIds = [option.id]
        @$nextTick => EventBus.$emit 'focusTextarea'

    mdColors: (option) ->
      buttonStyle @isSelected(option)

    isSelected: (option) ->
      _includes @selectedOptionIds, option.id

</script>

<template>
    <div class="poll-poll-vote-form lmo-drop-animation">
      <h3 v-t="'poll_common.your_response'" class="lmo-card-subheading"></h3>
      <poll-common-anonymous-helptext v-if="stance.poll().anonymous"></poll-common-anonymous-helptext>
      <div class="lmo-flex--column">
        <button
          :md-colors="mdColors(option)"
          @click="select(option)"
          v-for="option in orderedPollOptions()"
          :key="option.id"
          class="lmo-align-left poll-common-vote-form__button poll-common-vote-form__button--block"
        >
          <div :style="{'border-color': option.color}" class="poll-common-stance-icon__chip lmo-margin-right"></div>
          <span class="poll-common-vote-form__option-name">{{ option.name }}</span>
        </button>
      </div>
      <validation-errors :subject="stance" field="stanceChoices"></validation-errors>
      <poll-common-stance-reason :stance="stance" v-show="stance.poll().multipleChoice || selectedOptionIds.length" v-if="stance" class="animated"></poll-common-stance-reason>
      <div class="poll-common-form-actions lmo-flex lmo-flex__space-between">
        <poll-common-show-results-button v-if="stance.isNew()"></poll-common-show-results-button>
        <div v-if="!stance.isNew()"></div>
        <button
          @click="submit()"
          v-t="'poll_common.vote'"
          aria-label="$t('poll_poll_vote_form.vote')"
          class="md-primary md-raised poll-common-vote-form__submit"
        ></button>
      </div>
    </div>
</template>
