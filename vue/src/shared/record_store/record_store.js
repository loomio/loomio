/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let RecordStore;
import RecordView from '@/shared/record_store/record_view';
import RestfulClient from './restful_client';
import utils         from '@/shared/record_store/utils';
import { snakeCase, isEmpty, camelCase, map, keys, each, intersection, merge, pick } from 'lodash';

export default RecordStore = (function() {
  RecordStore = class RecordStore {
    static initClass() {
      this.prototype.eventTypeMap = {
        Group: 'groups',
        Discussion: 'discussions',
        Poll: 'polls',
        Outcome: 'outcomes',
        Stance: 'stances',
        Comment: 'comments',
        CommentVote: 'comments',
        Membership: 'memberships',
        MembershipRequest: 'membershipRequests'
      };
    }

    constructor(db) {
      this.db = db;
      this.collectionNames = [];
      this.views = {};
      this.remote = new RestfulClient;
      this.remote.onSuccess = data => {
        this.importJSON(data);
        return data;
      };
    }

    fetch(args) {
      return this.remote.fetch(args);
    }

    post({path, params}) {
      return this.remote.post(path, params);
    }

    addRecordsInterface(recordsInterfaceClass) {
      const recordsInterface = new recordsInterfaceClass(this);
      const name = camelCase(recordsInterface.model.plural);
      this[name] = recordsInterface;
      return this.collectionNames.push(name);
    }

    importJSON(json) {
      const collections = pick(json, map(this.collectionNames, snakeCase).concat(['parent_groups', 'parent_events']));
      return this.importREADY(utils.deserialize(collections));
    }

    importREADY(data) {
      if (isEmpty(data)) { return []; }

      // hack just to get around AMS
      if (data['parentGroups'] != null) {
        each(data['parentGroups'], recordData => {
          this.groups.importRecord(recordData);
          return true;
        });
      }

      if (data['parentEvents'] != null) {
        each(data['parentEvents'], recordData => {
          this.events.importRecord(recordData);
          return true;
        });
      }

      each(this.collectionNames, name => {
        if (data[name] != null) {
          return each(data[name], recordData => {
            this[name].importRecord(recordData);
            return true;
          });
        }
      });

      each(this.views, view => {
        if (intersection( map(view.collectionNames, camelCase) , map(keys(data), camelCase) )) {
          view.query(this);
        }
        return true;
      });
      return data;
    }

    view({name, collections, query}) {
      if (!this.views[name]) {
        this.views[name] = new RecordView({name, recordStore: this, collections, query});
      } else {
        console.warn(`Records.view exists: ${name}`);
      }
      this.views[name].query(this);
      return this.views[name];
    }
  };
  RecordStore.initClass();
  return RecordStore;
})();
