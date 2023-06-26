require "rails_helper"

describe HashSorter do
  describe ".sort" do
    context "given a nested Hash" do
      let(:hash) do
        {
          z: "y",
          x: "zzz",
          b: {
            b1: "bb1",
            a1: "ba1",
          },
        }
      end

      it "returns a Hash with all keys in alphabetical order" do
        expect(HashSorter.sort(hash)).to eq(
          {
            b: {
              a1: "ba1",
              b1: "bb1",
            },
            x: "zzz",
            z: "y",
          },
        )
      end

      context "when the Hash contains arrays" do
        let(:hash) do
          {
            z: "y",
            x: "zzz",
            b: %w[zzz ccc aaa],
          }
        end

        it "returns a Hash with the array in the original order" do
          expect(HashSorter.sort(hash)).to eq(
            {
              b: %w[zzz ccc aaa],
              x: "zzz",
              z: "y",
            },
          )
        end
      end
    end
  end
end
