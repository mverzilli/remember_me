require 'test_helper'

class SubscribersControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user1)
    @randweeks = randweeks_make
    @subscriber = @randweeks.subscribers.first
  end

  test "should get index" do
    get :index, :schedule_id => @randweeks.id
    assert_response :success
    assert_not_nil assigns(:subscribers)
  end

  test "should destroy subscriber" do
    assert_difference('Subscriber.count', -1) do
      delete :destroy, :id => @subscriber.to_param, :schedule_id => @randweeks.id
    end

    assert_redirected_to schedule_subscribers_path(@randweeks)
  end
end
