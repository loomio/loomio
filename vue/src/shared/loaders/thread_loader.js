import Records from '@/shared/services/records';
import { some, last, cloneDeep, max, uniq, compact, orderBy, pickBy, map, each } from 'lodash-es';
import { reactive } from 'vue';
import RangeSet         from '@/shared/services/range_set';
import EventBus         from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import AppConfig from '@/shared/services/app_config';

export default class ThreadLoader {
  constructor(topic) {
    this.topic = topic;
    this.reset();
  }

  reset() {
    this.collection = [];
    this.rules = [];
    this.ruleStrings = [];
    this.fetchedRules = [];
    this.lastReadAt = this.topic.lastReadAt;
    this.ranges = cloneDeep(this.topic.ranges);
    this.readRanges = cloneDeep(this.topic.readRanges);
    this.unreadRanges = RangeSet.subtractRanges(this.ranges, this.readRanges);
    this.visibleKeys = {};
    this.collapsed = reactive({});
    this.loading = false;
    this.isFirstLoad = true
    this.padding = 25;
  }

  clearRules() {
    this.rules = [];
    this.ruleStrings = [];
    this.fetchedRules = [];
  }

  firstUnreadSequenceId() {
    return (this.unreadRanges[0] || [])[0];
  }

  lastSequenceId() {
    return (last(this.ranges) || [])[1];
  }

  setVisible(isVisible, event) {
    this.readTimers = this.readTimers || {};
    if (isVisible && Session.isSignedIn()) {
      this.readTimers[event.sequenceId] = setTimeout(() => {
        this.topic.markAsRead(event.sequenceId);
        delete this.readTimers[event.sequenceId];
      }, 500);
    } else if (this.readTimers[event.sequenceId]) {
      clearTimeout(this.readTimers[event.sequenceId]);
      delete this.readTimers[event.sequenceId];
    }
    this.visibleKeys[event.positionKey] = isVisible;
    return EventBus.$emit('visibleKeys', Object.keys(this.visibleKeys).filter(key => this.visibleKeys[key]).sort());
  }

  collapse(event) {
    Object.keys(this.visibleKeys).forEach(key => {
      if (key.startsWith(event.positionKey)) { return this.visibleKeys[key] = false; }
    });
    return this.collapsed[event.id] = true;
  }

  isUnread(event) {
    return !RangeSet.includesValue(this.readRanges, event.sequenceId);
  }

  sequenceIdIsUnread(id) {
    return !RangeSet.includesValue(this.readRanges, id);
  }

  expand(event) {
    return this.collapsed[event.id] = false;
  }

  addLoadArgsRule(args) {
    const andParts = [{ topicId: this.topic.id }]

    if (args.depth) {
      andParts.push({depth: args.depth})
    }

    if (args.depth_lte) {
      andParts.push({depth: {$lte: args.depth_lte}})
    }

    if (args.position_key_lt) {
      andParts.push({positionKey: {$jlt: args.position_key_lt}})
    }
    if (args.position_key_lte) {
      andParts.push({positionKey: {$jlte: args.position_key_lte}})
    }
    if (args.position_key_gt) {
      andParts.push({positionKey: {$jgt: args.position_key_gt}})
    }
    if (args.position_key_gte) {
      andParts.push({positionKey: {$jgte: args.position_key_gte}})
    }
    if (args.position_key_sw) {
      andParts.push({positionKey: {$regex: `^${args.position_key_sw}`}})
    }
    this.addRule({
      name: `addLoadArgsRule`,
      local: {
        find: {$and: andParts},
        sortByPositionKey: args.order_by == 'position_key' && !args.order_desc,
        sortByPositionKeyDesc: args.order_by == 'position_key' && !!args.order_desc,
        limit: this.padding
      },
      remote: pickBy({
        topic_id: this.topic.id,
        depth: args.depth,
        depth_lte: args.depth_lte,
        position_key_gt: args.position_key_gt,
        position_key_gte: args.position_key_gte,
        position_key_lt: args.position_key_lt,
        position_key_lte: args.position_key_lte,
        position_key_sw: args.position_key_sw,
        order_by: args.order_by || 'position_key',
        order_desc: args.order_desc && 1,
        per: this.padding
      })
    });
  }

  addLoadMyStuffRule() {
    this.addRule({
      local: {
        find: {
          actorId: AppConfig.currentUserId,
          topicId: this.topic.id,
          createdAt: { $gte: new Date() }
        }
      }
    })
  }

  addLoadCommentRule(commentId, remoteTopicParams = { topic_id: this.topic.id }) {
    return this.addRule({
      name: "comment from url",
      local: {
        find: {
          topicId: this.topic.id,
          eventableId: commentId,
          eventableType: 'Comment'
        }
      },
      remote: {
        ...remoteTopicParams,
        order: 'sequence_id',
        comment_id: commentId,
        per: this.padding
      }
    });
  }

  addLoadSequenceIdRule(sequenceId, remoteTopicParams = { topic_id: this.topic.id }) {
    const id = max([parseInt(sequenceId) - parseInt(this.padding/2), 0]);
    this.loading = id;
    return this.addRule({
      name: "sequenceId from url",
      local: {
        find: {
          $and: [
            { topicId: this.topic.id },
            { sequenceId: {'$gte': id} },
          ]
        },
        simplesort: 'sequenceId',
        limit: this.padding
      },
      remote: {
        ...remoteTopicParams,
        sequence_id_gte: id,
        order: 'sequence_id',
        per: this.padding
      }
    });
  }

  addLoadNewestRule(remoteTopicParams = { topic_id: this.topic.id }) {
    return this.addRule({
      local: {
        find: {
          topicId: this.topic.id,
          sequenceId: { $lte: this.lastSequenceId() }
        },
        simplesort: 'sequenceId',
        simplesortDesc: true,
        limit: this.padding
      },
      remote: {
        ...remoteTopicParams,
        sequence_id_lte: this.lastSequenceId(),
        order_by: 'sequence_id',
        order_desc: true,
        per: this.padding
      }
    });
  }

  addLoadOldestRule() {
    return this.addRule({
      name: 'oldest',
      local: {
        find: {
          topicId: this.topic.id,
          sequenceId: { $lte: this.lastSequenceId() }
        },
        simplesort: 'sequenceId',
        limit: this.padding
      },
      remote: {
        topic_id: this.topic.id,
        order_by: 'sequence_id',
        per: this.padding
      }
    });
  }

  addLoadUnreadRule(remoteTopicParams = { topic_id: this.topic.id }) {
    return this.addRule({
      name: {path: "strand_nav.new_to_you"},
      local: {
        find: {
          topicId: this.topic.id,
          sequenceId: {$in: RangeSet.rangesToArray(this.unreadRanges)}
        },
        limit: this.padding,
        simplesort: 'sequenceId'
      },
      remote: {
        ...remoteTopicParams,
        sequence_id_in: RangeSet.serialize(this.unreadRanges).replace(/,/g, '_'),
        order_by: "sequence_id",
        per: this.padding
      }
    });
  }

  addLoadUnreadOrNewestRule(remoteTopicParams) {
    const unreadSequenceIds = RangeSet.rangesToArray(this.unreadRanges);
    const hasUnread = unreadSequenceIds.length > 0;

    return this.addRule({
      name: 'unread or newest',
      local: {
        find: hasUnread ? {
          topicId: this.topic.id,
          sequenceId: {$in: unreadSequenceIds}
        } : {
          topicId: this.topic.id,
          sequenceId: { $lte: this.lastSequenceId() }
        },
        limit: this.padding,
        simplesort: 'sequenceId',
        simplesortDesc: !hasUnread
      },
      remote: {
        ...remoteTopicParams,
        unread_or_newest: 1,
        per: this.padding
      }
    });
  }

  addRule(rule) {
    const ruleString = JSON.stringify(rule);
    if (!this.ruleStrings.includes(ruleString)) {
      this.rules.push(rule);
      this.ruleStrings.push(ruleString);
      return true;
    } else {
      return false;
    }
  }

  fetch() {
    const newRules = [];
    const promises = this.rules.filter(rule => rule.remote)
                     .filter(rule => !this.fetchedRules.includes(JSON.stringify(rule.remote)))
                     .map(rule => {
      newRules.push(JSON.stringify(rule.remote));
      const params = Object.assign({}, rule.remote, this.isFirstLoad ? {} : {exclude_types: 'topic'});
      return Records.events.fetch({params});
    });

    return Promise.all(promises).finally(() => {
      this.fetchedRules = uniq(this.fetchedRules.concat(newRules));
      this.isFirstLoad = false
      this.loading = false;
    });
  }

  updateCollection() {
    this.records = [];
    this.rules.forEach(rule => {
      let chain = Records.events.collection.chain().find(rule.local.find);

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

      this.records = this.records.concat(chain.data());
    });

    const parentsd1 = compact(this.records.map(o => o.parent()))
    const parentsd2 = compact(parentsd1.map(o => o.parent()))
    const parentsd3 = compact(parentsd2.map(o => o.parent()))
    this.records = uniq(this.records.concat(parentsd1).concat(parentsd2).concat(parentsd3));
    this.records = orderBy(this.records, 'positionKey');

    const eventIds = this.records.map(event => event.id);

    const orphans = this.records.filter(event => (event.parentId === null) || !eventIds.includes(event.parentId));

    const eventsByParentId = {};
    this.records.forEach(event => {
      eventsByParentId[event.parentId] = (eventsByParentId[event.parentId] || []).concat([event]);
    });

    var nest = function(records) {
      return records.map(event => ({
        event,
        children: (eventsByParentId[event.id] && nest(eventsByParentId[event.id])) || [],
        eventable: event.model()
      }));
    };

    this.collection = nest(orphans);

    this.addMetaData(this.collection);

    EventBus.$emit('collectionUpdated', this.topic.id);

    return this.collection;
  }

  addMetaData(collection) {
    if (collection.length == 0) return;

    const ranges = RangeSet.arrayToRanges(collection.map(e => e.event.position));
    const parentEvent = collection[0].event.parent();
    const lastPosition = (parentEvent && parentEvent.childCount) || 0;

    for (let i = 0; i < collection.length; i++) {
      const obj = collection[i];
      const isFirstInRange = some(ranges, range => range[0] === obj.event.position);
      const isLastInRange = some(ranges, range => range[1] === obj.event.position);
      const isLastInLastRange = last(ranges)[1] === obj.event.position;

      obj.isUnread = this.lastReadAt && this.isUnread(obj.event);
      obj.missingEarlier = isFirstInRange && obj.event.position > 1;
      obj.missingAfter = isLastInLastRange && obj.event.position !== lastPosition;
      obj.missingChildCount = obj.event.childCount - obj.children.length;

      if (obj.children.length) { this.addMetaData(obj.children); }
    }
  }
}
