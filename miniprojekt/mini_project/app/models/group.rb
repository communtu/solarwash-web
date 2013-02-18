class Group < ActiveRecord::Base
  attr_accessible :project_id

  has_many :users
  has_one  :project
end
