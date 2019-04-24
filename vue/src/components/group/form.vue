<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import AbilityService from '@/shared/services/ability_service'
import { groupPrivacy, groupPrivacyStatement } from '@/shared/helpers/helptext'
import { scrollTo }            from '@/shared/helpers/layout'
import { submitForm }          from '@/shared/helpers/form'
import { groupPrivacyConfirm } from '@/shared/helpers/helptext'
import { submitOnEnter }       from '@/shared/helpers/keyboard'
import GroupModalMixin from '@/mixins/group_modal'

export default
  mixins: [GroupModalMixin]
  props:
    group: Object
    close: Function
  data: ->
    isDisabled: false
    rules: {
      required: (value) ->
        !!value || 'Required.'
    }
    submit: null
    isExpanded: false
  mounted: ->
    @featureNames = AppConfig.features.group
    @submit = submitForm @, @group,
      prepareFn: =>
        allowPublic = @group.allowPublicThreads
        @group.discussionPrivacyOptions = switch @group.groupPrivacy
          when 'open'   then 'public_only'
          when 'closed' then (if allowPublic then 'public_or_private' else 'private_only')
          when 'secret' then 'private_only'

        @group.parentMembersCanSeeDiscussions = switch @group.groupPrivacy
          when 'open'   then true
          when 'closed' then @group.parentMembersCanSeeDiscussions
          when 'secret' then false
      confirmFn: (model)          => @$t groupPrivacyConfirm(model)
      flashSuccess:               => "group_form.messages.group_#{@actionName}"
      successCallback: (data) =>
        @isExpanded = false
        groupKey = data.groups[0].key
        @closeModal()
        @$router.push("/g/#{groupKey}")
  methods:
    expandForm: ->
      @isExpanded = true
      scrollTo '.group-form__permissions', container: '.group-modal md-dialog-content'

    privacyStringFor: (privacy) ->
      @$t groupPrivacy(@group, privacy),
        parent: @group.parentName()
  computed:
    actionName: ->
      if @group.isNew() then 'created' else 'updated'

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
v-card.group-form
  .lmo-disabled-form(v-show='isDisabled')
  v-card-title
    v-layout(justify-space-between style="align-items: center")
      .group-form__group-title
        h1.headline(v-if='group.isNew() && group.parentId', v-t="'group_form.start_subgroup_heading'")
        h1.headline(v-if='group.isNew() && !group.parentId', v-t="'group_form.start_group_heading'")
        h1.headline(v-if='!group.isNew()', v-t="'group_form.edit_group_heading'")
      dismiss-modal-button(:close='close')
  v-card-text
    v-text-field#group-name(v-model='group.name', :placeholder="$t('group_form.group_name_placeholder')", :rules='[rules.required]', maxlength='255', :label="$t('group_form.group_name')")
    lmo-textarea.group-form__group-description(:model='group' field="description" :placeholder="$t('group_form.description_placeholder')")
    validation-errors(:subject="group", field="name")
    .group-form__privacy-statement.lmo-hint-text {{privacyStatement}}
    section.group-form__section.group-form__privacy
      h3.lmo-h3(v-t="'group_form.privacy'")
      v-radio-group(v-model='group.groupPrivacy')
        v-radio(v-for='privacy in privacyOptions' :key="privacy" :class="'md-checkbox--with-summary group-form__privacy-' + privacy" :value='privacy' :aria-label='privacy')
          template(slot='label')
            .group-form__privacy-title
              strong(v-t="'common.privacy.' + privacy")
            .group-form__privacy-subtitle {{ privacyStringFor(privacy) }}
    .group-form__advanced(v-if='isExpanded')
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
  v-card-actions
    v-btn.group-form__advanced-link(flat color="accent", v-if='!isExpanded', @click='expandForm()', v-t="'group_form.advanced_settings'")
    v-btn.group-form__submit-button(flat color="primary", @click='submit()')
      span(v-if='group.isNew() && group.isParent()', v-t="'group_form.submit_start_group'")
      span(v-if='group.isNew() && !group.isParent()', v-t="'group_form.submit_start_subgroup'")
      span(v-if='!group.isNew()', v-t="'common.action.update_settings'")
</template>
