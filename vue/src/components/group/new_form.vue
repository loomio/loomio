<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import AbilityService from '@/shared/services/ability_service'
import Records  from '@/shared/services/records'
import EventBus  from '@/shared/services/event_bus'
import Session  from '@/shared/services/session'
import { groupPrivacy, groupPrivacyStatement } from '@/shared/helpers/helptext'
import { groupPrivacyConfirm } from '@/shared/helpers/helptext'
import Flash   from '@/shared/services/flash'
import { isEmpty, compact, debounce } from 'lodash'
import { onError } from '@/shared/helpers/form'
import openModal from '@/shared/helpers/open_modal'

export default
  props:
    group: Object

  data: ->
    rules: {
      required: (value) -> !!value || 'Required.'
    }
    uploading: false
    progress: 0
    categories: [ 'board', 'party', 'coop', 'union', 'nonprofit', 'professional', 'government', 'community', 'other' ]
    parentGroups: []
    loadingHandle: false

  created: ->
    @watchRecords
      collections: ['groups', 'memberships']
      query: (records) =>
        @parentGroups = [{value: null, text: @$t('common.none')}]
        @parentGroups = @parentGroups.concat Session.user().parentGroups().
          filter((g) -> AbilityService.canCreateSubgroups(g)).
          map((g) -> {value: g.id, text: g.name})

    @suggestHandle = debounce ->
      # if group is new, suggest handle whenever name changes
      # if group is old, suggest handle only if handle is empty
      if @group.isNew() or isEmpty(@group.handle)
        @loadingHandle = true
        parentHandle = if @group.parentId
          @group.parent().handle
        else
          null
        Records.groups.getHandle(name: @group.name, parentHandle: parentHandle).then (data) =>
          @group.handle = data.handle
          @loadingHandle = false
    , 250

  mounted: ->
    @suggestHandle()

  watch:
    'group.parentId': ->
      @group.handle = ''
      @group.name = ''

  methods:
    submit: ->
      allowPublic = @group.allowPublicThreads
      @group.discussionPrivacyOptions = switch @group.groupPrivacy
        when 'open'   then 'public_only'
        when 'closed' then (if allowPublic then 'public_or_private' else 'private_only')
        when 'secret' then 'private_only'

      @group.parentMembersCanSeeDiscussions = switch @group.groupPrivacy
        when 'open'   then true
        when 'closed' then @group.parentMembersCanSeeDiscussions
        when 'secret' then false

      @group.save()
      .then (data) =>
        groupKey = data.groups[0].key
        Flash.success "group_form.messages.group_#{@actionName}"
        Records.groups.findOrFetchById(groupKey, {}, true).then (group) =>
          if AppConfig.features.app.group_survey
            Records.remote.post 'group_surveys',
              group_id: group.id
              category: (@group.category == 'other' && @group.otherCategory) || @group.category
          EventBus.$emit 'closeModal'
          @$router.push("/g/#{groupKey}")
      .catch onError(@group)


    privacyStringFor: (privacy) ->
      @$t groupPrivacy(@group, privacy),
        parent: @group.parentName()

  computed:
    askCategory: ->
      !@group.parentId && AppConfig.features.app.group_survey

    actionName: ->
      if @group.isNew() then 'created' else 'updated'

    titleLabel: ->
      if @group.isParent()
        "group_form.group_name"
      else
        "group_form.subgroup_name"

    privacyOptions: ->
      if @group.parentId && @group.parent().groupPrivacy == 'secret'
        ['closed', 'secret']
      else
        ['open', 'closed', 'secret']

    privacyStatement: ->
      @$t groupPrivacyStatement(@group),
        parent: @group.parentName()

    groupNamePlaceholder: ->
      if @group.parentId
        'group_form.subgroup_name_placeholder'
      else
        'group_form.organization_name_placeholder'

    groupNameLabel: ->
      if @group.parentId
        'group_form.subgroup_name'
      else
        'group_form.group_name'
</script>

<template lang="pug">
v-card.group-form
  v-overlay(:value="uploading")
    v-progress-circular(size="64" :value="progress")
  //- submit-overlay(:value='group.processing')
  v-card-title
    v-layout(justify-space-between style="align-items: center")
      .group-form__group-title
        h1.headline(tabindex="-1" v-if='group.parentId' v-t="'group_form.new_subgroup'")
        h1.headline(tabindex="-1" v-if='!group.parentId' v-t="'group_form.new_group'")
      dismiss-modal-button(v-if="group.parentId" :model="group")
  .px-4
    p.text--secondary(v-if='!group.parentId' v-t="'group_form.new_group_explainer'")
    p.text--secondary(v-if='group.parentId' v-t="'group_form.new_subgroup_explainer'")
    v-select.group-form__parent-group(v-if="parentGroups.length > 1" v-model='group.parentId' :items="parentGroups" :label="$t('group_form.parent_group')")
    v-text-field.group-form__name#group-name(v-model='group.name' :placeholder="$t(groupNamePlaceholder)" :rules='[rules.required]' maxlength='255' :label="$t(groupNameLabel)" @keyup="suggestHandle()")
    validation-errors(:subject="group", field="name")

    div(v-if="!group.parentId || (group.parentId && group.parent().handle)")
      v-text-field.group-form__handle#group-handle(:loading="loadingHandle" v-model='group.handle' :hint="$t('group_form.group_handle_placeholder', {handle: group.handle})" maxlength='100' :label="$t('group_form.handle')")
      validation-errors(:subject="group", field="handle")

    div(v-if="group.parentId")
      .group-form__section.group-form__privacy
        v-radio-group(v-model='group.groupPrivacy' :label="$t('common.privacy.privacy')")
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

    div.pt-2(v-if="!group.parentId")
      span.text--secondary
        //- v-icon mdi-lock-outline
        span(v-t="'common.privacy.privacy'")
        span :
        space
        span(v-t="'common.privacy.secret'")
      p.text-caption.text--secondary
        span(v-t="'group_form.secret_by_default'")

    div(v-if="askCategory")
      v-radio-group.group-survey__category(v-model='group.category' :label="$t('group_survey.category_question')" :rules="[rules.required]")
        v-radio(v-for='category in categories' :key='category' :value='category' :aria-label='category' :label="$t('group_survey.categories.' + category)" :class="'group-survey__category-' + category")

      v-text-field(v-if="group.category == 'other'" :label="$t('group_survey.describe_other')" v-model="group.otherCategory")

  v-card-actions
    v-spacer
    v-btn.group-form__submit-button(:loading="group.processing" color="primary" @click='submit()')
      span(v-if='group.isParent()' v-t="'group_form.submit_start_group'")
      span(v-if='!group.isParent()' v-t="'group_form.submit_start_subgroup'")
</template>
