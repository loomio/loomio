def login(email, password)
  visit "/"
  fill_in 'user_email', :with => email
  fill_in 'user_password', :with => password
  click_button 'Sign in'
end

def logout
  find("#user ul.dropdown-menu li:last-child a").click
end

def visit_group_page(groupname)
  @group = Group.find_by_name(groupname)
  visit group_path(@group)
end

def visit_add_subgroup_page(groupname)
  @group = Group.find_by_name(groupname)
  visit add_subgroup_group_path(@group)
end

def fill_create_subgroup_common
  fill_in "group-name", :with => 'test group'
  uncheck "group_email_new_motion"
end
