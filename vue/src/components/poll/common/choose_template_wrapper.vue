<script lang="js">
import AppConfig    from '@/shared/services/app_config';
import Session      from '@/shared/services/session';
import Records      from '@/shared/services/records';
import EventBus     from '@/shared/services/event_bus';
import NullGroupModel   from '@/shared/models/null_group_model';
import PollTemplateService     from '@/shared/services/poll_template_service';
import PollCommonChooseTemplate from '@/components/poll/common/choose_template';
import {map, without, compact} from 'lodash';
import I18n from '@/i18n';

export default {
  components: {PollCommonChooseTemplate},

  props: {
    discussion: Object,
    group: Object
  },

  data() {
    return {selectedGroup: this.group};
  },

  created() {
    this.watchRecords({
      collections: ['groups'],
      query: store => this.fillGroups()
    });
  },

  methods: {
    fillGroups() {
      const defaultsGroup = new NullGroupModel();
      defaultsGroup.isNullGroup = false;
      defaultsGroup.name = I18n.t('templates.loomio_default_templates');
      const groups = [defaultsGroup];
      const groupIds = Session.user().groupIds();
      Records.groups.collection.chain().
                   find({id: { $in: groupIds }, archivedAt: null, parentId: null}).
                   data().forEach(function(parent) { 
        if (parent.pollTemplatesCount) { groups.push(parent); }
        Records.groups.collection.chain().
                   find({id: { $in: groupIds }, archivedAt: null, parentId: parent.id}).
                   data().forEach(function(subgroup) {
          if (subgroup.pollTemplatesCount) { groups.push(subgroup); }
        });
      });
      this.groups = groups;
    },
    selectGroup(group) { this.selectedGroup = group; },
    setPoll(poll) { this.$emit('setPoll', poll); }
  }
};
</script>

<template lang="pug">
div
  .poll-templates-select-group(v-if="selectedGroup.isNullGroup")
    p(v-t="'templates.which_templates_would_you_like_to_use'")
    v-list
      v-list-item(v-for="group in groups" :key="group.id" @click="selectGroup(group)")
        v-list-item-avatar(aria-hidden="true")
          group-avatar(:group="group" v-if="!group.parentId")
        v-list-item-content
          v-list-item-title {{group.name}}
  poll-common-choose-template(
    v-else 
    @setPoll="setPoll"
    :discussion="discussion"
    :group="selectedGroup")
</template>
