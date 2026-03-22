
import os
import sys
import re
import mysql.connector

# Asegura que la raíz del proyecto esté en sys.path para importar CapaDAL
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

from CapaDAL.config import MYSQL_CONFIG

# Palabras a dejar en minúscula si no son la primera
LOWER_WORDS = {
    "de", "del", "la", "las", "el", "los", "y", "o", "u", "a", "al", "en", "con", "sin", "para", "por", "frente", "desde", "que", "este"
}
# Siglas a dejar en mayúscula
PRESERVE_UPPER = {"GR"}


def transform_token(token: str, is_first_word: bool) -> str:
    if not token:
        return token
    upper = token.upper()
    lower = token.lower()
    if upper in PRESERVE_UPPER or any(ch.isdigit() for ch in token):
        return upper
    if not is_first_word and lower in LOWER_WORDS:
        return lower
    return lower.capitalize()


def capitalize_name(text: str) -> str:
    parts = re.split(r"(\s+)", text.strip())
    out = []
    word_index = 0
    for part in parts:
        if not part or part.isspace():
            out.append(part)
            continue
        tokens = re.split(r"([()/\-])", part)
        converted_tokens = []
        for token in tokens:
            if token in {"", "(", ")", "/", "-"}:
                converted_tokens.append(token)
                continue
            subtokens = re.split(r"([.,:+])", token)
            converted_subtokens = []
            for subtoken in subtokens:
                if subtoken in {"", ".", ",", ":", "+"}:
                    converted_subtokens.append(subtoken)
                    continue
                converted_subtokens.append(transform_token(subtoken, word_index == 0))
                word_index += 1
            converted_tokens.append("".join(converted_subtokens))
        out.append("".join(converted_tokens))
    return "".join(out)


def main():
    conn = mysql.connector.connect(**MYSQL_CONFIG)
    cur = conn.cursor()
    cur.execute("SELECT cliecodi, cliename FROM linaclie")
    rows = cur.fetchall()
    updates = []
    for cliecodi, cliename in rows:
        if not cliename:
            continue
        new_name = capitalize_name(cliename)
        if new_name != cliename:
            updates.append((new_name, cliecodi, cliename))
    print(f"Se actualizarán {len(updates)} registros.")
    for new_name, cliecodi, old_name in updates:
        print(f"{cliecodi}: '{old_name}' -> '{new_name}'")
    # Ejecutar en base:
    for new_name, cliecodi, _ in updates:
        cur.execute("UPDATE linaclie SET cliename = %s WHERE cliecodi = %s", (new_name, cliecodi))
    conn.commit()
    cur.close()
    conn.close()

if __name__ == "__main__":
    main()
