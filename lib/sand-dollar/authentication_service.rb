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

end
