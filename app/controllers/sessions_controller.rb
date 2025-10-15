class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: 'Login realizado com sucesso.'
    else
      flash.now[:alert] = 'E-mail ou senha inválidos.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: 'Sessão encerrada.'
  end
end
