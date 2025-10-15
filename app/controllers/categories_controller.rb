class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]
  before_action :authenticate_user!

  def index
    @categories = CategoryRepository.all(current_user.id)
  end

  def new
    @category = Category.new
  end

  def edit; end

  def create
    @category = CategoryRepository.create!(category_params)

    respond_to do |format|
      format.html { redirect_to categories_path, notice: 'Category successfully created.' }
      format.turbo_stream
    end
  rescue ActiveRecord::RecordInvalid => e
    @category = e.record
    render :new, status: :unprocessable_entity
  end

  def update
    CategoryRepository.update!(@category, category_params)
    redirect_to categories_path, notice: 'Category was successfully updated.'
  rescue ActiveRecord::RecordInvalid => e
    @category = e.record
    render :edit, status: :unprocessable_entity
  end

  def destroy
    CategoryRepository.destroy(@category.id)

    respond_to do |format|
      format.html { redirect_to categories_path, notice: 'Category successfully destroyed.' }
      format.turbo_stream
    end
  end

  private

  def set_category
    @category = CategoryRepository.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name).merge(user_id: current_user.id)
  end
end
