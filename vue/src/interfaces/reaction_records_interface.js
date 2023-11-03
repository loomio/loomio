import BaseRecordsInterface from '@/record_store/base_records_interface';
import ReactionModel        from '@/models/reaction_model';
import { debounce } from 'lodash';

export default class ReactionRecordsInterface extends BaseRecordsInterface {
  constructor(recordStore) {
    super(recordStore);
    this.model = ReactionModel;
    this.baseConstructor(recordStore);
  }
}
