require 'test_helper'

class SchedulesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user1) 
    
    @schedule = one_make
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

    assert_redirected_to edit_schedule_path(assigns(:schedule))
  end

  test "should get edit" do
    get :edit, :id => @schedule.to_param
    assert_response :success
  end

  test "should fail to change schedule type if there are messages with blank offset" do
    attributes = @schedule.attributes
    attributes[:type] = "FixedSchedule"
    
    put :update, :id => @schedule.id, @schedule.class.name.underscore.to_sym => attributes
  
    assert_template :edit
    assert !assigns(:schedule).errors[:messages].blank?
  end
  
  test "should update schedule" do
    put :update, :id => @schedule.to_param, @schedule.class.name.underscore.to_sym => @schedule.attributes
    assert_redirected_to edit_schedule_path(assigns(:schedule))
  end
  
  test "should destroy some messages on schedule update" do
    randweeks = randweeks_make
    msg1 = randweeks.messages.first
    msg2 = randweeks.messages.second

    assert_difference('Message.count', -2) do
      schedule = {
        :id => randweeks.id,
        :keyword => randweeks.keyword,
        :timescale => randweeks.timescale,
        :type => randweeks.type,
        :welcome_message => randweeks.welcome_message,
        :messages_attributes => {"0" => {:id => msg1.id, :text => msg1.text, :offset => msg1.offset, "_destroy" => "1"}, 
                                  "1" => {:id => msg2.id, :text => msg2.text, :offset => msg2.offset, "_destroy" => "1"}}
      }      

      put :update, :id => randweeks.id, :random_schedule => schedule
    end

    assert_redirected_to edit_schedule_path(assigns(:schedule))
  end

  test "should destroy schedule" do
    assert_difference('Schedule.count', -1) do
      delete :destroy, :id => @schedule.to_param
    end

    assert_redirected_to schedules_path
  end
end
