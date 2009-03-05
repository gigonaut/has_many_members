class Membership < ActiveRecord::Base
  
  # Relationships
  belongs_to :joinable, :polymorphic => true
  belongs_to :member, :foreign_key => :member_id
  
  validates_uniqueness_of :member_id, :scope => [:joinable_id, :joinable_type]
  validates_presence_of :status
  validates_presence_of :member_type
  
  before_create :do_defaults
  
  def member_parent
    joinable_type.to_s.constantize.find(joinable_id)
  end
  
  def do_defaults
    if member_type.blank?
      write_attribute(:member_type, "user")
    end
    if status.blank?
      write_attribute(:status, "active")
    end
    if default_membership
      Membership.update_all("default_membership = 0", ["joinable_type=? AND member_id=?", joinable_type, member_id])
    end
  end
  
  def only_one_default
    
    
  end
  
  
  
end
