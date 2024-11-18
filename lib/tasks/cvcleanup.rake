# frozen_string_literal: true

require 'net/http'
require Rails.root.join('app/services/application_service').to_s
require Rails.root.join('app/services/api_accreds_getter').to_s

namespace :data do
  desc 'Remove all inactive people from the legacy CV database'
  task cvcleanup: :environment do
    tcache = 'tmp/active_scipers.txt'
    jcache = 'tmp/active_accreds.json'
    if File.exist?(tcache)
      active_scipers = File.readlines(tcache).map(&:chomp).map(&:to_i)
    else
      active_scipers = if File.exist?(jcache)
                         JSON.parse(File.read(jcache))['accreds'].map { |a| a['persid'] }.uniq
                       else
                         APIAccredsGetter.all.fetch.map { |a| a['persid'].to_i }.sort.uniq
                       end
      File.write(tcache, active_scipers.join("\n"))
    end
    puts "There are #{active_scipers.count} active scipers"

    models = [
      Legacy::AccredPref, Legacy::Achievement, Legacy::Award, Legacy::Box,
      Legacy::Cv, Legacy::Education, Legacy::Experience, Legacy::Publication,
      Legacy::SocialId, Legacy::TranslatedCv
    ]

    models.each do |model|
      scipers = model.distinct.pluck(:sciper).map(&:to_i)
      delenda = scipers - active_scipers
      puts """
        There are #{scipers.count} scipers in table #{model.table_name}
        for model #{model.name}, #{delenda.count} of which are deletable
      """
      model.where(sciper: delenda).delete_all
    end
  end
end

namespace :data do
  desc 'Stats of remaning legacy data that will have to be migrated'
  task cvstats: :environment do
    models = [
      Legacy::Achievement, Legacy::Award, Legacy::Cv, Legacy::Education,
      Legacy::Experience, Legacy::Publication, Legacy::SocialId
    ]

    models.each do |model|
      puts "#{model.name}:"
      puts "  table: #{model.table_name}"
      puts "  records: #{model.count}"
    end
    model = Legacy::Box
    c = model.where("content != '' and content is not NULL").count
    puts "#{model.name}:"
    puts "  table: #{model.table_name}"
    puts "  records: #{model.count} of which with content: #{c}"

    model = Legacy::TranslatedCv
    s1 = "curriculum != '' and curriculum is not NULL"
    s2 = "expertise != '' and expertise is not NULL"
    s3 = "mission != '' and mission is not NULL"
    c1 = model.where(s1).count
    c2 = model.where(s2).count
    c3 = model.where(s3).count
    c  = model.where("#{s1} or #{s2} or #{s3}").count
    puts "#{model.name}:"
    puts "  table: #{model.table_name}"
    puts "  records: #{model.count} of which with content: #{c} (#{c1} curriculum, #{c2} expertise, #{c3} mission)"
  end
end

# VPSI/people2 >make restore_cv
# ./bin/restoredb.sh cv
# make cvcleanup
# docker compose exec webapp ./bin/rails data:cvcleanup
# There are 29814 active scipers
# There are 13988 scipers in accreds table, 9164 of which are deletable
# There are 22 scipers in achievements table, 1 of which are deletable
# There are 264 scipers in awards table, 48 of which are deletable
# There are 30711 scipers in boxes table, 20668 of which are deletable
# There are 31672 scipers in common table, 21561 of which are deletable
# There are 2253 scipers in edu table, 1559 of which are deletable
# There are 821 scipers in parcours table, 546 of which are deletable
# There are 2467 scipers in publications table, 1808 of which are deletable
# There are 8584 scipers in research_ids table, 2742 of which are deletable
# There are 186865 scipers in teachingact table, 164538 of which are deletable
# There are 30735 scipers in cv table, 20688 of which are deletable

# VPSI/people2 >dc exec webapp ./bin/rails data:cvstats
# Legacy::Achievement:
#   table: achievements
#   records: 77
# Legacy::Award:
#   table: awards
#   records: 679
# Legacy::Cv:
#   table: common
#   records: 10111
# Legacy::Education:
#   table: edu
#   records: 1663
# Legacy::Experience:
#   table: parcours
#   records: 993
# Legacy::Publication:
#   table: publications
#   records: 4718
# Legacy::SocialId:
#   table: research_ids
#   records: 26390
# Legacy::Box:
#   table: boxes
#   records: 122561 of which with content: 6750
# Legacy::TranslatedCv:
#   table: cv
#   records: 19393 of which with content: 2023 (601 curriculum, 1746 expertise, 379 mission)
