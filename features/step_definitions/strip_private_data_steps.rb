Given(/^there is a private group with members, discussions, comments, and motions$/) do
  group = FactoryGirl.create :group, privacy: 'private'
  @group_id = group.id
  @membership_id = group.memberships.first.id
  discussion = FactoryGirl.create :discussion, group: group
  @discussion_id = discussion.id
  comment = FactoryGirl.create :comment, discussion: discussion
  @comment_id = comment.id
  motion = FactoryGirl.create :motion, discussion: discussion
  @motion_id = motion.id
end

Given(/^there is an archived group$/) do
  group = FactoryGirl.create :group, privacy: 'public'
  group.archive!
end


When(/^I strip private data from the database$/) do
  StripPrivateData.go
end

Then(/^the database should be empty apart from users$/) do
  model_paths = Dir["#{Rails.root}/app/models/**/*.rb"]
  model_paths.reject! { |dir|  dir =~ /\/concerns\// }

  models = model_paths.map do |model_path|
    model_path.gsub("#{Rails.root}/app/models", '').
               chomp('.rb').
               camelize.constantize
  end
  models.reject! { |model| model == User }
  models.select! { |model| model.respond_to?(:table_name) }
  models.each do |model|
    model_count = model.unscoped.count
    p "#{model}.count = #{model_count}" if model_count > 0
    model_count.should == 0
  end
end

When(/^user email and passwords should be foo'd$/) do
  User.all.each do |user|
    user.email.should == "#{user.id}@fake.loomio.org"
    user.valid_password?('password').should be_true
  end
end

Given(/^there is a public group with members, discussions, comments, and motions$/) do
  group = FactoryGirl.create :group, privacy: 'public'
  @group_id = group.id
  @membership_id = group.memberships.first.id
  discussion = FactoryGirl.create :discussion, group: group
  @discussion_id = discussion.id
  comment = FactoryGirl.create :comment, discussion: discussion
  @comment_id = comment.id
  motion = FactoryGirl.create :motion, discussion: discussion
  @motion_id = motion.id
end

Then(/^the group should not be deleted$/) do
  Group.find_by_id(@group_id).should be_present
end

Then(/^no data associated with that group should be deleted$/) do
  Membership.unscoped.where(id: @membership_id).should be_present
  Discussion.unscoped.where(id: @discussion_id).should be_present
  Comment.unscoped.where(id: @comment_id).should be_present
  Motion.unscoped.where(id: @motion_id).should be_present
end
