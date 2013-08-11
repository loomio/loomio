ActiveAdmin::Dashboards.build do

  section "Groups", :priority => 1 do
    h1 { Group.count }
    div { "New today: #{Group.where('created_at >= ?', 24.hours.ago).count}"}
    div { "New this week: #{Group.where('created_at >= ?', 1.week.ago).count}"}
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

  # Define your dashboard sections here. Each block will be
  # rendered on the dashboard in the context of the view. So just
  # return the content which you would like to display.

  # == Simple Dashboard Section
  # Here is an example of a simple dashboard section
  #
  #   section "Recent Posts" do
  #     ul do
  #       Post.recent(5).collect do |post|
  #         li link_to(post.title, admin_post_path(post))
  #       end
  #     end
  #   end

  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end

  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section "Recent Posts", :priority => 10
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.

  # == Conditionally Display
  # Provide a method name or Proc object to conditionally render a section at run time.
  #
  # section "Membership Summary", :if => :memberships_enabled?
  # section "Membership Summary", :if => Proc.new { current_admin_user.account.memberships.any? }

end
