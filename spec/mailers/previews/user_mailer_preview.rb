class UserMailerPreview < ActionMailer::Preview
  def missed_yesterday
    user = FactoryGirl.create(:user)
    1.times do
      group = FactoryGirl.create(:group)
      group.add_admin!(user)
      discussion = FactoryGirl.build(:discussion, group: group, author: user)

      #raise user.can?(:create, discussion).inspect
      #discussion.reload
      #user.reload
      DiscussionService.start_discussion(discussion)
      for i in 1..3 do
        case i
        when 0
          # no motion
        when 1
          # new motion
          motion = FactoryGirl.create(:motion, discussion: discussion)
          vote  = Vote.new(motion: motion, user: discussion.author, position: 'yes', statement: 'Oh yes in deeedee')
          MotionService.cast_vote(vote)

        when 2
          # motion with outcome
          motion = FactoryGirl.create(:motion,
                             discussion: discussion,
                             closed_at: 1.hour.ago,
                             outcome: "We all agreed to go ahead with the proposal",
                             outcome_author: discussion.author)
          #vote  =  Vote.new(motion: motion, user: discussion.author, position: 'yes', statement: 'Oh yes in deeedee')
          #MotionService.cast_vote(vote)
        end
      end
    end
    UserMailer.missed_yesterday(user)
  end

  def group_membership_approved
    user = FactoryGirl.create(:user)
    discussion = FactoryGirl.create(:discussion)
    comment = FactoryGirl.create(:comment, discussion: discussion, body: "Hey there @#{user.username}, I love what you said and want to find out more about the stuff you mentioned, can we please have a cup of tea and a bike ride with me?")
    UserMailer.mentioned(user, comment)
  end

  def added_to_group
    user = FactoryGirl.create(:user)
    inviter = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group)
    group.add_member!(inviter)
    message = "Hello! It's been a long time coming but I though you would be the best person to invite to the group now that we're developing a univfying agreement plan consenting process"
    UserMailer.added_to_group(user: user, inviter: inviter, group: group, message: message)
  end
end
