class Product < ActiveRecord::Base
  include Permalink::Builder

  serialize :variant_labels, Array

  alias_attribute :title, :name

  attr_accessor :pictures_order

  validates :status, inclusion: { in: %w(active hidden sold_out) }, presence: true

  has_many :pictures, order: 'pictures.position'

  accepts_nested_attributes_for :pictures, allow_destroy: true, reject_if: proc { |r| r[:picture].blank? }

  has_many :variants, dependent: :destroy, autosave: true
  has_many                      :custom_field_answers, dependent: :destroy
  accepts_nested_attributes_for :custom_field_answers, allow_destroy: true

  after_initialize :initialize_status

  scope :active,    where(status: 'active')
  scope :hidden,    where(status: 'hidden')
  scope :sold_out,  where(status: 'sold_out')

  validates_presence_of :name, :description, :price

  validates_numericality_of :price

  def variants_assigned?
    defined?(@variant_rows)
  end

  def build_variants
    VariantBuilder.new(self).rebuild
  end

  before_validation :build_variants, if: :variants_assigned?

  def variant_rows
    @variant_rows ||=  begin 
                         variations.map(&:to_hash)
                       end
  end

  def variant_rows=(hsh)
    @variant_rows = hsh.values  
  end

  def picture
    pictures.first
  end

  # Attaches picture to a product. This method is used only in development and test.
  #
  # === Arguments
  #
  # * <tt>:filename_with_extension</tt>
  # * <tt>:path</tt> -- full path to the file. Something like Rails.root.join('db', 'original_pictures', filename )
  #
  def attach_picture(filename_with_extension, path)
    img = File.open(path) {|i| i.read}
    encoded_img = Base64.encode64 img
    io = FilelessIO.new(Base64.decode64(encoded_img))
    io.original_filename = filename_with_extension
    p = Picture.new(product: self, picture: io)
    p.save!
  end

  def find_or_build_answer_for_field(field)
    custom_field_answers.detect {|t| t.custom_field_id.to_s == field.id.to_s } ||
      custom_field_answers.build(custom_field_id: field.id)
  end

  def find_or_build_all_answers
    CustomField.all.each { |f| find_or_build_answer_for_field(f) }
  end

  def pictures_order=(value)
    return if value.empty?
    ordered_pictures = ActiveSupport::JSON.decode(value)
    current_pictures = pictures

    ordered_pictures.each do |position, picture_id|
      if picture_id.present?
        pic = current_pictures.find { |x| x.id == picture_id.to_i }
        pic.update_column(:position, position) if pic
      end
    end
  end

  def initialize_status
    self.status ||= 'active'
  end
end
