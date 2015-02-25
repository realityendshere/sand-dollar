module SandDollar::AuthenticationService
  NotAuthorized = Class.new(Exception)
  AuthenticationFailed = Class.new(Exception)

  module_function

  def valid_identification_provided?(identification)
    identification.to_s.length > 0
  end

  def valid_identification_provided!(*args)
    valid_identification_provided?(*args) or raise AuthenticationFailed
  end

  def authenticate_with_password(user, attempt)
    user && user.password == SandDollar::Utilities.season_password(attempt, user.password_salt)
  end

  def authenticate_with_password!(*args)
    authenticate_with_password(*args) or raise AuthenticationFailed
  end

  # def authenticate_with_api_key(user, key, current_token)
  #   user && key && current_token && OpenSSL::Digest::SHA256.new("#{user.username}:#{user.api_secret}:#{current_token}") == key
  # end

  # def authenticate_with_api_key!(*args)
  #   authenticate_with_api_key(*args) or raise NotAuthorized
  # end

  def season_password(password, salt)
    salt[0...-1*password.bytesize] + password
  end

end
