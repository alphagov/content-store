require "content_dumper"

desc "Dump content"
task :dump_content, [:filename] => [:environment] do |_, args|
  raise "Missing filename." unless args[:filename]
  ContentDumper.new(args[:filename]).dump
end
