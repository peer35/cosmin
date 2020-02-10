instrument_list = []
Record.all.each do |record|
  record.instrument.each do |ins|
    exists = false
    unless instrument_list.include? ins
      instrument_list.append(ins)
      @ins = Instrument.create({name: ins})
    else
      puts ins
      puts 'exists'
      exists = true
      puts record.id
      @ins = Instrument.where(name: ins).first
      puts @ins.id
    end
    if exists
      puts 'before'
      puts @ins.record_ids
    end
    @ins.records << record
    if exists
      puts 'after'
      puts @ins.record_ids
    end
  end
end
#puts instrument_list
puts instrument_list.count