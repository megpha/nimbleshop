require 'test_helper'

class VariantPresenterTest < ActiveRecord::TestCase
  def setup
    @presenter = VariantPresenter.
                  new(%w[color size], [%w[red medium 3 1.45], %w[blue large 8 9.25]])

  end

  test 'should render variant labels' do

  end
end
