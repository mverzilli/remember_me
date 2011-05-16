class String 
  def with_protocol
    "sms://#{self}"
  end
  
  def looks_as_an_int?
    begin 
      Integer(self) 
      true
    rescue
      false
    end
  end
end