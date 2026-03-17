require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get profiles_new_url
    assert_response :success
  end

  test "should get index" do
    get profiles_index_url
    assert_response :success
  end
end
