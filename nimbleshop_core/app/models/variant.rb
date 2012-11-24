class Variant < ActiveRecord::Base
  serialize :values, Hash
  belongs_to :product

  def to_hash
    ignored = %w[product_id created_at updated_at id]

    attributes.except(*ignored).tap do | hash |
      hash.update(hash.delete('values').stringify_keys)
    end.symbolize_keys
  end
end
