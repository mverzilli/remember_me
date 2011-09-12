require 'test_helper'

class LogTest < ActiveSupport::TestCase
  test "validate presence of required fields in Log" do
    log = Log.new
    log.save

    assert log.invalid?
    assert !log.errors[:severity].blank?, "Severity must be present for all logs"
    assert !log.errors[:description].blank?, "Description must be present for all logs"
  end
end
