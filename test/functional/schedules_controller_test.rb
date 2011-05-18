require 'test_helper'

class SchedulesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user1) 
    
    @schedule = schedules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:schedules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create schedule" do
    assert_difference('Schedule.count') do
      assert_difference('Message.count') do
        schedule = {
          :keyword => "new",
          :timescale => "weeks",
          :type => "RandomSchedule",
          :welcome_message => "foo",
          :messages_attributes => {"0" => {"text" => "foomsg", "offset" => "2"}}
        }

        post :create, :schedule => schedule
      end
    end

    assert_redirected_to schedule_path(assigns(:schedule))
  end

  test "should show schedule" do
    get :show, :id => @schedule.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @schedule.to_param
    assert_response :success
  end

  test "should update schedule" do
    put :update, :id => @schedule.to_param, :schedule => @schedule.attributes
    assert_redirected_to schedule_path(assigns(:schedule))
  end

  test "should destroy schedule" do
    assert_difference('Schedule.count', -1) do
      delete :destroy, :id => @schedule.to_param
    end

    assert_redirected_to schedules_path
  end
end
