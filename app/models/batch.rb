class Batch < ActiveRecord::Base
  belongs_to :batch_type
  belongs_to :server
  belongs_to :status
  has_many :packages, dependent: :destroy
  attr_accessible :batch_type_id, :dark_archive, :discussion_link, :name, :oral_history, :reprocessing, :server_id, :status_id, :generate_dip_identifiers
  before_create :mark_as_started, :check_if_reprocessing
  after_create :create_packages
  before_update :check_status
  has_paper_trail

  has_many :tasks, through: :packages

  def failures
    self.tasks.where(status_id: Status.failed.id).count
  end

  def done?
    self.packages.select {|p|
      p.done?
    }.count == self.packages.count
  end

  def notify message
    if message
      method = "when_#{message.to_s.gsub(/\s+/, '_')}".to_sym
      if respond_to? method
        logger.debug "\nDEBUG batch #{self.id}: dispatching to #{method}"
        send(method)
      else
        logger.debug "\nDEBUG batch #{self.id}: can't dispatch to #{method}"
      end
    end
  end

  def mark_reviewed
    if self.status == Status.awaiting_approval
      self.update_attributes(:status_id => Status.under_review.id)
    end

    if enough_packages_approved?
      self.update_attributes(:status_id => Status.approved.id)
    end
  end

  private

  def mark_as_started
    self.status ||= Status.started
  end

  def check_if_reprocessing
    base = '/opt/pdp/services/staging/processing'
    reprocessing = File.join(
      base,
      self.name,
      'reprocessing.txt'
    )
    if File.file? reprocessing
      self.reprocessing = true
    end
  end

  def create_packages
    # find the right place for this
    base = '/opt/pdp/services/staging/processing'
    path = File.join(
      base,
      self.name,
      'sips'
    )
    sip_paths = Dir.glob("#{path}/*")
    m = {}
    if self.reprocessing
      repro = File.join(
        base,
        self.name,
        'reprocessing.txt'
      )
      if File.file? repro
        File.open(repro, 'r').each_line do |line|
          if line =~ /^[^#\ ]/
            line.strip!
            pieces = line.split(/\s+/)
            sip = pieces[2]
            m[sip] = {
              :dip => pieces[0],
              :aip => pieces[1],
            }
          end
        end
      end
    end
    sip_paths.each_with_index do |sip_path, i|
      h = {
        batch_id: self.id,
        sip_path: sip_path,
        oral_history: self.oral_history,
        dark_archive: self.dark_archive,
        generate_dip_identifiers: self.generate_dip_identifiers,
        reprocessing: self.reprocessing,
        approved: false,
        requires_approval: true
      }
      sip = File.basename(sip_path)
      if m.has_key? sip
        h[:dip_identifier] = m[sip][:dip]
        h[:aip_identifier] = m[sip][:aip]
      end
      Package.create(h)
    end
  end

  def check_status
    if self.status_id_changed?
      if self.status == Status.approved
        approve_packages
      end
    end
    
    if enough_packages_approved?
      self.status = Status.approved
      approve_packages
    end
  end

  def enough_packages_approved?
    self.packages.where(
      :requires_approval => true
    ).reject { |package|
      package.status == Status.approved
    }.empty?
  end

  def approve_packages
    return
    self.packages.where(status_id: [
      Status.awaiting_approval.id,
      Status.rejected.id, # XXX: deprecated
    ]).each do |package|
      package.update_attributes(
        :approved => true,
        :status_id => Status.approved.id,
      )
    end
  end
end
