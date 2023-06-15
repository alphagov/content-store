# TODO: after migration is complete, delete this
namespace :mongo do
  namespace :export do
    desc "export all collections to JSON files in the given path"
    task :all, %i[path] => :environment do
      MongoExporter.export_all(path:)
    end

    desc "export the given collection to JSON file in the given path"
    task :collection, %i[collection path] => [:environment] do |_, args|
      MongoExporter.export(collection: args[:collection], path: args[:path])
    end
  end
end
