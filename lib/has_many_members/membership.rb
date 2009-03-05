class Membership < ActiveRecord::Base
  
  # Relationships
  belongs_to :joinable, :polymorphic => true
  belongs_to :member, :foreign_key => :member_id
  
  validates_uniqueness_of :member_id, :scope => [:joinable_id, :joinable_type]
  validates_presence_of :status
  validates_presence_of :member_type
  
  before_save :do_membership_type
  
  def member_parent
    joinable_type.to_s.constantize.find(joinable_id)
  end
  
  def do_membership_type
    if member_type.blank?
      write_attribute(:member_type, "basic")
    end
    if status.blank?
      write_attribute(:active)
    end
  end
  
end
