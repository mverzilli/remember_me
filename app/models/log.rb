class Log < ActiveRecord::Base

  symbolize :severity, :in => [:information, :error, :warning]

  validates_presence_of :description, :severity, :schedule
  belongs_to :schedule

end
