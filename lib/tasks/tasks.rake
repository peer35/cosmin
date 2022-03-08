namespace :tasks do
  desc "Reindex all records"
  task index: :environment do
    n = Record.count
    Record.all.each do |record|
      puts n
      record.delay.update_index
      n = n - 1
    end
  end
end
