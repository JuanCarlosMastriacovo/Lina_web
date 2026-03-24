"""Traduccion de funciones VB.NET Krpt y KrptAux a Python."""


def _vb_asc(ch: str) -> int:
    # Emula Asc de VB sobre un byte ANSI (cp1252).
    return ch.encode("cp1252")[0]


def _vb_chr(value: int) -> str:
    # Emula Chr de VB para valores de 0..255 en cp1252.
    if value < 0 or value > 255:
        raise ValueError(f"Valor fuera de rango para Chr: {value}")
    return bytes([value]).decode("cp1252")


def Krpt(InputString: str) -> str:
    rV = ""
    LongSubCadForKrpt = 10

    try:
        # Replica: K = Int((Len(InputString) / 10) + 1)
        K = int((len(InputString) / LongSubCadForKrpt) + 1)

        # En VB el rango es 1..K (incluido)
        for j in range(1, K + 1):
            start = (j - 1) * LongSubCadForKrpt
            usSubInString = InputString[start : start + LongSubCadForKrpt]
            rV = rV + KrptAux(usSubInString)

    except Exception as exc:
        msg = "Krpt: Error de la aplicacion al encriptar cadena.\r" + InputString
        raise Exception(msg) from exc

    return rV


def KrptAux(InputString: str) -> str:
    rV = ""
    iL = 1

    try:
        # En VB iL arranca en 1 y usa Len con indices 1-based
        while iL <= len(InputString):
            ch = InputString[iL - 1]
            try:
                asc_val = _vb_asc(ch)
            except Exception:
                asc_val = 0

            if 149 - asc_val <= 0:
                MidInstr = ch
            else:
                # CInt((-1) ^ iL) en VB: -1 para impar, +1 para par
                sign = -1 if (iL % 2) == 1 else 1
                MidInstr = _vb_chr(149 - asc_val + sign * iL)

            rV = rV + MidInstr
            iL = iL + 1

    except Exception as exc:
        msg = "KrptAux: Error de la aplicacion al encriptar cadena auxiliar.\r" + InputString
        raise Exception(msg) from exc

    return rV
