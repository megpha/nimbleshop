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
        intd(renderer, renderer.text_field_tag("product[variant_rows][#{index}][]", row[field.to_sym]))
      end

      inner << intd(renderer, renderer.link_to("Delete", '#', title: 'Delete', data: { behaviour: "product-variants-delete-row"}))
      renderer.content_tag(:tr, renderer.raw(inner.join(' ')))
    end.join(' ')
  end

  private

    def intd(renderer, html)
      renderer.content_tag(:td, renderer.raw(html))
    end

    def labels_with_required_fields
      labels + %w[price quantity]
    end
end
