include Warden::Test::Helpers
def view_screenshot
  filename = "tmp/screenshots/#{Time.now.to_i}.png" 
  page.driver.render(filename, full: true)
  system("open #{filename}")
end

def login(email, password)
  visit "/users/sign_in"
  fill_in 'user_email', :with => email
  fill_in 'user_password', :with => password
  click_button 'Sign in'
end

def login_automatically(user)
  login_as user, scope: :user
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
