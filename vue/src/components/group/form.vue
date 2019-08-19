<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import AbilityService from '@/shared/services/ability_service'
import Records  from '@/shared/services/records'
import { groupPrivacy, groupPrivacyStatement } from '@/shared/helpers/helptext'
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
    uploading: false
    progress: 0
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

    privacyStringFor: (privacy) ->
      @$t groupPrivacy(@group, privacy),
        parent: @group.parentName()

    selectCoverPhoto: ->
      @$refs.coverPhotoInput.click()

    selectLogo: ->
      @$refs.logoInput.click()

    uploadCoverPhoto: ->
      @uploading = true
      Records.groups.remote.onUploadSuccess = (response) =>
        Records.import response
        @uploading = false
      Records.groups.remote.upload("#{@group.id}/upload_photo/cover_photo", @$refs.coverPhotoInput.files[0], {}, (args) => @progress = args.loaded / args.total * 100)

    uploadLogo: ->
      @uploading = true
      Records.groups.remote.onUploadSuccess = (response) =>
        Records.import response
        @uploading = false
      Records.groups.remote.upload("#{@group.id}/upload_photo/logo", @$refs.logoInput.files[0], {}, (args) => @progress = args.loaded / args.total * 100)

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
  v-overlay(:value="uploading")
    v-progress-circular(size="64" :value="progress")
  submit-overlay(:value='group.processing')
  v-card-title
    v-layout(justify-space-between style="align-items: center")
      .group-form__group-title
        h1.headline(v-if='group.isNew() && group.parentId', v-t="'group_form.start_subgroup_heading'")
        h1.headline(v-if='group.isNew() && !group.parentId', v-t="'group_form.start_group_heading'")
        h1.headline(v-if='!group.isNew()', v-t="'group_form.edit_group_heading'")
      dismiss-modal-button(:close='close')
  v-card-text

    v-tabs(fixed-tabs)
      v-tab(v-t="'group_form.profile'")
      v-tab(v-t="'group_form.privacy'")
      v-tab(v-t="'group_form.permissions'")

      v-tab-item
        v-text-field.group-form__name#group-name(v-model='group.name', :placeholder="$t('group_form.group_name_placeholder')", :rules='[rules.required]', maxlength='255', :label="$t('group_form.group_name')")
        lmo-textarea.group-form__group-description(:model='group' field="description" :placeholder="$t('group_form.description_placeholder')" :label="$t('group_form.description')")
        validation-errors(:subject="group", field="name")
        v-btn.change-picture-form__option(@click='selectCoverPhoto()' v-t="'group_form.upload_cover_photo'")
        input.hidden.change-picture-form__file-input(type="file" ref="coverPhotoInput" @change='uploadCoverPhoto')
        v-btn.change-picture-form__option(@click='selectLogo()' v-t="'group_form.upload_logo'")
        input.hidden.change-picture-form__file-input(type="file" ref="logoInput" @change='uploadLogo')

      v-tab-item
        .group-form__section.group-form__privacy
          v-radio-group(v-model='group.groupPrivacy')
            v-radio(v-for='privacy in privacyOptions' :key="privacy" :class="'md-checkbox--with-summary group-form__privacy-' + privacy" :value='privacy' :aria-label='privacy')
              template(slot='label')
                .group-form__privacy-title
                  strong(v-t="'common.privacy.' + privacy")
                  mid-dot
                  span {{ privacyStringFor(privacy) }}
        p.group-form__privacy-statement.body-2 {{privacyStatement}}
        .group-form__section.group-form__joining.lmo-form-group(v-if='group.privacyIsOpen()')
          v-subheader(v-t="'group_form.how_do_people_join'")
          v-radio-group(v-model='group.membershipGrantedUpon')
            v-radio(v-for="granted in ['request', 'approval']" :key="granted" :class="'group-form__membership-granted-upon-' + granted" :value='granted')
              template(slot='label')
                span(v-t="'group_form.membership_granted_upon_' + granted")
      v-tab-item
        .group-form__section.group-form__permissions
          //- v-checkbox.group-form__allow-public-threads(hide-details v-model='group["allowPublicThreads"]' :label="$t('group_form.allow_public_threads')" v-if='group.privacyIsClosed() && !group.isSubgroupOfSecretParent()')
          v-checkbox.group-form__parent-members-can-see-discussions(hide-details v-model='group["parentMembersCanSeeDiscussions"]' :label="$t('group_form.parent_members_can_see_discussions', {parent: group.parent().name})" v-if='group.isSubgroup() && group.privacyIsClosed()')
          v-checkbox.group-form__members-can-add-members(hide-details v-model='group["membersCanAddMembers"]' :label="$t('group_form.members_can_add_members')")
          v-checkbox.group-form__members-can-announce(hide-details v-model='group["membersCanAnnounce"]' :label="$t('group_form.members_can_announce')")
          v-checkbox.group-form__members-can-create-subgroups(hide-details v-model='group["membersCanCreateSubgroups"]' v-if='group.isParent()' :label="$t('group_form.members_can_create_subgroups')")
          v-checkbox.group-form__members-can-start-discussions(hide-details v-model='group["membersCanStartDiscussions"]' :label="$t('group_form.members_can_start_discussions')")
          v-checkbox.group-form__members-can-edit-discussions(hide-details v-model='group["membersCanEditDiscussions"]' :label="$t('group_form.members_can_edit_discussions')")
          v-checkbox.group-form__members-can-edit-comments(hide-details v-model='group["membersCanEditComments"]' :label="$t('group_form.members_can_edit_comments')")
          v-checkbox.group-form__members-can-raise-motions(hide-details v-model='group["membersCanRaiseMotions"]' :label="$t('group_form.members_can_raise_motions')")
          v-checkbox.group-form__members-can-vote(hide-details v-model='group["membersCanVote"]' :label="$t('group_form.members_can_vote')")
        p.group-form__privacy-statement.body-2(v-t="'group_form.permissions_explaination'")


  v-card-actions
    v-spacer
    v-btn.group-form__submit-button(color="primary" @click='submit()')
      span(v-if='group.isNew() && group.isParent()' v-t="'group_form.submit_start_group'")
      span(v-if='group.isNew() && !group.isParent()' v-t="'group_form.submit_start_subgroup'")
      span(v-if='!group.isNew()' v-t="'common.action.update_settings'")
</template>
