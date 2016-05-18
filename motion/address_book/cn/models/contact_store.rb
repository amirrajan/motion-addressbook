module AddressBook
  module CN
    class ContactStore
      def initialize(auto_connect = false)
        @native_ref = CNContactStore.new
        connect if auto_connect
        self
      end

      def connect(&after_connect)
        if connected?
          return (after_connect.nil? ? @native_ref : after_connect.call)
        end

        request_authorization do |success, error|
          after_connect.call if success && after_connect
        end
      end

      def connected?
        Authorization.granted?
      end

      # @param block [Proc] will receive one boolean argument indicating whether
      #   or not access to the address book was granted. If no block is given,
      #   this request will be blocking
      def request_authorization(&block)
        synchronous = !block

        Authorization.request do |granted, error|
          raise(error) if !granted && error
          @access_granted = granted
          block.call(@access_granted) unless block.nil?
        end

        # Wait on the asynchronous callback before returning.
        while(synchronous && @access_granted.nil?) do sleep 0.1 end

        @access_granted
      end

      ###############
      ## Accessors ##
      ###############

      # Groups

      def groups
        ensure_connection! do
          Accessors::Groups.index(@native_ref).map { |group| group_new(group) }
        end
      end

      def groups_count
        ensure_connection! { Accessors::Groups.count(@native_ref) }
      end

      def group_new(attributes)
        ensure_connection! { Group.new(attributes, @native_ref) }
      end

      def group_create(attributes)
        ensure_connection! { group_new(attributes).save }
      end

      def group_find(id)
        ensure_connection! do
          ab_group = Accessors::Groups.find(@native_ref, id)
          ab_group && group_new(ab_group)
        end
      end

      # People

      def contacts(options = {})
        ensure_connection! do
          Accessors::Contacts.index(@native_ref)
            .map { |cn_contact| contact_new(cn_contact) }
        end
      end
      alias :people :contacts

      def contacts_changed_since(timestamp)
        ensure_connection! do
          Accessors::Contacts.changed_since(@native_ref, timestamp)
        end
      end
      alias :people_changed_since :contacts_changed_since

      def contacts_count
        ensure_connection! { Accessors::Contacts.count(@native_ref) }
      end
      alias :people_count :contacts_count

      def contacts_where(conditions)
        ensure_connection! do
          contacts.select { |person| person.matches? conditions }
        end
      end
      alias :people_where :contacts_where

      def contact_new(attributes)
        ensure_connection! { Contact.new(attributes) }
      end
      alias :person_new :contact_new

      def contact_create(attributes)
        ensure_connection! { contact_new(attributes).save }
      end
      alias :person_create :contact_create

      def contact_find(id)
        ensure_connection! do
          cn_contact = Accessors::Contacts.find(@native_ref, id)
          cn_contact && contact_new(cn_contact)
        end
      end
      alias :person_find :contact_find

      # Sources

      def sources
        ensure_connection! do
          Accessors::Sources.index(@native_ref).map { |s| Source.new(s) }
        end
      end

      private

      def ensure_connection!(&after_connect)
        connected? ? after_connect.call : connect(&after_connect)
      end
    end
  end
end
