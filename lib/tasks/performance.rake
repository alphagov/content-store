namespace :performance do
  desc "
    Compare response sizes and times from two hosts,
    using a given file of request paths, one path per line
  "
  task :compare_hosts, %i[path_file host_1 host_2 output_file] => :environment do |_t, args|
    ResponseComparator.new(
      path_file: args[:path_file],
      host_1: args[:host_1],
      host_2: args[:host_2],
      output_file: args[:output_file],
    ).call
  end
end
