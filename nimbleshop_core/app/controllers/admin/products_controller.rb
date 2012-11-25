class Admin::ProductsController < AdminController

  before_filter :load_product!, only: [:edit, :update, :destroy ]

  respond_to :html

  def index
    @products = Product.order(:id)
    respond_with @products
  end

  def new
    @products = Product.order(:id)
    @product = Product.new
    @product.pictures.build
    @product.find_or_build_all_answers
    respond_with @product
  end

  def edit
    @product_groups = ProductGroup.contains_product(@product)
    @product.find_or_build_all_answers
    respond_with @products
  end

  def create
    respond_to do |format|
      format.html do

        @product = Product.new(post_params[:product])
        if @product.save
          redirect_to edit_admin_product_path(@product), notice: t(:successfully_added)
        else
          render action: 'new'
        end

      end
    end
  end

  def update
    respond_to do |format|
      format.html do

        @product_groups = ProductGroup.contains_product(@product)
        if @product.update_attributes(post_params[:product])
          redirect_to edit_admin_product_path(@product), notice: t(:successfully_updated)
        else
          respond_with @product
        end

      end
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_url, notice: t(:successfully_deleted)
  end

  private

  def post_params
    params.permit(product: [:pictures_attributes, :name, :status, :description, :price, :new, :pictures_order, :custom_field_answers_attributes, :variant_labels, :variant_rows] )
  end

  def load_product!
    @product = Product.find_by_permalink!(params[:id])
  end

end
