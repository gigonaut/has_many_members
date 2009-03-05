# HasManyMembers
module HasManyMembers
  
    def self.included( recipient )
      recipient.extend( ClassMethods )
    end
    
    module ClassMethods
      
      def has_many_members(options={:member_class => "User"})
        has_many :memberships, :as => :joinable
        has_many :members, :through => :memberships, :source => :member, :class_name => options[:member_class], :foreign_key => :member_id
        has_many :invited_members, :through => :memberships, :source => :member, :class_name => options[:member_class], :conditions => ["memberships.member_type=?","invited"]
        has_many :requested_members, :through => :memberships, :source => :member, :class_name => options[:member_class], :conditions => ["memberships.member_type=?","requested"]
        has_many :active_members, :through => :memberships, :source => :member, :class_name => options[:member_class], :conditions => ["memberships.member_type=? OR memberships.member_type=?","active", "admin"]
        has_many :admin_members, :through => :memberships, :source => :member, :class_name => options[:member_class], :conditions => ["memberships.member_type=?","admin"]
        
        after_create :adminify_creator

        def self.find_for_member(member, status=nil, member_types=[])
          unless member_types.is_a? Array
            member_types = [member_types]
          end
          if !(status.nil? && member_types.empty?)
            self.find(:all, :joins => :memberships, :conditions => {:memberships => {:member_id => member.id, :member_type => member_types.join(" OR "), :status => status}})
          elsif status.nil?
            self.find(:all, :joins => :memberships, :conditions => {:memberships => {:member_id => member.id, :member_type => member_types.join(" OR ")}})
          elsif member_types.empty?
            self.find(:all, :joins => :memberships, :conditions => {:memberships => {:member_id => member.id, :status => status}})
          end
        end
        
        def self.find_admin(member)
          self.find_for_member(member, "active", "admin")
        end
        
        def self.find_active(member)
          self.find_for_member(member, "active", ["user", "admin"])
        end
        
        def self.find_default(member)
          self.find_for_member(member, "active", ["user", "admin"]).first
        end
        
        def self.find_invited(member)
          self.find_for_member(member, "invited")
        end
        
        def self.find_requested(member)
          self.find_for_member(member, "requested")
        end
        
        def self.find_any_for(member)
          self.find_for_member(member, nil, ["admin", "active", "requested", "invited"])
        end

        
        include HasManyMembers::InstanceMethods
      end
    end
    
    module InstanceMethods
      
      # checker methods
      def has_member?(member)
        is_member?(member)
      end
      
      def is_member?(member)
        active_members.include? member
      end
      
      def editable_by?(member)
        if member.has_role?(:admin)
          true
        elsif self.creator_id == member.id
          true
        elsif active_members.include? member
          true
        else
          false
        end
      end
      
      def postable_by?(member)
        editable_by?(member) || public? ? true : false
      end
      
      def joinable_by?(member)
        if editable_by?
          false
        elsif public?
          true
        else
          false
        end
      end
      
      def requestable_by?(member)
        true
      end
      
      def public?
        if self.attributes.include?(:public)
          logger.info("method public output #{read_attribute(:public)}")
          read_attribute(:public)
        else
          false
        end
      end
      
      # Management methods
      
      def adminify_creator
        if self.respond_to? :creator_id
          u = User.find(creator_id)
          make_admin!(u)
        else
          false
        end
      end
      
      def make_admin(member)
        make_membership(member, "admin")
      end
      
      def make_admin!(member)
        make_membership(member, "admin").save
      end
      
      def make_default(member)
        make_membership(member, "admin", "active", true)
      end
      
      def make_default!(member)
        make_default(member).save
      end
      
      def demote_admin(member)
        membership_for(member).update_attributes({:member_type => "user"})
      end
      
      def invite_member(member)
        make_membership(member, "user", "invited")
      end
      
      def invite_member!(member)
        make_membership(member, "user", "invited").save
      end
      
      def send_request(member)
        make_membership(member, "user", "requested")
      end
      
      def send_request!(member)
        make_membership(member, "user", "requested").save
      end
      
      def accept_member(member)
        membership_for(member).update_attributes({:status => "active"})
      end
      
      def decline_member(member)
        membership_for(member).destroy
      end
      
      def make_membership(member, member_type="user", status="active", default=false)
        if membership_for(member).nil?
          memberships.build({:member_id => member.id, :member_type => member_type, :status => status, :default_membership => default})
        else
          return_val = membership_for(member)
          return_val.member_type = member_type
          return_val.status = status
          return_val.default_membership = default
          return_val
        end
      end
      
      def make_membership!(member, member_type="user", status="active")
        make_membership(member, status).save
      end
      
      def make_memberships(u_arr=[])
        return_val = []
        u_arr.each do |u|
          return_val << make_membership(u)
        end
        return_val
      end
      
      def make_memberships!(u_arr=[])
        make_memberships(u_arr).each {|m| m.save}
      end
      
      def membership_for(member)
        memberships.find_by_member_id(member.id)
      end
      
    end  
end