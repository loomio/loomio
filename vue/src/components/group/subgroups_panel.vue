<script lang="js">
import Records        from '@/shared/services/records';
import Session        from '@/shared/services/session';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import AppConfig from '@/shared/services/app_config';
import { debounce, some } from 'lodash-es';
import { mdiMagnify } from '@mdi/js';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';

export default
{
  mixins: [WatchRecords, UrlFor],
  data() {
    return {
      mdiMagnify,
      group: null,
      loading: true,
      subgroups: [],
      upgradeUrl: AppConfig.baseUrl + 'upgrade'
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
    },
    upgradeRequired() {
      return !this.group.subscription.allow_subgroups;
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
  .d-flex.align-center.py-4.flex-wrap
    v-text-field.mr-2(clearable hide-details variant="solo" density="compact" :value="$route.query.q" @input="onQueryInput" :placeholder="$t('navbar.search_subgroups_short', {name: group.name})" :prepend-inner-icon="mdiMagnify")
    v-btn.subgroups-card__start(
      color="primary"
      variant="elevated"
      @click='startSubgroup()'
      v-if='canCreateSubgroups'
    )
      span(v-t="'common.action.add_subgroup'")

  v-alert(v-if="subgroups.length == 0" variant="tonal" color="info")
    v-card-title(v-t="'subgroups_panel.need_a_space_for_your_team'")
    v-card-text
      p(v-t="'subgroups_panel.explainer'")
      p(v-if="upgradeRequired" v-html="$t('subgroups_panel.upgrade', {url: upgradeUrl})")

  v-card.group-subgroups-panel(outlined v-if="subgroups.length")
    v-list(avatar lines="two")
      v-list-item.subgroups-card__list-item(v-for='group in subgroups', :key='group.id' :to='urlFor(group)')
        //- v-list-item-avatar.subgroups-card__list-item-logo
        template(v-slot:prepend)
          group-avatar(:group="group" :size="28")
        v-list-item-title {{ group.name }}
        v-list-item-subtitle {{ stripDescription(group.description) }}
</template>
