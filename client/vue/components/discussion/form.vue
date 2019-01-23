<style lang="scss">
@import 'variables';
.discussion-modal {
  max-width: $small-max-px;
}

.discussion-form__options {
  clear: both;
}

.discussion-form__options md-list-item,
.discussion-form__options md-list-item .md-no-style {
  padding: 0 !important;
}

.discussion-form__options md-checkbox .md-label {
  display: block !important;
  white-space: nowrap;
}

@media (max-width: $small-max-px){
  .discussion-modal { max-width: auto; }
  .discussion-form__formatting-help { display: none; }
  .thread-helptext { display: none; }
}
</style>

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
      I18n.t discussionPrivacy(discussion, true),
        group:  @discussion.group().name,
        parent: @discussion.group().parentName()

    groupSelectOptions: ->
      return [] unless @availableGroups
      _sortBy(_map(@availableGroups, (group) => {
        text: group.fullName,
        value: group.id
      }), 'fullName')
</script>

<template>
  <div class="discussion-form">
    <div v-t="'group_page.discussions_placeholder'" v-show="discussion.isNew() && !discussion.isForking()" class="lmo-hint-text"></div>
    <div v-t="{ path: 'discussion_form.fork_notice', args: { count: discussion.forkedEvents.length, title: discussion.forkTarget().discussion().title } }" v-if="discussion.isForking()" class="lmo-hint-text"></div>
    <div v-show="showGroupSelect" class="md-block">
      <label for="discussion-group-field" v-t="'discussion_form.group_label'"></label>
      <v-select
        v-model="discussion.groupId"
        :placeholder="$t('discussion_form.group_placeholder')"
        :items="groupSelectOptions"
        ng-required="true"
        @change="discussion.fetchAndRestoreDraft(); updatePrivacy()"
        class="discussion-form__group-select"
        id="discussion-group-field">
      </v-select>
      <div class="md-errors-spacer"></div>
    </div>
    <div v-if="discussion.groupId" class="discussion-form__group-selected">
      <div class="md-block">
        <label for="discussion-title" v-t="'discussion_form.title_label'"></label>
        <div class="lmo-relative">
          <input
            :placeholder="$t('discussion_form.title_placeholder')"
            v-model="discussion.title"
            maxlength="255"
            class="discussion-form__title-input lmo-primary-form-input"
            id="discussion-title">
        </div>
        <validation-errors :subject="discussion" field="title"></validation-errors>
      </div>
      <textarea
        lmo_textarea
        v-model="discussion"
        field="description"
        :placeholder="$t('discussion_form.context_placeholder')"
        :label="$t('discussion_form.context_label')"
        v-if="!discussion.isForking()">
      </textarea>
      <v-list class="discussion-form__options">
        <v-list-tile v-if="showPrivacyForm()" class="discussion-form__privacy-form">
          <v-radio-group v-model="discussion.private">
            <v-radio v-model="discussion.private" :value="false" class="md-checkbox--with-summary discussion-form__public">
              <discussion-privacy-icon discussion="discussion" private="false"></discussion-privacy-icon>
            </v-radio>
            <v-radio v-model="discussion.private" :value="true" class="md-checkbox--with-summary discussion-form__private">
              <discussion-privacy-icon discussion="discussion" private="true"></discussion-privacy-icon>
            </v-radio>
          </v-radio-group>
        </v-list-tile>
        <v-list-tile v-if="!showPrivacyForm()" class="discussion-form__privacy-notice">
          <label layout="row" class="discussion-form__privacy-notice lmo-flex">
            <i v-if="discussion.private" class="mdi mdi-24px mdi-lock-outline lmo-margin-right"></i>
            <i v-if="!discussion.private" class="mdi mdi-24px mdi-earth lmo-margin-right"></i>
            <discussion-privacy-icon discussion="discussion"></discussion-privacy-icon>
          </label>
        </v-list-tile>
      </v-list>
    </div>
  </div>
</template>
