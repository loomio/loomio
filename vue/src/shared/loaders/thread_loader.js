import Records from '@/shared/services/records';
import { some, last, cloneDeep, max, isNumber, uniq, compact, orderBy, camelCase, forEach, isObject, sortedUniq, sortBy, without, map } from 'lodash';
import Vue from 'vue';
import RangeSet         from '@/shared/services/range_set';
import EventBus         from '@/shared/services/event_bus';
import Session from '@/shared/services/session';

export default class ThreadLoader {
  constructor(discussion) {
    this.discussion = discussion;
    this.reset();
  }

  reset() {
    this.collection = Vue.observable([]);
    this.rules = [];
    this.ruleStrings = [];
    this.fetchedRules = [];
    this.readRanges = cloneDeep(this.discussion.readRanges);
    this.focusAttrs = {};
    this.visibleKeys = {};
    this.collapsed = Vue.observable({});
    this.loading = false;
    this.padding = 50;
    this.maxAutoLoadMore = 500;
  }

  firstUnreadSequenceId() {
    return (RangeSet.subtractRanges(this.discussion.ranges, this.readRanges)[0] || [])[0];
  }

  setVisible(isVisible, event) {
    if (isVisible) { event.markAsRead(); }
    this.visibleKeys[event.positionKey] = isVisible;
    return EventBus.$emit('visibleKeys', Object.keys(this.visibleKeys).filter(key => this.visibleKeys[key]).sort());
  }

  collapse(event) {
    Object.keys(this.visibleKeys).forEach(key => {
      if (key.startsWith(event.positionKey)) { return this.visibleKeys[key] = false; }
    });
    return Vue.set(this.collapsed, event.id, true);
  }

  isUnread(event) {
    if (event.kind === "new_discussion") {
      return this.discussion.updatedAt > this.discussion.lastReadAt;
    } else {
      return !RangeSet.includesValue(this.readRanges, event.sequenceId);
    }
  }

  sequenceIdIsUnread(id) {
    if (id === 0) {
      return this.discussion.updatedAt > this.discussion.lastReadAt;
    } else {
      return !RangeSet.includesValue(this.readRanges, id);
    }
  }

  expand(event) {
    return Vue.set(this.collapsed, event.id, false);
  }

  jumpToEarliest() {
    this.addLoadOldestFirstRule();
    return this.fetch();
  }

  jumpToLatest() {
    this.addLoadNewestFirstRule();
    return this.fetch();
  }

  jumpToUnread() {
    this.addLoadUnreadRule();
    return this.fetch();
  }

  jumpToSequenceId(id) {
    this.addLoadSequenceIdRule(id);
    return this.fetch();
  }

  loadEverything() {
    this.loading = true;
    return this.addRuleAndFetch({
      local: {
        find: {
          discussionId: this.discussion.id
        }
      },
      remote: {
        discussion_id: this.discussion.id,
        per: 1000
      }
    });
  }

  autoLoadAfter(obj) {
    if ((!this.discussion.newestFirst && (obj.event.depth === 1)) || (obj.missingAfterCount && (obj.missingAfterCount < this.maxAutoLoadMore))) {
      return this.loadAfter(obj.event);
    }
  }

  loadChildren(event) {
    this.addLoadChildrenRule(event);
    return this.fetch();
  }

  loadAfter(event) {
    this.addLoadAfterRule(event);
    return this.fetch();
  }

  autoLoadBefore(obj) {
    if ((this.discussion.newestFirst && (obj.event.depth === 1)) || (obj.missingEarlierCount && (obj.missingEarlierCount < this.maxAutoLoadMore))) {
      return this.loadBefore(obj.event);
    }
  }

  loadBefore(event) {
    this.loading = 'before'+event.id;
    this.addLoadBeforeRule(event);
    return this.fetch();
  }

  addLoadAfterRule(event) {
    return this.addRule({
      name: `load after ${event.positionKey}`,
      local: {
        find: {
          discussionId: this.discussion.id,
          positionKey: {
            $jgt: event.positionKey
          }
        },
        sortByPositionKey: true,
        limit: this.padding
      },
      remote: {
        discussion_id: this.discussion.id,
        position_key_gt: event.positionKey,
        order_by: 'position_key',
        per: this.padding
      }
    });
  }

  addLoadBeforeRule(event) {
    return this.addRule({
      name: `load before ${event.positionKey}`,
      local: {
        find: {
          discussionId: this.discussion.id,
          positionKey: {
            $jlt: event.positionKey
          }
        },
        sortByPositionKeyDesc: true,
        limit: this.padding
      },
      remote: {
        discussion_id: this.discussion.id,
        position_key_lt: event.positionKey,
        order_by: 'position_key',
        order_desc: 1,
        per: this.padding
      }
    });
  }

  addLoadChildrenRule(event) {
    return this.addRule({
      name: `load children ${event.positionKey}`,
      local: {
        find: {
          discussionId: this.discussion.id,
          parentId: event.id
        },
        sortByPositionKeyDesc: true,
        limit: this.padding
      },
      remote: {
        discussion_id: this.discussion.id,
        parent_id: event.id,
        order_by: 'position_key',
        order_desc: 1,
        per: this.padding
      }
    });
  }

  addLoadCommentRule(commentId) {
    return this.addRule({
      name: "comment from url",
      local: {
        find: {
          discussionId: this.discussion.id,
          eventableId: commentId,
          eventableType: 'Comment'
        }
      },
      remote: {
        order: 'sequence_id',
        discussion_id: this.discussion.id,
        comment_id: commentId
      }
    });
  }

  addLoadPositionRule(position) {
    return this.addRule({
      name: "position from url",
      local: {
        find: {
          discussionId: this.discussion.id,
          depth: 1,
          position: {$gte: position}
        },
        sortByPositionKey: true,
        limit: this.padding
      },
      remote: {
        discussion_id: this.discussion.id,
        from_sequence_id_of_position: position,
        order: 'position_key'
      }
    });
  }

  addLoadPositionKeyRule(positionKey) {
    this.loading = positionKey;
    this.addRule({
      name: "positionKey from url",
      local: {
        find: {
          discussionId: this.discussion.id,
          positionKey: {$jgte: positionKey}
        },
        sortByPositionKey: true,
        limit: parseInt(this.padding/2)
      },
      remote: {
        discussion_id: this.discussion.id,
        position_key_gte: positionKey,
        order_by: 'position_key',
        per: parseInt(this.padding/2)
      }
    });

    return this.addRule({
      name: "positionKey rollback",
      local: {
        find: {
          discussionId: this.discussion.id,
          positionKey: {$jlt: positionKey}
        },
        sortByPositionKeyDesc: true,
        limit: parseInt(this.padding/2)
      },
      remote: {
        discussion_id: this.discussion.id,
        position_key_lt: positionKey,
        order_by: 'position_key',
        order_desc: 1,
        per: parseInt(this.padding/2)
      }
    });
  }

  addLoadSequenceIdRule(sequenceId) {
    const id = max([parseInt(sequenceId) - parseInt(this.padding/2), 0]);
    this.loading = id;
    return this.addRule({
      name: "sequenceId from url",
      local: {
        find: {
          discussionId: this.discussion.id,
          sequenceId: {'$gte': id}
        },
        simplesort: 'sequenceId',
        limit: this.padding
      },
      remote: {
        sequence_id_gte: id,
        discussion_id: this.discussion.id,
        order: 'sequence_id',
        per: this.padding
      }
    });
  }

  addLoadNewestRule() {
    return this.addRule({
      local: {
        find: {
          discussionId: this.discussion.id
        },
        simplesort: 'sequenceId',
        simplesortDesc: true,
        limit: this.padding
      },
      remote: {
        discussion_id: this.discussion.id,
        order_by: 'sequence_id',
        order_desc: true,
        per: this.padding
      }
    });
  }

  addContextRule() {
    return this.addRule({
      name: 'context',
      local: {
        find: {
          id: this.discussion.createdEvent().id
        }
      }
    });
  }

  addLoadOldestRule() {
    return this.addRule({
      name: 'oldest',
      local: {
        find: {
          discussionId: this.discussion.id
        },
        simplesort: 'sequenceId',
        limit: this.padding
      },
      remote: {
        discussion_id: this.discussion.id,
        order_by: 'sequence_id',
        per: this.padding
      }
    });
  }

  addLoadUnreadRule() {
    if (this.discussion.updatedAt > this.discussion.lastReadAt) {
      this.addRule({
        name: "context updated",
        local: {
          find: {
            id: this.discussion.createdEvent().id
          }
        }
      });
    }

    const id = max([this.firstUnreadSequenceId() - parseInt(this.padding/2), this.discussion.firstSequenceId()]);
    return this.addRule({
      name: {path: "strand_nav.new_to_you"},
      local: {
        find: {
          discussionId: this.discussion.id,
          sequenceId: {$gte: id}
        },
        limit: this.padding,
        order: 'sequenceId'
      },
      remote: {
        discussion_id: this.discussion.id,
        sequence_id_gte: id,
        order_by: "sequence_id",
        per: this.padding
      }
    });
  }

  addRule(rule) {
    const ruleString = JSON.stringify(rule);
    if (!this.ruleStrings.includes(ruleString)) {
      this.rules.push(rule);
      this.ruleStrings.push(ruleString);
      // if @rules.length > 5
      //   @rules.shift()
      //   @ruleStrings.shift()
      return true;
    } else {
      return false;
    }
  }

  addRuleAndFetch(rule) {
    if (this.addRule(rule)) { return this.fetch(); }
  }

  fetch() {
    const newRules = [];
    const promises = this.rules.filter(rule => rule.remote)
                     .filter(rule => !this.fetchedRules.includes(JSON.stringify(rule.remote)))
                     .map(rule => {
      newRules.push(JSON.stringify(rule.remote));
      const params = Object.assign({}, rule.remote, {exclude_types: 'group discussion'});
      return Records.events.fetch({params});
    });

    return Promise.all(promises).finally(() => {
      this.fetchedRules = uniq(this.fetchedRules.concat(newRules));
      return this.loading = false;
    });
  }

  updateCollection() {
    this.records = [];
    this.rules.forEach(rule => {
      let chain = Records.events.collection.chain();
      chain.find(rule.local.find);

      if (rule.local.simplesort) {
        chain = chain.simplesort(rule.local.simplesort, rule.local.simplesortDesc);
      } else if (rule.local.sortByPositionKey) {
        chain = chain.sort((a,b) => {
          if (a.positionKey == b.positionKey) { return 0 }
          if (a.positionKey > b.positionKey) { return 1 }
          if (a.positionKey < b.positionKey) { return -1 }
        })
      } else if (rule.local.sortByPositionKeyDesc) {
        chain = chain.sort((a,b) => {
          if (a.positionKey == b.positionKey) { return 0 }
          if (a.positionKey > b.positionKey) { return -1 }
          if (a.positionKey < b.positionKey) { return 1 }
        })
      }

      if (rule.local.limit) {
        chain = chain.limit(rule.local.limit);
      }

      return this.records = this.records.concat(chain.data());
    });

    this.records = uniq(this.records.concat(compact(this.records.map(o => o.parent()))));
    this.records = orderBy(this.records, 'positionKey');
    const eventIds = this.records.map(event => event.id);

    const orphans = this.records.filter(event => (event.parentId === null) || !eventIds.includes(event.parentId));

    const eventsByParentId = {};
    this.records.forEach(event => {
      return eventsByParentId[event.parentId] = (eventsByParentId[event.parentId] || []).concat([event]);
    });

    var nest = function(records) {
      let r;
      return r = records.map(event => ({
        event,
        children: (eventsByParentId[event.id] && nest(eventsByParentId[event.id])) || [],
        eventable: event.model()
      }));
    };
      // orderBy r, 'positionKey'

    this.collection = nest(orphans);

    this.addMetaData(this.collection);

    EventBus.$emit('collectionUpdated', this.discussion.id);

    return this.collection;
  }

  addMetaData(collection) {
    const positions = collection.map(e => e.event.position);
    const ranges = RangeSet.arrayToRanges(positions);
    const parentExists = collection[0] && collection[0].event && collection[0].event.parent();
    const lastPosition = (parentExists && (collection[0].event.parent().childCount)) || 0;


    collection.forEach(obj => {
      obj.isUnread = this.isUnread(obj.event);
      const isFirstInRange = some(ranges, range => range[0] === obj.event.position);
      const isLastInLastRange = last(ranges)[1] === obj.event.position;
      const missingEarlier = parentExists && ((obj.event.position !== 1) && isFirstInRange);
      obj.missingEarlierCount = 0;
      if (missingEarlier) {
        let lastPos = 1;
        let val = 0;
        ranges.forEach(function(range) {
          if (range[0] === obj.event.position) {
            return val = (obj.event.position - lastPos);
          } else {
            return lastPos = range[1];
          }});
        obj.missingEarlierCount = val;
      }

      const missingAfter = (lastPosition !== 0) && isLastInLastRange && (obj.event.position !== lastPosition);
      obj.missingAfterCount = (missingAfter && (lastPosition - last(ranges)[1])) || 0;
      obj.missingChildCount = obj.event.childCount - obj.children.length;

      if (obj.children.length) { this.addMetaData(obj.children); }
    });
  }
}
