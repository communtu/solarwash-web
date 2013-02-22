# == Schema Information
#
# Table name: devices
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  devicetype :integer
#  state      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Device < ActiveRecord::Base
  attr_accessible :name, :state, :devicetype
  has_many :jobs
  has_many :programs
  
  validates :name,
      :presence   => true,
      :uniqueness => { :case_sensitive => false }
  
  validates :state,
      :presence => true
  
  validates :devicetype,
      :presence => true
  
  def to_param
    [id, name.parameterize].join("-")
  end
  
end
