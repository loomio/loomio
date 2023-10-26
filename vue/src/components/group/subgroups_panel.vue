<script lang="js">
import Records        from '@/shared/services/records';
import Session        from '@/shared/services/session';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import { debounce, some, every } from 'lodash';

export default
{
  data() {
    return {
      group: null,
      loading: true
    };
  },

  created() {
    this.onQueryInput = debounce(val => {
      return this.$router.replace(this.mergeQuery({q: val}));
    }
    , 500);

    Records.groups.findOrFetch(this.$route.params.key).then(group => {
      this.group = group;

      EventBus.$emit('currentComponent', {
        page: 'groupPage',
        title: this.group.name,
        group: this.group
      }
      );

      Records.groups.fetchByParent(this.group).then(() => {
        this.loading = false;
        return EventBus.$emit('subgroupsLoaded', this.group);
      });

      this.watchRecords({
        collections: ['memberships', 'groups'],
        query: this.findRecords
      });

      this.findRecords();
    });
  },

  computed: {
    canCreateSubgroups() {
      return AbilityService.canCreateSubgroups(this.group);
    }
  },

  methods: {
    findRecords() {
      const memberIds = Records.memberships.find({userId: Session.user().id}).map(m => m.groupId);
      const visibleIds = Records.groups.collection.chain().
                     find({parentId: this.group.id}).
                     find({groupPrivacy: {$in: ['closed', 'open']}}).data().map(g => g.id);

      let chain = Records.groups.collection.chain().
                     find({parentId: this.group.id, id: {$in: memberIds.concat(visibleIds)}}).
                     simplesort('name');

      if (this.$route.query.q) {
        chain = chain.where(group => {
          return some([group.name, group.description], field => {
            return RegExp(this.$route.query.q, "i").test(field);
          });
        });
      }

      this.subgroups = chain.data();
    },

    startSubgroup() {
      EventBus.$emit('openModal', {
        component: 'GroupNewForm',
        props: {
          group: Records.groups.build({parentId: this.group.id})
        }
      });
    },

    stripDescription(description) { return (description || '').replace(new RegExp(`<[^>]*>?`, 'gm'), ''); }
  },

  watch: {
    '$route.query': 'findRecords'
  }
};
</script>
<template lang="pug">
div(v-if="group")
  v-layout.my-2(align-center wrap)
    v-text-field.mr-2(clearable hide-details solo :value="$route.query.q" @input="onQueryInput" :placeholder="$t('subgroups_panel.search_subgroups_of_name', {name: group.name})" append-icon="mdi-magnify")
    v-btn.subgroups-card__start(color="primary" @click='startSubgroup()' v-if='canCreateSubgroups' v-t="'common.action.add_subgroup'")

  v-card.group-subgroups-panel(outlined)
    p.text-center.pa-4(v-if="!loading && !subgroups.length" v-t="'common.no_results_found'")
    v-list(v-else avatar three-line)
      v-list-item.subgroups-card__list-item(v-if="group.subgroups().length > 0" :to="urlFor(group)+'?subgroups=none'")
        v-list-item-avatar.subgroups-card__list-item-logo
          group-avatar(:group="group" :size="28")
        v-list-item-content
          v-list-item-title(v-t="{path: 'subgroups_panel.group_without_subgroups', args: {name: group.name}}")
          v-list-item-subtitle {{ stripDescription(group.description) }}
      v-list-item.subgroups-card__list-item(v-for='group in subgroups', :key='group.id' :to='urlFor(group)')
        v-list-item-avatar.subgroups-card__list-item-logo
          group-avatar(:group="group" :size="28")
        v-list-item-content
          v-list-item-title {{ group.name }}
          v-list-item-subtitle {{ stripDescription(group.description) }}
</template>
