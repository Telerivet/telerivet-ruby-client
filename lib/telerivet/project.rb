
module Telerivet

#
# Represents a Telerivet project.
# 
# Provides methods for sending and scheduling messages, as well as
# accessing, creating and updating a variety of entities, including contacts, messages,
# scheduled messages, groups, labels, phones, services, and data tables.
# 
# Fields:
# 
#   - id (string, max 34 characters)
#       * ID of the project
#       * Read-only
#   
#   - name
#       * Name of the project
#       * Updatable via API
#   
#   - timezone_id
#       * Default TZ database timezone ID; see [List of tz database time zones Wikipedia
#           article](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
#       * Updatable via API
#   
#   - url_slug
#       * Unique string used as a component of the project's URL in the Telerivet web app
#       * Updatable via API
#   
#   - default_route_id
#       * The ID of a basic route or custom route that will be used to send messages by
#           default (via both the API and web app), unless a particular route ID is specified when
#           sending the message.
#       * Updatable via API
#   
#   - auto_create_contacts (bool)
#       * If true, a contact will be automatically created for each unique phone number that a
#           message is sent to or received from. If false, contacts will not automatically be
#           created (unless contact information is modified by an automated service). The
#           Conversations tab in the web app will only show messages that are associated with a
#           contact.
#       * Updatable via API
#   
#   - vars (Hash)
#       * Custom variables stored for this project
#       * Updatable via API
#   
#   - organization_id (string, max 34 characters)
#       * ID of the organization this project belongs to
#       * Read-only
#
class Project < Entity
    #
    # Sends one message (SMS, MMS, chat app message, voice call, or USSD request).
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - message_type
    #         * Type of message to send. If `text`, will use the default text message type for the
    #             selected route.
    #         * Allowed values: text, sms, mms, ussd, call, chat, service
    #         * Default: text
    #     
    #     - content
    #         * Content of the message to send (if `message_type` is `call`, the text will be
    #             spoken during a text-to-speech call)
    #         * Required if sending SMS message
    #     
    #     - to_number (string)
    #         * Phone number to send the message to
    #         * Required if contact_id not set
    #     
    #     - contact_id
    #         * ID of the contact to send the message to
    #         * Required if to_number not set
    #     
    #     - route_id
    #         * ID of the phone or route to send the message from
    #         * Default: default sender route ID for your project
    #     
    #     - status_url
    #         * Webhook callback URL to be notified when message status changes
    #     
    #     - status_secret
    #         * POST parameter 'secret' passed to status_url
    #     
    #     - replace_variables (bool)
    #         * Set to true to evaluate variables like [[contact.name]] in message content. [(See
    #             available variables)](#variables) (`is_template` parameter also accepted)
    #         * Default: false
    #     
    #     - track_clicks (boolean)
    #         * If true, URLs in the message content will automatically be replaced with unique
    #             short URLs.
    #         * Default: false
    #     
    #     - short_link_params (Hash)
    #         *
    #             If `track_clicks` is true, `short_link_params` may be used to specify
    #             custom parameters for each short link in the message. The following parameters are
    #             supported:
    #             
    #             `domain` (string): A custom short domain name to use for the short
    #             links. The domain name must already be registered for your project or organization.
    #             
    #             `expiration_sec` (integer): The number of seconds after the message is
    #             created (queued to send) when the short links will stop forwarding to the
    #             destination URL.
    #             If null, the short links will not expire.
    #     
    #     - media_urls (array)
    #         * URLs of media files to attach to the text message. If `message_type` is `sms`,
    #             short links to each media URL will be appended to the end of the content (separated
    #             by a new line).
    #     
    #     - route_params (Hash)
    #         * Route-specific parameters for the message. The parameters object should have one
    #             or more keys matching the `phone_type` field of a phone (basic route) that may be
    #             used to send the message. The corresponding value should be an object with
    #             route-specific parameters to use if the message is sent by that type of route.
    #     
    #     - label_ids (array)
    #         * List of IDs of labels to add to this message
    #     
    #     - vars (Hash)
    #         * Custom variables to store with the message
    #     
    #     - priority (int)
    #         * Priority of the message. Telerivet will attempt to send messages with higher
    #             priority numbers first (for example, so you can prioritize an auto-reply ahead of a
    #             bulk message to a large group).
    #         * Allowed values: 1, 2
    #         * Default: 1
    #     
    #     - simulated (bool)
    #         * Set to true to test the Telerivet API without actually sending a message from the
    #             route
    #         * Default: false
    #     
    #     - service_id
    #         * Service that defines the call flow of the voice call (when `message_type` is
    #             `call`)
    #     
    #     - audio_url
    #         * The URL of an MP3 file to play when the contact answers the call (when
    #             `message_type` is `call`).
    #             
    #             If `audio_url` is provided, the text-to-speech voice is not used to say
    #             `content`, although you can optionally use `content` to indicate the script for the
    #             audio.
    #             
    #             For best results, use an MP3 file containing only speech. Music is not
    #             recommended because the audio quality will be low when played over a phone line.
    #     
    #     - tts_lang
    #         * The language of the text-to-speech voice (when `message_type` is `call`)
    #         * Allowed values: en-US, en-GB, en-GB-WLS, en-AU, en-IN, da-DK, nl-NL, fr-FR, fr-CA,
    #             de-DE, is-IS, it-IT, pl-PL, pt-BR, pt-PT, ru-RU, es-ES, es-US, sv-SE
    #         * Default: en-US
    #     
    #     - tts_voice
    #         * The name of the text-to-speech voice (when message_type=call)
    #         * Allowed values: female, male
    #         * Default: female
    #   
    # Returns:
    #     Telerivet::Message
    #
    def send_message(options)
        require_relative 'message'
        Message.new(@api, @api.do_request("POST", get_base_api_path() + "/messages/send", options))
    end

    #
    # Sends a text message (optionally with mail-merge templates) or voice call to a group or a
    # list of up to 500 phone numbers.
    # 
    # With `message_type`=`service`, invokes an automated service (such as
    # a poll) for a group or list of phone numbers. Any service that can be triggered for a
    # contact can be invoked via this method, whether or not the service actually sends a message.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - message_type
    #         * Type of message to send. If `text`, will use the default text message type for the
    #             selected route.
    #         * Allowed values: text, sms, mms, call, chat, service
    #         * Default: text
    #     
    #     - content
    #         * Content of the message to send
    #         * Required if sending SMS message
    #     
    #     - group_id
    #         * ID of the group to send the message to
    #         * Required if to_numbers not set
    #     
    #     - to_numbers (array of strings)
    #         * List of up to 500 phone numbers to send the message to
    #         * Required if group_id not set
    #     
    #     - route_id
    #         * ID of the phone or route to send the message from
    #         * Default: default sender route ID
    #     
    #     - title (string)
    #         * Title of the broadcast. If a title is not provided, a title will automatically be
    #             generated from the recipient group name or phone numbers.
    #     
    #     - status_url
    #         * Webhook callback URL to be notified when message status changes
    #     
    #     - status_secret
    #         * POST parameter 'secret' passed to status_url
    #     
    #     - label_ids (array)
    #         * Array of IDs of labels to add to all messages sent (maximum 5). Does not apply
    #             when `message_type`=`service`, since the labels are determined by the service
    #             itself.
    #     
    #     - exclude_contact_id
    #         * Optionally excludes one contact from receiving the message (only when group_id is
    #             set)
    #     
    #     - replace_variables (bool)
    #         * Set to true to evaluate variables like [[contact.name]] in message content [(See
    #             available variables)](#variables) (`is_template` parameter also accepted)
    #         * Default: false
    #     
    #     - track_clicks (boolean)
    #         * If true, URLs in the message content will automatically be replaced with unique
    #             short URLs.
    #         * Default: false
    #     
    #     - short_link_params (Hash)
    #         *
    #             If `track_clicks` is true, `short_link_params` may be used to specify
    #             custom parameters for each short link in the message. The following parameters are
    #             supported:
    #             
    #             `domain` (string): A custom short domain name to use for the short
    #             links. The domain name must already be registered for your project or organization.
    #             
    #             `expiration_sec` (integer): The number of seconds after the message is
    #             created (queued to send) when the short links will stop forwarding to the
    #             destination URL.
    #             If null, the short links will not expire.
    #     
    #     - media_urls (array)
    #         * URLs of media files to attach to the text message. If `message_type` is `sms`,
    #             short links to each URL will be appended to the end of the content (separated by a
    #             new line).
    #     
    #     - vars (Hash)
    #         * Custom variables to set for each message
    #     
    #     - route_params (Hash)
    #         * Route-specific parameters for the messages in the broadcast. The parameters object
    #             may have keys matching the `phone_type` field of a phone (basic route) that may be
    #             used to send messages in this broadcast. The corresponding value is an object with
    #             route-specific parameters to use when sending messages with that type of route.
    #     
    #     - service_id
    #         * Service to invoke for each recipient (when `message_type` is `call` or `service`)
    #         * Required if message_type is service
    #     
    #     - audio_url
    #         * The URL of an MP3 file to play when the contact answers the call (when
    #             `message_type` is `call`).
    #             
    #             If `audio_url` is provided, the text-to-speech voice is not used to say
    #             `content`, although you can optionally use `content` to indicate the script for the
    #             audio.
    #             
    #             For best results, use an MP3 file containing only speech. Music is not
    #             recommended because the audio quality will be low when played over a phone line.
    #     
    #     - tts_lang
    #         * The language of the text-to-speech voice (when `message_type` is `call`)
    #         * Allowed values: en-US, en-GB, en-GB-WLS, en-AU, en-IN, da-DK, nl-NL, fr-FR, fr-CA,
    #             de-DE, is-IS, it-IT, pl-PL, pt-BR, pt-PT, ru-RU, es-ES, es-US, sv-SE
    #         * Default: en-US
    #     
    #     - tts_voice
    #         * The name of the text-to-speech voice (when message_type=call)
    #         * Allowed values: female, male
    #         * Default: female
    #   
    # Returns:
    #     Telerivet::Broadcast
    #
    def send_broadcast(options)
        require_relative 'broadcast'
        Broadcast.new(@api, @api.do_request("POST", get_base_api_path() + "/send_broadcast", options))
    end

    #
    # Sends up to 100 different messages in a single API request. This method is significantly
    # faster than sending a separate API request for each message.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - messages (array)
    #         * Array of up to 100 objects with `content` and `to_number` properties. Each object
    #             may also contain the optional properties `status_url`, `status_secret`, `vars`,
    #             and/or `priority`, which override the parameters of the same name defined below, to
    #             allow passing different values for each message.
    #         * Required
    #     
    #     - message_type
    #         * Type of message to send. If `text`, will use the default text message type for the
    #             selected route.
    #         * Allowed values: text, sms, mms, call, chat, service
    #         * Default: text
    #     
    #     - route_id
    #         * ID of the phone or route to send the messages from
    #         * Default: default sender route ID
    #     
    #     - broadcast_id (string)
    #         * ID of an existing broadcast to associate the messages with
    #     
    #     - broadcast_title (string)
    #         * Title of broadcast to create (when `broadcast_id` is not provided).
    #             When sending more than 100 messages over multiple API
    #             requests, you can associate all messages with the same broadcast by providing a
    #             `broadcast_title` parameter in the first
    #             API request, then retrieving the `broadcast_id` property
    #             from the API response, and passing it as the `broadcast_id` parameter in subsequent
    #             API requests.
    #     
    #     - status_url
    #         * Webhook callback URL to be notified when message status changes
    #     
    #     - status_secret
    #         * POST parameter 'secret' passed to status_url
    #     
    #     - label_ids (array)
    #         * Array of IDs of labels to add to each message (maximum 5)
    #     
    #     - replace_variables (bool)
    #         * Set to true to evaluate variables like [[contact.name]] in message content [(See
    #             available variables)](#variables) (`is_template` parameter also accepted)
    #         * Default: false
    #     
    #     - track_clicks (boolean)
    #         * If true, URLs in the message content will automatically be replaced with unique
    #             short URLs.
    #         * Default: false
    #     
    #     - short_link_params (Hash)
    #         *
    #             If `track_clicks` is true, `short_link_params` may be used to specify
    #             custom parameters for each short link in the message. The following parameters are
    #             supported:
    #             
    #             `domain` (string): A custom short domain name to use for the short
    #             links. The domain name must already be registered for your project or organization.
    #             
    #             `expiration_sec` (integer): The number of seconds after the message is
    #             created (queued to send) when the short links will stop forwarding to the
    #             destination URL.
    #             If null, the short links will not expire.
    #     
    #     - media_urls (array)
    #         * URLs of media files to attach to the text message. If `message_type` is `sms`,
    #             short links to each media URL will be appended to the end of the content (separated
    #             by a new line).
    #     
    #     - route_params (Hash)
    #         * Route-specific parameters to apply to all messages. The parameters object may have
    #             keys matching the `phone_type` field of a phone (basic route) that may be used to
    #             send messages. The corresponding value is an object with route-specific parameters
    #             to use when sending messages with that type of route.
    #     
    #     - vars (Hash)
    #         * Custom variables to store with the message
    #     
    #     - priority (int)
    #         * Priority of the message. Telerivet will attempt to send messages with higher
    #             priority numbers first (for example, so you can prioritize an auto-reply ahead of a
    #             bulk message to a large group).
    #         * Allowed values: 1, 2
    #         * Default: 1
    #     
    #     - simulated (bool)
    #         * Set to true to test the Telerivet API without actually sending a message from the
    #             route
    #         * Default: false
    #   
    # Returns:
    #     (associative array)
    #       - messages (array)
    #           * List of objects representing each newly created message, with the same length
    #               and order as provided in the `messages` parameter in the API request.
    #               Each object has the `id` and `status` properties,
    #               and may have the property `error_message`.
    #               (Other properties of the Message object are
    #               omitted in order to reduce the amount of redundant data sent in each API
    #               response.)
    #               If the `messages` parameter in the API request
    #               contains items with `to_number` values that are associated with blocked contacts,
    #               the `id` and `status` properties corresponding to those items will be null, and no
    #               messages will be sent to those numbers.
    #       
    #       - broadcast_id
    #           * ID of broadcast that these messages are associated with, if `broadcast_id` or
    #               `broadcast_title` parameter is provided in the API request.
    #
    def send_multi(options)
        data = @api.do_request("POST", get_base_api_path() + "/send_multi", options)
        return data
    end

    #
    # (Deprecated) Send a message a to group or a list of phone numbers.
    # This method is only needed to maintain backward compatibility with
    # code developed using previous versions of the client library.
    # Use `sendBroadcast` or `sendMulti` instead.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - message_type
    #     
    #     - content
    #         * Required
    #     
    #     - group_id
    #     
    #     - to_numbers
    #   
    # Returns:
    #     (associative array)
    #       - count_queued (int)
    #           * Number of messages queued to send
    #       
    #       - broadcast_id
    #           * ID of broadcast created for this message batch.
    #
    def send_messages(options)
        data = @api.do_request("POST", get_base_api_path() + "/messages/send_batch", options)
        return data
    end

    #
    # Schedules a message to a group or single contact. Note that Telerivet only sends scheduled
    # messages approximately once every 15 seconds, so it is not possible to control the exact
    # second at which a scheduled message is sent.
    # 
    # Only one of the parameters group_id, to_number, and contact_id
    # should be provided.
    # 
    # With `message_type`=`service`, schedules an automated service (such
    # as a poll) to be invoked for a group or list of phone numbers. Any service that can be
    # triggered for a contact can be scheduled via this method, whether or not the service
    # actually sends a message.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - message_type
    #         * Type of message to send
    #         * Allowed values: text, sms, mms, ussd, call, chat, service
    #         * Default: text
    #     
    #     - content
    #         * Content of the message to schedule
    #         * Required if sending text message
    #     
    #     - group_id
    #         * ID of the group to send the message to
    #     
    #     - to_number (string)
    #         * Phone number to send the message to
    #     
    #     - contact_id (string)
    #         * ID of the contact to send the message to
    #     
    #     - start_time (UNIX timestamp)
    #         * The time that the message will be sent (or first sent for recurring messages)
    #         * Required if start_time_offset not set
    #     
    #     - start_time_offset (int)
    #         * Number of seconds from now until the message is sent
    #         * Required if start_time not set
    #     
    #     - rrule
    #         * A recurrence rule describing the how the schedule repeats, e.g. 'FREQ=MONTHLY' or
    #             'FREQ=WEEKLY;INTERVAL=2'; see <https://tools.ietf.org/html/rfc2445#section-4.3.10>.
    #             (UNTIL is ignored; use end_time parameter instead).
    #         * Default: COUNT=1 (one-time scheduled message, does not repeat)
    #     
    #     - route_id
    #         * ID of the phone or route to send the message from
    #         * Default: default sender route ID
    #     
    #     - service_id
    #         * Service to invoke for each recipient (when `message_type` is `call` or `service`)
    #         * Required if message_type is service
    #     
    #     - audio_url
    #         * The URL of an MP3 file to play when the contact answers the call (when
    #             `message_type` is `call`).
    #             
    #             If `audio_url` is provided, the text-to-speech voice is not used to say
    #             `content`, although you can optionally use `content` to indicate the script for the
    #             audio.
    #             
    #             For best results, use an MP3 file containing only speech. Music is not
    #             recommended because the audio quality will be low when played over a phone line.
    #     
    #     - tts_lang
    #         * The language of the text-to-speech voice (when `message_type` is `call`)
    #         * Allowed values: en-US, en-GB, en-GB-WLS, en-AU, en-IN, da-DK, nl-NL, fr-FR, fr-CA,
    #             de-DE, is-IS, it-IT, pl-PL, pt-BR, pt-PT, ru-RU, es-ES, es-US, sv-SE
    #         * Default: en-US
    #     
    #     - tts_voice
    #         * The name of the text-to-speech voice (when message_type=call)
    #         * Allowed values: female, male
    #         * Default: female
    #     
    #     - track_clicks (boolean)
    #         * If true, URLs in the message content will automatically be replaced with unique
    #             short URLs.
    #         * Default: false
    #     
    #     - short_link_params (Hash)
    #         *
    #             If `track_clicks` is true, `short_link_params` may be used to specify
    #             custom parameters for each short link in the message. The following parameters are
    #             supported:
    #             
    #             `domain` (string): A custom short domain name to use for the short
    #             links. The domain name must already be registered for your project or organization.
    #             
    #             `expiration_sec` (integer): The number of seconds after the message is
    #             created (queued to send) when the short links will stop forwarding to the
    #             destination URL.
    #             If null, the short links will not expire.
    #     
    #     - replace_variables (bool)
    #         * Set to true to evaluate variables like [[contact.name]] in message content
    #             (`is_template` parameter also accepted)
    #         * Default: false
    #     
    #     - media_urls (array)
    #         * URLs of media files to attach to the text message. If `message_type` is `sms`,
    #             short links to each media URL will be appended to the end of the content (separated
    #             by a new line).
    #     
    #     - route_params (Hash)
    #         * Route-specific parameters to use when sending the message. The parameters object
    #             may have keys matching the `phone_type` field of a phone (basic route) that may be
    #             used to send the message. The corresponding value is an object with route-specific
    #             parameters to use when sending a message with that type of route.
    #     
    #     - label_ids (array)
    #         * Array of IDs of labels to add to the sent messages (maximum 5). Does not apply
    #             when `message_type`=`service`, since the labels are determined by the service
    #             itself.
    #     
    #     - timezone_id
    #         * TZ database timezone ID; see [List of tz database time zones Wikipedia
    #             article](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
    #         * Default: project default timezone
    #     
    #     - end_time (UNIX timestamp)
    #         * Time after which a recurring message will stop (not applicable to non-recurring
    #             scheduled messages)
    #     
    #     - end_time_offset (int)
    #         * Number of seconds from now until the recurring message will stop
    #     
    #     - vars (Hash)
    #         * Custom variables to set for this scheduled message, which will be copied to each
    #             message sent from this scheduled message
    #   
    # Returns:
    #     Telerivet::ScheduledMessage
    #
    def schedule_message(options)
        require_relative 'scheduledmessage'
        ScheduledMessage.new(@api, @api.do_request("POST", get_base_api_path() + "/scheduled", options))
    end

    #
    # Creates a relative scheduled message. This allows scheduling messages on a different date
    # for each contact, for example on their birthday, a certain number of days before an
    # appointment, or a certain number of days after enrolling in a campaign.
    # 
    # Telerivet will automatically create a
    # [ScheduledMessage](#ScheduledMessage) for each contact matching a RelativeScheduledMessage.
    # 
    # Relative scheduled messages can be created for a group or an
    # individual contact, although dynamic groups are not supported. Only one of the parameters
    # group_id, to_number, and contact_id should be provided.
    # 
    # With message_type=service, schedules an automated service (such as a
    # poll). Any service that can be triggered for a contact can be scheduled via this method,
    # whether or not the service actually sends a message.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - message_type
    #         * Type of message to send
    #         * Allowed values: text, sms, mms, call, chat, service
    #         * Default: text
    #     
    #     - content
    #         * Content of the message to schedule
    #         * Required if sending text message
    #     
    #     - group_id
    #         * ID of the group to send the message to. Dynamic groups are not supported.
    #     
    #     - to_number (string)
    #         * Phone number to send the message to
    #     
    #     - contact_id (string)
    #         * ID of the contact to send the message to
    #     
    #     - time_of_day
    #         * Time of day when scheduled messages will be sent in HH:MM format (with hours from
    #             00 to 23)
    #         * Required
    #     
    #     - timezone_id
    #         * TZ database timezone ID; see [List of tz database time zones Wikipedia
    #             article](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
    #         * Default: project default timezone
    #     
    #     - date_variable
    #         * Custom contact variable storing date or date/time values relative to which
    #             messages will be scheduled.
    #         * Required
    #     
    #     - offset_scale
    #         * The type of interval (day/week/month/year) that will be used to adjust the
    #             scheduled date relative to the date stored in the contact's date_variable, when
    #             offset_count is non-zero (D=day, W=week, M=month, Y=year)
    #         * Allowed values: D, W, M, Y
    #         * Default: D
    #     
    #     - offset_count (int)
    #         * The number of days/weeks/months/years to adjust the date of the scheduled message
    #             relative relative to the date stored in the custom contact variable identified by
    #             the date_variable parameter. May be positive, negative, or zero.
    #         * Default: 0
    #     
    #     - rrule
    #         * A recurrence rule describing the how the schedule repeats, e.g. 'FREQ=MONTHLY' or
    #             'FREQ=WEEKLY;INTERVAL=2'; see <https://tools.ietf.org/html/rfc2445#section-4.3.10>.
    #             (UNTIL is ignored; use end_time parameter instead).
    #         * Default: COUNT=1 (one-time scheduled message, does not repeat)
    #     
    #     - route_id
    #         * ID of the phone or route to send the message from
    #         * Default: default sender route ID
    #     
    #     - service_id
    #         * Service to invoke for each recipient (when `message_type` is `call` or `service`)
    #         * Required if message_type is service
    #     
    #     - audio_url
    #         * The URL of an MP3 file to play when the contact answers the call (when
    #             `message_type` is `call`).
    #             
    #             If `audio_url` is provided, the text-to-speech voice is not used to say
    #             `content`, although you can optionally use `content` to indicate the script for the
    #             audio.
    #             
    #             For best results, use an MP3 file containing only speech. Music is not
    #             recommended because the audio quality will be low when played over a phone line.
    #     
    #     - tts_lang
    #         * The language of the text-to-speech voice (when `message_type` is `call`)
    #         * Allowed values: en-US, en-GB, en-GB-WLS, en-AU, en-IN, da-DK, nl-NL, fr-FR, fr-CA,
    #             de-DE, is-IS, it-IT, pl-PL, pt-BR, pt-PT, ru-RU, es-ES, es-US, sv-SE
    #         * Default: en-US
    #     
    #     - tts_voice
    #         * The name of the text-to-speech voice (when message_type=call)
    #         * Allowed values: female, male
    #         * Default: female
    #     
    #     - track_clicks (boolean)
    #         * If true, URLs in the message content will automatically be replaced with unique
    #             short URLs.
    #         * Default: false
    #     
    #     - short_link_params (Hash)
    #         *
    #             If `track_clicks` is true, `short_link_params` may be used to specify
    #             custom parameters for each short link in the message. The following parameters are
    #             supported:
    #             
    #             `domain` (string): A custom short domain name to use for the short
    #             links. The domain name must already be registered for your project or organization.
    #             
    #             `expiration_sec` (integer): The number of seconds after the message is
    #             created (queued to send) when the short links will stop forwarding to the
    #             destination URL.
    #             If null, the short links will not expire.
    #     
    #     - replace_variables (bool)
    #         * Set to true to evaluate variables like [[contact.name]] in message content
    #         * Default: false
    #     
    #     - media_urls (array)
    #         * URLs of media files to attach to the text message. If `message_type` is `sms`,
    #             short links to each media URL will be appended to the end of the content (separated
    #             by a new line).
    #     
    #     - route_params (Hash)
    #         * Route-specific parameters to use when sending the message. The parameters object
    #             may have keys matching the `phone_type` field of a phone (basic route) that may be
    #             used to send the message. The corresponding value is an object with route-specific
    #             parameters to use when sending a message with that type of route.
    #     
    #     - label_ids (array)
    #         * Array of IDs of labels to add to the sent messages (maximum 5). Does not apply
    #             when `message_type`=`service`, since the labels are determined by the service
    #             itself.
    #     
    #     - end_time (UNIX timestamp)
    #         * Time after which a recurring message will stop (not applicable to non-recurring
    #             scheduled messages)
    #     
    #     - end_time_offset (int)
    #         * Number of seconds from now until the recurring message will stop
    #     
    #     - vars (Hash)
    #         * Custom variables to set for this relative scheduled message, which will be copied
    #             to each message sent from this scheduled message
    #   
    # Returns:
    #     Telerivet::RelativeScheduledMessage
    #
    def create_relative_scheduled_message(options)
        require_relative 'relativescheduledmessage'
        RelativeScheduledMessage.new(@api, @api.do_request("POST", get_base_api_path() + "/relative_scheduled", options))
    end

    #
    # Add an incoming message to Telerivet. Acts the same as if the message was received by a
    # phone. Also triggers any automated services that apply to the message.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - content
    #         * Content of the incoming message
    #         * Required unless `message_type` is `call`
    #     
    #     - message_type
    #         * Type of message
    #         * Allowed values: sms, call
    #         * Default: sms
    #     
    #     - from_number
    #         * Phone number that sent the incoming message
    #         * Required
    #     
    #     - phone_id
    #         * ID of the phone (basic route) that received the message
    #         * Required
    #     
    #     - to_number
    #         * Phone number that the incoming message was sent to
    #         * Default: phone number of the phone that received the message
    #     
    #     - simulated (bool)
    #         * If true, Telerivet will not send automated replies to actual phones
    #     
    #     - starred (bool)
    #         * True if this message should be starred
    #     
    #     - label_ids (array)
    #         * Array of IDs of labels to add to this message (maximum 5)
    #     
    #     - vars (Hash)
    #         * Custom variables to set for this message
    #   
    # Returns:
    #     Telerivet::Message
    #
    def receive_message(options)
        require_relative 'message'
        Message.new(@api, @api.do_request("POST", get_base_api_path() + "/messages/receive", options))
    end

    #
    # Retrieves OR creates and possibly updates a contact by name or phone number.
    # 
    # If a phone number is provided, by default, Telerivet will search for
    # an existing contact with that phone number (including suffix matches to allow finding
    # contacts with phone numbers in a different format). If a phone number is not provided but a
    # name is provided, Telerivet will search for a contact with that exact name (case
    # insensitive). This behavior can be modified by setting the `lookup_key` parameter to look up
    # a contact by another field, including a custom variable.
    # 
    # If no existing contact is found, a new contact will be created.
    # 
    # Then that contact will be updated with any parameters provided
    # (`name`, `phone_number`, `vars`, `default_route_id`, `send_blocked`, `add_group_ids`,
    # `remove_group_ids`).
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Name of the contact
    #     
    #     - phone_number
    #         * Phone number of the contact
    #     
    #     - lookup_key
    #         * The field used to search for a matching contact, or 'none' to always create a new
    #             contact. To search by a custom variable, precede the variable name with 'vars.'.
    #         * Allowed values: phone_number, name, id, vars.variable_name, none
    #         * Default: phone_number
    #     
    #     - send_blocked (bool)
    #         * True if Telerivet is blocked from sending messages to this contact
    #     
    #     - default_route_id
    #         * ID of the route to use by default to send messages to this contact
    #     
    #     - add_group_ids (array)
    #         * ID of one or more groups to add this contact as a member (max 20)
    #     
    #     - id
    #         * ID of an existing contact (only used if `lookup_key` is 'id')
    #     
    #     - remove_group_ids (array)
    #         * ID of one or more groups to remove this contact as a member (max 20)
    #     
    #     - vars (Hash)
    #         * Custom variables and values to update on the contact
    #   
    # Returns:
    #     Telerivet::Contact
    #
    def get_or_create_contact(options = nil)
        require_relative 'contact'
        Contact.new(@api, @api.do_request("POST", get_base_api_path() + "/contacts", options))
    end

    #
    # Creates and/or updates up to 200 contacts in a single API call. When creating or updating a
    # large number of contacts, this method is significantly faster than sending a separate API
    # request for each contact.
    # 
    # By default, if the phone number for any contact matches an existing
    # contact, the existing contact will be updated with any information provided. This behavior
    # can be modified by setting the `lookup_key` parameter to look up contacts by another field,
    # including a custom variable.
    # 
    # If any contact was not found matching the provided `lookup_key`, a
    # new contact will be created.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - contacts (array)
    #         * Array of up to 200 objects which may contain the properties `name` (string),
    #             `phone_number` (string), `vars` (object), and `send_blocked` (boolean). All
    #             properties are optional, unless used as a lookup key; however, either a `name` or
    #             `phone_number` property must be provided for new contacts.
    #         * Required
    #     
    #     - lookup_key
    #         * The field used to search for a matching contact, or 'none' to always create a new
    #             contact. To search by a custom variable, precede the variable name with 'vars.'.
    #         * Allowed values: phone_number, id, vars.variable_name, none
    #         * Default: phone_number
    #     
    #     - add_group_ids (array)
    #         * ID of one or more groups to add these contacts as members (max 5)
    #     
    #     - remove_group_ids (array)
    #         * ID of one or more groups to remove these contacts as members (max 5)
    #     
    #     - default_route_id
    #         * ID of the route to use by default to send messages to these contacts
    #   
    # Returns:
    #     (associative array)
    #       - contacts (array)
    #           * List of objects representing each contact, with the same length and order as
    #               provided in the `contacts` parameter in the API request. Each object has a string
    #               `id` property.
    #
    def import_contacts(options)
        data = @api.do_request("POST", get_base_api_path() + "/import_contacts", options)
        return data
    end

    #
    # Queries contacts within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - group_id
    #         * Filter contacts within a group
    #     
    #     - name
    #         * Filter contacts by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
    #     
    #     - phone_number
    #         * Filter contacts by phone number
    #         * Allowed modifiers: phone_number[ne], phone_number[prefix],
    #             phone_number[not_prefix], phone_number[gte], phone_number[gt], phone_number[lt],
    #             phone_number[lte], phone_number[exists]
    #     
    #     - time_created (UNIX timestamp)
    #         * Filter contacts by time created
    #         * Allowed modifiers: time_created[min], time_created[max]
    #     
    #     - last_message_time (UNIX timestamp)
    #         * Filter contacts by last time a message was sent or received
    #         * Allowed modifiers: last_message_time[min], last_message_time[max],
    #             last_message_time[exists]
    #     
    #     - last_incoming_message_time (UNIX timestamp)
    #         * Filter contacts by last time a message was received
    #         * Allowed modifiers: last_incoming_message_time[min],
    #             last_incoming_message_time[max], last_incoming_message_time[exists]
    #     
    #     - last_outgoing_message_time (UNIX timestamp)
    #         * Filter contacts by last time a message was sent
    #         * Allowed modifiers: last_outgoing_message_time[min],
    #             last_outgoing_message_time[max], last_outgoing_message_time[exists]
    #     
    #     - incoming_message_count (int)
    #         * Filter contacts by number of messages received from the contact
    #         * Allowed modifiers: incoming_message_count[ne], incoming_message_count[min],
    #             incoming_message_count[max]
    #     
    #     - outgoing_message_count (int)
    #         * Filter contacts by number of messages sent to the contact
    #         * Allowed modifiers: outgoing_message_count[ne], outgoing_message_count[min],
    #             outgoing_message_count[max]
    #     
    #     - send_blocked (bool)
    #         * Filter contacts by blocked status
    #     
    #     - vars (Hash)
    #         * Filter contacts by value of a custom variable (e.g. vars[email], vars[foo], etc.)
    #         * Allowed modifiers: vars[foo][ne], vars[foo][prefix], vars[foo][not_prefix],
    #             vars[foo][gte], vars[foo][gt], vars[foo][lt], vars[foo][lte], vars[foo][min],
    #             vars[foo][max], vars[foo][exists]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, name, phone_number, last_message_time
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
    #     Telerivet::APICursor (of Telerivet::Contact)
    #
    def query_contacts(options = nil)
        require_relative 'contact'
        @api.cursor(Contact, get_base_api_path() + "/contacts", options)
    end

    #
    # Retrieves the contact with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the contact
    #       * Required
    #   
    # Returns:
    #     Telerivet::Contact
    #
    def get_contact_by_id(id)
        require_relative 'contact'
        Contact.new(@api, @api.do_request("GET", get_base_api_path() + "/contacts/#{id}"))
    end

    #
    # Initializes the Telerivet contact with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the contact
    #       * Required
    #   
    # Returns:
    #     Telerivet::Contact
    #
    def init_contact_by_id(id)
        require_relative 'contact'
        return Contact.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries basic routes within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter phones by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
    #     
    #     - phone_number
    #         * Filter phones by phone number
    #         * Allowed modifiers: phone_number[ne], phone_number[prefix],
    #             phone_number[not_prefix], phone_number[gte], phone_number[gt], phone_number[lt],
    #             phone_number[lte]
    #     
    #     - last_active_time (UNIX timestamp)
    #         * Filter phones by last active time
    #         * Allowed modifiers: last_active_time[min], last_active_time[max],
    #             last_active_time[exists]
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, name, phone_number
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
    #     Telerivet::APICursor (of Telerivet::Phone)
    #
    def query_phones(options = nil)
        require_relative 'phone'
        @api.cursor(Phone, get_base_api_path() + "/phones", options)
    end

    #
    # Retrieves the basic route with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the phone - see <https://telerivet.com/dashboard/api>
    #       * Required
    #   
    # Returns:
    #     Telerivet::Phone
    #
    def get_phone_by_id(id)
        require_relative 'phone'
        Phone.new(@api, @api.do_request("GET", get_base_api_path() + "/phones/#{id}"))
    end

    #
    # Initializes the basic route with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the phone - see <https://telerivet.com/dashboard/api>
    #       * Required
    #   
    # Returns:
    #     Telerivet::Phone
    #
    def init_phone_by_id(id)
        require_relative 'phone'
        return Phone.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries messages within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - label_id
    #         * Filter messages with a label
    #     
    #     - direction
    #         * Filter messages by direction
    #         * Allowed values: incoming, outgoing
    #     
    #     - message_type
    #         * Filter messages by message_type
    #         * Allowed values: sms, mms, ussd, ussd_session, call, chat, service
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
    #             failed_queued, cancelled, delivered, not_delivered, read
    #     
    #     - time_created[min] (UNIX timestamp)
    #         * Filter messages created on or after a particular time
    #     
    #     - time_created[max] (UNIX timestamp)
    #         * Filter messages created before a particular time
    #     
    #     - external_id
    #         * Filter messages by ID from an external provider
    #         * Allowed modifiers: external_id[ne], external_id[exists]
    #     
    #     - contact_id
    #         * ID of the contact who sent/received the message
    #         * Allowed modifiers: contact_id[ne], contact_id[exists]
    #     
    #     - phone_id
    #         * ID of the phone (basic route) that sent/received the message
    #     
    #     - broadcast_id
    #         * ID of the broadcast containing the message
    #         * Allowed modifiers: broadcast_id[ne], broadcast_id[exists]
    #     
    #     - scheduled_id
    #         * ID of the scheduled message that created this message
    #         * Allowed modifiers: scheduled_id[ne], scheduled_id[exists]
    #     
    #     - group_id
    #         * Filter messages sent or received by contacts in a particular group. The group must
    #             be a normal group, not a dynamic group.
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
    # Retrieves the message with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the message
    #       * Required
    #   
    # Returns:
    #     Telerivet::Message
    #
    def get_message_by_id(id)
        require_relative 'message'
        Message.new(@api, @api.do_request("GET", get_base_api_path() + "/messages/#{id}"))
    end

    #
    # Initializes the Telerivet message with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the message
    #       * Required
    #   
    # Returns:
    #     Telerivet::Message
    #
    def init_message_by_id(id)
        require_relative 'message'
        return Message.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries broadcasts within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - time_created[min] (UNIX timestamp)
    #         * Filter broadcasts created on or after a particular time
    #     
    #     - time_created[max] (UNIX timestamp)
    #         * Filter broadcasts created before a particular time
    #     
    #     - last_message_time[min] (UNIX timestamp)
    #         * Filter broadcasts with most recent message on or after a particular time
    #     
    #     - last_message_time[max] (UNIX timestamp)
    #         * Filter broadcasts with most recent message before a particular time
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, last_message_time
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
    #     Telerivet::APICursor (of Telerivet::Broadcast)
    #
    def query_broadcasts(options = nil)
        require_relative 'broadcast'
        @api.cursor(Broadcast, get_base_api_path() + "/broadcasts", options)
    end

    #
    # Retrieves the broadcast with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the broadcast
    #       * Required
    #   
    # Returns:
    #     Telerivet::Broadcast
    #
    def get_broadcast_by_id(id)
        require_relative 'broadcast'
        Broadcast.new(@api, @api.do_request("GET", get_base_api_path() + "/broadcasts/#{id}"))
    end

    #
    # Initializes the Telerivet broadcast with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the broadcast
    #       * Required
    #   
    # Returns:
    #     Telerivet::Broadcast
    #
    def init_broadcast_by_id(id)
        require_relative 'broadcast'
        return Broadcast.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Creates and starts an asynchronous task that is applied to all entities matching a filter
    # (e.g. contacts, messages, or data rows).
    # Tasks are designed to efficiently process a large number of
    # entities. When processing a large number of entities,
    # tasks are much faster than using the API to query and loop over
    # all objects matching a filter.
    # 
    # Several different types of tasks are supported, including
    # applying services to contacts, messages, or data rows;
    # adding or removing contacts from a group; blocking or unblocking
    # sending messages to a contact; updating a custom variable;
    # deleting contacts, messages, or data rows; or exporting data to
    # CSV.
    # 
    # When using a task to apply a Custom Actions or Cloud Script API
    # service (`apply_service_to_contacts`, `apply_service_to_rows`, or
    # `apply_service_to_messages`),
    # the `task` variable will be available within the service. The
    # service can use custom variables on the task object (e.g. `task.vars.example`), such as
    # to store aggregate statistics for the rows matching the filter.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - task_type
    #         * Type of task to create. Each `task_type` applies to a certain type of entity (such
    #             as a contact, message, or data row).
    #             
    #             Tasks for contacts:
    #             
    #             - update_contact_var
    #             - add_group_members
    #             - remove_group_members
    #             - set_conversation_status
    #             - set_send_blocked
    #             - apply_service_to_contacts
    #             - delete_contacts
    #             - export_contacts
    #             
    #             Tasks for data rows:
    #             
    #             - update_row_var
    #             - apply_service_to_rows
    #             - delete_rows
    #             - export_rows
    #             
    #             Tasks for messages:
    #             
    #             - cancel_messages
    #             - resend_messages
    #             - retry_message_services
    #             - apply_service_to_messages
    #             - add_label
    #             - remove_label
    #             - update_message_var
    #             - delete_messages
    #             - export_messages
    #         * Required
    #     
    #     - task_params (Hash)
    #         * Parameters applied to all matching rows (specific to `task_type`).
    #             
    #             **apply_service_to_contacts**,
    #             **apply_service_to_messages**, **apply_service_to_rows**:
    #             <table>
    #             <tr><td> service_id </td> <td> The ID of the service
    #             to apply (string) </td></tr>
    #             <tr><td> variables </td> <td> Optional object
    #             containing up to 25 temporary variable names and their corresponding values to set
    #             when invoking the service. Values may be strings, numbers, or boolean (true/false).
    #             String values may be up to 4096 bytes in length. Arrays and objects are not
    #             supported. Within Custom Actions, each variable can be used like [[$name]] (with a
    #             leading $ character and surrounded by double square brackets). Within a Cloud Script
    #             API service or JavaScript action, each variable will be available as a global
    #             JavaScript variable like $name (with a leading $ character). (object) </td></tr>
    #             </table>
    #             <br />
    #             **update_contact_var**, **update_message_var**,
    #             **update_row_var**:
    #             <table>
    #             <tr><td> variable </td> <td> The custom variable
    #             name (string) </td></tr>
    #             <tr><td> value </td> <td> The value to set (string,
    #             boolean, float, null) </td></tr>
    #             </table>
    #             <br />
    #             **add_group_members**, **remove_group_members**:
    #             <table>
    #             <tr><td> group_id </td> <td> The ID of the group
    #             (string) </td></tr>
    #             </table>
    #             <br />
    #             **add_label**, **remove_label**:
    #             <table>
    #             <tr><td> label_id </td> <td> The ID of the label
    #             (string) </td></tr>
    #             </table>
    #             <br />
    #             **resend_messages**:
    #             <table>
    #             <tr><td> route_id </td> <td> ID of the new route to
    #             use, or null to use the original route (string) </td></tr>
    #             </table>
    #             <br />
    #             **set_send_blocked**:
    #             <table>
    #             <tr><td> send_blocked </td> <td> true to block
    #             sending messages, false to unblock sending messages (boolean) </td></tr>
    #             </table>
    #             <br />
    #             **set_conversation_status**:
    #             <table>
    #             <tr><td> conversation_status </td> <td> "active",
    #             "handled", or "closed" (string) </td></tr>
    #             </table>
    #             <br />
    #             **export_contacts**, **export_messages**,
    #             **export_rows**:
    #             <table>
    #             <tr><td>storage_id </td> <td> ID of a storage
    #             provider where the CSV file will be saved. (string)
    #             
    #             Currently only AWS S3 is supported as a storage
    #             provider.
    #             This requires creating a S3 bucket in your own
    #             AWS account, as well as an IAM user with access key and secret that has permission
    #             to write to that bucket.
    #             You can configure your own S3 bucket as a
    #             storage provider on the <a href="/dashboard/a/storage">Storage Providers</a> page.
    #             
    #             Direct downloads are not supported when
    #             exporting data via the API.
    #             (string) </td></tr>
    #             <tr><td>filename </td> <td> Path within the storage
    #             backend where the CSV file will be saved </td></tr>
    #             <tr><td>column_ids </td> <td> IDs of columns to save
    #             in the CSV file. If not provided, all default columns will be saved. (array of
    #             strings, optional) </td></tr>
    #             </table>
    #             <br />
    #             **delete_contacts**, **delete_messages**,
    #             **delete_rows**, **cancel_messages**, **retry_message_services**: <br />
    #             No parameters.
    #     
    #     - filter_type
    #         * Type of filter defining the rows that the task is applied to.
    #             
    #             Each `filter_type` queries a certain type of
    #             entity (such as contacts, messages, or data rows).
    #             
    #             In general, the `task_type` and the
    #             `filter_type` must return the same type of entity; however, tasks applied to
    #             contacts (other than `export_contacts`) can also be applied
    #             when the filter returns entities that are
    #             associated with a contact, such as messages or data rows. (Note that in this case,
    #             it is possible for the task to be applied multiple times to an individual contact if
    #             multiple messages or data rows are associated with the same contact.)
    #         * Allowed values: query_contacts, contact_ids, query_rows, row_ids, query_messages,
    #             message_ids
    #         * Required
    #     
    #     - filter_params (Hash)
    #         * Parameters defining the rows that the task is applied to (specific to
    #             `filter_type`).
    #             
    #             **`query_contacts`**: <br />
    #             The same filter parameters as used by
    #             [project.queryContacts](#Project.queryContacts). If you want to apply the task to
    #             all contacts, use the parameters {"all": true}.
    #             
    #             **`contact_ids`**:
    #             <table>
    #             <tr><td> `contact_ids` </td> <td> IDs of up to 100
    #             contacts to apply this task to (array of strings) </td></tr>
    #             </table>
    #             
    #             **`query_messages`**: <br />
    #             The same filter parameters as used by
    #             [project.queryMessages](#Project.queryMessages). If you want to apply the task to
    #             all messages, use the parameters {"all": true}.
    #             
    #             **`message_ids`**:
    #             <table>
    #             <tr><td> `message_ids` </td> <td> IDs of up to 100
    #             messages to apply this task to (array of strings) </td></tr>
    #             </table>
    #             
    #             **`query_rows`**: <br />
    #             The same filter parameters as used by
    #             [table.queryRows](#DataTable.queryRows). If you want to apply the task to all rows
    #             in the table, use the parameters {"all": true}.
    #             
    #             **`row_ids`**:
    #             <table>
    #             <tr><td> `row_ids` </td> <td> IDs of up to 100 data
    #             rows to apply this task to (array of strings) </td></tr>
    #             </table>
    #         * Required
    #     
    #     - table_id (string, max 34 characters)
    #         * ID of the data table this task is applied to (if applicable).
    #             
    #             Required if filter_type is `query_rows` or `row_ids`.
    #     
    #     - vars (Hash)
    #         * Initial custom variables to set for the task.
    #             
    #             If the task applies a service, the service can read
    #             and write custom variables on the task object (e.g. `task.vars.example`), such as
    #             to store aggregate statistics for the rows matching
    #             the filter.
    #   
    # Returns:
    #     Telerivet::Task
    #
    def create_task(options)
        require_relative 'task'
        Task.new(@api, @api.do_request("POST", get_base_api_path() + "/tasks", options))
    end

    #
    # Queries batch tasks within the given project.
    # 
    # Arguments:
    #   - options (Hash)
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
    #     Telerivet::APICursor (of Telerivet::Task)
    #
    def query_tasks(options = nil)
        require_relative 'task'
        @api.cursor(Task, get_base_api_path() + "/tasks", options)
    end

    #
    # Retrieves the task with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the task
    #       * Required
    #   
    # Returns:
    #     Telerivet::Task
    #
    def get_task_by_id(id)
        require_relative 'task'
        Task.new(@api, @api.do_request("GET", get_base_api_path() + "/tasks/#{id}"))
    end

    #
    # Initializes the task with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the task
    #       * Required
    #   
    # Returns:
    #     Telerivet::Task
    #
    def init_task_by_id(id)
        require_relative 'task'
        return Task.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries groups within the given project.
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
    # Retrieves or creates a group by name.
    # 
    # Arguments:
    #   - name
    #       * Name of the group
    #       * Required
    #   
    # Returns:
    #     Telerivet::Group
    #
    def get_or_create_group(name)
        require_relative 'group'
        Group.new(@api, @api.do_request("POST", get_base_api_path() + "/groups", {'name' => name}))
    end

    #
    # Retrieves the group with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the group
    #       * Required
    #   
    # Returns:
    #     Telerivet::Group
    #
    def get_group_by_id(id)
        require_relative 'group'
        Group.new(@api, @api.do_request("GET", get_base_api_path() + "/groups/#{id}"))
    end

    #
    # Initializes the group with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the group
    #       * Required
    #   
    # Returns:
    #     Telerivet::Group
    #
    def init_group_by_id(id)
        require_relative 'group'
        return Group.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries labels within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter labels by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
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
    #     Telerivet::APICursor (of Telerivet::Label)
    #
    def query_labels(options = nil)
        require_relative 'label'
        @api.cursor(Label, get_base_api_path() + "/labels", options)
    end

    #
    # Gets or creates a label by name.
    # 
    # Arguments:
    #   - name
    #       * Name of the label
    #       * Required
    #   
    # Returns:
    #     Telerivet::Label
    #
    def get_or_create_label(name)
        require_relative 'label'
        Label.new(@api, @api.do_request("POST", get_base_api_path() + "/labels", {'name' => name}))
    end

    #
    # Retrieves the label with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the label
    #       * Required
    #   
    # Returns:
    #     Telerivet::Label
    #
    def get_label_by_id(id)
        require_relative 'label'
        Label.new(@api, @api.do_request("GET", get_base_api_path() + "/labels/#{id}"))
    end

    #
    # Initializes the label with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the label
    #       * Required
    #   
    # Returns:
    #     Telerivet::Label
    #
    def init_label_by_id(id)
        require_relative 'label'
        return Label.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries data tables within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter data tables by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
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
    #     Telerivet::APICursor (of Telerivet::DataTable)
    #
    def query_data_tables(options = nil)
        require_relative 'datatable'
        @api.cursor(DataTable, get_base_api_path() + "/tables", options)
    end

    #
    # Gets or creates a data table by name.
    # 
    # Arguments:
    #   - name
    #       * Name of the data table
    #       * Required
    #   
    # Returns:
    #     Telerivet::DataTable
    #
    def get_or_create_data_table(name)
        require_relative 'datatable'
        DataTable.new(@api, @api.do_request("POST", get_base_api_path() + "/tables", {'name' => name}))
    end

    #
    # Retrieves the data table with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the data table
    #       * Required
    #   
    # Returns:
    #     Telerivet::DataTable
    #
    def get_data_table_by_id(id)
        require_relative 'datatable'
        DataTable.new(@api, @api.do_request("GET", get_base_api_path() + "/tables/#{id}"))
    end

    #
    # Initializes the data table with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the data table
    #       * Required
    #   
    # Returns:
    #     Telerivet::DataTable
    #
    def init_data_table_by_id(id)
        require_relative 'datatable'
        return DataTable.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries scheduled messages within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - message_type
    #         * Filter scheduled messages by message_type
    #         * Allowed values: sms, mms, ussd, ussd_session, call, chat, service
    #     
    #     - time_created (UNIX timestamp)
    #         * Filter scheduled messages by time_created
    #         * Allowed modifiers: time_created[min], time_created[max]
    #     
    #     - next_time (UNIX timestamp)
    #         * Filter scheduled messages by next_time
    #         * Allowed modifiers: next_time[min], next_time[max], next_time[exists]
    #     
    #     - relative_scheduled_id
    #         * Filter scheduled messages created for a relative scheduled message
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, next_time
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
    # Queries relative scheduled messages within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - message_type
    #         * Filter relative scheduled messages by message_type
    #         * Allowed values: sms, mms, ussd, ussd_session, call, chat, service
    #     
    #     - time_created (UNIX timestamp)
    #         * Filter relative scheduled messages by time_created
    #         * Allowed modifiers: time_created[min], time_created[max]
    #     
    #     - group_id
    #         * Filter relative scheduled messages sent to a group
    #     
    #     - contact_id
    #         * Filter relative scheduled messages sent to an individual contact
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
    #     Telerivet::APICursor (of Telerivet::RelativeScheduledMessage)
    #
    def query_relative_scheduled_messages(options = nil)
        require_relative 'relativescheduledmessage'
        @api.cursor(RelativeScheduledMessage, get_base_api_path() + "/relative_scheduled", options)
    end

    #
    # Retrieves the scheduled message with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the scheduled message
    #       * Required
    #   
    # Returns:
    #     Telerivet::ScheduledMessage
    #
    def get_scheduled_message_by_id(id)
        require_relative 'scheduledmessage'
        ScheduledMessage.new(@api, @api.do_request("GET", get_base_api_path() + "/scheduled/#{id}"))
    end

    #
    # Initializes the scheduled message with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the scheduled message
    #       * Required
    #   
    # Returns:
    #     Telerivet::ScheduledMessage
    #
    def init_scheduled_message_by_id(id)
        require_relative 'scheduledmessage'
        return ScheduledMessage.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Retrieves the scheduled message with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the relative scheduled message
    #       * Required
    #   
    # Returns:
    #     Telerivet::RelativeScheduledMessage
    #
    def get_relative_scheduled_message_by_id(id)
        require_relative 'relativescheduledmessage'
        RelativeScheduledMessage.new(@api, @api.do_request("GET", get_base_api_path() + "/relative_scheduled/#{id}"))
    end

    #
    # Initializes the relative scheduled message with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the relative scheduled message
    #       * Required
    #   
    # Returns:
    #     Telerivet::RelativeScheduledMessage
    #
    def init_relative_scheduled_message_by_id(id)
        require_relative 'relativescheduledmessage'
        return RelativeScheduledMessage.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Creates a new automated service.
    # 
    # Only certain types of automated services can be created via the API.
    # Other types of services can only be created via the web app.
    # 
    # Although Custom Actions services cannot be created directly via the
    # API, they may be converted to a template,
    # and then instances of the template can be created via this method
    # with `service_type`=`custom_template_instance`. Converting a service
    # to a template requires the Service Templates feature to be enabled
    # for the organization.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - name (string)
    #         * Name of the service to create, which must be unique in the project. If a name is
    #             not provided, a unique default name will be generated.
    #     
    #     - service_type (string)
    #         * Type of service to create.  The following service types can be created via the
    #             API:
    #             
    #             - incoming_message_webhook
    #             - incoming_message_script
    #             - contact_script
    #             - message_script
    #             - data_row_script
    #             - webhook_script
    #             - voice_script
    #             - ussd_script
    #             - project_script
    #             - custom_template_instance
    #             
    #             Other types of services can only be created via the web app.
    #         * Required
    #     
    #     - config (Hash)
    #         * Configuration specific to the service `type`.
    #             
    #             **incoming_message_webhook**:
    #             <table>
    #             <tr><td> url </td> <td> The webhook URL that will be
    #             triggered when an incoming message is received (string) </td></tr>
    #             <tr><td> secret </td> <td> Optional string that will
    #             be passed as the `secret` POST parameter to the webhook URL. (object) </td></tr>
    #             </table>
    #             <br />
    #             
    #             **incoming_message_script, contact_script,
    #             message_script, data_row_script, webhook_script, voice_script, ussd_script,
    #             project_script**:
    #             <table>
    #             <tr><td> code </td> <td> The JavaScript code to run
    #             when the service is triggered (max 100 KB). To run code longer than 100 KB, use a
    #             Cloud Script Module. (string) </td></tr>
    #             </table>
    #             <br />
    #             
    #             **custom_template_instance**:
    #             <table>
    #             <tr><td> template_service_id </td> <td> ID of the
    #             service template (string). The service template must be available to the current
    #             project or organization.</td></tr>
    #             <tr><td> params </td> <td> Key/value pairs for all
    #             service template parameters (object). If the values satisfy the validation rules
    #             specified in the service template, they will also be copied to the `vars` property
    #             of the service. Any values not associated with service template parameters will be
    #             ignored.
    #             </td></tr>
    #             </table>
    #             <br />
    #         * Required
    #     
    #     - vars
    #         * Custom variables and values to set for this service
    #     
    #     - active (bool)
    #         * Whether the service is initially active or inactive. Inactive services are not
    #             automatically triggered and cannot be invoked via the API.
    #         * Default: 1
    #     
    #     - response_table_id
    #         * ID of a data table where responses will be stored, or null to disable
    #             automatically storing responses. If the response_table_id parameter is not provided,
    #             a data table may automatically be created with the same name as the service if the
    #             service collects responses.
    #     
    #     - phone_ids (array)
    #         * IDs of phones (basic routes) to associate with this service, or null to associate
    #             this service with all routes. Only applies for service types that handle incoming
    #             messages, voice calls, or USSD sessions.
    #     
    #     - message_types (array)
    #         * Types of messages that this service should handle. Only applies to services that
    #             handle incoming messages.
    #         * Allowed values: text, call, sms, mms, ussd_session, chat
    #     
    #     - show_action (bool)
    #         * Whether to show this service in the Actions menu within the Telerivet web app when
    #             the service is active. Only applies for service types that are manually triggered.
    #         * Default: 1
    #     
    #     - contact_number_filter
    #         * If contact_number_filter is `long_number`, this service will only be triggered if
    #             the contact phone number has at least 7 digits (ignoring messages from shortcodes
    #             and alphanumeric senders). If contact_number_filter is `all`, the service will be
    #             triggered for all contact phone numbers.  Only applies to services that handle
    #             incoming messages.
    #         * Allowed values: long_number, all
    #         * Default: long_number
    #     
    #     - direction
    #         * Determines whether the service handles incoming voice calls, outgoing voice calls,
    #             or both. Only applies to services that handle voice calls.
    #         * Allowed values: incoming, outgoing, both
    #         * Default: both
    #     
    #     - priority (int)
    #         * A number that determines the order that services are triggered when an event
    #             occurs (e.g. when an incoming message is received). Smaller numbers are triggered
    #             first. The priority is ignored for services that are triggered directly.
    #     
    #     - apply_mode
    #         * If apply_mode is `unhandled`, the service will not be triggered if another service
    #             has already handled the incoming message. If apply_mode is `always`, the service
    #             will always be triggered regardless of other services. Only applies to services that
    #             handle incoming messages.
    #         * Allowed values: always, unhandled
    #         * Default: unhandled
    #   
    # Returns:
    #     Telerivet::Service
    #
    def create_service(options)
        require_relative 'service'
        Service.new(@api, @api.do_request("POST", get_base_api_path() + "/services", options))
    end

    #
    # Queries services within the given project.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter services by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
    #     
    #     - active (bool)
    #         * Filter services by active/inactive state
    #     
    #     - context
    #         * Filter services that can be invoked in a particular context
    #         * Allowed values: message, call, ussd_session, row, contact, project
    #     
    #     - sort
    #         * Sort the results based on a field
    #         * Allowed values: default, priority, name
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
    #     Telerivet::APICursor (of Telerivet::Service)
    #
    def query_services(options = nil)
        require_relative 'service'
        @api.cursor(Service, get_base_api_path() + "/services", options)
    end

    #
    # Retrieves the service with the given ID.
    # 
    # Arguments:
    #   - id
    #       * ID of the service
    #       * Required
    #   
    # Returns:
    #     Telerivet::Service
    #
    def get_service_by_id(id)
        require_relative 'service'
        Service.new(@api, @api.do_request("GET", get_base_api_path() + "/services/#{id}"))
    end

    #
    # Initializes the service with the given ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the service
    #       * Required
    #   
    # Returns:
    #     Telerivet::Service
    #
    def init_service_by_id(id)
        require_relative 'service'
        return Service.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Queries service log entries associated with this project.
    # 
    # Note: Service logs are automatically deleted and no longer available
    # via the API after approximately one month.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - service_id
    #         * Filter logs generated by a particular service
    #     
    #     - message_id
    #         * Filter service logs related to a particular message
    #     
    #     - contact_id
    #         * Filter service logs related to a particular contact. Ignored if using the
    #             message_id parameter.
    #     
    #     - time_created (UNIX timestamp)
    #         * Filter service logs by the time they were created
    #         * Allowed modifiers: time_created[min], time_created[max]
    #     
    #     - execution_stats (bool)
    #         * Show detailed execution stats for each log entry, if available.
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
    #     Telerivet::APICursor (of Hash)
    # 
    # Returned Item Properties:
    #     - time_created (UNIX timestamp)
    #         * The time when the log entry was created
    #     
    #     - content
    #         * The text logged
    #     
    #     - elapsed_ms (int)
    #         * Elapsed time in milliseconds, if available.
    #     
    #     - service_id
    #         * ID of the service associated with this log entry. Not returned when querying log
    #             entries for a particular service.
    #     
    #     - message_id
    #         * ID of the message associated with this log entry. Not returned when querying log
    #             entries for a particular message.
    #     
    #     - contact_id
    #         * ID of the contact associated with this log entry. Not returned when querying log
    #             entries for a particular message or contact.
    #     
    #     - api_request_count (int)
    #         * The total number of API requests triggered via the Cloud Script API. (Only
    #             provided if execution_stats=true.)
    #     
    #     - api_request_ms (int)
    #         * The total execution time of all API requests triggered via the Cloud Script API.
    #             (Only provided if execution_stats=true.)
    #     
    #     - http_request_count (int)
    #         * The total number of external HTTP requests triggered via the Cloud Script API.
    #             (Only provided if execution_stats=true.)
    #     
    #     - http_request_ms (int)
    #         * The total execution time of all external HTTP requests triggered via the Cloud
    #             Script API. (Only provided if execution_stats=true.)
    #     
    #     - webhook_count (int)
    #         * The total number of Webhook API requests triggered. (Only provided if
    #             execution_stats=true.)
    #     
    #     - requests (array)
    #         *  Details about each API request, external HTTP request, and Cloud Script Module
    #             loaded via the Cloud Script API. (Only provided if execution_stats=true.)
    #             
    #             Each item in the array has the following properties:
    #             
    #             - type (string): `api_request`, `http_request`, or
    #             `module_load`
    #             - resource (string): A string specific to the type of
    #             request.
    #             For module_load, this is the module path. For
    #             api_request, it contains the HTTP
    #             method, path, and query string. For http_request, it
    #             contains the HTTP method and
    #             URL.
    #             - elapsed_ms (int): Number of milliseconds elapsed in
    #             fetching
    #             this resource
    #             - status_code (int): Response status code, if available
    #
    def query_service_logs(options = nil)
        @api.cursor(nil, get_base_api_path() + "/service_logs", options)
    end

    #
    # Queries custom routes that can be used to send messages (not including Phones).
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - name
    #         * Filter routes by name
    #         * Allowed modifiers: name[ne], name[prefix], name[not_prefix], name[gte], name[gt],
    #             name[lt], name[lte]
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
    #     Telerivet::APICursor (of Telerivet::Route)
    #
    def query_routes(options = nil)
        require_relative 'route'
        @api.cursor(Route, get_base_api_path() + "/routes", options)
    end

    #
    # Gets a custom route by ID
    # 
    # Arguments:
    #   - id
    #       * ID of the route
    #       * Required
    #   
    # Returns:
    #     Telerivet::Route
    #
    def get_route_by_id(id)
        require_relative 'route'
        Route.new(@api, @api.do_request("GET", get_base_api_path() + "/routes/#{id}"))
    end

    #
    # Initializes a custom route by ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the route
    #       * Required
    #   
    # Returns:
    #     Telerivet::Route
    #
    def init_route_by_id(id)
        require_relative 'route'
        return Route.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Returns an array of user accounts that have access to this project. Each item in the array
    # is an object containing `id`, `email`, and `name` properties. (The id corresponds to the
    # `user_id` property of the Message object.)
    # 
    # Returns:
    #     array
    #
    def get_users()
        return @api.do_request("GET", get_base_api_path() + "/users")
    end

    #
    # Returns information about each airtime transaction.
    # 
    # Arguments:
    #   - options (Hash)
    #     
    #     - time_created[min] (UNIX timestamp)
    #         * Filter transactions created on or after a particular time
    #     
    #     - time_created[max] (UNIX timestamp)
    #         * Filter transactions created before a particular time
    #     
    #     - contact_id
    #         * Filter transactions sent to a particular contact
    #     
    #     - to_number
    #         * Filter transactions sent to a particular phone number
    #     
    #     - service_id
    #         * Filter transactions sent by a particular service
    #     
    #     - status
    #         * Filter transactions by status
    #         * Allowed values: pending, queued, processing, successful, failed, cancelled,
    #             pending_payment, pending_approval
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
    #     Telerivet::APICursor (of Telerivet::AirtimeTransaction)
    #
    def query_airtime_transactions(options = nil)
        require_relative 'airtimetransaction'
        @api.cursor(AirtimeTransaction, get_base_api_path() + "/airtime_transactions", options)
    end

    #
    # Gets an airtime transaction by ID
    # 
    # Arguments:
    #   - id
    #       * ID of the airtime transaction
    #       * Required
    #   
    # Returns:
    #     Telerivet::AirtimeTransaction
    #
    def get_airtime_transaction_by_id(id)
        require_relative 'airtimetransaction'
        AirtimeTransaction.new(@api, @api.do_request("GET", get_base_api_path() + "/airtime_transactions/#{id}"))
    end

    #
    # Initializes an airtime transaction by ID without making an API request.
    # 
    # Arguments:
    #   - id
    #       * ID of the airtime transaction
    #       * Required
    #   
    # Returns:
    #     Telerivet::AirtimeTransaction
    #
    def init_airtime_transaction_by_id(id)
        require_relative 'airtimetransaction'
        return AirtimeTransaction.new(@api, {'project_id' => self.id, 'id' => id}, false)
    end

    #
    # Gets a list of all custom fields defined for contacts in this project. The return value is
    # an array of objects with the properties 'name', 'variable', 'type', 'order', 'readonly', and
    # 'lookup_key'. (Fields are automatically created any time a Contact's 'vars' property is
    # updated.)
    # 
    # Returns:
    #     array
    #
    def get_contact_fields()
        return @api.do_request("GET", get_base_api_path() + "/contact_fields")
    end

    #
    # Allows customizing how a custom contact field is displayed in the Telerivet web app.
    # 
    # Arguments:
    #   - variable
    #       * The variable name of the field to create or update.
    #       * Required
    #   
    #   - options (Hash)
    #       * Required
    #     
    #     - name (string, max 64 characters)
    #         * Display name for the field
    #     
    #     - type (int)
    #         * Field type
    #         * Allowed values: text, long_text, secret, phone_number, email, url, audio, date,
    #             date_time, number, boolean, checkbox, select, radio
    #     
    #     - order (int)
    #         * Order in which to display the field
    #     
    #     - items (array)
    #         * Array of up to 100 objects containing `value` and `label` string properties to
    #             show in the dropdown list when type is `select`. Each `value` and `label` must be
    #             between 1 and 256 characters in length.
    #         * Required if type is `select`
    #     
    #     - readonly (bool)
    #         * Set to true to prevent editing the field in the Telerivet web app
    #     
    #     - lookup_key (bool)
    #         * Set to true to allow using this field as a lookup key when importing contacts via
    #             the Telerivet web app
    #     
    #     - show_on_conversation (bool)
    #         * Set to true to show field on Conversations tab
    #   
    # Returns:
    #     object
    #
    def set_contact_field_metadata(variable, options)
        return @api.do_request("POST", get_base_api_path() + "/contact_fields/#{variable}", options)
    end

    #
    # Gets a list of all custom fields defined for messages in this project. The return value is
    # an array of objects with the properties 'name', 'variable', 'type', 'order', 'readonly', and
    # 'lookup_key'. (Fields are automatically created any time a Contact's 'vars' property is
    # updated.)
    # 
    # Returns:
    #     array
    #
    def get_message_fields()
        return @api.do_request("GET", get_base_api_path() + "/message_fields")
    end

    #
    # Allows customizing how a custom message field is displayed in the Telerivet web app.
    # 
    # Arguments:
    #   - variable
    #       * The variable name of the field to create or update.
    #       * Required
    #   
    #   - options (Hash)
    #       * Required
    #     
    #     - name (string, max 64 characters)
    #         * Display name for the field
    #     
    #     - type (string)
    #         * Field type
    #         * Allowed values: text, long_text, secret, phone_number, email, url, audio, date,
    #             date_time, number, boolean, checkbox, select, radio
    #     
    #     - order (int)
    #         * Order in which to display the field
    #     
    #     - items (array)
    #         * Array of up to 100 objects containing `value` and `label` string properties to
    #             show in the dropdown list when type is `select`. Each `value` and `label` must be
    #             between 1 and 256 characters in length.
    #         * Required if type is `select`
    #     
    #     - hide_values (bool)
    #         * Set to true to avoid showing values of this field on the Messages page
    #   
    # Returns:
    #     object
    #
    def set_message_field_metadata(variable, options)
        return @api.do_request("POST", get_base_api_path() + "/message_fields/#{variable}", options)
    end

    #
    # Retrieves statistics about messages sent or received via Telerivet. This endpoint returns
    # historical data that is computed shortly after midnight each day in the project's time zone,
    # and does not contain message statistics for the current day.
    # 
    # Arguments:
    #   - options (Hash)
    #       * Required
    #     
    #     - start_date (string)
    #         * Start date of message statistics, in YYYY-MM-DD format
    #         * Required
    #     
    #     - end_date (string)
    #         * End date of message statistics (inclusive), in YYYY-MM-DD format
    #         * Required
    #     
    #     - rollup (string)
    #         * Date interval to group by
    #         * Allowed values: day, week, month, year, all
    #         * Default: day
    #     
    #     - properties (string)
    #         * Comma separated list of properties to group by
    #         * Allowed values: org_id, org_name, org_industry, project_id, project_name, user_id,
    #             user_email, user_name, phone_id, phone_name, phone_type, direction, source, status,
    #             network_code, network_name, message_type, service_id, service_name, simulated, link
    #     
    #     - metrics (string)
    #         * Comma separated list of metrics to return (summed for each distinct value of the
    #             requested properties)
    #         * Allowed values: count, num_parts, duration, price
    #         * Required
    #     
    #     - currency (string)
    #         * Three-letter ISO 4217 currency code used when returning the 'price' field. If the
    #             original price was in a different currency, it will be converted to the requested
    #             currency using the approximate current exchange rate.
    #         * Default: USD
    #     
    #     - filters (Hash)
    #         * Key-value pairs of properties and corresponding values; the returned statistics
    #             will only include messages where the property matches the provided value. Only the
    #             following properties are supported for filters: `user_id`, `phone_id`, `direction`,
    #             `source`, `status`, `service_id`, `simulated`, `message_type`, `network_code`
    #   
    # Returns:
    #     (associative array)
    #       - intervals (array)
    #           * List of objects representing each date interval containing at least one message
    #               matching the filters.
    #               Each object has the following properties:
    #               
    #               <table>
    #               <tr><td> start_time </td> <td> The UNIX timestamp of the start
    #               of the interval (int) </td></tr>
    #               <tr><td> end_time </td> <td> The UNIX timestamp of the end of
    #               the interval, exclusive (int) </td></tr>
    #               <tr><td> start_date </td> <td> The date of the start of the
    #               interval in YYYY-MM-DD format (string) </td></tr>
    #               <tr><td> end_date </td> <td> The date of the end of the
    #               interval in YYYY-MM-DD format, inclusive (string) </td></tr>
    #               <tr><td> groups </td> <td> Array of groups for each
    #               combination of requested property values matching the filters (array)
    #               <br /><br />
    #               Each object has the following properties:
    #               <table>
    #               <tr><td> properties </td> <td> An object of key/value
    #               pairs for each distinct value of the requested properties (object) </td></tr>
    #               <tr><td> metrics </td> <td> An object of key/value pairs
    #               for each requested metric (object) </td></tr>
    #               </table>
    #               </td></tr>
    #               </table>
    #
    def get_message_stats(options)
        data = @api.do_request("GET", get_base_api_path() + "/message_stats", options)
        return data
    end

    #
    # Saves any fields or custom variables that have changed for the project.
    #
    def save()
        super
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

    def timezone_id
        get('timezone_id')
    end

    def timezone_id=(value)
        set('timezone_id', value)
    end

    def url_slug
        get('url_slug')
    end

    def url_slug=(value)
        set('url_slug', value)
    end

    def default_route_id
        get('default_route_id')
    end

    def default_route_id=(value)
        set('default_route_id', value)
    end

    def auto_create_contacts
        get('auto_create_contacts')
    end

    def auto_create_contacts=(value)
        set('auto_create_contacts', value)
    end

    def organization_id
        get('organization_id')
    end

    def get_base_api_path()
        "/projects/#{get('id')}"
    end
 
end

end
