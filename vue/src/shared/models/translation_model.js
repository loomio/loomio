import BaseModel from '@/shared/record_store/base_model';

export default class TranslationModel extends BaseModel {
  static singular = 'translation';
  static plural = 'translations';
  static indices = ['id'];
}
