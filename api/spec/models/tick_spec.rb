require "./spec/spec_helper"
require "./models/tick"

describe Tick do
  let(:tick) { Tick.new(ticks: 2, updated_at: DateTime.now) }

  describe "attributes" do

    it "has a tick number" do
      expect(tick.ticks).to eq(2)
    end

    it "has a date of upate" do
      expect(tick.updated_at).to_not be_nil
    end

  end
end
