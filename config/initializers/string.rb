class String 
  def with_protocol
    "sms://#{self}"
  end
  
  def looks_as_an_int?
    Integer(self) 
    true
  rescue
    false
  end

  
  def one_to_s
    case self
    when "hours", "hour"
      "an hour"
    when "days", "day"
      "a day"
    when "weeks", "week"
      "a week"
    when "months", "month"
      "a month"
    when "years", "year"
      "a year"
    else
      nil
    end
  end
end