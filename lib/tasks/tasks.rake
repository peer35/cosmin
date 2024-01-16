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
end
