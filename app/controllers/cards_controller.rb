class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, only: %i[show edit update destroy]

  def index
    cards = Account::Card.where(user_id: current_user.id).order(:name)
    @cards = Account::AccountDecorator.decorate_collection(cards)
  end

  def show
    @card = Account::CardDecorator.decorate(@card)
  end

  def new
    @card = Account::Card.new
  end

  def edit; end

  def create
    @card = AccountServices::CreateAccount.create(card_params.merge(type: 'Account::Card')).decorate
    if @card.valid?
      respond_to do |format|
        format.html { redirect_to cards_path, notice: 'Cartão cadastrado.' }
        format.turbo_stream { flash.now[:notice] = 'Cartão cadastrado.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
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
    @card.destroy

    respond_to do |format|
      format.html { redirect_to cards_path, notice: 'Cartão removido.' }
      format.turbo_stream { flash.now[:notice] = 'Cartão removido.' }
    end
  end

  private

  def card_params
    params.require(:card).permit(:name).merge(user_id: current_user.id)
  end

  def set_card
    @card = AccountServices::FetchAccount.call(params[:id], current_user.id)
  end
end
