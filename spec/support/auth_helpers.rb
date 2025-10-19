# spec/support/auth_helpers.rb
module AuthHelpers
  def sign_in(user)
    post login_path, params: { username: user.username, password: 'senha123' }
  end

  def sign_out
    delete logout_path
  end
end
