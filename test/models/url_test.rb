require 'test_helper'

class UrlTest < ActiveSupport::TestCase
  test "test origin_url must be set" do
    url = Url.new
    assert_not url.save, "Saved the url without an origin_url"
  end

  test "test slug must be uniq" do
    url = Url.new(origin_url: 'http://foo.bar.com', slug: 'iohIYvVF')
    assert url.valid?

    url.slug = Url.first.slug
    assert_not url.valid?
  end

  test "test slug is automatically set" do
    url = Url.new
    url.valid?

    assert_not url.slug.blank?
  end

  test "test expiration date is automatically set" do
    url = Url.new
    url.valid?

    assert_not url.expiration_date.blank?
  end

  test "test expiration date is automatically set to today + 3 days" do
    url = Url.new
    url.valid?

    assert_equal Date.today + 3.days, url.expiration_date
  end

  test "test origin_url does not contain whitespace" do
    url = Url.new(origin_url: ' http://www.foo.bar   ')
    url.valid?

    assert_equal 'http://www.foo.bar', url.origin_url
  end

  test "test expired? method with date in the past" do
    url = Url.new(expiration_date: Date.today - 1.day)
    assert url.expired?
  end

  test "test expired? method with today" do
    url = Url.new(expiration_date: Date.today)
    assert_not url.expired?
  end

  test "test expired? method with date in the future" do
    url = Url.new(expiration_date: Date.today + 1.day)
    assert_not url.expired?
  end

  test "test origin_url must be uniq if valid url already exists" do
    url = Url.new(origin_url: urls(:google_url).origin_url)

    assert_not url.valid?
    assert url.errors.full_messages.to_s.include?(Settings.host)
    assert url.errors.full_messages.to_s.include?(urls(:google_url).slug)
  end

  test "test origin_url must not be uniq if already existing urls are expired" do
    url = Url.new(origin_url: urls(:expired_url).origin_url)
    assert url.valid?
  end
end
