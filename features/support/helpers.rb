include Warden::Test::Helpers
def view_screenshot
  filename = "tmp/screenshots/#{Time.now.to_i}.png" 
  page.driver.render(filename, full: true)
  system("open #{filename}")
end

def login(user_or_email, password = nil)

  if password.nil?
    #assume email is a user object and password is password
    email = user_or_email.email
    password = 'password'
  else
    email = user_or_email
  end

  visit "/users/sign_in"
  fill_in 'user_email', with: email
  fill_in 'user_password', :with => password
  click_button 'Sign in'
end

def login_automatically(user)
  visit "/users/sign_in"
  fill_in 'user_email', with: user.email
  fill_in 'user_password', :with => 'password'
  click_on 'sign-in-btn'
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

def last_email_text_body
  ActionMailer::Base.deliveries.last.parts[0].body
end

def last_email_html_body
  ActionMailer::Base.deliveries.last.parts[1].body
end
