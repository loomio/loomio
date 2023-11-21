<script lang="js">
import Records       from '@/shared/services/records';
import Session       from '@/shared/services/session';
import LmoUrlService from '@/shared/services/lmo_url_service';
import EventBus      from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import DiscussionTemplateService from '@/shared/services/discussion_template_service';
import utils         from '@/shared/record_store/utils';
import VuetifyColors  from 'vuetify/lib/util/colors';

const colors = Object.keys(VuetifyColors).filter(name => name !== 'shades').map(name => VuetifyColors[name]['base']);

export default {
  data() {
    return {
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
  },

  methods: {
    changed() { return this.fetch(); },
    fetch() {
      this.loading = true;
      this.results = [];
      Records.remote.get('discussion_templates/browse', {query: this.query}).then(data => {
        this.results = data.results.map(utils.parseJSON);
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
.thread-templates-page
  v-main
    v-container.max-width-800.px-0.px-sm-3
      v-card
        v-card-title.d-flex.pr-3
          h1.headline(tabindex="-1" v-t="'templates.template_gallery'")
          v-spacer
          v-btn.back-button(v-if="$route.query.return_to" icon :aria-label="$t('common.action.cancel')" :to='$route.query.return_to')
            common-icon(name="mdi-close")


        v-alert.mx-4(type="info" text outlined v-t="'thread_template.these_are_public_templates'") 
        .d-flex.px-4.align-center
          v-combobox(
            :loading="loading"
            autofocus
            filled
            rounded
            single-line
            hide-selected
            clearable
            @change="changed"
            append-icon="mdi-magnify"
            @click:append="fetch"
            v-model="query"
            :placeholder="$t('common.action.search')"
            @keydown.enter.prevent="fetch"
            hide-details
            :items="tags"
            )

        v-list.append-sort-here(three-line)
          v-list-item(
            v-for="result in results" 
            :key="result.id"
            :to="'/d/new?' + (result.id ? 'template_id='+result.id : 'template_key='+result.key)+ '&group_id='+ $route.query.group_id"
            title="Use this template to start a new thread"
          )
            v-list-item-avatar
              v-avatar(:size="38" tile)
                img(:alt="result.groupName || result.authorName" :src="result.avatarUrl")

            v-list-item-content
              v-list-item-title.d-flex
                span {{result.processName || result.title}}
                v-spacer
                v-chip.ml-1(
                  v-for="tag in result.tags"
                  :key="tag"
                  outlined
                  xSmall
                  :color="tagColor(tag)"
                ) {{tag}}

              v-list-item-subtitle.text--primary {{result.processSubtitle}}
              v-list-item-subtitle 
                span
                  span {{result.authorName}}
                  mid-dot
                  span {{result.groupName}}

            v-list-item-action
              v-btn.text--secondary(
                icon
                :to="'/thread_templates/new?template_id='+result.id+'&group_id='+$route.query.group_id"
                title="Make a copy of this template and edit it"
              )
                common-icon(name="mdi-pencil")

</template>
