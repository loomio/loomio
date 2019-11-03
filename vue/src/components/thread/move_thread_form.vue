<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import I18n           from '@/i18n'
import { submitForm } from '@/shared/helpers/form'
import { filter } from 'lodash'
import WatchRecords from '@/mixins/watch_records'
import AnnouncementModalMixin from '@/mixins/announcement_modal'

export default
  mixins: [WatchRecords, AnnouncementModalMixin]
  props:
    discussion: Object
    close: Function
  data: ->
    targetGroup: null
    submit: null
    availableGroups: []
  created: ->
    @updateTarget()
    @submit = submitForm @, @discussion,
      submitFn: @discussion.move
      flashSuccess: 'move_thread_form.messages.success'
      flashOptions:
        name: => @discussion.group().name
      successCallback: (data) =>
        discussionKey = data.discussions[0].key
        Records.discussions.findOrFetchById(discussionKey, {}, true).then (discussion) =>
          @close()
          @$router.push("/d/#{discussionKey}")
          @openAnnouncementModal(Records.announcements.buildFromModel(discussion))
    @watchRecords
      collections: ['groups', 'memberships']
      query: (store) =>
        @availableGroups = filter(Session.user().formalGroups(), (group) => group.id != @discussion.groupId)
  methods:

    updateTarget: ->
      @targetGroup = Records.groups.find(@discussion.groupId)

    moveThread: ->
      if @discussion.private and @targetGroup.privacyIsOpen()
        @submit() if confirm(I18n.t('move_thread_form.confirm_change_to_private_thread', groupName: @targetGroup.name))
      else
        @submit()
</script>
<template lang="pug">
v-card.move-thread-form
  submit-overlay(:value='discussion.processing')
  v-card-title
    h1.headline(v-t="'move_thread_form.title'")
    v-spacer
    dismiss-modal-button(:close='close')
  v-card-text
    v-select#group-dropdown.move-thread-form__group-dropdown(v-model='discussion.groupId' :required='true' @change='updateTarget()' :items='availableGroups' item-value='id' item-text='fullName' :label="$t('move_thread_form.body')")
      template(v-slot:item='data')
        v-list-item-content.group-dropdown-item
          v-list-item-title.group-dropdown-item-group-name
            span {{ data.item.fullName }}
  v-card-actions
    v-spacer
    v-btn.move-thread-form__submit(color="primary" type='button', v-t="'move_thread_form.confirm'", @click='moveThread()')
</template>
