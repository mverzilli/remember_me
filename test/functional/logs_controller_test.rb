require 'test_helper'

class LogsControllerTest < ActionController::TestCase

  setup do
    sign_in users(:user1)    
  end
  
  test "should get index" do
    schedule = RandomSchedule.make
    get :index, :schedule_id => schedule.id
    assert_response :success
    assert_not_nil assigns(:logs)
  end
end
