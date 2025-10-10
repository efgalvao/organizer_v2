class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]
  before_action :authenticate_user!

  def index
    @categories = CategoryServices::FetchCategories.fetch_categories(current_user.id)
  end

  def new
    @category = Category.new
  end

  def edit; end

  def create
    @category = CategoryRepository.new.create!(category_params)

    respond_to do |format|
      format.html { redirect_to categories_path, notice: 'Category successfully created.' }
      format.turbo_stream
    end
  rescue ActiveRecord::RecordInvalid => e
    @category = e.record
    render :new, status: :unprocessable_entity
  end

  def update
    CategoryRepository.new.update!(@category, category_params)
    redirect_to categories_path, notice: 'Category was successfully updated.'
  rescue ActiveRecord::RecordInvalid => e
    @category = e.record
    render :edit, status: :unprocessable_entity
  end

  def destroy
    CategoryRepository.new.destroy(@category.id)

    respond_to do |format|
      format.html { redirect_to categories_path, notice: 'Category successfully destroyed.' }
      format.turbo_stream
    end
  end

  private

  def set_category
    @category = CategoryRepository.new.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name).merge(user_id: current_user.id)
  end
end
