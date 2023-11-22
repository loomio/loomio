<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import AbilityService from '@/shared/services/ability_service';
import Records  from '@/shared/services/records';
import EventBus  from '@/shared/services/event_bus';
import Session  from '@/shared/services/session';
import { groupPrivacy, groupPrivacyStatement } from '@/shared/helpers/helptext';
import { groupPrivacyConfirm } from '@/shared/helpers/helptext';
import Flash   from '@/shared/services/flash';
import { isEmpty, debounce } from 'lodash-es';
import openModal from '@/shared/helpers/open_modal';
import I18n from '@/i18n';

export default
{
  props: {
    group: Object
  },

  data() {
    return {
      rules: {
        required(value) { return !!value || 'Required.'; }
      },
      uploading: false,
      progress: 0,
      hostname: AppConfig.theme.canonical_host,
      parentGroups: [],
      loadingHandle: false
    };
  },

  created() {
    this.watchRecords({
      collections: ['groups', 'memberships'],
      query: records => {
        this.parentGroups = [{value: null, text: this.$t('common.none')}];
        this.parentGroups = this.parentGroups.concat(Session.user().parentGroups().
          filter(g => AbilityService.canCreateSubgroups(g)).
          map(g => ({
          value: g.id,
          text: g.name
        }))
        );
      }
    });

    this.suggestHandle = debounce(function() {
      // if group is new, suggest handle whenever name changes
      // if group is old, suggest handle only if handle is empty
      if (this.group.isNew() || isEmpty(this.group.handle)) {
        this.loadingHandle = true;
        const parentHandle = this.group.parentId ? this.group.parent().handle : null;
        Records.groups.getHandle({name: this.group.name, parentHandle}).then(data => {
          this.group.handle = data.handle;
          this.loadingHandle = false;
        });
      }
    } , 250);
  },

  mounted() {
    return this.suggestHandle();
  },

  watch: {
    'group.parentId'() {
      this.group.handle = '';
      this.group.name = '';
    }
  },

  methods: {
    submit() {
      const allowPublic = this.group.allowPublicThreads;
      this.group.discussionPrivacyOptions = (() => { switch (this.group.groupPrivacy) {
        case 'open':   return 'public_only';
        case 'closed': if (allowPublic) { return 'public_or_private'; } else { return 'private_only'; }
        case 'secret': return 'private_only';
      } })();

      this.group.parentMembersCanSeeDiscussions = (() => { switch (this.group.groupPrivacy) {
        case 'open':   return true;
        case 'closed': return this.group.parentMembersCanSeeDiscussions;
        case 'secret': return false;
      } })();

      this.group.save().then(data => {
        const groupKey = data.groups[0].key;
        Flash.success(`group_form.messages.group_${this.actionName}`);
        Records.groups.findOrFetchById(groupKey, {}, true).then(group => {
          EventBus.$emit('closeModal');
          this.$router.push(`/g/${groupKey}`);
          EventBus.$emit('openModal', {
            component: 'GroupInvitationForm',
            props: { 
              group
            }
          });
        });
      }).catch(error => true);
    },

    privacyStringFor(privacy) {
      return this.$t(groupPrivacy(this.group, privacy),
        {parent: this.group.parentName()});
    }
  },

  computed: {
    categoryItems() {
      // ['board', 'community', 'coop', 'membership', 'nonprofit', 'party', 'professional', 'self_managing', 'union', 'other'].map (category) ->
      return ['board', 'membership', 'self_managing', 'other'].map(category => ({
        text: I18n.t('group_survey.categories.'+category),
        value: category
      }));
    }, 
    actionName() {
      if (this.group.isNew()) { return 'created'; } else { return 'updated'; }
    },

    titleLabel() {
      if (this.group.isParent()) {
        return "group_form.group_name";
      } else {
        return "group_form.subgroup_name";
      }
    },

    privacyOptions() {
      if (this.group.parentId && (this.group.parent().groupPrivacy === 'secret')) {
        return ['closed', 'secret'];
      } else {
        return ['open', 'closed', 'secret'];
      }
    },

    privacyStatement() {
      return this.$t(groupPrivacyStatement(this.group),
        {parent: this.group.parentName()});
    },

    groupNamePlaceholder() {
      if (this.group.parentId) {
        return 'group_form.subgroup_name_placeholder';
      } else {
        return 'group_form.organization_name_placeholder';
      }
    },

    groupNameLabel() {
      if (this.group.parentId) {
        return 'group_form.subgroup_name';
      } else {
        return 'group_form.group_name';
      }
    }
  }
};
</script>

<template>

<v-card class="group-form">
  <v-overlay :value="uploading">
    <v-progress-circular size="64" :value="progress"></v-progress-circular>
  </v-overlay>
  <v-card-title>
    <v-layout justify-space-between="justify-space-between" style="align-items: center">
      <div class="group-form__group-title">
        <h1 class="headline" tabindex="-1" v-if="group.parentId" v-t="'group_form.new_subgroup'"></h1>
        <h1 class="headline" tabindex="-1" v-if="!group.parentId" v-t="'group_form.new_group'"></h1>
      </div>
      <dismiss-modal-button v-if="group.parentId" :model="group"></dismiss-modal-button>
    </v-layout>
  </v-card-title>
  <div class="px-4">
    <p class="text--secondary" v-if="!group.parentId" v-t="'group_form.new_group_explainer'"></p>
    <p class="text--secondary" v-if="group.parentId" v-t="'group_form.new_subgroup_explainer'"></p>
    <v-select class="group-form__parent-group" v-if="parentGroups.length > 1" v-model="group.parentId" :items="parentGroups" :label="$t('group_form.parent_group')"></v-select>
    <v-text-field class="group-form__name" id="group-name" v-model="group.name" :placeholder="$t(groupNamePlaceholder)" :rules="[rules.required]" maxlength="255" :label="$t(groupNameLabel)" @keyup="suggestHandle()"></v-text-field>
    <validation-errors :subject="group" field="name"></validation-errors>
    <div v-if="!group.parentId || (group.parentId && group.parent().handle)">
      <v-text-field class="group-form__handle" id="group-handle" :loading="loadingHandle" v-model="group.handle" :hint="$t('group_form.group_handle_placeholder', {host: hostname, handle: group.handle})" maxlength="100" :label="$t('group_form.handle')"></v-text-field>
      <validation-errors :subject="group" field="handle"></validation-errors>
    </div>
    <v-select v-if="!group.parentId" v-model="group.category" :items="categoryItems" :label="$t('group_survey.describe_other')"></v-select>
    <lmo-textarea class="group-form__group-description" :model="group" field="description" :placeholder="$t('group_form.new_description_placeholder')" :label="$t('group_form.description')"></lmo-textarea>
    <div v-if="group.parentId">
      <div class="group-form__section group-form__privacy">
        <v-radio-group v-model="group.groupPrivacy" :label="$t('common.privacy.privacy')">
          <v-radio v-for="privacy in privacyOptions" :key="privacy" :class="'md-checkbox--with-summary group-form__privacy-' + privacy" :value="privacy" :aria-label="privacy">
            <template slot="label">
              <div class="group-form__privacy-title"><strong v-t="'common.privacy.' + privacy"></strong>
                <mid-dot></mid-dot><span>{{ privacyStringFor(privacy) }}</span>
              </div>
            </template>
          </v-radio>
        </v-radio-group>
      </div>
      <p class="group-form__privacy-statement text-caption text--secondary">{{privacyStatement}}</p>
      <div class="group-form__section group-form__joining lmo-form-group" v-if="group.privacyIsOpen()">
        <v-subheader v-t="'group_form.how_do_people_join'"></v-subheader>
        <v-radio-group v-model="group.membershipGrantedUpon">
          <v-radio v-for="granted in ['request', 'approval']" :key="granted" :class="'group-form__membership-granted-upon-' + granted" :value="granted">
            <template slot="label"><span v-t="'group_form.membership_granted_upon_' + granted"></span></template>
          </v-radio>
        </v-radio-group>
      </div>
    </div>
    <div class="pt-2" v-if="!group.parentId"><span class="text--secondary"><span v-t="'common.privacy.privacy'"></span><span>:</span>
        <space></space><span v-t="'common.privacy.secret'"></span></span>
      <p class="text-caption text--secondary"><span v-t="'group_form.secret_by_default'"></span></p>
    </div>
  </div>
  <v-card-actions class="ma-2">
    <help-link path="en/user_manual/groups/starting_a_group"></help-link>
    <v-spacer></v-spacer>
    <v-btn class="group-form__submit-button" :loading="group.processing" color="primary" @click="submit()"><span v-if="group.isParent()" v-t="'group_form.submit_start_group'"></span><span v-if="!group.isParent()" v-t="'group_form.submit_start_subgroup'"></span></v-btn>
  </v-card-actions>
</v-card>
</template>
