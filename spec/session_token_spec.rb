require 'spec_helper'
require 'delorean'

class APISessionToken
  include SandDollar::SessionToken::Base
end

describe SandDollar::SessionToken do
  after do
    SandDollar.reset_configuration
    Delorean.back_to_the_present
  end

  describe 'initialize' do
    context "When using default token length" do
      let(:subject) { APISessionToken.new() }

      it "automatically generates a token" do
        expect(subject.token.length).to eq(SandDollar::Default::TOKEN_LENGTH)
      end
    end

    context "When using configured token length" do
      before do
        SandDollar.configure do |config|
          config.token_length = 512
        end
      end

      let(:subject) { APISessionToken.new() }

      it "automatically generates a token of the configured length" do
        expect(subject.token.length).to eq(512)
      end
    end
  end

  describe ".updated_at" do
    context "When checking a new session" do
      let(:subject) { APISessionToken.new() }
      it "returns a recent timestamp" do
        t = Time.now
        expect(t-1...t+1).to cover(subject.updated_at)
      end
    end
  end

  describe "#session_lifetime" do
    context "When using the default config" do
      it "returns the default session_lifetime" do
        expect(APISessionToken.session_lifetime).to eq(SandDollar::Default::SESSION_LIFETIME)
      end
    end

    context "When using a custom config" do
      before do
        SandDollar.configure do |config|
          config.session_lifetime = life
        end
      end

      let(:life) { 9000 }
      it "returns the specified session_lifetime" do
        expect(APISessionToken.session_lifetime).to eq(life)
      end
    end

  end

  describe ".ttl" do
    context "When using the default config" do
      let(:life) { SandDollar::Default::SESSION_LIFETIME }

      it "returns approximately the default session_lifetime" do
        subject = APISessionToken.new()
        expect(life-1...life).to cover(subject.ttl)
      end

      it "returns a smaller number as time passes" do
        subject = APISessionToken.new()
        Delorean.jump(life - 20)
        expect(19...21).to cover(subject.ttl)
      end
    end

    context "When using a custom config" do
      before do
        SandDollar.configure do |config|
          config.session_lifetime = life
        end
      end

      let(:life) { 120 }

      it "returns approximately the specified session_lifetime" do
        subject = APISessionToken.new()
        expect(life-1...life).to cover(subject.ttl)
      end

      it "returns a smaller number as time passes" do
        subject = APISessionToken.new()
        Delorean.jump(life - 20)
        expect(19...21).to cover(subject.ttl)
      end
    end

  end

  describe ".expired?/alive?" do

    context "When using the default config" do

      let(:life) { SandDollar::Default::SESSION_LIFETIME }

      it "returns true/false after #{SandDollar::Default::SESSION_LIFETIME} seconds" do
        subject = APISessionToken.new()

        expect(subject.expired?).to eq(false)
        expect(subject.alive?).to eq(true)

        Delorean.jump(life - 20)

        expect(subject.expired?).to eq(false)
        expect(subject.alive?).to eq(true)

        Delorean.back_to_the_present
        Delorean.jump(life + 1)

        expect(subject.expired?).to eq(true)
        expect(subject.alive?).to eq(false)
      end
    end

    context "When using a custom config" do
      before do
        SandDollar.configure do |config|
          config.session_lifetime = life
        end
      end

      let(:life) { 120 }

      it "returns true/false after the configured number of seconds" do
        subject = APISessionToken.new()

        expect(subject.expired?).to eq(false)
        expect(subject.alive?).to eq(true)

        Delorean.jump(life - 20)

        expect(subject.expired?).to eq(false)
        expect(subject.alive?).to eq(true)

        Delorean.back_to_the_present
        Delorean.jump(life + 1)

        expect(subject.expired?).to eq(true)
        expect(subject.alive?).to eq(false)
      end
    end

  end

end
