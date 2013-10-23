class Batch < ActiveRecord::Base
  belongs_to :batch_type
  belongs_to :server
  belongs_to :status
  has_many :packages, dependent: :destroy
  attr_accessible :batch_type_id, :dark_archive, :discussion_link, :name, :oral_history, :reprocessing, :server_id, :status_id
  before_create :mark_as_started
  after_create :create_packages
  before_update :check_status
  has_paper_trail

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

  def create_packages
    # find the right place for this
    base = '/opt/pdp/services/staging/processing'
    path = File.join(
      base,
      self.name,
      'sips'
    )
    limit = 100
    sip_paths = Dir.glob("#{path}/*")
    tickets = (1..sip_paths.count).to_a.shuffle
    sip_paths.each_with_index do |sip_path, i|
      Package.create(
        batch_id: self.id,
        sip_path: sip_path,
        oral_history: self.oral_history,
        dark_archive: self.dark_archive,
        reprocessing: self.reprocessing,
        approved: false,
        requires_approval: tickets[i] <= limit
      )
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
    self.packages.where(status_id: [
      Status.awaiting_approval.id,
      Status.rejected.id,
    ]).each do |package|
      package.update_attributes(
        :approved => true,
        :status_id => Status.approved.id,
      )
    end
  end
end
