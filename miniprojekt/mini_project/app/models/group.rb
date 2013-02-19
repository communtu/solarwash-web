class Group < ActiveRecord::Base
  attr_accessible :project_id

  has_many :users
  has_one  :project, foreign_key: "project_id"
end
