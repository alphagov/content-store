require 'rails_helper'

describe UpdateLock, :type => :model do
  describe "initializing without a lockable instance" do
    let(:not_lockable) { double(:not_lockable) }

    it "raises an error" do
      expect { UpdateLock.new(not_lockable) }.to raise_error OutOfOrderTransmissionError
    end
  end

  describe "#check_availability!" do
    subject { UpdateLock.new(lockable) }

    context "for a nil item" do
      let(:lockable) { nil }

      it "does not raise an error" do
        expect {
          subject.check_availability!(2)
        }.to_not raise_error
      end
    end

    context "for a locked item" do
      let(:lockable) { double(:lockable, transmitted_at: "10") }
      it "raises an error when the lock is checked with a lesser value" do
        expect {
          subject.check_availability!(9)
        }.to raise_error(OutOfOrderTransmissionError, /has a newer/)
      end

      it "raises an error when the lock is checked with an equal value" do
        expect {
          subject.check_availability!(10)
        }.to raise_error(OutOfOrderTransmissionError, /has a newer/)
      end

      it "does not raise an error when the lock is checked with a greater value" do
        expect {
          subject.check_availability!(11)
        }.to_not raise_error
      end

      it "raises an error when the lock is checked against nil" do
        expect {
          subject.check_availability!(nil)
        }.to raise_error
      end

      it "coerces strings to integers" do
        expect {
          subject.check_availability!("11")
        }.to_not raise_error
      end
    end
  end
end
