module SandDollar
  module Default

    SESSION_LIFETIME = 1200

    TOKEN_LENGTH = 128

    VALID_STORAGE = [:none, :mongoid, :redis]

    STORAGE = VALID_STORAGE.first

    USER_MODEL = :user

    AUTHENTICATORS = [:sand_dollar_token, :sand_dollar_password]

  end
end
