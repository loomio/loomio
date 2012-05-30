namespace :data do
  task :example => :environment do
    # create some users
    User.create!(:email => 'admin@loom.io',
                 :password => 'password',
                 :admin => true,
                 :name => 'Administrator')
    user1 = User.create(name: "User 1", email: "user1@loom.io", password: "password")
    user2 = User.create(name: "User 2", email: "user2@loom.io", password: "password")
    user3 = User.create(name: "User 3", email: "user3@loom.io", password: "password")
    
    # create a group
    group = Group.create!(name: "Devs")
    
    # create memberships and add them to the group
    membership = Membership.new(access_level: 'member')
    membership.user = user1
    membership.group = group
    membership.save!
    membership = Membership.new(access_level: 'member')
    membership.user = user2
    membership.group = group
    membership.save!
    membership = Membership.new(access_level: 'member')
    membership.user = user3
    membership.group = group
    membership.save!
    
    # add a motion
    motion = Motion.new(name: 'Start using seed.rb', phase: 'voting', description: "Fake description")
    motion.author = user1
    motion.facilitator = motion.author
    discussion = Discussion.new(title: "A Discussion")
    discussion.author = motion.author
    discussion.group = group
    discussion.group.add_member!(discussion.author)
    discussion.group.save!
    discussion.save!
    motion.discussion = discussion
    motion.save!
    
    # add votes
    vote = Vote.new(:position => "yes")
    vote.user = user1
    vote.motion = motion
    vote.save!
    
    vote = Vote.new(:position => "abstain")
    vote.user = user2
    vote.motion = motion
    vote.save!
  end
end
