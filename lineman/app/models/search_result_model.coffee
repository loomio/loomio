angular.module('loomioApp').factory 'SearchResultModel', (BaseModel) ->
  class SearchResultModel extends BaseModel
    @singular: 'search_result'
    @plural: 'search_results'

    isDiscussion: -> @resultType == 'Discussion'
    isProposal:   -> @resultType == 'Proposal'
    isComment:    -> @resultType == 'Comment'

    result: ->
      switch @resultType
        when 'Group'      then @recordStore.groups.find(@resultId)
        when 'Discussion' then @recordStore.discussions.find(@resultId)
        when 'Proposal'   then @recordStore.proposals.find(@resultId)
        when 'Comment'    then @recordStore.comments.find(@resultId)
