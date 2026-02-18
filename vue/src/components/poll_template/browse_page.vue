<script lang="js">
import Records       from '@/shared/services/records';
import LmoUrlService from '@/shared/services/lmo_url_service';
import utils         from '@/shared/record_store/utils';
import { compact }   from 'lodash-es';
import { mdiSourceBranchPlus } from '@mdi/js';

export default {
  data() {
    return {
      mdiSourceBranchPlus,
      group: null,
      results: [],
      loading: false,
      filter: 'proposal'
    };
  },

  mounted() {
    this.fetch();
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
    filteredResults() {
      if (this.filter === 'proposal') {
        return this.results.filter(r => ['proposal', 'question'].includes(r.pollType));
      } else {
        return this.results.filter(r => ['score', 'poll', 'ranked_choice', 'dot_vote', 'meeting', 'count'].includes(r.pollType));
      }
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
    fetch() {
      this.loading = true;
      Records.remote.get('poll_templates/browse', {group_id: this.$route.query.group_id}).then(data => {
        this.results = data.map(utils.parseJSON);
        this.loading = false;
      });
    }
  }
};
</script>
<template lang="pug">
.poll-templates-browse-page
  v-main
    v-container.max-width-800
      v-breadcrumbs(v-if="breadcrumbs.length" color="anchor" :items="breadcrumbs")
        template(v-slot:divider)
          common-icon(name="mdi-chevron-right")
      v-card(:title="$t('poll_common.example_poll_templates')")
        template(v-slot:append)
          v-btn(v-if="$route.query.return_to" icon variant="text" :to="$route.query.return_to" :aria-label="$t('common.action.back')")
            common-icon(name="mdi-close")
        v-alert.ma-4(type="info" variant="tonal" :icon="mdiSourceBranchPlus")
          div(v-html="$t('poll_common.browse_example_fork_hint')")

        .d-flex.px-4
          v-chip.mr-1(
            :color="filter === 'proposal' ? 'primary' : null"
            label
            @click="filter = 'proposal'"
          )
            common-icon.mr-2(size="small" name="mdi-thumbs-up-down" :color="filter === 'proposal' ? 'primary' : null")
            span(v-t="'decision_tools_card.proposal_title'")
          v-chip(
            :color="filter === 'poll' ? 'primary' : null"
            label
            @click="filter = 'poll'"
          )
            common-icon.mr-2(size="small" name="mdi-poll" :color="filter === 'poll' ? 'primary' : null")
            span(v-t="'decision_tools_card.poll_title'")

        v-list(lines="two")
          v-list-item(
            v-for="result in filteredResults"
            :key="result.id || result.key"
            :to="'/p/new?' + (result.id ? 'template_id='+result.id : 'template_key='+result.key) + groupIdParam+returnToParam"
          )
            template(v-slot:append)
              v-btn(
                variant="tonal"
                color="primary"
                icon
                :to="'/poll_templates/new?' + (result.id ? 'template_id='+result.id : 'template_key='+result.key) + groupIdParam+returnToParam"
                :title="$t('common.action.fork_template')"
              )
                common-icon(name="mdi-source-branch-plus")

            v-list-item-title {{result.processName}}
            v-list-item-subtitle {{result.groupName || result.processSubtitle}}
</template>
