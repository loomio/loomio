<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import { iconFor }          from '@/shared/helpers/poll'
import PollCommonDirective from '@/components/poll/common/directive.vue'
import Flash   from '@/shared/services/flash'
import _sortBy from 'lodash/sortBy'
import { onError } from '@/shared/helpers/form'

export default
  props:
    stance: Object
    close: Function
  data: ->
    isEditing: true
  components:
    PollCommonDirective: PollCommonDirective

  methods:
    submit: ->
      actionName = if @stance.isNew() then 'created' else 'updated'
      @stance.save()
      .then =>
        @stance.poll().clearStaleStances()
        Flash.success "poll_#{@stance.poll().pollType}_vote_form.stance_#{actionName}"
        @close()
      .catch onError(@stance)

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
  submit-overlay(:value="stance.processing")
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
        v-btn.poll-common-edit-vote__button(color="accent" outlined @click="toggleCreation()", v-t="'poll_common.change_vote'")
      .poll-common-stance-reason
        lmo-textarea.poll-common-vote-form__reason(:model='stance', field='reason', :label="$t('poll_common.reason')", :placeholder="$t('poll_common.reason_placeholder')", maxlength="500" autofocus)
    v-card-actions
      v-spacer
      v-btn.poll-common-edit-vote__submit(color="primary" @click="submit()", v-t="'poll_common.save_changes'")
</template>
