module ynab_tools

import Dates, Formatting

export reconcile

function parse_date(s)
    df = Dates.DateFormat("yyyy-mm-dd")
    Dates.Date(s, df)
end

function format_acct(millidollars)
    fspec = Formatting.FormatSpec(">8.2f")
    s = ""
    if millidollars < 0
        millidollars = -millidollars
        strdollars = Formatting.fmt(fspec, millidollars/1000)
        offset = max(3, Int(floor(log(10, millidollars))))
        padding = 8 - offset
        s = strdollars * ")"
        if padding > 0
            s = "\$" * repeat(" ", padding - 1) * "(" * lstrip(s)
        else
            s = "\$ (" * s
        end
    elseif millidollars == 0
        s = "\$     -    "
    else
        strdollars = Formatting.fmt(fspec, millidollars/1000)
        s = "\$  " * strdollars
    end
    s
end

function reconcile(transactions, reconcile_date, stmt_balance,
                   open_date, open_balance)

    reconcile_data = sort(filter(tx -> parse_date(tx["date"]) <= reconcile_date &&
                                 parse_date(tx["date"]) >= open_date,
                                 transactions),
                          by = tx -> tx["date"])
    cleared_tx = filter(tx -> tx["cleared"] == "cleared", reconcile_data)
    uncleared_tx = filter(tx -> tx["cleared"] != "cleared", reconcile_data)
    
    cleared_balance = open_balance
    uncleared_balance = 0
    
    for tx in cleared_tx
        cleared_balance += tx["amount"]
    end
    
    for tx in uncleared_tx
        uncleared_balance += tx["amount"]
    end
    
    Dict("cleared" => cleared_balance,
         "uncleared" => uncleared_balance,
         "cleared_tx" => cleared_tx,
         "uncleared_tx" => uncleared_tx,
         "rec_dt" => reconcile_date,
         "stmt" => stmt_balance,
         "open_dt" => open_date,
         "open" => open_balance)
end

function reconcile_report(reconciled)

    cleared_tx = reconciled["cleared_tx"]
    uncleared_tx = reconciled["uncleared_tx"]
    cleared_balance = reconciled["cleared"]
    uncleared_balance = reconciled["uncleared"]
    reconcile_date = reconciled["rec_dt"]
    stmt_balance = reconciled["stmt"]
    open_date = reconciled["open_dt"]
    open_balance = reconciled["open"]
    
    println("*** Reconciliation Report ***")
    println("Period Ending: $reconcile_date")
    println()
    println("Open       - $(format_acct(open_balance))")
    println("*** Cleared Transactions ***")
    
    for tx in cleared_tx
        println("$(tx["date"]) - $(format_acct(tx["amount"]))")
    end

    if length(uncleared_tx) > 0
        println()
        println("*** Uncleared transactions ***")
        for tx in uncleared_tx
            println("$(tx["date"]) - $(format_acct(tx["amount"]))")
        end
    end

    diff = stmt_balance - cleared_balance
    println()
    println("YNAB balance:      $(format_acct(cleared_balance))")
    println("Discrepancy:       $(format_acct(diff))")
    println("Statement balance: $(format_acct(stmt_balance))")
end
end
# Example Usage
# import JSON, ynab_api, ynab_tools
#
# api = Dict("key" => api_key) # Put your API key in here
# budgets = JSON.parse(ynab_api.budgets(api))["data"]["budgets"]
# accounts = JSON.parse(ynab_api.accounts(api, budgets[1]["id"]))["data"]["accounts"]
# budget = budgets[1]["id"]
# account = accounts[1]["id"]
# transactions = JSON.parse(ynab_api.account_transactions(api,
#                                                         budget,
#                                                         account))["data"]["transactions"]
# rec = ynab_tools.reconcile(transactions, parse_date("2018-10-01"), 1000000,
#                            parse_date("2018-09-01"), 750000)
# reconcile_report(rec, parse_date("2018-10-01"), 1000000,
#                  parse_date("2018-09-01"), 750000)
