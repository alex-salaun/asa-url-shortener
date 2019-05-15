class Url < ApplicationRecord
  DEFAULT_EXPIRATION_DELAY  = 3.days
  SLUG_SIZE                 = 8

  validates :origin_url, :expiration_date, presence: true
  validates :slug, presence: true, uniqueness: true
  validate :origin_url_already_exists?, on: :create

  before_validation :format_origin_url
  before_validation :set_expiration_date, :generate_slug, on: :create

  # Check if the expiration date is after today
  def expired?
    self.expiration_date < Date.today
  end

  private

  # Set expiration date with the default value
  # User can not set the number of days
  # The expiration date is set only if there is no value for this field (on creation)
  def set_expiration_date
    self.expiration_date = Date.today + DEFAULT_EXPIRATION_DELAY
  end

  # Slugs are automatically generated
  # They must be uniq
  def generate_slug
    return unless self.slug.blank?

    loop do
      # We generate a random string (8 characters by default)
      # and check if an other url entity exists with this slug
      self.slug = (('A'..'Z').to_a + ('a'..'z').to_a).sample(SLUG_SIZE).join
      break unless Url.where(slug: slug).exists?
    end
  end

  # To avoid whitespace in origin url we clean the value
  def format_origin_url
    return if self.origin_url.blank?
    self.origin_url = self.origin_url.strip
  end

  # Check if a non-expired url entity already exists with the same origin_url
  # if there is already an url entity, the target url is given in the error message
  # Settings are used to get the host
  def origin_url_already_exists?
    return false if self.origin_url.blank?

    existing_url = Url.where(origin_url: self.origin_url).where('urls.expiration_date >= ?', self.expiration_date).first

    if existing_url
      self.errors.add(:origin_url, I18n.t('activerecord.errors.url.origin_url_uniqueness', shortened_url: [Settings.host, existing_url.slug].join('/')))
    end

  end
end


