require 'spec_helper'

describe SandDollar do
  describe "#configure" do
    before do
      SandDollar.configure do |config|
        config.drawing_count = 10
      end
    end

    it "configures" do
      expect(10).to eq(10)
    end
  end
end
