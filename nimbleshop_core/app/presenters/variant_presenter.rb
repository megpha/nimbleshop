class VariantPresenter

  attr_reader :labels, :rows

  def initialize(labels, rows)
    @labels = labels.empty? ? ['',''] : labels
    @rows   = rows.empty? ? [{}, {}] : rows
  end

  def render_labels(renderer)
    labels.map do | field |
      renderer.content_tag(:th, renderer.text_field_tag('product[variant_labels][]', field))
    end.join(' ')
  end

  def render_variants(renderer)
    index = -1
    rows.map do | row |
      index += 1
      inner = labels_with_required_fields.map do | field |
        text_html = renderer.text_field_tag("product[variant_rows][#{index}][]", row[field.to_sym])
        renderer.content_tag(:td, renderer.raw(text_html))
      end.join(' ')
      renderer.content_tag(:tr, renderer.raw(inner))
    end.join(' ')
  end

  private

    def labels_with_required_fields
      labels + %w[price quantity]
    end
end
