class NuntiumException < Exception
  def initialize(summary, properties)
    @summary = summary
    @properties = properties
  end
  def summary
    @summary
  end
  def properties
    @properties
  end
end