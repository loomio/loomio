class TasksUser < ApplicationRecord
  #only used to keep track of @user mentions in tasks
  belongs_to :task
  belongs_to :user
end
