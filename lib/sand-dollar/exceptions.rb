module SandDollar
  class InvalidStorageConfig < Exception

    def to_s
      "Please choose a valid storage config #{SandDollar::Default::VALID_STORAGE}"
    end

  end

end
