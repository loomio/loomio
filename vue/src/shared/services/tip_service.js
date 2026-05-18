import EventBus       from '@/shared/services/event_bus';
import GroupService   from '@/shared/services/group_service';
import Records from '@/shared/services/records';

export default new class TipService {
  tips(user, group, vm) {
    return [
      // {
      //   title: 'tips.intro.tip_title',
      //   show() { return !!group },
      //   completed() { return user.hasExperienced('tips.intro') },
      //   disabled() { return false },
      //   perform() {
      //     EventBus.$emit('openModal', {
      //       component: 'ConfirmModal',
      //       props: {
      //         confirm: {
      //           submit: () => {
      //             return Records.users.saveExperience('tips.intro', true);
      //           },
      //           forceSubmit: true,
      //           text: {
      //             title:    'tips.intro.title',
      //             helptext: 'tips.intro.body',
      //             submit:   'tips.intro.submit'
      //           },
      //         }
      //       }
      //     });
      //   }
      // },
      // {
      //   title: 'profile_page.set_your_profile_picture',
      //   completed() { return user && user.avatarKind != 'initials' },
      //   show() { return true },
      //   disabled() { return false },
      //   perform() {
      //     EventBus.$emit('openModal', { component: 'ChangePictureForm' });
      //   }
      // },
      // {
      //   title: 'tips.group.upload_image.title',
      //   completed() { return group.hasCustomCoverPhoto },
      //   show() { return !!group },
      //   disabled() { return false },
      //   perform() {
      //     EventBus.$emit('openModal', {
      //       component: 'ConfirmModal',
      //       props: {
      //         confirm: {
      //           forceSubmit: true,
      //           submit() { return new Promise((resolve) => resolve()) },
      //           successCallback() {
      //             GroupService.actions(group).edit_group.perform();
      //             vm.$router.push(vm.urlFor(group));
      //           },
      //           text: {
      //             title:    'tips.group.upload_image.title',
      //             helptext: 'tips.group.upload_image.helptext',
      //             submit:   'tips.group.upload_image.open_group_settings'
      //           },
      //         }
      //       }
      //     });
      //   }
      // },
      {
        title: 'tips.group.invite_people.title',
        completed() { return group.membershipsCount > 1 },
        show() { return !!group },
        disabled() { return false },
        perform() {
          EventBus.$emit('openModal', { component: 'GroupInvitationForm', props: { group } });
        }
      },
      {
        title: 'tips.group.start_a_discussion.title',
        completed() { return group.discussionsCount > 0 },
        show() { return !!group },
        disabled() { return false },
        perform() {
          EventBus.$emit('openModal', {
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit() { return new Promise((resolve) => resolve()) },
                successCallback() {
                  vm.$router.push(`/discussion_templates/?group_id=${group.id}`);
                },
                forceSubmit: true,
                text: {
                  title:    'tips.group.start_a_discussion.title',
                  helptext: 'tips.group.start_a_discussion.helptext',
                  submit:   'tips.group.start_a_discussion.submit'
                },
              }
            }
          });
        }
      },
      {
        title: 'tips.group.start_a_proposal.title',
        show() { return !!group },
        completed() { return group.pollsCount },
        disabled() { return group.discussionsCount == 0 },
        perform() {
          EventBus.$emit('openModal', {
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit: () => {
                  let discussion = null;
                  return Records.remote.fetch({
                    path: 'discussions',
                    params: {
                      group_id: group.id,
                      subgroups: 'none'
                    }
                  }).then(() => {
                    discussion = Records.discussions.collection.chain()
                      .find({groupId: group.id})
                      .simplesort('id')
                      .data()[0];
                    vm.$router.push(vm.urlFor(discussion, null, { current_action: 'add-poll' }));
                  });
                },
                forceSubmit: true,
                text: {
                  title:    'tips.group.start_a_proposal.title',
                  helptext: 'tips.group.start_a_proposal.helptext',
                  submit:   'tips.group.start_a_proposal.submit'
                },
              }
            }
          });
        }
      },
      {
        title: 'tips.group.share_an_outcome.title',
        show() { return !!group },
        completed() { return group.polls().filter((poll) => poll.outcome()).length },
        disabled() { return group.pollsCount == 0 },
        perform() {
          EventBus.$emit('openModal', {
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit() { return new Promise((resolve) => resolve()) },
                successCallback() {
                  let poll = group.polls().filter((poll) => !poll.outcome())[0]
                  vm.$router.push(vm.urlFor(poll));
                },
                text: {
                  title:    'tips.group.share_an_outcome.title',
                  helptext: 'tips.group.share_an_outcome.helptext',
                  submit:   'tips.group.share_an_outcome.submit',
                  cancel: 'tips.group.share_an_outcome.cancel'
                },
              }
            }
          });
        }
      },


      // {
      //   title: 'tips.any_questions_get_in_touch',
      //   show() { return AppConfig.features.app.subscriptions },
      //   perform() { vm.$router.push('/contact') }
      // }
    ];
  }
};
