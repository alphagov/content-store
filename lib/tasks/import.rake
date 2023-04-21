namespace :import do
  task json: :environment do |t, args|
    JsonImporter.new(model_class: args.extras[0], file: args.extras[1]).call()
  end
end