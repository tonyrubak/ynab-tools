module ynab-tools
function parse_date(s)
    df = Dates.DateFormat("yyyy-mm-dd")
    Dates.Date(s, df)
end 

function build_header(api)
    key = api["key"]
    Dict("Authorization" => "Bearer $key",
         "accept" => "application/json")
end

function ynab_get(api, request_string)
    header = build_header(api)
    r = ""
    try
        r = HTTP.request("GET", request_string, header)
    catch ex
        api["last_error"] = string(ex.status)
        r = ex.response
    end
    String(r.body)
end

function get_user(api)
    ynab_get(api, "https://api.youneedabudget.com/v1/user")
end

function get_budgets(api)
    ynab_get(api, "https://api.youneedabudget.com/v1/budgets")
end

function get_accounts(api, budget_id)
    ynab_get(api, "https://api.youneedabudget.com/v1/budgets/$(budget_id)/accounts")
end

function get_account_transactions(api, budget_id, account_id)
    ynab_get(api, "https://api.youneedabudget.com/v1//budgets/$(budget_id)/accounts/$(account_id)/transactions")
end

function reconcile(transactions, reconcile_date, stmt_balance,
                   start_date, open_balance)
    reconcile_data = filter(tx -> parse_date(tx["date"]) <= reconcile_date &&
                            parse_date(tx["date"]) >= start_date,
                            transactions)
    cleared_tx = filter(tx -> tx["cleared"] == "cleared", reconcile_data)
    uncleared_tx = filter(tx -> tx["cleared"] != "cleared", reconcile_data)
    
    cleared_balance = open_balance
    uncleared_balance = 0
    
    for tx in cleared_tx
        cleared_balance += tx["amount"]
    end

    if length(uncleared_tx) > 0
        println("*** Uncleared transactions ***")
        for tx in uncleared_tx
            println("$(tx["date"]) - $(tx["amount"])")
            uncleared_balance += tx["amount"]
        end
    end

    if cleared_balance != stmt_balance
        diff = cleared_balance - stmt_balance
        println("*** Balance Discrepancy ***")
        println("YNAB balance: $cleared_balance")
        println("Statement balance: $stmt_balance")
        println("Difference (cleared-statement): $diff")
    else
        println("*** Balances Match ***")
    end
    Dict("cleared" => cleared_balance,
         "uncleared" => uncleared_balance,
         "open" => open_balance,
         "stmt" => stmt_balance,
         "cleared_tx" => cleared_tx,
         "uncleared_tx" => uncleared_tx,
         "start_dt" => start_date,
         "end_dt" => reconcile_date)
end
end
