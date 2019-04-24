<script lang="coffee">
import Session        from '@/shared/services/session'
import AbilityService from '@/shared/services/ability_service'
import { discussionPrivacy } from '@/shared/helpers/helptext'
import { submitDiscussion } from '@/shared/helpers/form'
import _map from 'lodash/map'
import _sortBy from 'lodash/sortBy'

export default
  props:
    discussion: Object
    close: Function
  data: ->
    showGroupSelect: false
    isDisabled: false
  created: ->
    @submit = submitDiscussion @, @discussion,
      successCallback: (data) =>
        discussionKey = data.discussions[0].key
        @close()
        @$router.push("/d/#{discussionKey}")
    if @discussion.isNew()
      @showGroupSelect = true
  methods:
    updatePrivacy: ->
      @discussion.private = @discussion.privateDefaultValue()

    showPrivacyForm: ->
      return unless @discussion.group()
      @discussion.group().discussionPrivacyOptions == 'public_or_private'

  computed:
    availableGroups: ->
      _.filter Session.user().formalGroups(), (group) ->
        AbilityService.canStartThread(group)

    privacyPrivateDescription: ->
      @$t discussionPrivacy(discussion, true),
        group:  @discussion.group().name,
        parent: @discussion.group().parentName()

    groupSelectOptions: ->
      return [] unless @availableGroups
      _sortBy(_map(@availableGroups, (group) => {
        text: group.fullName,
        value: group.id
      }), 'fullName')
</script>

<template lang="pug">
v-card.discussion-form
  .lmo-disabled-form(v-show='isDisabled')
  v-card-title
    v-layout(justify-space-between style="align-items: center")
      v-flex
        .headline(v-t="'discussion_form.new_discussion_title'")
      v-flex(shrink)
        dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-text
    span {{ discussion }}
    .lmo-hint-text(v-t="'group_page.discussions_placeholder'", v-show='discussion.isNew() && !discussion.isForking()')
    .lmo-hint-text(v-t="{ path: 'discussion_form.fork_notice', args: { count: discussion.forkedEvents.length, title: discussion.forkTarget().discussion().title } }", v-if='discussion.isForking()')
    .md-block(v-show='showGroupSelect')
      label(for='discussion-group-field', v-t="'discussion_form.group_label'")
      v-select#discussion-group-field.discussion-form__group-select(v-model='discussion.groupId', :placeholder="$t('discussion_form.group_placeholder')", :items='groupSelectOptions', ng-required='true', @change='discussion.fetchAndRestoreDraft(); updatePrivacy()')
      .md-errors-spacer
    .discussion-form__group-selected(v-if='discussion.groupId')
      v-text-field#discussion-title.discussion-form__title-input.lmo-primary-form-input(:label="$t('discussion_form.title_label')", :placeholder="$t('discussion_form.title_placeholder')", v-model='discussion.title', maxlength='255')
      //- validation-errors(:subject='discussion', field='title')
      //- textarea(lmo_textarea='', v-model='discussion.description', field='description', :placeholder="$t('discussion_form.context_placeholder')", :label="$t('discussion_form.context_label')", v-if='!discussion.isForking()')
      lmo-textarea(:model='discussion' field="description" :placeholder="$t('discussion_form.context_placeholder')")
      v-list.discussion-form__options
        v-list-tile.discussion-form__privacy-form(v-if='showPrivacyForm()')
          v-radio-group(v-model='discussion.private')
            v-radio.md-checkbox--with-summary.discussion-form__public(:value='false')
              discussion-privacy-icon(slot='label', :discussion='discussion', :private='false')
            v-radio.md-checkbox--with-summary.discussion-form__private(:value='true')
              discussion-privacy-icon(slot='label', :discussion='discussion', :private='true')
        v-list-tile.discussion-form__privacy-notice(v-if='!showPrivacyForm()')
          label.discussion-form__privacy-notice.lmo-flex(layout='row')
            i.mdi.mdi-24px.mdi-lock-outline.lmo-margin-right(v-if='discussion.private')
            i.mdi.mdi-24px.mdi-earth.lmo-margin-right(v-if='!discussion.private')
            discussion-privacy-icon(:discussion='discussion')
  v-card-actions
    .discussion-form-actions.lmo-md-actions
      v-btn.discussion-form__submit(@click="submit()" ng-disabled="submitIsDisabled || !discussion.groupId" v-t="'common.action.start'" v-if="discussion.isNew()" class="md-primary md-raised discussion-form__submit")
      v-btn.discussion-form__submit(@click="submit()" ng-disabled="submitIsDisabled" v-t="'common.action.save'" v-if="!discussion.isNew()" class="md-primary md-raised discussion-form__submit")
</template>
