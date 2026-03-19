import mysql.connector

try:
    # 1. Conectar a la base de datos
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="tu_password",
        database="lina"
    )
    cursor = conn.cursor(dictionary=True) # dictionary=True para leer por nombre de columna

    # 2. Llamar al procedimiento almacenado
    # callproc devuelve una lista de los parámetros de entrada (si tuviera)
    cursor.callproc("`@_List_Columns`")

    # 3. Importante: En MySQL, los resultados de un SP se recuperan via stored_results()
    for result in cursor.stored_results():
        # Aquí obtenemos las filas del SELECT que está dentro del SP
        columnas = result.fetchall()
        
        for col in columnas:
            print(f"Tabla: {col['table_name']} | Columna: {col['column_name']} | Tipo: {col['data_type']}")

except mysql.connector.Error as err:
    print(f"Error: {err}")

finally:
    if conn.is_connected():
        cursor.close()
        conn.close()