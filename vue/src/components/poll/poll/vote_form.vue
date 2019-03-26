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
        @$emit 'processing'
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
        @$nextTick => @$emit 'focusTextarea'

    mdColors: (option) ->
      buttonStyle @isSelected(option)

    isSelected: (option) ->
      _includes @selectedOptionIds, option.id

</script>

<template lang="pug">
.poll-poll-vote-form.lmo-drop-animation
  v-subheader(v-t="'poll_common.your_response'")
  poll-common-anonymous-helptext(v-if='stance.poll().anonymous')
  v-list(column)
    v-list-tile.poll-common-vote-form__button(flat align-center :md-colors='mdColors(option)', @click='select(option)', v-for='option in orderedPollOptions()', :key='option.id')
      .poll-common-stance-icon__chip(:style="{'border-color': option.color}")
      v-list-tile-title {{ option.name }}
  validation-errors(:subject='stance', field='stanceChoices')
  poll-common-stance-reason.animated(:stance='stance', v-show='stance.poll().multipleChoice || selectedOptionIds.length', v-if='stance')
  v-card-actions
    poll-common-show-results-button(v-if='stance.isNew()')
    v-spacer
    v-btn.poll-common-vote-form__submit(color="primary" @click='submit()', v-t="'poll_common.vote'")
</template>
