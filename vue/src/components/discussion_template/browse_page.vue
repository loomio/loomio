<script lang="js">
import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import EventBus      from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import DiscussionTemplateService from '@/shared/services/discussion_template_service';
import utils         from '@/shared/record_store/utils';
import { compact }   from 'lodash-es';
import VuetifyColors  from 'vuetify/lib/util/colors';
import { mdiMagnify, mdiSourceBranchPlus } from '@mdi/js';

const colors = Object.keys(VuetifyColors).filter(name => name !== 'shades').map(name => VuetifyColors[name]['base']);

export default {
  data() {
    return {
      mdiMagnify,
      mdiSourceBranchPlus,
      group: null,
      results: [],
      query: this.$route.query.query,
      loading: false,
      tags: []
    };
  },

  mounted() {
    this.fetch();
    Records.remote.get('discussion_templates/browse_tags').then(data => {
      this.tags = data;
    });
    const groupId = parseInt(this.$route.query.group_id);
    if (groupId) {
      Records.groups.findOrFetchById(groupId).then(group => {
        this.group = group;
      });
    }
  },

  computed: {
    breadcrumbs() {
      if (!this.group) return [];
      return compact([this.group.parentId && this.group.parent(), this.group]).map(g => {
        return {
          title: g.name,
          disabled: false,
          to: LmoUrlService.route({model: g})
        };
      });
    },
    sortedResults() {
      const first = ['blank', 'practice_thread'];
      const top = first.map(k => this.results.find(r => r.key === k)).filter(Boolean);
      const rest = this.results.filter(r => !first.includes(r.key));
      return [...top, ...rest];
    },
    groupIdParam() {
      return this.$route.query.group_id ? '&group_id='+this.$route.query.group_id : '';
    },
    returnToParam() {
      const base = this.$route.path;
      const groupId = this.$route.query.group_id;
      const returnTo = groupId ? `${base}?group_id=${groupId}` : base;
      return '&return_to=' + encodeURIComponent(returnTo);
    }
  },

  methods: {
    changed() { return this.fetch(); },
    fetch() {
      this.loading = true;
      this.results = [];
      Records.remote.get('discussion_templates/browse', {query: this.query, group_id: this.$route.query.group_id}).then(data => {
        this.results = data.map(utils.parseJSON);
        this.loading = false;
      });
    },

    tagColor(tag){
      return colors[this.tags.indexOf(tag) % colors.length];
    }
  }
};

</script>
<template lang="pug">
.discussion-templates-browse-page
  v-main
    v-container.max-width-800
      v-breadcrumbs(v-if="breadcrumbs.length" color="anchor" :items="breadcrumbs")
        template(v-slot:divider)
          common-icon(name="mdi-chevron-right")
      v-card(:title="$t('discussion_template.example_discussion_templates')")
        template(v-slot:append)
          v-btn(v-if="$route.query.return_to" icon variant="text" :to="$route.query.return_to" :aria-label="$t('common.action.back')")
            common-icon(name="mdi-close")
        v-alert.ma-4(type="info" variant="tonal" :icon="mdiSourceBranchPlus")
          div(v-html="$t('discussion_template.browse_example_fork_hint')")

        v-list(lines="two")
          v-list-item(
            v-for="result in sortedResults"
            :key="result.id || result.key"
            :to="'/d/new?' + (result.id ? 'template_id='+result.id : 'template_key='+result.key) + groupIdParam+returnToParam"
          )
            template(v-slot:append)
              v-btn(
                variant="tonal"
                color="primary"
                icon
                :to="'/discussion_templates/new?' + (result.id ? 'template_id='+result.id : 'template_key='+result.key) + groupIdParam+returnToParam"
                :title="$t('common.action.fork_template')"
              )
                common-icon(name="mdi-source-branch-plus")

            v-list-item-title {{result.processName || result.title}}
            v-list-item-subtitle {{result.groupName || result.processSubtitle}}


</template>
