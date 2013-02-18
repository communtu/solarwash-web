class Project < ActiveRecord::Base
  attr_accessible :description

  belongs_to :group
end
