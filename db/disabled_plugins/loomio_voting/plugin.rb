module Plugins
  module LoomioVoting
    class Plugin < Plugins::Base
      setup! :loomio_voting do |plugin|
        plugin.enabled = true
        plugin.use_class 'app/models/votes/loomio'
        plugin.use_view_path 'app/views', controller: ThreadMailer
        plugin.register_proposal_kind :loomio,
          vote:            :loomio_vote,
          vote_form:       :loomio_vote_form,
          proposal:        :loomio_proposal,
          # proposal_form:   :loomio_proposal_form,
          preview_large:   :loomio_preview_large,
          preview_small:   :pie_chart
      end
    end
  end
end
