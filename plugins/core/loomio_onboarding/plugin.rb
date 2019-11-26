module Plugins
  module LoomioOnboarding
    class Plugin < Plugins::Base
      setup! :loomio_onboarding do |plugin|
        plugin.use_component :group_progress_card, outlet: [:before_group_page_column_right]
        # plugin.use_component :user_progress_card, outlet: :after_user_username

        plugin.use_translations 'config/locales', :loomio_onboarding

        plugin.use_test_route(:setup_progress_card_coordinator) do
          GroupService.create(group: create_group, actor: patrick)
          test_subgroup = FormalGroup.new(name: 'Johnny sub',
                                    parent: create_group,
                                    discussion_privacy_options: 'public_or_private',
                                    group_privacy: 'closed')
          GroupService.create(group: test_subgroup, actor: patrick)
          create_group.update_attribute(:description, 'Here is a group description')
          create_group.logo        = File.new("#{Rails.root}/spec/fixtures/images/strongbad.png")
          create_group.cover_photo = File.new("#{Rails.root}/spec/fixtures/images/strongbad.png")
          create_group.save
          patrick.avatar_kind = 'gravatar'
          patrick.save
          sign_in patrick
          create_discussion
          redirect_to group_url(create_group)
        end

        plugin.use_test_route(:setup_progress_card_member) do
          sign_in jennifer
          redirect_to group_url(create_group)
        end

        plugin.use_e2e 'spec/nightwatch/onboarding.js'

        plugin.use_class_directory 'app/mailers'
        plugin.use_view_path :"app/views"

        if ENV['WELCOME_EMAIL_SENDER_NAME'] && ENV['WELCOME_EMAIL_SENDER_EMAIL']
          plugin.use_events do |event_bus|
            event_bus.listen('user_create') do |user|
              OnboardingMailer.delay(queue: :low_priority, run_at: 5.minutes.from_now).welcome(user)
            end
          end
        end

        plugin.use_test_route(:setup_welcome_email) do
          UserService.create(user: jennifer)
          last_email
        end
      end
    end
  end
end
