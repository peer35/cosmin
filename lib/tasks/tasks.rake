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

  # task to clean out old guest users
  # rake devise_guests:delete_old_guest_users[days_old]
  # example cron entry to delete users older than 7 days at 2:00 AM every day:
  # 0 2 * * * cd /path/to/your/app && /path/to/rake devise_guests:delete_old_guest_users[7] RAILS_ENV=your_env
  desc "Removes entries in the users table for guest users that are older than the number of days given."
  task :delete_old_guest_users, [:days_old] => [:environment] do |t, args|
    args.with_defaults(days_old: 7)
    User
      .where("guest = ? and updated_at < ?", true, Time.now - args[:days_old].to_i.days)
      .find_each(batch_size: 1000, &:destroy)
  end

  # task to process proqolid instrument list
  # rake tasks:db:process_proqolid_list
  namespace :db do
    desc "Process proqolid instrument list"
    task process_list: :environment do
      require 'csv'
      records_to_update=[] # list of records that should be reindexed because of instrument changes
      listfile = 'proqolid_matching.csv'
      CSV.foreach('lib/tasks/eprovide/' + listfile,
                  encoding: "bom|utf-8",
                  headers: :first_row,
                  col_sep: ',',
                  :header_converters => lambda {|f| f.strip},
                  :converters => lambda {|f| f ? f.strip : nil}
      ) do |row|
        unless row['PROQOLID ID'].nil?
          instrument_id = row['COSMIN ID']
          puts 'processing instrument id ' + instrument_id
          instrument = Instrument.find_by(id: instrument_id)
          unless instrument.nil?
            old_url = instrument.url1
            # update columns does not trigger after_save
            instrument.update_columns(url1: row['PROQOLID URL'], proqolid_id: row['PROQOLID ID'])
            unless old_url == row['PROQOLID URL']
              puts instrument_id + ' is updated'
              records_to_update.concat(instrument.records)
            end
          end
        end
      end
      records_to_update.uniq.each do |record|
        # only index records that contain instruments that are actually changed
        puts 'indexing: ' + record.id.to_s
        record.delay.update_index
      end
    end
  end
end
