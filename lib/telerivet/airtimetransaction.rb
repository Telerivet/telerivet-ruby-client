
module Telerivet

#
# Represents a transaction where airtime is sent to a mobile phone number.
# 
# To send airtime, first [create a Custom Actions service to send a particular amount of
# airtime](/dashboard/add_service?subtype_id=main.service.rules.contact&action_id=main.rule.sendairtime),
# then trigger the service using [service.invoke](#Service.invoke),
# [project.sendBroadcast](#Project.sendBroadcast), or
# [project.scheduleMessage](#Project.scheduleMessage).
# 
# Fields:
# 
#   - id
#       * ID of the airtime transaction
#       * Read-only
#   
#   - to_number
#       * Destination phone number in international format (no leading +)
#       * Read-only
#   
#   - operator_name
#       * Operator name
#       * Read-only
#   
#   - country
#       * Country code
#       * Read-only
#   
#   - time_created (UNIX timestamp)
#       * The time that the airtime transaction was created on Telerivet's servers
#       * Read-only
#   
#   - transaction_time (UNIX timestamp)
#       * The time that the airtime transaction was sent, or null if it has not been sent
#       * Read-only
#   
#   - status
#       * Current status of airtime transaction (`successful`, `failed`, `cancelled`,
#           `queued`, `pending_approval`, or `pending_payment`)
#       * Read-only
#   
#   - status_text
#       * Error or success message returned by airtime provider, if available
#       * Read-only
#   
#   - value
#       * Value of airtime sent to destination phone number, in units of value_currency
#       * Read-only
#   
#   - value_currency
#       * Currency code of price
#       * Read-only
#   
#   - price
#       * Price charged for airtime transaction, in units of price_currency
#       * Read-only
#   
#   - price_currency
#       * Currency code of price
#       * Read-only
#   
#   - contact_id
#       * ID of the contact the airtime was sent to
#       * Read-only
#   
#   - service_id
#       * ID of the service that sent the airtime
#       * Read-only
#   
#   - project_id
#       * ID of the project that the airtime transaction belongs to
#       * Read-only
#   
#   - external_id
#       * The ID of this transaction from an external airtime gateway provider, if available.
#       * Read-only
#   
#   - vars (Hash)
#       * Custom variables stored for this transaction
#       * Updatable via API
#
class AirtimeTransaction < Entity
    def id
        get('id')
    end

    def to_number
        get('to_number')
    end

    def operator_name
        get('operator_name')
    end

    def country
        get('country')
    end

    def time_created
        get('time_created')
    end

    def transaction_time
        get('transaction_time')
    end

    def status
        get('status')
    end

    def status_text
        get('status_text')
    end

    def value
        get('value')
    end

    def value_currency
        get('value_currency')
    end

    def price
        get('price')
    end

    def price_currency
        get('price_currency')
    end

    def contact_id
        get('contact_id')
    end

    def service_id
        get('service_id')
    end

    def project_id
        get('project_id')
    end

    def external_id
        get('external_id')
    end

    def get_base_api_path()
        "/projects/#{get('project_id')}/airtime_transactions/#{get('id')}"
    end
 
end

end
