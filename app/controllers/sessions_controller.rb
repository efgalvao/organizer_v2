class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: I18n.t('sessions.signed_in')
    else
      flash.now[:alert] = I18n.t('.failure.user.invalid')
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: I18n.t('sessions.signed_out')
  end
end
