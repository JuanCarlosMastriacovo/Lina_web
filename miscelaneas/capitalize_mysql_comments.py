from collections import defaultdict
import re

import mysql.connector

from CapaDAL.config import MYSQL_CONFIG


LOWER_WORDS = {
    "de",
    "del",
    "la",
    "las",
    "el",
    "los",
    "y",
    "o",
    "u",
    "a",
    "al",
    "en",
    "con",
    "sin",
    "para",
    "por",
    "frente",
    "desde",
    "que",
    "este",
}

PRESERVE_UPPER = {
    "SP",
    "S/N",
    "IVA",
    "CUIT",
    "SHA2-256",
    "NAME+DIRE",
    "SUCU#01",
    "CARDEX",
}

MANUAL_COLUMN_COMMENTS = {
    ("linabanc", "provcodi"): "Codigo de Proveedor",
    ("linacaja", "cliecodi"): "Codigo de Cliente",
    ("linacohe", "cliecodi"): "Codigo de Cliente",
    ("linacode", "codedesc"): "Descripcion del Concepto",
    ("linafcde", "fcdedesc"): "Descripcion del Item",
    ("linafche", "provcodi"): "Codigo de Proveedor",
    ("linafvhe", "cliecodi"): "Codigo de Cliente",
    ("linafvhe", "fvheobse"): "Persona que Retira",
    ("linafvhe", "fvhereci"): "Numero de Recibo Simultaneo a Factura",
    ("linapahe", "provcodi"): "Codigo de Proveedor",
    ("linapahe", "paheobse"): "Persona que Recibio el Pago",
    ("linapade", "padedesc"): "Descripcion del Concepto",
    ("linacohe", "coheobse"): "Persona que Pago",
}

NUMERIC_TYPES = {
    "int",
    "tinyint",
    "smallint",
    "mediumint",
    "bigint",
    "decimal",
    "numeric",
    "float",
    "double",
    "bit",
}


def is_upper_comment(text: str) -> bool:
    if not text or "<" in text or ">" in text:
        return False
    letters = [ch for ch in text if ch.isalpha()]
    return bool(letters) and "".join(letters).upper() == "".join(letters)


def transform_token(token: str, is_first_word: bool) -> str:
    if not token:
        return token

    upper = token.upper()
    lower = token.lower()

    if upper in PRESERVE_UPPER or any(ch.isdigit() for ch in token):
        return upper

    if token.startswith("[") and "]" in token and len(token) > 3:
        marker, rest = token[:3], token[3:]
        rest_lower = rest.lower()
        if not is_first_word and rest_lower in LOWER_WORDS:
            return marker + rest_lower
        return marker + rest_lower.capitalize()

    if not is_first_word and lower in LOWER_WORDS:
        return lower

    return lower.capitalize()


def capitalize_comment(text: str) -> str:
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


def sql_quote(value: str) -> str:
    return "'" + value.replace("\\", "\\\\").replace("'", "''") + "'"


def default_sql(data_type: str, is_nullable: str, column_default) -> str:
    if column_default is None:
        return " DEFAULT NULL" if is_nullable == "YES" else ""

    default_text = str(column_default)
    if data_type in {"timestamp", "datetime"} and default_text.upper().startswith("CURRENT_TIMESTAMP"):
        return f" DEFAULT {default_text}"

    if data_type in NUMERIC_TYPES and re.fullmatch(r"-?\d+(\.\d+)?", default_text.strip()):
        return f" DEFAULT {default_text.strip()}"

    return f" DEFAULT {sql_quote(default_text)}"


def build_definition(row: tuple, new_comment: str) -> str:
    (
        _table_name,
        column_name,
        column_type,
        data_type,
        is_nullable,
        column_default,
        extra,
        character_set_name,
        collation_name,
        _column_comment,
    ) = row

    parts = [f"`{column_name}` {column_type}"]

    if character_set_name:
        parts.append(f"CHARACTER SET {character_set_name}")
    if collation_name:
        parts.append(f"COLLATE {collation_name}")

    parts.append("NULL" if is_nullable == "YES" else "NOT NULL")

    default_clause = default_sql((data_type or "").lower(), is_nullable, column_default)
    if default_clause:
        parts.append(default_clause.strip())

    extra_text = (extra or "").replace("DEFAULT_GENERATED", "").strip()
    if extra_text:
        parts.append(extra_text)

    parts.append(f"COMMENT {sql_quote(new_comment)}")
    return " ".join(parts)


def main() -> None:
    conn = mysql.connector.connect(**MYSQL_CONFIG)
    cur = conn.cursor()

    cur.execute(
        """
        SELECT table_name,
               column_name,
               column_type,
               data_type,
               is_nullable,
               column_default,
               extra,
               character_set_name,
               collation_name,
               column_comment
        FROM information_schema.columns
        WHERE table_schema = DATABASE()
          AND column_comment <> ''
        ORDER BY table_name, ordinal_position
        """
    )
    rows = cur.fetchall()

    changes_by_table = defaultdict(list)
    preview = []

    for row in rows:
        table_name = row[0]
        column_name = row[1]
        column_comment = row[9]

        manual_comment = MANUAL_COLUMN_COMMENTS.get((table_name, column_name))
        if manual_comment:
            new_comment = manual_comment
        else:
            if not is_upper_comment(column_comment):
                continue
            new_comment = capitalize_comment(column_comment)

        if new_comment == column_comment:
            continue

        definition = build_definition(row, new_comment)
        changes_by_table[table_name].append((column_name, definition, column_comment, new_comment))
        if len(preview) < 20:
            preview.append((table_name, column_name, column_comment, new_comment))

    for table_name, changes in changes_by_table.items():
        clauses = [f"MODIFY COLUMN {definition}" for _, definition, _, _ in changes]
        sql = f"ALTER TABLE `{table_name}`\n  " + ",\n  ".join(clauses)
        cur.execute(sql)

    cur.execute(
        """
        SELECT table_name, table_comment
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
          AND table_comment <> ''
        ORDER BY table_name
        """
    )
    table_rows = cur.fetchall()
    table_changes = []
    for table_name, table_comment in table_rows:
        if not is_upper_comment(table_comment):
            continue
        new_comment = capitalize_comment(table_comment)
        if new_comment == table_comment:
            continue
        cur.execute(
            f"ALTER TABLE `{table_name}` COMMENT = %s",
            (new_comment,),
        )
        table_changes.append((table_name, table_comment, new_comment))

    conn.commit()

    print({
        "tables_changed": len(changes_by_table),
        "columns_changed": sum(len(changes) for changes in changes_by_table.values()),
        "table_comment_changes": len(table_changes),
        "sample": preview,
    })

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()