module Plugins
  module LoomioContentPreview
    class Plugin < Plugins::Base
      setup! :loomio_content_preview do |plugin|
        plugin.enabled = true

        plugin.use_component :preview_button, outlet: [
          :before_outcome_submit,
          :before_comment_submit,
          :before_poll_submit,
          :before_discussion_submit
        ]
        plugin.use_component :preview_pane, outlet: :before_lmo_textarea

        plugin.use_translations 'config/locales', :loomio_content_preview

        plugin.use_test_route(:setup_comment_preview) do
          sign_in patrick
          create_discussion.group.update(enable_experiments: true)
          @comment = CommentService.create(
            comment: FactoryBot.build(:comment, discussion: create_discussion),
            actor: patrick
          )
          redirect_to discussion_path(@comment.discussion)
        end
        plugin.use_e2e 'spec/nightwatch/contentPreview.js'
      end
    end
  end
end
