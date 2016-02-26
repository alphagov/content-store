require 'rails_helper'

describe UpdateLock, type: :model do
  describe "initializing without a lockable instance" do
    let(:not_lockable) { double(:not_lockable) }

    it "raises an error" do
      expect { UpdateLock.new(not_lockable) }.to raise_error ArgumentError
    end
  end

  describe "#check_availability!" do
    subject { UpdateLock.new(lockable) }

    context "for a nil item" do
      let(:lockable) { nil }

      it "does not raise an error" do
        expect {
          subject.check_availability!(transmitted_at: "1")
        }.to_not raise_error
      end
    end

    context "for a locked item" do
      let(:lockable) {
        double(
          :lockable,
          transmitted_at: "10",
          payload_version: "20"

        )
      }
      context "with neither transmitted_at or payload_version" do
        let(:attributes) { {} }
        it "raises an error" do
          expect {
            subject.check_availability!(attributes)
          }.to raise_error(
            MissingAttributeError
          )
        end
      end

      context "with transmitted_at" do
        context "where existing is higher" do
          let(:attributes) { { transmitted_at: "9" } }

          it "raises an error" do
            expect {
              subject.check_availability!(attributes)
            }.to raise_error(
              OutOfOrderTransmissionError,
              /has a newer \(or equal\) transmitted_at/
            )
          end
        end

        context "where existing is equal" do
          let(:attributes) { { transmitted_at: "10" } }

          it "raises an error" do
            expect {
              subject.check_availability!(attributes)
            }.to raise_error(
              OutOfOrderTransmissionError,
              /has a newer \(or equal\) transmitted_at/
            )
          end
        end

        context "where existing is lower" do
          let(:attributes) { { transmitted_at: "12" } }
          it "does not raise an error" do
            expect {
              subject.check_availability!(attributes)
            }.to_not raise_error
          end
        end
      end

      context "with payload_version" do
        context "where existing is higher" do
          let(:attributes) { { payload_version: "19" } }

          it "raises an error" do
            expect {
              subject.check_availability!(attributes)
            }.to raise_error(
              OutOfOrderTransmissionError,
              /has a newer \(or equal\) payload_version/
            )
          end
        end

        context "where existing is equal" do
          let(:attributes) { { payload_version: "20" } }

          it "raises an error" do
            expect {
              subject.check_availability!(attributes)
            }.to raise_error(
              OutOfOrderTransmissionError,
              /has a newer \(or equal\) payload_version/)
          end
        end

        context "where existing is lower" do
          let(:attributes) { { payload_version: "21" } }
          it "does not raise an error" do
            expect {
              subject.check_availability!(attributes)
            }.to_not raise_error
          end
        end
      end

      context "with both transmitted_at and payload_version" do
        let(:attributes) { { transmitted_at: "5", payload_version: "21" } }
        it "prefers payload_version does not raise" do
          expect {
            subject.check_availability!(attributes)
          }.to_not raise_error
        end
      end
    end
  end
end
