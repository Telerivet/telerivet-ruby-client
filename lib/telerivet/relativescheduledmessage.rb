
module Telerivet

#
# A relative scheduled message is a message that is scheduled relative to a date stored as a
# custom field for each recipient contact.
# This allows scheduling messages on a different date for each contact, for
# example on their birthday, a certain number of days before an appointment, or a certain
# number of days after enrolling in a campaign.
# 
# Telerivet will automatically create a [ScheduledMessage](#ScheduledMessage)
# for each contact matching a RelativeScheduledMessage.
# 
# Any service that can be manually triggered for a contact (including polls)
# may also be scheduled via a relative scheduled message, whether or not the service actually
# sends a message.
# 
# Fields:
# 
#   - id (string, max 34 characters)
#       * ID of the relative scheduled message
#       * Read-only
#   
#   - content
#       * Text content of the relative scheduled message
#       * Updatable via API
#   
#   - time_of_day
#       * Time of day when scheduled messages will be sent in HH:MM format (with hours from 00
#           to 23)
#       * Updatable via API
#   
#   - date_variable
#       * Custom contact variable storing date or date/time values relative to which messages
#           will be scheduled.
#       * Updatable via API
#   
#   - offset_scale
#       * The type of interval (day/week/month/year) that will be used to adjust the scheduled
#           date relative to the date stored in the contact's date_variable, when offset_count is
#           non-zero (D=day, W=week, M=month, Y=year)
#       * Allowed values: D, W, M, Y
#       * Updatable via API
#   
#   - offset_count (int)
#       * The number of days/weeks/months/years to adjust the date of the scheduled message
#           relative relative to the date stored in the contact's date_variable. May be positive,
#           negative, or zero.
#       * Updatable via API
#   
#   - rrule
#       * Recurrence rule for recurring scheduled messages, e.g. 'FREQ=MONTHLY' or
#           'FREQ=WEEKLY;INTERVAL=2'; see
#           [RFC2445](https://tools.ietf.org/html/rfc2445#section-4.3.10).
#       * Updatable via API
#   
#   - end_time (UNIX timestamp)
#       * Time after which recurring messages will stop (not applicable to non-recurring
#           scheduled messages)
#       * Updatable via API
#   
#   - timezone_id
#       * Timezone ID used to compute times for recurring messages; see [List of tz database
#           time zones Wikipedia
#           article](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
#       * Updatable via API
#   
#   - recipients_str
#       * A string with a human readable description of the recipient
#       * Read-only
#   
#   - group_id
#       * ID of the group to send the message to (null if the recipient is an individual
#           contact)
#       * Updatable via API
#   
#   - contact_id
#       * ID of the contact to send the message to (null if the recipient is a group)
#       * Updatable via API
#   
#   - to_number
#       * Phone number to send the message to (null if the recipient is a group)
#       * Updatable via API
#   
#   - route_id
#       * ID of the phone or route the message will be sent from
#       * Updatable via API
#   
#   - service_id (string, max 34 characters)
#       * The service associated with this message (for voice calls, the service defines the
#           call flow)
#       * Updatable via API
#   
#   - audio_url
#       * For voice calls, the URL of an MP3 file to play when the contact answers the call
#       * Updatable via API
#   
#   - tts_lang
#       * For voice calls, the language of the text-to-speech voice
#       * Allowed values: en-US, en-GB, en-GB-WLS, en-AU, en-IN, da-DK, nl-NL, fr-FR, fr-CA,
#           de-DE, is-IS, it-IT, pl-PL, pt-BR, pt-PT, ru-RU, es-ES, es-US, sv-SE
#       * Updatable via API
#   
#   - tts_voice
#       * For voice calls, the text-to-speech voice
#       * Allowed values: female, male
#       * Updatable via API
#   
#   - message_type
#       * Type of scheduled message
#       * Allowed values: sms, mms, ussd, ussd_session, call, chat, service
#       * Read-only
#   
#   - time_created (UNIX timestamp)
#       * Time the relative scheduled message was created in Telerivet
#       * Read-only
#   
#   - replace_variables (bool)
#       * Set to true if Telerivet will render variables like [[contact.name]] in the message
#           content, false otherwise
#       * Updatable via API
#   
#   - track_clicks (boolean)
#       * If true, URLs in the message content will automatically be replaced with unique
#           short URLs
#       * Updatable via API
#   
#   - media (array)
#       * For text messages containing media files, this is an array of objects with the
#           properties `url`, `type` (MIME type), `filename`, and `size` (file size in bytes).
#           Unknown properties are null. This property is undefined for messages that do not
#           contain media files. Note: For files uploaded via the Telerivet web app, the URL is
#           temporary and may not be valid for more than 1 day.
#       * Read-only
#   
#   - route_params (Hash)
#       * Route-specific parameters to use when sending the message. The parameters object may
#           have keys matching the `phone_type` field of a phone (basic route) that may be used to
#           send the message. The corresponding value is an object with route-specific parameters
#           to use when sending a message with that type of route.
#       * Updatable via API
#   
#   - vars (Hash)
#       * Custom variables stored for this scheduled message (copied to each ScheduledMessage
#           and Message when sent)
#       * Updatable via API
#   
#   - label_ids (array)
#       * IDs of labels to add to the Message
#       * Updatable via API
#   
#   - project_id
#       * ID of the project this relative scheduled message belongs to
#       * Read-only
#
class RelativeScheduledMessage < Entity
    #
    # Saves any fields or custom variables that have changed for this relative scheduled message.
    #
    def save()
        super
    end

    #
    # Deletes this relative scheduled message and any associated scheduled messages.
    #
    def delete()
        @api.do_request("DELETE", get_base_api_path())
    end

    def id
        get('id')
    end

    def content
        get('content')
    end

    def content=(value)
        set('content', value)
    end

    def time_of_day
        get('time_of_day')
    end

    def time_of_day=(value)
        set('time_of_day', value)
    end

    def date_variable
        get('date_variable')
    end

    def date_variable=(value)
        set('date_variable', value)
    end

    def offset_scale
        get('offset_scale')
    end

    def offset_scale=(value)
        set('offset_scale', value)
    end

    def offset_count
        get('offset_count')
    end

    def offset_count=(value)
        set('offset_count', value)
    end

    def rrule
        get('rrule')
    end

    def rrule=(value)
        set('rrule', value)
    end

    def end_time
        get('end_time')
    end

    def end_time=(value)
        set('end_time', value)
    end

    def timezone_id
        get('timezone_id')
    end

    def timezone_id=(value)
        set('timezone_id', value)
    end

    def recipients_str
        get('recipients_str')
    end

    def group_id
        get('group_id')
    end

    def group_id=(value)
        set('group_id', value)
    end

    def contact_id
        get('contact_id')
    end

    def contact_id=(value)
        set('contact_id', value)
    end

    def to_number
        get('to_number')
    end

    def to_number=(value)
        set('to_number', value)
    end

    def route_id
        get('route_id')
    end

    def route_id=(value)
        set('route_id', value)
    end

    def service_id
        get('service_id')
    end

    def service_id=(value)
        set('service_id', value)
    end

    def audio_url
        get('audio_url')
    end

    def audio_url=(value)
        set('audio_url', value)
    end

    def tts_lang
        get('tts_lang')
    end

    def tts_lang=(value)
        set('tts_lang', value)
    end

    def tts_voice
        get('tts_voice')
    end

    def tts_voice=(value)
        set('tts_voice', value)
    end

    def message_type
        get('message_type')
    end

    def time_created
        get('time_created')
    end

    def replace_variables
        get('replace_variables')
    end

    def replace_variables=(value)
        set('replace_variables', value)
    end

    def track_clicks
        get('track_clicks')
    end

    def track_clicks=(value)
        set('track_clicks', value)
    end

    def media
        get('media')
    end

    def route_params
        get('route_params')
    end

    def route_params=(value)
        set('route_params', value)
    end

    def label_ids
        get('label_ids')
    end

    def label_ids=(value)
        set('label_ids', value)
    end

    def project_id
        get('project_id')
    end

    def get_base_api_path()
        "/projects/#{get('project_id')}/relative_scheduled/#{get('id')}"
    end
 
end

end
