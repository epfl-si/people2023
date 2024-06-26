# frozen_string_literal: true

# Implement `./bin/rake devel:clean` and `./bin/rake devel:realclean`

namespace :devel do
  desc 'Delete all generated files'
  task clean: :environment do
    Dir.chdir(Rails.root)
    Rake::Task['javascript:clobber'].invoke

    ['node_modules', 'vendor/bundle'].each do |dir|
      FileUtils.remove_dir(dir) if File.exist?(dir)
    end

    Rake::Task['tmp:clear'].invoke
    (['tmp/development_secret.txt', 'tmp/restart.txt'] +
     Dir.glob('app/assets/builds/*')).each do |path|
      File.delete(path) if File.exist?(path)
    end
  end

  desc "Delete gen'd files and the test databases"
  task realclean: :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['devel:clean'].invoke
  end
end
