require 'digest/md5'
require 'find'
require 'pairtree'
require 'pathname'
require 'ruby-progressbar'
require 'yaml'

class PackageValidator
  def initialize package
    @package = package
    config = YAML.load_file File.join('config', 'nodes.yml')
    aip_tree = Pairtree.at(config['aips'], create: true)
    @aip_path = aip_tree.get(@package.aip_identifier).path
    @sip_path = @package.sip_path
  end

  def valid?
    read_aip_checksums
    unless aip_consistent?
      return false
    end
    unless aip_complete?
      return false
    end
    true
  end

  def read_aip_checksums
    @aip = {}
    File.readlines(File.join(@aip_path, 'manifest-md5.txt')).each do |line|
      line.chomp!
      sum, file = line.split(/\s+data\//)
      @aip[file] = sum
    end
    @aip
  end

  def aip_consistent?
    @aip.each_pair do |file, aip_sum|
      sip_file = File.join(@sip_path, file)
      sip_sum = Digest::MD5.file(sip_file).hexdigest
      unless sip_sum == aip_sum
        return false
      end
    end
    true
  end

  def aip_complete?
    base = Pathname.new(@sip_path)
    Find.find(@sip_path).each do |path|
      if File.file?(path)
        key = Pathname.new(path).relative_path_from(base).to_s
        unless @aip.include? key
          return false
        end
      end
    end
    true
  end
end

class DipValidator
  def initialize package
    @package = package
    config = YAML.load_file File.join('config', 'nodes.yml')
    dip_tree = Pairtree.at(config['dips_test'], create: true)
    @dip_path = dip_tree.get(@package.dip_identifier).path
  end

  def valid?
    read_dip_checksums
    unless dip_complete?
      puts "DIP INCOMPLETE"
      return false
    end
    unless dip_consistent?
      puts "DIP INCONSISTENT"
      return false
    end
    true
  end

  def read_dip_checksums
    @dip = {}
    File.readlines(File.join(@dip_path, 'manifest-md5.txt')).each do |line|
      line.chomp!
      sum, file = line.split(/\s+data\//)
      @dip[file] = sum
    end
    @dip
  end

  def dip_consistent?
    @dip.each_pair do |file, expected_sum|
      path = File.join(@dip_path, 'data', file)
      dip_sum = Digest::MD5.file(path).hexdigest
      unless dip_sum == expected_sum
        puts "** inconsistent #{file}"
        return false
      end
    end
    true
  end

  def dip_complete?
    base = Pathname.new(@dip_path)
    @dip.each_pair do |file, expected_sum|
      path = File.join(@dip_path, 'data', file)
      unless File.exist?(path)
        puts "** missing #{file}"
        return false
      end
    end
    true
  end
end

namespace :batch do
  desc "Validate fixity of packages in a batch"
  task :validate => :environment do
    batch_id = ENV['BATCH_ID'].to_i
    batch = Batch.find(batch_id)
    if batch
      pb = ProgressBar.create( :format         => '%a %bᗧ%i %p%% %t',
                               :progress_mark  => ' ',
                               :remainder_mark => '･')
      pb.total = batch.packages.count
      pb.log "Validating batch #{batch.name} (#{batch_id})..."
      good = 0
      bad = 0
      batch.packages.each do |package|
        pv = PackageValidator.new package
        if pv.valid?
          pb.log "ok #{package.name} (#{package.aip_identifier})"
          good += 1
        else
          pb.log "NOT ok #{package.name} (#{package.aip_identifier})"
          bad += 1
        end
        pb.increment
      end
      puts "Validation of batch #{batch.name} (#{batch_id}) complete\nDone (good: #{good}, bad: #{bad}, total: #{pb.total})."
    else
      puts "No such batch (BATCH_ID: #{batch_id})"
    end
  end

  desc "Validate fixity of DIPs in progress"
  task :validate_dips => :environment do
    batch_id = ENV['BATCH_ID'].to_i
    batch = Batch.find(batch_id)
    if batch
      pb = ProgressBar.create( :format         => '%a %bᗧ%i %p%% %t',
                               :progress_mark  => ' ',
                               :remainder_mark => '･')
      packages = batch.packages.select {|p|
        p.tasks.where(:type_id => Type.store_test_dip.id, :status_id => Status.archived.id).count > 0
      }
      pb.total = packages.count
      pb.log "Validating batch #{batch.name} (#{batch_id})..."
      good = 0
      bad = 0
      packages.each do |package|
        pv = DipValidator.new package
        if pv.valid?
          pb.log "ok #{package.name} (#{package.dip_identifier})"
          good += 1
        else
          pb.log "NOT ok #{package.name} (#{package.dip_identifier})"
          bad += 1
        end
        pb.increment
      end
      puts "Validation of batch #{batch.name} (#{batch_id}) complete\nDone (good: #{good}, bad: #{bad}, total: #{pb.total})."
    else
      puts "No such batch (BATCH_ID: #{batch_id})"
    end
  end

  desc "Reset failed index tasks for a batch"
  task :reset_failed_index => :environment do
    batch_id = ENV['BATCH_ID'].to_i
    batch = Batch.find(batch_id)
    if batch
      batch.packages.each do |package|
        package.tasks.where(:type_id => [
                              Type.index_into_solr.id, 
                              Type.index_into_test_solr.id
                           ]).where(:status_id => Status.failed.id).each do |task|
          puts "Resetting failed index task: batch #{batch_id}, package #{package.id}, task #{task.id}"
          task.update_attributes(:status_id => Status.ready.id)
        end
      end
      puts "Done."
    else
      puts "No such batch (BATCH_ID: #{batch_id})"
    end
  end

  desc "Rebuild JSON and reindex a batch"
  task :reindex => :environment do
    batch_id = ENV['BATCH_ID'].to_i
    batch = Batch.find(batch_id)
    if batch
      batch.packages.each do |package|
        package.tasks.where('type_id > ?',
                              Type.create_solr_json.id)
        .each do |task|
          puts "Rolling back post-JSON tasks: batch #{batch_id}, package #{package.id}, task #{task.id}"
          task.destroy
        end

        package.tasks.where(:type_id =>
                              Type.create_solr_json.id)
        .each do |task|
          puts "Restarting JSON task: batch #{batch_id}, package #{package.id}, task #{task.id}"
          task.update_attribute(:status, Status.ready)
        end

        puts "Clearing approval for package #{package.id}"
        package.update_attribute(:status, Status.started)
      end
      puts "Clearing approval for batch #{batch_id}"
      batch.update_attribute(:status, Status.started)
    else
      puts "No such batch (BATCH_ID: #{batch_id})"
    end
  end
end
