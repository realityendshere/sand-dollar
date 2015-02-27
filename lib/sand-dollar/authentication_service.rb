module SandDollar::AuthenticationService
  module_function

  def authenticate_request(request)
    PasswordAuthenticator.new(request).authenticate!
  end

  def authenticate_request!(*args)
    authenticate_request(*args) or raise SandDollar::AuthenticationFailed
  end

  def valid_identification_provided?(identification)
    identification.to_s.length > 0
  end

  def valid_identification_provided!(*args)
    valid_identification_provided?(*args) or raise AuthenticationFailed
  end
end

class PasswordAuthenticator
  attr_reader :request

  def initialize(request)
    @request = request
  end

  # def valid?
  #   return false unless request.post?
  #   !(post_params[:identification].blank? || post_params[:password].blank?)
  # end

  def authenticate!
    user = SandDollar.configuration.user_model_class.find_by_identification(identification)
    if user.nil? || user.password != SandDollar::Utilities.season_password(password, user.password_salt)
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


