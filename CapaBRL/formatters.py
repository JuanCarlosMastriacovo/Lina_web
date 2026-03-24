def fmt_money(val) -> str:
    """Formatea un valor numérico con punto de miles y coma decimal: 1.234,56"""
    return f"{float(val or 0):,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
