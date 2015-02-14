module SandDollar
  module Default

    SESSION_LIFETIME = 1200

    TOKEN_LENGTH = 128

    VALID_STORAGE = [:none, :mongoid]

    STORAGE = VALID_STORAGE.first

    USER_MODEL = :user

  end
end
