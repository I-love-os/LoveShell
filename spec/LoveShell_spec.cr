require "spec"
require "../src/historian"

describe Historian do
  describe "#getPosition" do
    it "should equal -1" do
      historian = Historian.new
      historian.getPosition.should eq -1
    end
  end
end
