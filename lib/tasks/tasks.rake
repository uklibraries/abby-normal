namespace :tasks do
  desc "Retry failing tasks"
  task :retry => :environment do
    index_type_ids = Type.where(
      name: ["Index into Test Solr", "Index into Solr"]
    ).collect {|ty| ty.id}

    Task.where(
      status_id: Status.failed.id
    ).reject {|t|
      index_type_ids.include? t.type_id
    }.each {|t|
      puts "Retrying failing task #{t}"
      t.status = Status.ready
      t.save
    }

    #t = Task.order("RAND()").where(
    ts = Task.order("id").where(
        status_id: Status.failed.id,
        type_id: index_type_ids
    ).take(4)

    ts.each do |t|
      if t
        puts "Retrying failing task #{t}"
        t.status = Status.ready
        t.save
      end
    end
  end
end
