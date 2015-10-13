class Webhooks::Slack::NewVote < Webhooks::Slack::Base

	def text
		I18n.t :"webhooks.slack.new_vote", author: author.name, position: eventable.position, name: vote_discussion_link
	end

	def attachment_fallback
		"*#{eventable.position}*\n#{eventable.statement}\n"
	end

	def attachment_title
		vote_proposal_link(eventable)
	end

	def attachment_text
		"#{eventable.statement}\n"
	end

	def attachment_fields
		[user_vote_field]
	end

end