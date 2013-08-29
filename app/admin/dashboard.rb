def print_month_totals(model)
  if model == "users"
    collection = User.where('created_at > ?', 6.months.ago).group_by{|u| u.created_at.month}
  elsif model == "groups"
    collection = Group.where('parent_id IS NULL AND created_at > ?', 6.months.ago).group_by{|g| g.created_at.month}
  end
  counts = {}
  collection.each_pair do |k, v|
    counts[k] = v.count
  end
  month_totals = []
  counts.each_pair do |k,v|
    month_name = Date::MONTHNAMES[k]
    month_totals << "#{month_name}: #{v}"
  end
  month_totals.join("<br>")
end

ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Groups" do
          h1 { Group.count }
          div { "New today: #{Group.where('parent_id IS NULL AND created_at >= ?', 24.hours.ago).count}"}
          div { print_month_totals("groups").html_safe}
          div { link_to "See all groups", admin_groups_path }
        end
      end
      column do
        panel "Users" do
          h1 { User.count }
          div { "New today: #{User.where('created_at >= ?', 24.hours.ago).count}"}
          div { print_month_totals("users").html_safe}
          div { link_to "See all users", admin_users_path }
        end
      end
      column do
        panel "Discussions" do
          h1 { Discussion.count }
        end
      end
      column do
        panel "Proposals" do
          h1 { Motion.count }
        end
      end
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
