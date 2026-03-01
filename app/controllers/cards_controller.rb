class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, only: %i[show edit update destroy]

  def index
    @cards = AccountRepository.by_type_and_user(current_user.id, 'cards')
                              .decorate
  end

  def show
    @card = @card.decorate
    @expenses_by_category = fetch_expenses_by_category
  end

  def new
    @card = Account::Card.new
  end

  def edit; end

  def create
    result = AccountServices::CreateAccount.create(card_params.merge(type: 'Account::Card'))
    @card = result[:account].decorate

    if result[:success?]
      handle_successful_creation
    else
      handle_failed_creation(result[:errors])
    end
  rescue StandardError => e
    handle_creation_error(e)
  end

  def update
    @card = AccountServices::UpdateAccount
            .update(card_params.merge(id: @card.id))
            .decorate

    if @card.valid?
      redirect_to cards_path, notice: 'Cartão atualizado.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    AccountRepository.destroy(@card.id)

    respond_to do |format|
      format.html { redirect_to cards_path, notice: 'Cartão removido.' }
      format.turbo_stream { flash.now[:notice] = 'Cartão removido.' }
    end
  end

  private

  def fetch_expenses_by_category
    Report::FetchExpensesByCategory.call(current_user.id, @card.id)
  end

  def handle_successful_creation
    respond_to do |format|
      format.html { redirect_to cards_path, notice: t('.success') }
      format.turbo_stream { flash.now[:notice] = t('.success') }
    end
  end

  def handle_failed_creation(errors)
    flash.now[:error] = format_errors(errors)
    render :new, status: :unprocessable_entity
  end

  def handle_creation_error(error)
    Rails.logger.error("Error creating card: #{error.message}")
    flash.now[:error] = t('.error')
    render :new, status: :unprocessable_entity
  end

  def format_errors(errors)
    if errors.is_a?(Array)
      errors.join(', ')
    else
      errors.to_s
    end
  end

  def card_params
    params.require(:card).permit(:name).merge(user_id: current_user.id)
  end

  def set_card
    @card = AccountRepository.find_by(id: params[:id], user: current_user.id)
    raise ActionController::RoutingError, 'Not Found' unless @card
  end
end
