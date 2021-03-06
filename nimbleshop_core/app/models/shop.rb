class Shop < ActiveRecord::Base

  before_validation :sanitize_twitter_handle, if: :twitter_handle

  validates :from_email, email: true, allow_blank: false

  validates_format_of :facebook_url, with: URI::regexp, allow_blank: true

  validates_presence_of :name, :theme, :time_zone, :default_creditcard_action
  validates_inclusion_of :default_creditcard_action,  in: %W( authorize purchase )
  validates_numericality_of :tax_percentage, greater_than_or_equal_to: 0, less_than: 100

  class << self
    alias_method :current, :first
  end

  def twitter_url
    twitter_handle.blank? ? nil : "http://twitter.com/#{twitter_handle}"
  end

  private

  def sanitize_twitter_handle
    twitter_handle.gsub!(/^@/, '')
  end

end
