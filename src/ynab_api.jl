module ynab_api

import HTTP

export user, budgets, budget, budget_settings, accounts, account
export categories, category, category!, payees, payee
export payee_locations, payee_location, month
export transactions, transactions!, account_transactions
export category_transactions, payee_transactions
export transaction, transaction!
export scheduled_transactions, scheduled_transaction

"""
    build_header(api::Dict{String, String}, header_data::Dict{String, String})

Create an HTTP header for a YNAB request. The header will contain:

Authorization: Bearer `api["key"]`
accept: application/json

and any additional key/value pairs passed in through `header_data`.
"""
function build_header(api, header_data)
    key = api["key"]
    r = Dict("Authorization" => "Bearer $key",
             "accept" => "application/json")
    if header_data != nothing
        r = merge(r, header_data)
    end
    r
end

"""
    build_url(request_url::String)

Return the URL for a YNAB request. Appends `request_url` to the base API URL.
"""
function build_url(request_url)
    "https://api.youneedabudget.com/v1" * request_url
end

"""
    ynab_request(api::Dict{String, String}, method::String, url::String, header::Dict{String, String}, data

Executes an HTTP request to the YNAB API. Thee return
value is a `String` with the unparsed JSON data. 

`data` can be any type accepted by `HTTP.request` `body` parameter.
"""
function ynab_request(api, method, url, header, data)
    header = build_header(api, header)

    String(HTTP.request(method, url, header, data).body)
end

"""
    ynab_get(api::Dict{String, String}, request_url::String)

Builds and executes a `GET` request on the YNAB API.
The return value is an unparsed JSON string with
the response.
"""
function ynab_get(api, request_url)
    ynab_request(api, "GET", build_url(request_url), nothing, "")
end

"""
    ynab_patch(api::Dict{String, String}, request_url::String, data)

Builds and executes a `PATCH` request on the YNAB API
with the given data. The is an unparsed JSON string with
the response.

`data` should be a JSON string.
"""
function ynab_patch(api, request_url, data)
    ynab_request(api, "PATCH", build_url(request_url),
                 Dict("Content-Type" => "application/json"),
                 data)
end


"""
    ynab_post(api::Dict{String, String}, request_url::String, data)

Builds and executes a `POST` request on the YNAB API
with the given data. The return value is an unparsed
JSON string with the response.

`data` should be a JSON string.
"""
function ynab_post(api, request_url, data)
    ynab_request(api, "POST", build_url(request_url),
                 Dict("Content-Type" => "application/json"),
                 data)
end

"""
    ynab_put(api::Dict{String, String}, request_url::String, data)

Builds and executes a `PUT` request on the YNAB API
with the given data. The return value is an unparsed
JSON string with the response.

`data` should be a JSON string.
"""
function ynab_put(api, request_url, data)
    ynab_request(api, "POST", build_url(request_url),
                 Dict("Content-Type" => "application/json"),
                 data)
end

# User

"""
    user(api::Dict{String, String})

Returns authenticated user information as an
unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function user(api)
    ynab_get(api, "/user")
end

# Budgets

"""
    budgets(api::Dict{String, String})

Returns budgets list with summary information as an
unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function budgets(api)
    ynab_get(api, "/budgets")
end

"""
    budget(api::Dict{String, String}, budget_id::String)

Returns a single budget with all related entities
as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function budget(api, budget_id)
    ynab_get(api, "/budgets/$budget_id")
end

"""
    budget(api::Dict{String, String}, budget_id::String, last_knowledge_of_server::Int64)

Returns a single budget with all related entities
as an unparsed JSON string.

Only entities that have changed since
`last_knowledge_of_server` will be included.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function budget(api, budget_id, last_knowledge_of_server)
    ynab_get(api, "/budgets/$budget_id?last_knowdledge_of_server=$(string(last_knowledge_of_server))")
end

"""
    budget_settings(api::Dict{String, String}, budget_id::String)

Returns settings for a budget as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function budget_settings(api, budget_id)
    ynab_get(api, "/budgets/$budget_id/settings")
end

# Accounts

"""
    accounts(api::Dict{String, String}, budget_id::String)

Returns all accounts as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function accounts(api, budget_id)
    ynab_get(api, "/budgets/$(budget_id)/accounts")
end

"""
    account(api::Dict{String, String}, budget_id::String, account_id::String)

Returns a single account as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function account(api, budget_id, account_id)
    ynab_get(api, "/budgets/$(budget_id)/accounts/$account_id")
end

# Categories

"""
    categories(api::Dict{String, String}, budget_id::String)

Returns all categories grouped by category group as
an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function categories(api, budget_id)
    ynab_get(api, "/budgets/$(budget_id)/categories")
end

"""
    category(api::Dict{String, String}, budget_id::String, category_id::String)

Returns a single category as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function category(api, budget_id, category_id)
    ynab_get(api, "/budgets/$(budget_id)/categories/$category_id")
end

"""
    category(api::Dict{String, String}, budget_id::String, category_id::String, month::Int64)

Returns a single category for a specific budget month
as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function category(api, budget_id, category_id, month)
    ynab_get(api, "/budgets/$(budget_id)/months/$(string(month))/categories/$category_id")
end

"""
    category!(api::Dict{String, String}, budget_id::String, category_id::String, month::Int64, data::String)

Update an existing month category. Returns the updated
category as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function category!(api, budget_id, category_id, month, data)
    ynab_patch(api, "/budgets/$(budget_id)/months/$(string(month))/categories/$category_id",
               data)
end

# Payees

"""
    payees(api::Dict{String, String}, budget_id::String)

Returns all payees as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function payees(api, budget_id)
    ynab_get(api, "/budgets/$(budget_id)/payees")
end


"""
    payee(api::Dict{String, String}, budget_id::String, payee_id::String)

Returns a single payee as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function payee(api, budget_id, payee_id)
    ynab_get(api, "/budgets/$(budget_id)/payees/$payee_id")
end

# Payee Locations

"""
    payee_locations(api::Dict{String, String}, budget_id::String)

Returns all payee locations as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function payee_locations(api, budget_id)
    ynab_get(api, "/budgets/$(budget_id)/payee_locations")
end

"""
    payee_locations(api::Dict{String, String}, budget_id::String, payee_id::String)

Returns all payee locations for a given payee
as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function payee_locations(api, budget_id, payee_id)
    ynab_get(api, "/budgets/$(budget_id)/payees/$payee_id/payee_locations")
end


"""
    payee_location(api::Dict{String, String}, budget_id::String, payee_location_id::String)

Returns a single payee location as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function payee_location(api, budget_id, payee_location_id)
    ynab_get(api, "/budgets/$(budget_id)/payee_locations/$payee_location_id")
end

# Months

"""
    months(api::Dict{String, String}, budget_id::String)

Returns all budget months as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function months(api, budget_id)
    ynab_get(api, "/budgets/$(budget_id)/months")
end

"""
    months(api::Dict{String, String}, budget_id::String, month::Int64)

Returns a single budget month as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function month(api, budget_id, month)
    ynab_get(api, "/budgets/$(budget_id)/months/$(string(month))")
end

# Transactions

"""
    transactions(api::Dict{String, String}, budget_id::String; since_date::String, tx_type::String, last_knowledge_of_server::Int64)

Returns budget transactions as an unparsed JSON string.

If `since_date` is provided, only transactions on or
after that date are returned.

If `tx_type` is provided, only transactions of the
specified type are returned.

If `last_knowledge_of_server` is provided, only
entities that have changed since `last_knowledge_of_server`
are returned.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function transactions(api, budget_id; since_date = nothing, tx_type = nothing, last_knowledge_of_server = nothing)
    url = "/budgets/$(budget_id)/transactions"
    if since_date != nothing
        url = url * "?since_date=$since_date"
    end
    if tx_type != nothing
        url = url * "?type=$tx_type"
    end
    if last_knowledge_of_server != nothing
        url = url * "?last_knowledge_of_server=$(string(last_knowledge_of_server))"
    end
    ynab_get(api, url)
end

"""
    transactions!(api::Dict{String, String}, budget_id::String, transactions::String)

Creates a single transaction or multiple transactions.

`transactions` should be a JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function transactions!(api, budget_id, transactions)
    ynab_post(api, "/budgets/$(budget_id)/transactions",
              transactions)
end

"""
    account_transactions(api::Dict{String, String}, budget_id::String, account_id::String; since_date::String, tx_type::String, last_knowledge_of_server::Int64)

Returns budget transactions for a specified account
as an unparsed JSON string.

If `since_date` is provided, only transactions on or
after that date are returned.

If `tx_type` is provided, only transactions of the
specified type are returned.

If `last_knowledge_of_server` is provided, only
entities that have changed since `last_knowledge_of_server`
are returned.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function account_transactions(api, budget_id, account_id; since_date = nothing, tx_type = nothing, last_knowledge_of_server = nothing)
    url = "/budgets/$(budget_id)/accounts/$(account_id)/transactions"
    if since_date != nothing
        url = url * "?since_date=$since_date"
    end
    if tx_type != nothing
        url = url * "?type=$tx_type"
    end
    if last_knowledge_of_server != nothing
        url = url * "?last_knowledge_of_server=$(string(last_knowledge_of_server))"
    end
    ynab_get(api, url)
end

"""
    category_transactions(api::Dict{String, String}, budget_id::String, category_id::String; since_date::String, tx_type::String, last_knowledge_of_server::Int64)

Returns budget transactions for a specified category
as an unparsed JSON string.

If `since_date` is provided, only transactions on or
after that date are returned.

If `tx_type` is provided, only transactions of the
specified type are returned.

If `last_knowledge_of_server` is provided, only
entities that have changed since `last_knowledge_of_server`
are returned.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function category_transactions(api, budget_id, category_id; since_date = nothing, tx_type = nothing, last_knowledge_of_server = nothing)
    url = "/budgets/$(budget_id)/categories/$(category_id)/transactions"
    if since_date != nothing
        url = url * "?since_date=$since_date"
    end
    if tx_type != nothing
        url = url * "?type=$tx_type"
    end
    if last_knowledge_of_server != nothing
        url = url * "?last_knowledge_of_server=$(string(last_knowledge_of_server))"
    end
    ynab_get(api, url)
end

"""
    payee_transactions(api::Dict{String, String}, budget_id::String, payee_id::String; since_date::String, tx_type::String, last_knowledge_of_server::Int64)

Returns budget transactions for a specified payee
as an unparsed JSON string.

If `since_date` is provided, only transactions on or
after that date are returned.

If `tx_type` is provided, only transactions of the
specified type are returned.

If `last_knowledge_of_server` is provided, only
entities that have changed since `last_knowledge_of_server`
are returned.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function payee_transactions(api, budget_id, payee_id; since_date = nothing, tx_type = nothing, last_knowledge_of_server = nothing)
    url = "/budgets/$(budget_id)/payees/$(payee_id)/transactions"
    if since_date != nothing
        url = url * "?since_date=$since_date"
    end
    if tx_type != nothing
        url = url * "?type=$tx_type"
    end
    if last_knowledge_of_server != nothing
        url = url * "?last_knowledge_of_server=$(string(last_knowledge_of_server))"
    end
    ynab_get(api, url)
end

"""
    transaction(api::Dict{String, String}, budget_id::String, transaction_id::String)

Returns a single transaction as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function transaction(api, budget_id, transaction_id)
    ynab_get(api, "/budgets/$(budget_id)/transactions/$transaction_id")
end

"""
    transaction!(api::Dict{String, String}, budget_id::String, transaction_id::String, data::String)

Updates a transaction. Returns the updated transaction
as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function transaction!(api, budget_id, transaction_id, transaction)
    ynab_put(api, "/budgets/$(budget_id)/transactions/$transaction_id", transaction)
end

"""
    scheduled_transactions(api::Dict{String, String}, budget_id::String)

Returns all scheduled transactions as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function scheduled_transactions(api, budget_id)
    ynab_get(api, "/budgets/$(budget_id)/scheduled_transactions")
end

"""
    scheduled_transaction(api::Dict{String, String}, budget_id::String, transaction_id::String)

Returns a specified transactions as an unparsed JSON string.

See https://api.youneedabudget.com/v1/ for
response data format.
"""
function scheduled_transaction(api, budget_id, transaction_id)
    ynab_get(api, "/budgets/$(budget_id)/scheduled_transactions/$transaction_id")
end



# Example Usage
#
# import JSON
# import ynab_api
#
# api = Dict("key" => api_key) # Put your API key in here
# budgets = JSON.parse(ynab_api.budgets(api))["data"]["budgets"]
# accounts = JSON.parse(ynab_api.accounts(api, budgets[1]["id"]))["data"]["accounts"]
# budget = budgets[1]["id"]
# account = accounts[1]["id"]
# transactions = JSON.parse(ynab_api.account_transactions(api,
#                                                         budget,
#                                                         account))["data"]["transactions"]
