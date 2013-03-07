class Setting < ActiveRecord::Base
  attr_accessible :sun_hour, :sun_minute, :sun_second, :time_to_confirm

  validates :sun_hour, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
  validates :sun_minute, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 59 }
  validates :sun_second, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 59 }
end
