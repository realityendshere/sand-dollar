module SandDollar::AuthenticationService
  module_function

  def authenticate_request(options, authenticators = nil)
    authenticators ||= [:sand_dollar_token, :sand_dollar_password]

    authenticators.map{|key|
      auth = SandDollar::Authenticators.load(key).new(options)
      if auth.valid?
        identity = auth.authenticate!
        identity.is_a?(SandDollar.configuration.user_model_class) ? identity : nil
      end
    }.compact.first
  end

  def authenticate_request!(*args)
    authenticate_request(*args) or raise SandDollar::AuthenticationFailed
  end

end
