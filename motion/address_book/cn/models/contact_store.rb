module AddressBook
  module CN
    class ContactStore
      include Common::PublicInterface::ContactAccessor

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

      private

      def connected_contacts(options, &callback)
        Accessors::Contacts.index(@native_ref) do |contacts, error|
          raise error if error

          mapped_contacts =
            contacts.map { |cn_contact| connected_contacts_new(cn_contact) }

          callback.call(mapped_contacts)
        end
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
    end
  end
end
