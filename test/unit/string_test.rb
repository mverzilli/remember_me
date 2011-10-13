require 'test_helper'

class StringTest < ActiveSupport::TestCase
  test "to channel name replace at and dots" do
    assert_equal "lorem_plus_123_at_acme_dot_org_dot_ar", "lorem+123@acme.org.ar".to_channel_name
  end
end
