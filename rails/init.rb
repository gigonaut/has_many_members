require 'has-many-members'


ActiveRecord::Base.send :include, IsMember
ActiveRecord::Base.send :include, HasManyMembers

RAILS_DEFAULT_LOGGER.info "** has_many_members: initialized properly."
RAILS_DEFAULT_LOGGER.info "** is_member: initialized properly."