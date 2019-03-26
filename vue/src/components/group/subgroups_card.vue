<script lang="coffee">
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
urlFor         = require 'src/mixins/url_for'
truncate       = require 'src/mixins/truncate'

module.exports =
  mixins: [urlFor, truncate]
  props:
    group: Object
  created: ->
    Records.groups.fetchByParent(@group).then =>
      EventBus.$emit 'subgroupsLoaded', @group
  methods:
    orderedSubgroups: ->
      _.sortBy @group.subgroups(), 'name'

    show: ->
      @group.isParent()

    canCreateSubgroups: ->
      AbilityService.canCreateSubgroups(@group)

    startSubgroup: ->
       ModalService.open 'GroupModal', group: => Records.groups.build(parentId: @group.id)
</script>

<template lang="pug">
v-card.subgroups-card(aria-labelledby='subgroups-card__title', v-if='show()')
  v-subheader(v-t="'group_page.subgroups'")
  v-card-text
    p.lmo-hint-text(v-t="'group_page.subgroups_placeholder'", v-if='group.subgroups().length == 0')
    ul.subgroups-card__list
      li.subgroups-card__list-item(v-for='subgroup in orderedSubgroups()', :key='subgroup.id')
        .subgroups-card__list-item-logo
          // <group_avatar group="subgroup" size="medium"></group_avatar>
        .subgroups-card__list-item-name
          router-link(:to='urlFor(subgroup)') {{ subgroup.name }}
        .subgroups-card__list-item-description {{ truncate(subgroup.description) }}
    .lmo-flex.lmo-flex__space-between
  v-card-actions
    // <outlet name="subgroup-card-footer"></outlet>
    v-btn.subgroups-card__start(flat='', @click='startSubgroup()', v-if='canCreateSubgroups()')
      span(v-t="'common.action.add_subgroup'")

</template>
<style lang="scss">
@import 'app.scss';

.subgroups-card{
}

.subgroups-card__list{
  list-style: none;
  padding: 0;
  margin: 0;
}

.subgroups-card__list-item{
  clear: both;
  min-height: 50px;
  margin-bottom: 12px;
}

.subgroups-card__list-item-logo{
  width: 50px;
  height: 50px;
  float: left;
}

.subgroups-card__list-item-name{
  @include md-body-2;
  margin-left: 60px;
}

.subgroups-card__list-item-description{
  margin-left: 60px;
}

.subgroups-card__add-subgroup-link {
  @include cardMinorAction;
  @include lmoBtnLink;
}

</style>
