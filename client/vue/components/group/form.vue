<style lang="scss">
</style>

<script lang="coffee">
AppConfig      = require 'shared/services/app_config'
AbilityService = require 'shared/services/ability_service'
I18n           = require 'shared/services/i18n'

{ groupPrivacy, groupPrivacyStatement } = require 'shared/helpers/helptext'

module.exports =
  props:
    group: Object
    modal: Boolean
  data: ->
    isDisabled: false
    rules: {
      required: (value) ->
        !!value || 'Required.'
    }
  created: ->
    @featureNames = AppConfig.features.group
  methods:
    privacyStringFor: (privacy) ->
      @$t groupPrivacy(@group, privacy),
        parent: @group.parentName()
  computed:
    titleLabel: ->
      if @group.isParent()
        "group_form.group_name"
      else
        "group_form.subgroup_name"

    privacyOptions: ->
      if @group.isSubgroup() && @group.parent().groupPrivacy == 'secret'
        ['closed', 'secret']
      else
        ['open', 'closed', 'secret']

    privacyStatement: ->
      @$t groupPrivacyStatement(@group),
        parent: @group.parentName()

    showGroupFeatures: ->
      AbilityService.isSiteAdmin() and _.some(@featureNames)
</script>

<template lang="pug">
.group-form
  .lmo-disabled-form(v-show='isDisabled')
    //- <div md-input-container class="md-block">
    //- <label v-t="titleLabel"></label>
    //- <input
    //- type="text"
    //- :placeholder="$t('group_form.group_name_placeholder')"
    //- required="true"
    //- v-model="group.name"
    //- :model-options="{ allowInvalid: true }"
    //- md-maxlength="255"
    //- class="lmo-primary-form-input group-form__name"
    //- id="group-name"
    //- >
    //- <validation-errors :subject="group" field="name"></validation-errors>
    //- </div>
  v-text-field(v-model='group.name', :placeholder="$t('group_form.group_name_placeholder')", :rules='[rules.required]', maxlength='255')
  v-textarea(:model="group.description", :placeholder="$t('group_form.description_placeholder')", :label="$t('group_form.description')")
  .group-form__privacy-statement.lmo-hint-text {{privacyStatement}}
  section.group-form__section.group-form__privacy
    h3.lmo-h3(v-t="'group_form.privacy'")
    v-radio-group(v-model='group.groupPrivacy')
      v-radio(v-for='privacy in privacyOptions' :key="privacy" :class="'md-checkbox--with-summary group-form__privacy-' + privacy" :value='privacy' :aria-label='privacy')
        template(slot='label')
          .group-form__privacy-title
            strong(v-t="'common.privacy.' + privacy")
          .group-form__privacy-subtitle {{ privacyStringFor(privacy) }}
  .group-form__advanced(v-show='group.expanded')
    section.group-form__section.group-form__joining.lmo-form-group(v-if='group.privacyIsOpen()')
      h3.lmo-h3(v-t="'group_form.how_do_people_join'")
      v-radio-group(ng-model='group.membershipGrantedUpon')
        v-radio(v-for="granted in ['request', 'approval']" :key="granted" :class="'group-form__membership-granted-upon-' + granted" :value='granted')
          template(slot='label')
            span(v-t="'group_form.membership_granted_upon_' + granted")
    section.group-form__section.group-form__permissions
      h3.lmo-h3(v-t="'group_form.permissions'")
      group-setting-checkbox.group-form__allow-public-threads(:group='group', setting='allowPublicThreads', v-if='group.privacyIsClosed() && !group.isSubgroupOfSecretParent()')
      group-setting-checkbox.group-form__parent-members-can-see-discussions(:group='group', setting='parentMembersCanSeeDiscussions', :translate-values='{parent: group.parent().name}', v-if='group.isSubgroup() && group.privacyIsClosed()')
      group-setting-checkbox.group-form__members-can-add-members(:group='group', setting='membersCanAddMembers')
      group-setting-checkbox.group-form__members-can-announce(:group='group', setting='membersCanAnnounce')
      group-setting-checkbox.group-form__members-can-create-subgroups(:group='group', setting='membersCanCreateSubgroups', v-if='group.isParent()')
      group-setting-checkbox.group-form__members-can-start-discussions(:group='group', setting='membersCanStartDiscussions')
      group-setting-checkbox.group-form__members-can-edit-discussions(:group='group', setting='membersCanEditDiscussions')
      group-setting-checkbox.group-form__members-can-edit-comments(:group='group', setting='membersCanEditComments')
      group-setting-checkbox.group-form__members-can-raise-motions(:group='group', setting='membersCanRaiseMotions')
      group-setting-checkbox.group-form__members-can-vote(:group='group', setting='membersCanVote')
    section.group-form__section.group-form__features(v-if='showGroupFeatures')
      h3.lmo-h3(v-t="'group_form.features'")
      .group-form__feature(v-for='name in featureNames', :key='name')
        // <md-checkbox id="{{name}}" ng-model="group.features[name]" class="md-checkbox--with-summary"><span for="{{name}}" translate="group_features.{{name}}"></span></md-checkbox>
  group-form-actions(:group='group', v-if='!modal')
</template>
