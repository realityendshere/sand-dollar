module SandDollar
  module Utilities

    module_function

    def season_password(password, salt)
      salt[0...-1*password.bytesize] + password
    end

  end
end
