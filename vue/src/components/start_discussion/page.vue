<script lang="coffee">
import Records       from '@/shared/services/records'
import ModalService  from '@/shared/services/modal_service'
import LmoUrlService from '@/shared/services/lmo_url_service'
import EventBus      from '@/shared/services/event_bus'

import { applyDiscussionStartSequence } from '@/shared/helpers/apply'
import { listenForLoading }             from '@/shared/helpers/listen'

export default
  data: ->
    discussion: null
    isDisabled: false
  created: ->
    @init()
  methods:
    init: ->
      EventBus.$emit 'currentComponent', { page: 'startDiscussionPage', skipScroll: true }
      @discussion = Records.discussions.build
        title:       @$route.query.title
        groupId:     parseInt(@$route.query.group_id)

      # listenForLoading $scope

      Records.groups.findOrFetch(@$route.params.group_id).then =>
        # applyDiscussionStartSequence @,
        #   emitter: @
        #   afterSaveComplete: (event) ->
        #     ModalService.open 'AnnouncementModal', announcement: ->
        #       Records.announcements.buildFromModel(event)
</script>
<template>
  <div class="lmo-one-column-layout">
    <main class="start-discussion-page lmo-row">
      <div layout="column" class="start-discussion-page__main-content lmo-flex lmo-card lmo-relative">
        <div v-if="isDisabled" class="lmo-disabled-form"></div>
        <div class="discussion-start-discussion__header lmo-flex lmo-flex__center"><i class="mdi mdi-forum lmo-margin-right"></i>
          <h2 v-t="'discussion_form.new_discussion_title'" class="lmo-card-heading"></h2></div>
        <div class="discussion-start-discussion">
          <discussion-form :discussion="discussion"></discussion-form>
        </div>
      </div>
    </main>
  </div>
</template>
