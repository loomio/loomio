def print_month_totals(model)
  if model == "users"
    collection = User.where('created_at > ?', 6.months.ago).order("created_at DESC").group_by{|u| u.created_at.month}
    divisor = 50
  elsif model == "groups"
    collection = Group.where('parent_id IS NULL AND created_at > ?', 6.months.ago).order("created_at DESC").group_by{|g| g.created_at.month}
    divisor = 25
  end
  counts = {}
  collection.each_pair do |k, v|
    counts[k] = v.count
  end
  month_totals = []
  counts.each_pair do |k,v|
    graph = ''
    (v/divisor).times {|x| graph << '.'}
    month_name = Date::ABBR_MONTHNAMES[k]
    month_totals << "<span style='font-family:monaco'>#{month_name}#{graph}#{v}</span>"
  end
  month_totals.join("<br>")
end


def print_active_users()
  counts = Event.connection.select_all(%q{
    SELECT M.action_year, M.action_month, COUNT(M.user_id) active_users
      FROM (
        SELECT DISTINCT user_id, extract(year from created_at) action_year, extract(month from created_at) action_month FROM comments
        UNION
        SELECT DISTINCT user_id, extract(year from created_at) action_year, extract(month from created_at) action_month FROM votes
        ) AS M
      GROUP BY
        M.action_year,
        M.action_month
      ORDER BY
        M.action_year DESC,
        M.action_month DESC
    })
  current_month_active = counts[0]['active_users']
  month_totals = []
  month_totals << "<h1> #{current_month_active} </h1><table>"
  counts.each do |m|
    month = Date.new(m['action_year'].to_i, m['action_month'].to_i, 1).strftime('%Y - %b')
    active_users = m['active_users']
    month_totals << "<tr><td> #{month} </td><td> #{active_users} </td><td>"
  end
  month_totals << "</table>"
  month_totals.join('')
end

ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Monthly Active Users" do
          div { print_active_users().html_safe }
        end
      end
      column do
        panel "Groups" do
          h1 { Group.count }
          div { "New today: #{Group.where('parent_id IS NULL AND created_at >= ?', 24.hours.ago).count}"}
          div { print_month_totals("groups").html_safe}
          div { link_to "See all groups", admin_groups_path }
        end
      end
      column do
        panel "User Accounts" do
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
