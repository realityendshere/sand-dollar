module SandDollar::AuthenticationService
  module_function

  def authenticate_request(request)
    PasswordAuthenticator.new(request).authenticate!
  end

  def authenticate_request!(*args)
    authenticate_request(*args) or raise SandDollar::AuthenticationFailed
  end

end

class PasswordAuthenticator < ::SandDollar::Authenticators::Base
  # def valid?
  #   return false unless request.post?
  #   !(post_params[:identification].blank? || post_params[:password].blank?)
  # end

  def authenticate!
    user = user_model_class.find_by_identification(identification)
    if user.nil? || user.password != season_password(password, user.password_salt)
      false
    else
      user
    end
  end

  def post_params
    request.params.fetch('session')
  end

  def identification
    post_params['identification']
  end

  def password
    post_params['password']
  end

end
