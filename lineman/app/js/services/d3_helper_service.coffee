angular.module('loomioApp').service 'd3Helpers',
	class d3Helper
    proposalArray: (proposal) ->
      votes = ['yes_votes', 'no_votes', 'abstain_votes', 'block_votes']
      if proposal.votes_count is 0
        datum = {type:'not_yet_voted', count:1}
        array = [datum]
      else
      	array = (this.voteDatum vote, proposal for vote in votes)
      return array

    voteDatum:(vote, proposal) ->
    	key = vote + '_count'
    	datum = 
    		type: vote
    		count: proposal[key]	
