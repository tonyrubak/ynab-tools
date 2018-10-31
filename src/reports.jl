module ynab_reports
function reconcile_report(account, reconcile, open_dt, open_bal,
                          stmt_dt, stmt_bal)
    c = canvas.Canvas("reconcile_$(account["name"]).pdf",
                      pagesize=pagesizes.portrait(pagesizes.letter))
    width, height = pagesizes.letter
    font = "Helvetica"
    font_size = 16
    c[:setFont](font, font_size, leading=nothing)
    text_width = pdfmetrics.stringWidth(account["name"],
                                        font,
                                        font_size)
    x_loc = (width - text_width) / 2
    text_object = c[:beginText](x_loc,
                                     9.5 * units.inch)
    text_object[:textLine](text=account["name"])
    font_size = 12
    text_object[:setFont](font, font_size, leading = nothing)
    y = text_object[:getY]()
    txt = "Period Ending $stmt_dt"
    text_width = pdfmetrics.stringWidth(txt,
                                        font,
                                        font_size)
    x_loc = (width - text_width) / 2
    text_object[:setTextOrigin](x_loc, y)
    text_object[:textLine](text=txt)
    c[:drawText](text_object)
    c[:save]()
end
end
