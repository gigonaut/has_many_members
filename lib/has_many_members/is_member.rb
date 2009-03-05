module IsMember
  
    def self.included( recipient )
      recipient.extend( ClassMethods )
    end
    
    module ClassMethods
      
      def is_member(options={})
        has_many :memberships, :foreign_key => :member_id
        
        include IsMember::InstanceMethods
      end
      
      
    end
    
    module InstanceMethods
      def is_member_of?(thing)
        !membership_for(thing).nil?
      end
      
      def membership_for(thing)
        memberships.find(:first, :conditions => {:joinable_type => thing.class.to_s, :joinable_id => thing.id})
      end
      
      def has_membership_in?(stuff=[])
        !memberships_for(stuff).empty
      end
      
      def memberships_for(stuff=[])
        conditions_array = []
        stuff.each do |i|
          conditions_array << "(joinable_type = '#{i.class.to_s}' AND joinable_id = #{i.id})"
        end
        memberships.find(:all, :conditions => conditions_array.join(" OR "))
      end
    end  
end