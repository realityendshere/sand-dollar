module SandDollar
  class InvalidStorageConfig < Exception

    def to_s
      "Please choose a valid storage config #{SandDollar::Default::VALID_STORAGE}"
    end

  end

  class NotAuthorized < Exception

    def to_s
      "Not Authorized"
    end

  end

  class AuthenticationFailed < Exception

    def to_s
      "That username and password could not be authenticated."
    end

  end

  class InvalidRequest < Exception

    def to_s
      "Request authenticators must be instantiated with an instance of Rack::Request or ActionDispatch::Request"
    end

  end

end
