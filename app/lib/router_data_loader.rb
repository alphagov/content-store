require "set"

module RouterDataLoader
  def self.load(path)
    routes = Set.new

    Dir.glob("#{path}/data/*.csv").each do |csv_path|
      CSV.foreach(csv_path) do |row|
        routes.add?(row[0].to_sym)
      end
    end
  end
end
