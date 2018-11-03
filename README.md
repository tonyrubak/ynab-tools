# ynab-tools

This library contains modules `ynab_api` and `ynab_tools`.

`ynab_api` wraps the YNAB API for Julia. It provides full access to the API. Use of the API will require authentication with a token or oauth. See [here](https://api.youneedabudget.com/#authentication) for authentication details.

`ynab_tools` provides tools for managing your YNAB account that are not provided by YNAB. At this time the only tool that is provided is a reconciliation tool that allows you to reconcile accounts at any point in time, rather than only being able to reconcile as of now.

## Usage Example
```julia
import JSON, ynab_api, ynab_tools

api = Dict("key" => api_key) # Put your API key in here
budgets = JSON.parse(ynab_api.budgets(api))["data"]["budgets"]
accounts = JSON.parse(ynab_api.accounts(api, budgets[1]["id"]))["data"]["accounts"]
budget = budgets[1]["id"]
account = accounts[1]["id"]
transactions = JSON.parse(ynab_api.account_transactions(api,
                                                        budget,
                                                        account))["data"]["transactions"]
rec = ynab_tools.reconcile(transactions, ynab_tools.parse_date("2018-10-31"), 1000000,
                           ynab_tools.parse_date("2018-10-01"), 750000)
ynab_tools.reconcile_report(rec)
```

## API Documentation
See [YNAB API Endpoints](https://api.youneedabudget.com/v1) for documentation on the contents of the return values of the API.
