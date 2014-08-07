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
    group = FactoryGirl.create(:group)
    UserMailer.group_membership_approved(user, group)
  end

  def added_to_group
    user = FactoryGirl.create(:user)
    inviter = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group)
    group.add_member!(inviter)
    message = "Hello! It's been a long time coming but I though you would be the best person to invite to the group now that we're developing a univfying agreement plan consenting process"
    UserMailer.added_to_group(user: user, inviter: inviter, group: group, message: message)
  end

  def motion_blocked
    motion = FactoryGirl.create(:motion)
    vote = FactoryGirl.create(:vote, motion: motion, position: 'block')
    UserMailer.motion_blocked(vote)
  end

  def motion_closed
    motion = FactoryGirl.create(:motion)
    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
    motion.save!
    UserMailer.motion_closed(motion, motion.author.email)
  end

  def motion_created
    motion = FactoryGirl.create(:motion)
    group = motion.group
    user = FactoryGirl.create(:user)
    group.add_member!(user)
    UserMailer.motion_created(motion, user)
  end

  def motion_closing_soon
    user = FactoryGirl.create(:user)
    motion = FactoryGirl.create(:motion)
    motion.group.add_member!(user)
    UserMailer.motion_closing_soon(user, motion)
  end

  def motion_outcome_created
    motion = FactoryGirl.create(:motion)
    group = motion.group
    user = FactoryGirl.create(:user)
    group.add_member!(user)
    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
    motion.save!
    motion.outcome = "the motion was voted upon variously, hurrah"
    motion.outcome_author = motion.author
    UserMailer.motion_outcome_created(motion, user)
  end
end
