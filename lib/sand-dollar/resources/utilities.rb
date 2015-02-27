module SandDollar
  module Utilities

    module_function

    def season_password(password, salt)
      pw = password.to_s
      salt[0...-1*pw.bytesize] + pw
    end

  end
end
