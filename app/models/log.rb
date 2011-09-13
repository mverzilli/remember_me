class Log < ActiveRecord::Base
  validates :severity,
             :inclusion => {:in => [:information, :error, :warning]}

  validates_presence_of :description, :severity, :schedule
  belongs_to :schedule
  
  def severity
    read_attribute(:severity).to_sym rescue nil
  end

  def severity= (a_severity)
    write_attribute(:severity, a_severity.to_s)
  end

end
