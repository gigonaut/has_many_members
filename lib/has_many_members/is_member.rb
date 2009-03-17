module IsMember
  
    def self.included( recipient )
      recipient.extend( ClassMethods )
    end
    
    module ClassMethods
      
      def is_member(options={})
        has_many :memberships, :foreign_key => :member_id
        options[:of].each do |thing|
          has_many thing, :through => :memberships, :as => :joinable, :source_type => thing.to_s.capitalize.singularize, :source => :joinable do
            def default
              find(:first, :conditions => ["memberships.default_membership=?", true]) || find(:first, :conditions => ["memberships.member_type=?", "admin"])
            end
          end
        end
        
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