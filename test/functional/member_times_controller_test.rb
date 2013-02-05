require 'test_helper'

class MemberTimesControllerTest < ActionController::TestCase
  setup do
    @member_time = member_times(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:member_times)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create member_time" do
    assert_difference('MemberTime.count') do
      post :create, member_time: { created_at: @member_time.created_at, member_id: @member_time.member_id, type: @member_time.type }
    end

    assert_redirected_to member_time_path(assigns(:member_time))
  end

  test "should show member_time" do
    get :show, id: @member_time
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @member_time
    assert_response :success
  end

  test "should update member_time" do
    put :update, id: @member_time, member_time: { created_at: @member_time.created_at, member_id: @member_time.member_id, type: @member_time.type }
    assert_redirected_to member_time_path(assigns(:member_time))
  end

  test "should destroy member_time" do
    assert_difference('MemberTime.count', -1) do
      delete :destroy, id: @member_time
    end

    assert_redirected_to member_times_path
  end
end
