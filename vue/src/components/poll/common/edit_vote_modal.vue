<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import { listenForLoading } from '@/shared/helpers/listen'
import { iconFor }          from '@/shared/helpers/poll'
import { submitStance }  from '@/shared/helpers/form'
import PollCommonDirective from '@/components/poll/common/directive.vue'
import _sortBy from 'lodash/sortBy'

export default
  props:
    stance: Object
    close: Function
  data: ->
    isEditing: true
    dstance: @stance.clone()
  components:
    PollCommonDirective: PollCommonDirective

  created: ->
    @submit = submitStance(@, @stance)
    EventBus.$on 'stanceSaved', => @close()
    # EventBus.broadcast $rootScope, 'refreshStance'
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
v-card.poll-common-edit-vote-modal
  v-card-title
    h1.headline
      span(v-if="stance.isNew()", v-t="'poll_common.your_response'")
      span(v-if="!stance.isNew()", v-t="'poll_common.change_your_response'")
    v-spacer
    dismiss-modal-button(:close="close")

  v-card-text(v-if="!isEditing")
    poll-common-directive(name="vote-form", :stance="stance")

  div(v-if="isEditing")
    v-card-text
      v-layout.mb-3(align-center wrap)
        poll-common-directive(:size="48" :stance-choice="choice", name="stance-choice", v-if="choice.id && choice.score > 0", v-for="choice in orderedStanceChoices" :key="choice.id")
        v-btn(color="accent" outlined @click="toggleCreation()", v-t="'poll_common.change_vote'")
      .poll-common-stance-reason
        lmo-textarea.poll-common-vote-form__reason(:model='stance', field='reason', :label="$t('poll_common.reason')", :placeholder="$t('poll_common.reason_placeholder')", maxlength="500")
    v-card-actions
      v-spacer
      v-btn(color="primary" @click="submit()", v-t="'poll_common.save_changes'")
</template>
