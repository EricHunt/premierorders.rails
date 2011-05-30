require 'csv'
require 'bigdecimal'

module WeightLoader
  def self.load_weights
    updated = 0
    not_found = 0
    CSV.foreach("db/seed_data/weights.csv") do |row|
      part_id, weight = row
      if weight
        item = Item.find_by_purchase_part_id(part_id)
        if item #&& item.weight.nil?
          item.update_attribute(:weight, BigDecimal.new(weight))
          puts "#{part_id}  :  #{weight}"
          updated += 1
        else
          puts "Could not find item for purchase part id #{part_id}, or item weight is already set."
          not_found += 1
        end
      end
    end

    puts 'done'
    puts "Updated: #{updated}; not found: #{not_found}"
  end
end
