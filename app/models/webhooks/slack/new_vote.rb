class Webhooks::Slack::NewVote < Webhooks::Slack::Base

	def text
		I18n.t :"webhooks.slack.new_vote", author: author.name, position: eventable.position
	end

	def attachment_fallback
		"*#{eventable.position}*\n#{eventable.statement}\n"
	end

	def attachment_title
		"A proposal..."
	end

	def attachment_text
		"#{eventable.statement}\n"
	end

	def attachment_fields
		[user_vote_field]
	end

end