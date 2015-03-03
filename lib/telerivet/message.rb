module Telerivet

#
# Represents a single message.
# 
# Fields:
# 
#   - id (string, max 34 characters)
#       * ID of the message
#       * Read-only
#   
#   - direction
#       * Direction of the message: incoming messages are sent from one of your contacts to
#           your phone; outgoing messages are sent from your phone to one of your contacts
#       * Allowed values: incoming, outgoing
#       * Read-only
#   
#   - status
#       * Current status of the message
#       * Allowed values: ignored, processing, received, sent, queued, failed, failed_queued,
#           cancelled, delivered, not_delivered
#       * Read-only
#   
#   - message_type
#       * Type of the message
#       * Allowed values: sms, mms, ussd, call
#       * Read-only
#   
#   - source
#       * How the message originated within Telerivet
#       * Allowed values: phone, provider, web, api, service, webhook, scheduled
#       * Read-only
#   
#   - time_created (UNIX timestamp)
#       * The time that the message was created on Telerivet's servers
#       * Read-only
#   
#   - time_sent (UNIX timestamp)
#       * The time that the message was reported to have been sent (null for incoming messages
#           and messages that have not yet been sent)
#       * Read-only
#   
#   - from_number (string)
#       * The phone number that the message originated from (your number for outgoing
#           messages, the contact's number for incoming messages)
#       * Read-only
#   
#   - to_number (string)
#       * The phone number that the message was sent to (your number for incoming messages,
#           the contact's number for outgoing messages)
#       * Read-only
#   
#   - content (string)
#       * The text content of the message (null for USSD messages and calls)
#       * Read-only
#   
#   - starred (bool)
#       * Whether this message is starred in Telerivet
#       * Updatable via API
#   
#   - simulated (bool)
#       * Whether this message is was simulated within Telerivet for testing (and not actually
#           sent to or received by a real phone)
#       * Read-only
#   
#   - label_ids (array)
#       * List of IDs of labels applied to this message
#       * Read-only
#   
#   - vars (Hash)
#       * Custom variables stored for this message
#       * Updatable via API
#   
#   - error_message
#       * A description of the error encountered while sending a message. (This field is
#           omitted from the API response if there is no error message.)
#       * Updatable via API
#   
#   - external_id
#       * The ID of this message from an external SMS gateway provider (e.g. Twilio or Nexmo),
#           if available.
#       * Read-only
#   
#   - price (number)
#       * The price of this message, if known. By convention, message prices are negative.
#       * Read-only
#   
#   - price_currency
#       * The currency of the message price, if applicable.
#       * Read-only
#   
#   - mms_parts (array)
#       * A list of parts in the MMS message, the same as returned by the
#           [getMMSParts](#Message.getMMSParts) method.
#           
#           Note: This property is only present when retrieving an individual
#           MMS message by ID, not when querying a list of messages. In other cases, use
#           [getMMSParts](#Message.getMMSParts).
#       * Read-only
#   
#   - phone_id (string, max 34 characters)
#       * ID of the phone that sent or received the message
#       * Read-only
#   
#   - contact_id (string, max 34 characters)
#       * ID of the contact that sent or received the message
#       * Read-only
#   
#   - route_id (string, max 34 characters)
#       * ID of the route that sent the message (if applicable)
#       * Read-only
#   
#   - project_id
#       * ID of the project this contact belongs to
#       * Read-only
#
class Message < Entity

    #
    # Returns true if this message has a particular label, false otherwise.
    # 
    # Arguments:
    #   - label (Telerivet::Label)
    #       * Required
    #   
    # Returns:
    #     bool
    #
    def has_label?(label)
        load()
        return @label_ids_set.has_key?(label.id)
    end
      
    #
    # Adds a label to the given message.
    # 
    # Arguments:
    #   - label (Telerivet::Label)
    #       * Required
    #
    def add_label(label)
        @api.do_request("PUT", label.get_base_api_path() + "/messages/" + get('id'));
        @label_ids_set[label.id] = true
    end
    
    #
    # Removes a label from the given message.
    # 
    # Arguments:
    #   - label (Telerivet::Label)
    #       * Required
    #
    def remove_label(label)
        @api.do_request("DELETE", label.get_base_api_path() + "/messages/" + get('id'))
        if @label_ids_set.has_key?(label.id)
            @label_ids_set.delete(label.id)
        end
    end

    #
    # Retrieves a list of MMS parts for this message (empty for non-MMS messages).
    # 
    # Each MMS part in the list is an object with the following
    # properties:
    # 
    # - cid: MMS content-id
    # - type: MIME type
    # - filename: original filename
    # - size (int): number of bytes
    # - url: URL where the content for this part is stored (secret but
    # publicly accessible, so you could link/embed it in a web page without having to re-host it
    # yourself)
    # 
    # Returns:
    #     array
    #
    def get_mmsparts()
        return @api.do_request("GET", get_base_api_path() + "/mms_parts")
    end

    #
    # Saves any fields that have changed for this message.
    #
    def save()
        super
    end

    #
    # Resends a message, for example if the message failed to send or if it was not delivered. If
    # the message was originally in the queued, retrying, failed, or cancelled states, then
    # Telerivet will return the same message object. Otherwise, Telerivet will create and return a
    # new message object.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - route_id
    #         * ID of the phone or route to send the message from
    #   
    # Returns:
    #     Telerivet::Message
    #
    def resend(options = nil)
        require_relative 'message'
        Message.new(@api, @api.do_request("POST", get_base_api_path() + "/resend", options))
    end

    #
    # Cancels sending a message that has not yet been sent. Returns the updated message object.
    # Only valid for outgoing messages that are currently in the queued, retrying, or cancelled
    # states. For other messages, the API will return an error with the code 'not_cancellable'.
    # 
    # Returns:
    #     Telerivet::Message
    #
    def cancel()
        require_relative 'message'
        Message.new(@api, @api.do_request("POST", get_base_api_path() + "/cancel"))
    end

    #
    # Deletes this message.
    #
    def delete()
        @api.do_request("DELETE", get_base_api_path())
    end

    def id
        get('id')
    end

    def direction
        get('direction')
    end

    def status
        get('status')
    end

    def message_type
        get('message_type')
    end

    def source
        get('source')
    end

    def time_created
        get('time_created')
    end

    def time_sent
        get('time_sent')
    end

    def from_number
        get('from_number')
    end

    def to_number
        get('to_number')
    end

    def content
        get('content')
    end

    def starred
        get('starred')
    end

    def starred=(value)
        set('starred', value)
    end

    def simulated
        get('simulated')
    end

    def label_ids
        get('label_ids')
    end

    def error_message
        get('error_message')
    end

    def error_message=(value)
        set('error_message', value)
    end

    def external_id
        get('external_id')
    end

    def price
        get('price')
    end

    def price_currency
        get('price_currency')
    end

    def mms_parts
        get('mms_parts')
    end

    def phone_id
        get('phone_id')
    end

    def contact_id
        get('contact_id')
    end

    def route_id
        get('route_id')
    end

    def project_id
        get('project_id')
    end

    def get_base_api_path()
        "/projects/#{get('project_id')}/messages/#{get('id')}"
    end
 
    
    def set_data(data)
        super
        
        @label_ids_set = {}
        
        if data.has_key?('label_ids')
            data['label_ids'].each { |id| @label_ids_set[id] = true }
        end
    end

end

end
