<script lang="coffee">
Session        = require 'shared/services/session'
AbilityService = require 'shared/services/ability_service'
I18n           = require 'shared/services/i18n'

{ discussionPrivacy } = require 'shared/helpers/helptext'

_map = require 'lodash/map'
_sortBy = require 'lodash/sortBy'

module.exports =
  props:
    discussion: Object
  data: ->
    showGroupSelect: false
  created: ->
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
.discussion-form
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
          discussion-privacy-icon(discussion='discussion')
</template>
