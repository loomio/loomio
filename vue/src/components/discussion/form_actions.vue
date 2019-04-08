<script lang="coffee">
import Records       from '@/shared/services/records'
import EventBus      from '@/shared/services/event_bus'
import LmoUrlService from '@/shared/services/lmo_url_service'
import { submitDiscussion } from '@/shared/helpers/form'
import { submitOnEnter }    from '@/shared/helpers/keyboard'

export default
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
