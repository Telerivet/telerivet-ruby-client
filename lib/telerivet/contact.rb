module Telerivet

#
# Fields:
# 
#   - id (string, max 34 characters)
#       * ID of the contact
#       * Read-only
#   
#   - name
#       * Name of the contact
#       * Updatable via API
#   
#   - phone_number (string)
#       * Phone number of the contact
#       * Updatable via API
#   
#   - time_created (UNIX timestamp)
#       * Time the contact was added in Telerivet
#       * Read-only
#   
#   - time_updated (UNIX timestamp)
#       * Time the contact was last updated in Telerivet
#       * Read-only
#   
#   - send_blocked (bool)
#       * True if Telerivet is blocked from sending messages to this contact
#       * Updatable via API
#   
#   - conversation_status
#       * Current status of the conversation with this contact
#       * Allowed values: closed, active, handled
#       * Updatable via API
#   
#   - last_message_time (UNIX timestamp)
#       * Last time the contact sent or received a message (null if no messages have been sent
#           or received)
#       * Read-only
#   
#   - last_incoming_message_time (UNIX timestamp)
#       * Last time a message was received from this contact
#       * Read-only
#   
#   - last_outgoing_message_time (UNIX timestamp)
#       * Last time a message was sent to this contact
#       * Read-only
#   
#   - message_count (int)
#       * Total number of non-deleted messages sent to or received from this contact
#       * Read-only
#   
#   - incoming_message_count (int)
#       * Number of messages received from this contact
#       * Read-only
#   
#   - outgoing_message_count (int)
#       * Number of messages sent to this contact
#       * Read-only
#   
#   - last_message_id
#       * ID of the last message sent to or received from this contact (null if no messages
#           have been sent or received)
#       * Read-only
#   
#   - default_route_id
#       * ID of the phone or route that Telerivet will use by default to send messages to this
#           contact (null if using project default route)
#       * Updatable via API
#   
#   - group_ids (array of strings)
#       * List of IDs of groups that this contact belongs to
#       * Read-only
#   
#   - vars (Hash)
#       * Custom variables stored for this contact
#       * Updatable via API
#   
#   - project_id
#       * ID of the project this contact belongs to
#       * Read-only
#
class Contact < Entity

    #
    # Returns true if this contact is in a particular group, false otherwise.
    # 
    # Arguments:
    #   - group (Telerivet::Group)
    #       * Required
    #   
    # Returns:
    #     bool
    #
    def is_in_group?(group)
        load()
        return @group_ids_set.has_key?(group.id)
    end
      
    #
    # Adds this contact to a group.
    # 
    # Arguments:
    #   - group (Telerivet::Group)
    #       * Required
    #
    def add_to_group(group)
        @api.do_request("PUT", group.get_base_api_path() + "/contacts/" + get('id'));
        @group_ids_set[group.id] = true
    end
    
    #
    # Removes this contact from a group.
    # 
    # Arguments:
    #   - group (Telerivet::Group)
    #       * Required
    #
    def remove_from_group(group)
        @api.do_request("DELETE", group.get_base_api_path() + "/contacts/" + get('id'))
        if @group_ids_set.has_key?(group.id)
            @group_ids_set.delete(group.id)
        end
    end

    #
    # Queries messages sent or received by this contact.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - direction
    #         * Filter messages by direction
    #         * Allowed values: incoming, outgoing
    #     
    #     - message_type
    #         * Filter messages by message_type
    #         * Allowed values: sms, mms, ussd, call, service
    #     
    #     - source
    #         * Filter messages by source
    #         * Allowed values: phone, provider, web, api, service, webhook, scheduled,
    #             integration
    #     
    #     - starred (bool)
    #         * Filter messages by starred/unstarred
    #     
    #     - status
    #         * Filter messages by status
    #         * Allowed values: ignored, processing, received, sent, queued, failed,
    #             failed_queued, cancelled, delivered, not_delivered
    #     
    #     - time_created[min] (UNIX timestamp)
    #         * Filter messages created on or after a particular time
    #     
    #     - time_created[max] (UNIX timestamp)
    #         * Filter messages created before a particular time
    #     
    #     - external_id
    #         * Filter messages by ID from an external provider
    #     
    #     - contact_id
    #         * ID of the contact who sent/received the message
    #     
    #     - phone_id
    #         * ID of the phone (basic route) that sent/received the message
    #     
    #     - broadcast_id
    #         * ID of the broadcast containing the message
    #     
    #     - scheduled_id
    #         * ID of the scheduled message that created this message
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default
    #         * Default: default
    #     
    #     - sort_dir
    #         * Sort the results in ascending or descending order
    #         * Allowed values: asc, desc
    #         * Default: asc
    #     
    #     - page_size (int)
    #         * Number of results returned per page (max 500)
    #         * Default: 50
    #     
    #     - offset (int)
    #         * Number of items to skip from beginning of result set
    #         * Default: 0
    #   
    # Returns:
    #     Telerivet::APICursor (of Telerivet::Message)
    #
    def query_messages(options = nil)
        require_relative 'message'
        @api.cursor(Message, get_base_api_path() + "/messages", options)
    end

    #
    # Queries groups for which this contact is a member.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter groups by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
    #     
    #     - dynamic (bool)
    #         * Filter groups by dynamic/non-dynamic
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, name
    #         * Default: default
    #     
    #     - sort_dir
    #         * Sort the results in ascending or descending order
    #         * Allowed values: asc, desc
    #         * Default: asc
    #     
    #     - page_size (int)
    #         * Number of results returned per page (max 500)
    #         * Default: 50
    #     
    #     - offset (int)
    #         * Number of items to skip from beginning of result set
    #         * Default: 0
    #   
    # Returns:
    #     Telerivet::APICursor (of Telerivet::Group)
    #
    def query_groups(options = nil)
        require_relative 'group'
        @api.cursor(Group, get_base_api_path() + "/groups", options)
    end

    #
    # Queries messages scheduled to this contact (not including messages scheduled to groups that
    # this contact is a member of)
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - message_type
    #         * Filter scheduled messages by message_type
    #         * Allowed values: sms, mms, ussd, call, service
    #     
    #     - time_created (UNIX timestamp)
    #         * Filter scheduled messages by time_created
    #         * Allowed modifiers: time_created[ne], time_created[min], time_created[max]
    #     
    #     - next_time (UNIX timestamp)
    #         * Filter scheduled messages by next_time
    #         * Allowed modifiers: next_time[exists], next_time[ne], next_time[min],
    #             next_time[max]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, name
    #         * Default: default
    #     
    #     - sort_dir
    #         * Sort the results in ascending or descending order
    #         * Allowed values: asc, desc
    #         * Default: asc
    #     
    #     - page_size (int)
    #         * Number of results returned per page (max 500)
    #         * Default: 50
    #     
    #     - offset (int)
    #         * Number of items to skip from beginning of result set
    #         * Default: 0
    #   
    # Returns:
    #     Telerivet::APICursor (of Telerivet::ScheduledMessage)
    #
    def query_scheduled_messages(options = nil)
        require_relative 'scheduledmessage'
        @api.cursor(ScheduledMessage, get_base_api_path() + "/scheduled", options)
    end

    #
    # Queries data rows associated with this contact (in any data table).
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - time_created (UNIX timestamp)
    #         * Filter data rows by the time they were created
    #         * Allowed modifiers: time_created[ne], time_created[min], time_created[max]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default
    #         * Default: default
    #     
    #     - sort_dir
    #         * Sort the results in ascending or descending order
    #         * Allowed values: asc, desc
    #         * Default: asc
    #     
    #     - page_size (int)
    #         * Number of results returned per page (max 500)
    #         * Default: 50
    #     
    #     - offset (int)
    #         * Number of items to skip from beginning of result set
    #         * Default: 0
    #   
    # Returns:
    #     Telerivet::APICursor (of Telerivet::DataRow)
    #
    def query_data_rows(options = nil)
        require_relative 'datarow'
        @api.cursor(DataRow, get_base_api_path() + "/rows", options)
    end

    #
    # Queries this contact's current states for any service
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - id
    #         * Filter states by id
    #         * Allowed modifiers: id[ne], id[prefix], id[not_prefix], id[gte], id[gt], id[lt],
    #             id[lte]
    #     
    #     - vars (Hash)
    #         * Filter states by value of a custom variable (e.g. vars[email], vars[foo], etc.)
    #         * Allowed modifiers: vars[foo][exists], vars[foo][ne], vars[foo][prefix],
    #             vars[foo][not_prefix], vars[foo][gte], vars[foo][gt], vars[foo][lt], vars[foo][lte],
    #             vars[foo][min], vars[foo][max]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default
    #         * Default: default
    #     
    #     - sort_dir
    #         * Sort the results in ascending or descending order
    #         * Allowed values: asc, desc
    #         * Default: asc
    #     
    #     - page_size (int)
    #         * Number of results returned per page (max 500)
    #         * Default: 50
    #     
    #     - offset (int)
    #         * Number of items to skip from beginning of result set
    #         * Default: 0
    #   
    # Returns:
    #     Telerivet::APICursor (of Telerivet::ContactServiceState)
    #
    def query_service_states(options = nil)
        require_relative 'contactservicestate'
        @api.cursor(ContactServiceState, get_base_api_path() + "/states", options)
    end

    #
    # Saves any fields or custom variables that have changed for this contact.
    #
    def save()
        super
    end

    #
    # Deletes this contact.
    #
    def delete()
        @api.do_request("DELETE", get_base_api_path())
    end

    def id
        get('id')
    end

    def name
        get('name')
    end

    def name=(value)
        set('name', value)
    end

    def phone_number
        get('phone_number')
    end

    def phone_number=(value)
        set('phone_number', value)
    end

    def time_created
        get('time_created')
    end

    def time_updated
        get('time_updated')
    end

    def send_blocked
        get('send_blocked')
    end

    def send_blocked=(value)
        set('send_blocked', value)
    end

    def conversation_status
        get('conversation_status')
    end

    def conversation_status=(value)
        set('conversation_status', value)
    end

    def last_message_time
        get('last_message_time')
    end

    def last_incoming_message_time
        get('last_incoming_message_time')
    end

    def last_outgoing_message_time
        get('last_outgoing_message_time')
    end

    def message_count
        get('message_count')
    end

    def incoming_message_count
        get('incoming_message_count')
    end

    def outgoing_message_count
        get('outgoing_message_count')
    end

    def last_message_id
        get('last_message_id')
    end

    def default_route_id
        get('default_route_id')
    end

    def default_route_id=(value)
        set('default_route_id', value)
    end

    def group_ids
        get('group_ids')
    end

    def project_id
        get('project_id')
    end

    def get_base_api_path()
        "/projects/#{get('project_id')}/contacts/#{get('id')}"
    end
 
    
    def set_data(data)
        super
        
        @group_ids_set = {}
        
        if data.has_key?('group_ids')
            data['group_ids'].each { |id| @group_ids_set[id] = true }
        end
    end

end

end
