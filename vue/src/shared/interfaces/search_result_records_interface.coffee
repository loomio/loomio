import BaseRecordsInterface from '@/shared/record_store/base_records_interface'
import SearchResultModel    from '@/shared/models/search_result_model'

export default class SearchResultRecordsInterface extends BaseRecordsInterface
  model: SearchResultModel
  apiEndPoint: 'search'
