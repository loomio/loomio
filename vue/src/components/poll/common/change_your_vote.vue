<script lang="coffee">
import ModalService  from '@/shared/services/modal_service'

export default
  props:
    stance: Object
  data: ->
    isModalOpen: false
  methods:
    orderedStanceChoices: ->
      _.sortBy @stance.stanceChoices(), 'rank'
    openStanceForm: ->
      @isModalOpen = true
    closeStanceForm: ->
      @isModalOpen = false
      # ModalService.open 'PollCommonEditVoteModal', stance: => @stance
</script>

<template>
    <div class="poll-common-change-your-vote">
      <h3 v-t="'poll_common.your_response'" class="lmo-card-subheading"></h3>
      <poll-common-directive :stance_choice="choice" name="stance-choice" v-if="choice.id && choice.score > 0" v-for="choice in orderedStanceChoices" :key="choice.id"></poll-common-directive>
      <div class="md-actions lmo-md-actions">
        <button @click="openStanceForm()" v-t="'poll_common.change_your_stance'" aria-label="$t('poll_common.change_your_stance')" class="md-accent"></button>
      </div>
      <v-dialog v-model="isModalOpen" lazy persistent>
        <poll-common-edit-vote-modal :close="closeStanceForm" :stance="stance"></poll-common-edit-vote-modal>
      </v-dialog>
    </div>
</template>
