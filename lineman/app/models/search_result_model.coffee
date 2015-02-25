angular.module('loomioApp').factory 'SearchResultModel', (BaseModel) ->
  class SearchResultModel extends BaseModel
    @singular: 'searchResult'
    @plural: 'searchResults'

    initialize: (data) ->
      @discussion = data.discussion
      @proposals  = data.proposals
      @comments   = data.comments
      @query      = data.query
      @priority   = data.priority

    isDiscussion: -> @resultType == 'Discussion'
    isProposal:   -> @resultType == 'Proposal'
    isComment:    -> @resultType == 'Comment'

    result: ->
      switch @resultType
        when 'Group'      then @recordStore.groups.find(@resultId)
        when 'Discussion' then @recordStore.discussions.find(@resultId)
        when 'Proposal'   then @recordStore.proposals.find(@resultId)
        when 'Comment'    then @recordStore.comments.find(@resultId)
