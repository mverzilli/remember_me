require 'test_helper'

class LogsControllerTest < ActionController::TestCase

  test "should get index" do
    schedule = RandomSchedule.make
    get :index, :schedule_id => schedule.id
    assert_response :success
    assert_not_nil assigns(:logs)
  end
end
