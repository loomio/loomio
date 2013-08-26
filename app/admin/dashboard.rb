ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    section "Groups", :priority => 1 do
    h1 { Group.count }
    div { "New today: #{Group.where('parent_id IS NULL AND created_at >= ?', 24.hours.ago).count}"}
    div { "New this week: #{Group.where('parent_id IS NULL AND created_at >= ?', 1.week.ago).count}"}
    div { link_to "See all groups", admin_groups_path }
    end

    section "Users", :priority => 2 do
      h1 { User.count }
      div { link_to "See all users", admin_users_path }
    end

    section "Members Per Group (average)", :priority => 3 do
      h1{ Group.average("memberships_count").round unless Group.count == 0 }
    end

    section "Discussions", :priority => 4 do
      h1 { Discussion.count }
    end

    section "Proposals", :priority => 7 do
      h1 { Motion.count }
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
