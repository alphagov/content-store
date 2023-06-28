require "rails_helper"

describe HashSorter do
  describe ".sort" do
    let(:links) do
      {
        group_2: [
          { base_path: "/group-1/link-1", api_path: "/api/content/group-1/link-1" },
          { base_path: "/group-1/link-2", api_path: "/api/content/group-1/link-2" },
          { base_path: "/group-1/link-3", api_path: "/api/content/group-1/link-3" },
        ],
        group_1: [
          { base_path: "/group-2/link-3", api_path: "/api/content/group-2/link-3" },
          { base_path: "/group-2/link-2", api_path: "/api/content/group-2/link-2" },
          { base_path: "/group-2/link-1", api_path: "/api/content/group-2/link-1" },
        ],
      }
    end
    let(:result) { described_class.sort(links) }

    it "sorts the top-level keys" do
      expect(result.keys).to eq(%i[group_1 group_2])
    end

    it "does not sort the arrays" do
      expect(result[:group_1].map { |e| e[:base_path] }).to eq(links[:group_1].map { |e| e[:base_path] })
    end

    it "sorts the keys on Hashes within arrays" do
      %i[group_1 group_2].each do |group|
        result[group].each do |hash|
          expect(hash.keys).to eq(hash.keys.sort)
        end
      end
    end
  end
end
