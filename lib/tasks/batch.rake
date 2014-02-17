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
      puts "Done (good: #{good}, bad: #{bad}, total: #{pb.total})."
    else
      puts "No such batch (BATCH_ID: #{batch_id})"
    end
  end
end
