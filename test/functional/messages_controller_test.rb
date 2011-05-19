require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  setup do
    sign_in users(:user1) 
    
    @message = messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:messages)
  end

  test "should show message" do
    get :show, :id => @message.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @message.to_param
    assert_response :success
  end

  test "should update message" do
    put :update, :id => @message.to_param, :message => @message.attributes
    assert_redirected_to message_path(assigns(:message))
  end
end
