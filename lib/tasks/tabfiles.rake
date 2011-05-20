require ::Rails.root.to_s + '/db/seed_loader.rb'

namespace :tabfile do
  task :dump => :environment do
    SeedLoader.new.dump_tab_file('parts_premier.tab')
  end
end
