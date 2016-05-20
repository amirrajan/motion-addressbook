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

      def groups(&callback)
        with_connection(:connected_groups, &callback)
      end

      def groups_count(&callback)
        with_connection(:connected_groups_count, &callback)
      end

      def group_new(attributes, &callback)
        with_connection(:connected_groups_new, attributes, &callback)
      end

      def group_create(attributes, &callback)
        with_connection(:connected_groups_create, attributes, &callback)
      end

      def group_find(id, &callback)
        with_connection(:connected_groups_find, id, &callback)
      end

      # People

      def contacts(options = {}, &callback)
        with_connection(:connected_contacts, options, &callback)
      end
      alias :people :contacts

      def contacts_changed_since(timestamp, &callback)
        with_connection(:connected_contacts_changed_since, timestamp, &callback)
      end
      alias :people_changed_since :contacts_changed_since

      def contacts_count(&callback)
        with_connection(:connected_contacts_count, &callback)
      end
      alias :people_count :contacts_count

      def contacts_where(conditions, &callback)
        with_connection(:connected_contacts_where, conditions, &callback)
      end
      alias :people_where :contacts_where

      def contact_new(attributes, &callback)
        with_connection(:connected_contacts_new, attributes, &callback)
      end
      alias :person_new :contact_new

      def contact_create(attributes, &callback)
        with_connection(:connected_contacts_create, attributes, &callback)
      end
      alias :person_create :contact_create

      def contact_find(id, &callback)
        with_connection(:connected_contacts_find, id, &callback)
      end
      alias :person_find :contact_find

      # Sources

      def sources(&callback)
        with_connection(:connected_sources_index, &callback)
      end

      private

      def connected_contacts(options)
        Accessors::Contacts.index(@native_ref)
          .map { |cn_contact| connected_contacts_new(cn_contact) }
      end

      def connected_contacts_changed_since(timestamp)
        Accessors::Contacts.changed_since(@native_ref, timestamp)
      end

      def connected_contacts_count
        Accessors::Contacts.count(@native_ref)
      end

      def connected_contacts_create(attributes)
        connected_contacts_new(attributes).save
      end

      def connected_contacts_new(attributes)
        Contact.new(attributes)
      end

      def connected_contacts_find(id)
        cn_contact = Accessors::Contacts.find(@native_ref, id)
        cn_contact && connected_contacts_new(cn_contact)
      end

      def connected_contacts_where(conditions)
        connected_contacts.select { |person| person.matches? conditions }
      end

      def connected_groups
        Accessors::Groups.index(@native_ref).map { |group| group_new(group) }
      end

      def connected_groups_count
        Accessors::Groups.count(@native_ref)
      end

      def connected_groups_new(attributes)
        Group.new(attributes, @native_ref)
      end

      def connected_groups_create(attributes)
        group_new(attributes).save
      end

      def connected_groups_find(id)
        ab_group = Accessors::Groups.find(@native_ref, id)
        ab_group && group_new(ab_group)
      end

      def connected_sources_index
        Accessors::Sources.index(@native_ref)
          .map { |source| Source.new(source) }
      end

      def ensure_connection!(&after_connect)
        connected? ? after_connect.call : connect(&after_connect)
      end

      def with_connection(method_name, *args, &callback)
        ensure_connection! { callback.call(send(method_name, *args)) }
      end
    end
  end
end
