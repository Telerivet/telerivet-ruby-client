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
#           cancelled, delivered, not_delivered, read
#       * Read-only
#   
#   - message_type
#       * Type of the message
#       * Allowed values: sms, mms, ussd, ussd_session, call, chat, service
#       * Read-only
#   
#   - source
#       * How the message originated within Telerivet
#       * Allowed values: phone, provider, web, api, service, webhook, scheduled, integration
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
#   - time_updated (UNIX timestamp)
#       * The time that the message was last updated in Telerivet.
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
#       * Whether this message was simulated within Telerivet for testing (and not actually
#           sent to or received by a real phone)
#       * Read-only
#   
#   - label_ids (array)
#       * List of IDs of labels applied to this message
#       * Read-only
#   
#   - route_params (Hash)
#       * Route-specific parameters for the message.
#           
#           When sending messages via chat apps such as WhatsApp, the route_params
#           parameter can be used to send messages with app-specific features such as quick
#           replies and link buttons.
#           
#           For more details, see [Route-Specific Parameters](#route_params).
#       * Read-only
#   
#   - vars (Hash)
#       * Custom variables stored for this message. Variable names may be up to 32 characters
#           in length and can contain the characters a-z, A-Z, 0-9, and _.
#           Values may be strings, numbers, or boolean (true/false).
#           String values may be up to 4096 bytes in length when encoded as UTF-8.
#           Up to 100 variables are supported per object.
#           Setting a variable to null will delete the variable.
#       * Updatable via API
#   
#   - priority (int)
#       * Priority of this message. Telerivet will attempt to send messages with higher
#           priority numbers first. Only defined for outgoing messages.
#       * Read-only
#   
#   - error_message
#       * A description of the error encountered while sending a message. (This field is
#           omitted from the API response if there is no error message.)
#       * Updatable via API
#   
#   - error_code
#       * A route-specific error code encountered while sending a message. The error code
#           values depend on the provider and may be described in the provider's API
#           documentation. Error codes may be strings or numbers, depending on the provider. (This
#           field is omitted from the API response if there is no error code.)
#       * Read-only
#   
#   - external_id
#       * The ID of this message from an external SMS gateway provider (e.g. Twilio or
#           Vonage), if available.
#       * Read-only
#   
#   - num_parts (number)
#       * The number of SMS parts associated with the message, if applicable and if known.
#       * Read-only
#   
#   - price (number)
#       * The price of this message, if known.
#       * Read-only
#   
#   - price_currency
#       * The currency of the message price, if applicable.
#       * Read-only
#   
#   - duration (number)
#       * The duration of the call in seconds, if known, or -1 if the call was not answered.
#       * Read-only
#   
#   - ring_time (number)
#       * The length of time the call rang in seconds before being answered or hung up, if
#           known.
#       * Read-only
#   
#   - audio_url
#       * For voice calls, the URL of an MP3 file to play when the contact answers the call
#       * Read-only
#   
#   - tts_lang
#       * For voice calls, the language of the text-to-speech voice
#       * Allowed values: en-US, en-GB, en-GB-WLS, en-AU, en-IN, da-DK, nl-NL, fr-FR, fr-CA,
#           de-DE, is-IS, it-IT, pl-PL, pt-BR, pt-PT, ru-RU, es-ES, es-US, sv-SE
#       * Read-only
#   
#   - tts_voice
#       * For voice calls, the text-to-speech voice
#       * Allowed values: female, male
#       * Read-only
#   
#   - track_clicks (boolean)
#       * If true, URLs in the message content are short URLs that redirect to a destination
#           URL.
#       * Read-only
#   
#   - short_urls (array)
#       * For text messages containing short URLs, this is an array of objects with the
#           properties `short_url`, `link_type`, `time_clicked` (the first time that URL was
#           clicked), and `expiration_time`. If `link_type` is "redirect", the object also
#           contains a `destination_url` property. If `link_type` is "media", the object also
#           contains an `media_index` property (the index in the media array). If `link_type` is
#           "service", the object also contains a `service_id` property. This property is
#           undefined for messages that do not contain short URLs.
#       * Read-only
#   
#   - network_code (string)
#       * A string identifying the network that sent or received the message, if known. For
#           mobile networks, this string contains the 3-digit mobile country code (MCC) followed
#           by the 2- or 3-digit mobile network code (MNC), which results in a 5- or 6-digit
#           number. For lists of mobile network operators and their corresponding MCC/MNC values,
#           see [Mobile country code Wikipedia
#           article](https://en.wikipedia.org/wiki/Mobile_country_code). The network_code property
#           may be non-numeric for messages not sent via mobile networks.
#       * Read-only
#   
#   - media (array)
#       * For text messages containing media files, this is an array of objects with the
#           properties `url`, `type` (MIME type), `filename`, and `size` (file size in bytes).
#           Unknown properties are null. This property is undefined for messages that do not
#           contain media files. Note: For files uploaded via the Telerivet web app, the URL is
#           temporary and may not be valid for more than 1 day.
#       * Read-only
#   
#   - mms_parts (array)
#       * A list of parts in the MMS message (only for incoming MMS messages received via
#           Telerivet Gateway Android app).
#           
#           Each MMS part in the list is an object with the following
#           properties:
#           
#           - cid: MMS content-id
#           - type: MIME type
#           - filename: original filename
#           - size (int): number of bytes
#           - url: URL where the content for this part is stored (secret but
#           publicly accessible, so you could link/embed it in a web page without having to
#           re-host it yourself)
#           
#           In general, the `media` property of the message is recommended for
#           retrieving information about MMS media files, instead of `mms_parts`.
#           The `mms_parts` property is also only present when retrieving an
#           individual MMS message by ID, not when querying a list of messages.
#       * Read-only
#   
#   - time_clicked (UNIX timestamp)
#       * If the message contains any short URLs, this is the first time that a short URL in
#           the message was clicked.  This property is undefined for messages that do not contain
#           short URLs.
#       * Read-only
#   
#   - service_id (string, max 34 characters)
#       * ID of the service that handled the message (for voice calls, the service defines the
#           call flow)
#       * Read-only
#   
#   - phone_id (string, max 34 characters)
#       * ID of the phone (basic route) that sent or received the message
#       * Read-only
#   
#   - contact_id (string, max 34 characters)
#       * ID of the contact that sent or received the message
#       * Read-only
#   
#   - route_id (string, max 34 characters)
#       * ID of the custom route that sent the message (if applicable)
#       * Read-only
#   
#   - broadcast_id (string, max 34 characters)
#       * ID of the broadcast that this message is part of (if applicable)
#       * Read-only
#   
#   - scheduled_id (string, max 34 characters)
#       * ID of the scheduled message that created this message is part of (if applicable)
#       * Read-only
#   
#   - user_id (string, max 34 characters)
#       * ID of the Telerivet user who sent the message (if applicable)
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
    # (Deprecated) Retrieves a list of MMS parts for this message (only for incoming MMS messages
    # received via Telerivet Gateway Android app).
    # Note: This only works for MMS messages received via the Telerivet
    # Gateway Android app.
    # In general, the `media` property of the message is recommended for
    # retrieving information about MMS media files.
    # 
    # The return value has the same format as the `mms_parts` property of
    # the Message object.
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

    def time_updated
        get('time_updated')
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

    def route_params
        get('route_params')
    end

    def priority
        get('priority')
    end

    def error_message
        get('error_message')
    end

    def error_message=(value)
        set('error_message', value)
    end

    def error_code
        get('error_code')
    end

    def external_id
        get('external_id')
    end

    def num_parts
        get('num_parts')
    end

    def price
        get('price')
    end

    def price_currency
        get('price_currency')
    end

    def duration
        get('duration')
    end

    def ring_time
        get('ring_time')
    end

    def audio_url
        get('audio_url')
    end

    def tts_lang
        get('tts_lang')
    end

    def tts_voice
        get('tts_voice')
    end

    def track_clicks
        get('track_clicks')
    end

    def short_urls
        get('short_urls')
    end

    def network_code
        get('network_code')
    end

    def media
        get('media')
    end

    def mms_parts
        get('mms_parts')
    end

    def time_clicked
        get('time_clicked')
    end

    def service_id
        get('service_id')
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

    def broadcast_id
        get('broadcast_id')
    end

    def scheduled_id
        get('scheduled_id')
    end

    def user_id
        get('user_id')
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
