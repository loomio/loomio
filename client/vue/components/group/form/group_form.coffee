AppConfig      = require 'shared/services/app_config'
AbilityService = require 'shared/services/ability_service'
I18n           = require 'shared/services/i18n'

{ groupPrivacy, groupPrivacyStatement } = require 'shared/helpers/helptext'

module.exports =
  props:
    group: Object
    modal: Object
  data: ->
    isDisabled: false
  created: ->
    @featureNames = AppConfig.features.group
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
      I18n.t groupPrivacyStatement(@group),
        parent: @group.parentName()

    privacyStringFor: (privacy) ->
      I18n.t groupPrivacy(@group, privacy),
        parent: @group.parentName()

    showGroupFeatures: ->
      AbilityService.isSiteAdmin() and _.some(@featureNames)
  template:
    """
      <div class="group-form">
        <div v-show="isDisabled" class="lmo-disabled-form"></div>
        <div md-input-container class="md-block">
          <label v-t="titleLabel"></label>
          <input
            type="text"
            :placeholder="$t('group_form.group_name_placeholder')"
            required="true"
            v-model="group.name"
            :model-options="{ allowInvalid: true }"
            md-maxlength="255"
            class="lmo-primary-form-input group-form__name"
            id="group-name"
          >
          <validation-errors :subject="group" field="name"></validation-errors>
        </div>
        <!-- <lmo_textarea :model="group" field="description" placeholder="\'group_form.description_placeholder\' | translate" label="\'group_form.description\' | translate"></lmo_textarea> -->
        <div class="group-form__privacy-statement lmo-hint-text">{{privacyStatement}}</div>
        <section class="group-form__section group-form__privacy">
          <h3 v-t="'group_form.privacy'" class="lmo-h3"></h3>
          <!-- <md-radio-group v-model="group.groupPrivacy">
            <md-radio-button v-for="privacy in privacyOptions" class="md-checkbox--with-summary group-form__privacy-{{privacy}}" ng-value="privacy" aria-label="{{privacy}}">
              <div class="group-form__privacy-title"><strong translate="common.privacy.{{privacy}}"></strong></div>
              <div class="group-form__privacy-subtitle">{{ privacyStringFor(privacy) }}</div>
            </md-radio-button>
          </md-radio-group> -->
        </section>
        <div v-show="group.expanded" class="group-form__advanced">
          <section v-if="group.privacyIsOpen()" class="group-form__section group-form__joining lmo-form-group">
            <h3 v-t="'group_form.how_do_people_join'" class="lmo-h3"></h3>
            <!-- <md-radio-group ng-model="group.membershipGrantedUpon">
              <md-radio-button ng-repeat="granted in [\'request\', \'approval\']" class="group-form__membership-granted-upon-{{granted}}" ng-value="granted"><span translate="group_form.membership_granted_upon_{{granted}}"></span></md-radio-button>
            </md-radio-group> -->
          </section>
          <section class="group-form__section group-form__permissions">
            <h3 translate="group_form.permissions" class="lmo-h3"></h3>
            <group-setting-checkbox :group="group" setting="allowPublicThreads" v-if="group.privacyIsClosed() && !group.isSubgroupOfSecretParent()" class="group-form__allow-public-threads"></group-setting-checkbox>
            <group-setting-checkbox :group="group" setting="parentMembersCanSeeDiscussions" :translate-values="{parent: group.parent().name}" v-if="group.isSubgroup() && group.privacyIsClosed()" class="group-form__parent-members-can-see-discussions"></group-setting-checkbox>
            <group-setting-checkbox :group="group" setting="membersCanAddMembers" class="group-form__members-can-add-members"></group-setting-checkbox>
            <group-setting-checkbox :group="group" setting="membersCanAnnounce" class="group-form__members-can-announce"></group-setting-checkbox>
            <group-setting-checkbox :group="group" setting="membersCanCreateSubgroups" v-if="group.isParent()" class="group-form__members-can-create-subgroups"></group-setting-checkbox>
            <group-setting-checkbox :group="group" setting="membersCanStartDiscussions" class="group-form__members-can-start-discussions"></group-setting-checkbox>
            <group-setting-checkbox :group="group" setting="membersCanEditDiscussions" class="group-form__members-can-edit-discussions"></group-setting-checkbox>
            <group-setting-checkbox :group="group" setting="membersCanEditComments" class="group-form__members-can-edit-comments"></group-setting-checkbox>
            <group-setting-checkbox :group="group" setting="membersCanRaiseMotions" class="group-form__members-can-raise-motions"></group-setting-checkbox>
            <group-setting-checkbox :group="group" setting="membersCanVote" class="group-form__members-can-vote"></group-setting-checkbox>
          </section>
          <section v-if="showGroupFeatures" class="group-form__section group-form__features">
            <h3 v-t="'group_form.features'" class="lmo-h3"></h3>
            <div v-for="name in featureNames" :key="name" class="group-form__feature">
              <!-- <md-checkbox id="{{name}}" ng-model="group.features[name]" class="md-checkbox--with-summary"><span for="{{name}}" translate="group_features.{{name}}"></span></md-checkbox> -->
            </div>
          </section>
        </div>
        <group-form-actions :group="group" v-if="!modal"></group-form-actions>
      </div>
    """
