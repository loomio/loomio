angular.module('loomioApp').factory 'DiscussionReaderRecordsInterface', (BaseRecordsInterface, DiscussionReaderModel) ->
  class DiscussionReaderRecordsInterface extends BaseRecordsInterface
    model: DiscussionReaderModel
