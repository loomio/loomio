<script lang="js">
import AppConfig from '@/shared/services/app_config';
import Records   from '@/shared/services/records';
import EventBus  from '@/shared/services/event_bus';
import UrlFor    from '@/mixins/url_for';
import _truncate from 'lodash/truncate';
import _map      from 'lodash/map';
import {marked}    from 'marked';

import { debounce, camelCase, orderBy } from 'lodash';

export default {
  mixins: [UrlFor],
  data() {
    return {
      groupIds: [],
      resultsCount: 0,
      perPage: 50,
      canLoadMoreGroups: true,
      query: "",
      searching: true,
      order: null,
      orderOptions: [
        {name: this.$t('explore_page.newest_first'), val: "created_at"},
        {name: this.$t('explore_page.biggest_first'), val: "memberships_count"}
      ]
    };
  },
  created() {
    if (this.$route.query.order) {
      this.order = this.$route.query.order;
    } else {
      this.$router.replace(this.mergeQuery({ order: "memberships_count" }));
    }
  },
  mounted() {
    EventBus.$emit('currentComponent', { titleKey: 'explore_page.header', page: 'explorePage'});
    this.search();
  },

  methods: {
    groups() {
      return Records.groups.find(this.groupIds);
    },

    handleSearchResults(response) {
      Records.groups.getExploreResultsCount(this.query).then(data => {
        return this.resultsCount = data.count;
      });
      this.groupIds = this.groupIds.concat(_map(response.groups, 'id'));
      this.canLoadMoreGroups = (response.groups || []).length === this.perPage;
      this.searching = false;
    },

    search: debounce(function() {
      this.groupIds = [];
      Records.groups.fetchExploreGroups(this.query, {per: this.perPage, order: this.order}).then(this.handleSearchResults);
    }
    , 250),

    loadMore() {
      this.searching = true;
      Records.groups.fetchExploreGroups(this.query, {from: this.groupIds.length, per: this.perPage, order: this.order}).then(this.handleSearchResults);
    },

    groupCover(group) {
      return { 'background-image': `url(${group.coverUrl})` };
    },

    groupDescription(group) {
      let description = group.description || '';
      if (group.descriptionFormat === 'md') {
        description = marked(description);
      }
      const parser = new DOMParser();
      const doc = parser.parseFromString(description, 'text/html');
      return _truncate(doc.body.textContent, {length: 100});
    },

    handleOrderChange(val) {
      this.$router.replace(this.mergeQuery({ order: val }));
    }
  },
  computed: {
    showMessage() {
      return !this.searching && (this.query.length > 0) && (this.groups().length > 0);
    },

    searchResultsMessage() {
      if (this.groups().length === 1) {
        return 'explore_page.single_search_result';
      } else {
        return 'explore_page.multiple_search_results';
      }
    },

    noResultsFound() {
      return !this.searching && (this.groups().length === 0);
    },

    orderedGroups() {
      return orderBy(this.groups(), [camelCase(this.order)], ['desc']);
    }
  },

  watch: {
    'query'() {
      this.searching = true;
      return this.search();
    },
    '$route.query.order': {
      immediate: true,
      handler() {
        this.order = this.$route.query.order;
        return this.search();
      }
    }
  }
};
</script>

<template lang='pug'>
v-main
  v-container.explore-page.max-width-1024.px-0.px-sm-3
    //- h1.headline(tabindex="-1" v-t="'explore_page.header'")
    v-text-field(v-model="query" :placeholder="$t('explore_page.search_placeholder')" id="search-field" append-icon="mdi-magnify")
    v-select(@change="handleOrderChange" :items="orderOptions" item-value="val" item-text="name" :placeholder="$t('explore_page.order_by')" :value="order")
    loading(:until="!searching")
    .explore-page__no-results-found(v-show='noResultsFound' v-html="$t('explore_page.no_results_found')")
    .explore-page__search-results(v-show='showMessage' v-html="$t(searchResultsMessage, {resultCount: resultsCount, searchTerm: query})")
    v-row.explore-page__groups.my-4(v-show="!searching" wrap)
      v-col(:lg="6" :md="6" :sm="12" v-for='group in orderedGroups' :key='group.id')
        v-card.explore-page__group.my-4(:to='urlFor(group)')
          v-img.explore-page__group-cover(:src="group.coverUrl" max-height="120")
          v-card-title {{ group.name }}
          v-card-text
            .explore-page__group-description {{groupDescription(group)}}
            v-layout.explore-page__group-stats(justify-start align-center)
              v-icon.mr-2 mdi-account-multiple
              span.mr-4 {{group.membershipsCount}}
              v-icon.mr-2 mdi-comment-text-outline
              span.mr-4 {{group.discussionsCount}}
              v-icon.mr-2 mdi-thumbs-up-down
              span.mr-4 {{group.pollsCount}}
      .lmo-show-more(v-show='canLoadMoreGroups')
        v-btn(v-show="!searching" @click="loadMore()" v-t="'common.action.show_more'" class="explore-page__show-more")


</template>
