require 'test_helper'

class UrlsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @url = urls(:google_url)
    @expired_url = urls(:expired_url)
  end

  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should redirect to the origin_url" do
    get [root_url, @url.slug].join()
    assert_redirected_to @url.origin_url
  end

  test "should redirect to the root url if url is expired" do
    get [root_url, @expired_url.slug].join()
    assert_redirected_to root_url
  end

  test "should create article" do
    assert_difference('Url.count') do
      post urls_url, params: { url: { origin_url: 'http://www.mynewurl.com' } }
    end

    assert_redirected_to root_url
  end

  test "should update url" do
    patch url_url(id: @url.id, url: { expiration_date: Date.today - 1.day })
    assert_redirected_to root_url
    assert Url.find(@url.id).expired?
  end
end
