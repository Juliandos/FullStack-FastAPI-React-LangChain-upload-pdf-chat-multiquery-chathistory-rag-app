# 📘 Guía Técnica Completa: RAG Chat History PDF - v1-166-part5

## 🎯 Objetivo

Esta guía te permitirá levantar desde cero el proyecto "v1-166-part5", un sistema RAG (Retrieval-Augmented Generation) con memoria conversacional persistente, basado en LangChain, FastAPI y React.

## 📋 Tabla de Contenidos

1. [Requisitos del Sistema](#1-requisitos-del-sistema)
2. [Configuración de Python y Poetry](#2-configuración-de-python-y-poetry)
3. [Creación de Bases de Datos PostgreSQL](#3-creación-de-bases-de-datos-postgresql)
4. [Configuración del Entorno (.env)](#4-configuración-del-entorno-env)
5. [Instalación de Dependencias](#5-instalación-de-dependencias)
6. [Verificación de Esquemas de Bases de Datos](#6-verificación-de-esquemas-de-bases-de-datos)
7. [Carga y Procesamiento de PDFs](#7-carga-y-procesamiento-de-pdfs)
8. [Ejecución del Backend](#8-ejecución-del-backend)
9. [Ejecución del Frontend](#9-ejecución-del-frontend)
10. [Pruebas del Sistema](#10-pruebas-del-sistema)
11. [Verificación de Memoria Conversacional](#11-verificación-de-memoria-conversacional)
12. [Solución de Problemas](#12-solución-de-problemas)

---

## 1. Requisitos del Sistema

### Software Necesario

- **Python 3.11.4**
- **Poetry 1.8.2**
- **PostgreSQL 14+** con extensión pgvector
- **Node.js 18+** (para el frontend)
- **Clave OpenAI API**

---

## 2. Configuración de Python y Poetry

### 2.1 Instalar pyenv (Gestor de Versiones de Python)

```bash
# Instalar pyenv (Linux/macOS)
curl https://pyenv.run | bash

# Agregar a ~/.bashrc o ~/.zshrc
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Recargar shell
source ~/.bashrc  # o source ~/.zshrc
```

### 2.2 Instalar Python 3.11.4

```bash
# Instalar Python 3.11.4
pyenv install 3.11.4

# Verificar instalación
pyenv versions
```

**Salida esperada:**
```
  system
* 3.11.4 (set by /home/usuario/.pyenv/version)
```

### 2.3 Configurar Python Global

```bash
# Establecer 3.11.4 como versión global
pyenv global 3.11.4

# Verificar versión activa
python --version
```

**Salida esperada:**
```
Python 3.11.4
```

### 2.4 Instalar Poetry con pipx

```bash
# Instalar pipx si no lo tienes
python -m pip install --user pipx
python -m pipx ensurepath

# Instalar Poetry 1.8.2
pipx install poetry==1.8.2

# Verificar instalación
poetry --version
```

**Salida esperada:**
```
Poetry (version 1.8.2)
```

### 2.5 Crear Entorno Virtual del Proyecto

```bash
# Navegar a la raíz del proyecto
cd /ruta/a/tu/proyecto/v1-166-part5

# Crear entorno virtual con pyenv
pyenv virtualenv 3.11.4 rag-v1-166-env

# Activar el entorno
pyenv activate rag-v1-166-env

# Verificar entorno activo
pyenv which python
```

**Salida esperada:**
```
/home/usuario/.pyenv/versions/3.11.4/envs/rag-v1-166-env/bin/python
```

### 2.6 Configurar Poetry para Usar el Entorno

```bash
# Configurar Poetry para usar el entorno actual
poetry env use $(pyenv which python)

# Verificar configuración
poetry env info
```

**Salida esperada:**
```
Virtualenv
Python:         3.11.4
Implementation: CPython
Path:           /home/usuario/.pyenv/versions/3.11.4/envs/rag-v1-166-env
Executable:     /home/usuario/.pyenv/versions/3.11.4/envs/rag-v1-166-env/bin/python
Valid:          True
```

---

## 3. Creación de Bases de Datos PostgreSQL

### 3.1 Conectarse a PostgreSQL

```bash
# Conectar como usuario postgres
psql -U postgres
```

**Prompt esperado:**
```
psql (16.10 (Ubuntu 16.10-0ubuntu0.24.04.1))
Type "help" for help.

postgres=#
```

### 3.2 Crear Base de Datos para Embeddings (database164)

```sql
-- Crear base de datos principal
CREATE DATABASE database164;

-- Listar bases de datos para verificar
\l | grep database164
```

**Salida esperada:**
```
 database164                   | postgres | UTF8     | libc            | C.UTF-8 | C.UTF-8 |            |           |
```

### 3.3 Habilitar Extensión pgvector en database164

```sql
-- Conectarse a database164
\c database164

-- Crear extensión pgvector
CREATE EXTENSION IF NOT EXISTS vector;

-- Verificar extensión
\dx
```

**Salida esperada:**
```
                                      List of installed extensions
  Name   | Version |   Schema   |                         Description
---------+---------+------------+--------------------------------------------------------------
 plpgsql | 1.0     | pg_catalog | PL/pgSQL procedural language
 vector  | 0.7.0   | public     | vector data type and ivfflat and hnsw access methods
(2 rows)
```

### 3.4 Crear Base de Datos para Historial (pdf_rag_history)

```sql
-- Salir de database164
\c postgres

-- Crear base de datos de historial
CREATE DATABASE pdf_rag_history;

-- Verificar creación
\l | grep pdf_rag_history
```

**Salida esperada:**
```
 pdf_rag_history               | postgres | UTF8     | libc            | C.UTF-8 | C.UTF-8 |            |           |
```

### 3.5 Crear Tabla message_store en pdf_rag_history

```sql
-- Conectarse a pdf_rag_history
\c pdf_rag_history

-- Crear tabla para historial de conversaciones
CREATE TABLE IF NOT EXISTS message_store (
    id SERIAL PRIMARY KEY,
    session_id TEXT NOT NULL,
    message JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índice para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_message_store_session_id ON message_store(session_id);

-- Verificar tabla creada
\dt
```

**Salida esperada:**
```
             List of relations
 Schema |     Name      | Type  |  Owner
--------+---------------+-------+----------
 public | message_store | table | postgres
(1 row)
```

### 3.6 Salir de PostgreSQL

```sql
-- Salir de psql
\q
```

---

## 4. Configuración del Entorno (.env)

### 4.1 Crear Archivo .env

```bash
# Desde la raíz del proyecto
touch .env
```

### 4.2 Editar Archivo .env

```bash
nano .env  # o usa tu editor preferido
```

**Contenido del archivo .env:**

```bash
# OpenAI Configuration
OPENAI_API_KEY=sk-proj-TU_CLAVE_OPENAI_AQUI

# Database Configuration - Embeddings
DATABASE_URL=postgresql+psycopg://postgres:TU_PASSWORD@localhost:5432/database164

# Database Configuration - Chat History (usado en rag_chain.py)
# postgres_memory_url en el código
# postgresql+psycopg://postgres:postgres@localhost:5432/pdf_rag_history

# LangSmith Configuration (Opcional - para monitoreo)
LANGCHAIN_TRACING_V2=true
LANGCHAIN_ENDPOINT=https://api.smith.langchain.com
LANGCHAIN_API_KEY=lsv2_pt_TU_CLAVE_LANGSMITH
LANGCHAIN_PROJECT=rag-chat-history-project
```

⚠️ **Importante:** 
- Reemplaza `TU_CLAVE_OPENAI_AQUI` con tu clave real de OpenAI
- Reemplaza `TU_PASSWORD` con tu contraseña de PostgreSQL
- La URL de `pdf_rag_history` está hardcodeada en `app/rag_chain.py` como `postgresql+psycopg://postgres:postgres@localhost:5432/pdf_rag_history`

### 4.3 Verificar Formato de URLs

```bash
# Verificar que la URL esté correcta
cat .env | grep DATABASE
```

**Salida esperada:**
```
DATABASE_URL=postgresql+psycopg://postgres:tu_password@localhost:5432/database164
```

---

## 5. Instalación de Dependencias

### 5.1 Backend - Instalar con Poetry

```bash
# Asegurarse de estar en la raíz del proyecto
cd /ruta/a/tu/proyecto/v1-166-part5

# Asegurarse de que el entorno virtual está activado
pyenv activate rag-v1-166-env

# Instalar dependencias del backend
poetry install
```

**Salida esperada (parcial):**
```
Installing dependencies from lock file

Package operations: 120 installs, 0 updates, 0 removals

  - Installing certifi (2024.x.x)
  - Installing charset-normalizer (3.x.x)
  ...
  - Installing fastapi (0.x.x)
  - Installing langchain-core (0.x.x)
  - Installing langchain-openai (0.x.x)
  - Installing langchain-community (0.x.x)
  - Installing psycopg (3.1.18)
  - Installing pgvector (0.2.5)
  ...

Installing the current project: 164-rag-for-pdfs-v2 (0.1.0)
```

### 5.2 Verificar Instalación de Dependencias

```bash
# Verificar paquetes instalados
poetry show | grep -E "fastapi|langchain|psycopg|pgvector"
```

**Salida esperada:**
```
fastapi                   0.x.x
langchain-community       0.0.31
langchain-core            0.x.x
langchain-experimental    0.0.55
langchain-openai          0.1.1
psycopg                   3.1.18
pgvector                  0.2.5
```

### 5.3 Frontend - Instalar con npm

```bash
# Navegar al directorio del frontend
cd frontend

# Instalar dependencias
npm install
```

**Salida esperada (parcial):**
```
added 1500 packages, and audited 1501 packages in 45s

250 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

### 5.4 Verificar Instalación del Frontend

```bash
# Verificar paquetes clave
npm list react react-dom uuid @microsoft/fetch-event-source tailwindcss
```

**Salida esperada:**
```
frontend@0.1.0
├── @microsoft/fetch-event-source@2.0.1
├── react-dom@18.2.0
├── react@18.2.0
└── tailwindcss@3.4.3
```

**Nota:** El proyecto no tiene uuid en package.json, necesitarás instalarlo:

```bash
npm install uuid @types/uuid
```

---

## 6. Verificación de Esquemas de Bases de Datos

### 6.1 Verificar Esquema de pdf_rag_history

```bash
# Conectarse a la base de datos
psql -U postgres -d pdf_rag_history
```

**Verificar tablas:**

```sql
\dt
```

**Salida esperada:**
```
             List of relations
 Schema |     Name      | Type  |  Owner
--------+---------------+-------+----------
 public | message_store | table | postgres
(1 row)
```

**Verificar estructura de message_store:**

```sql
\d message_store
```

**Salida esperada:**
```
                              Table "public.message_store"
   Column   |            Type             | Collation | Nullable |                  Default
------------+-----------------------------+-----------+----------+-------------------------------------------
 id         | integer                     |           | not null | nextval('message_store_id_seq'::regclass)
 session_id | text                        |           | not null |
 message    | jsonb                       |           | not null |
 created_at | timestamp without time zone |           |          | CURRENT_TIMESTAMP
Indexes:
    "message_store_pkey" PRIMARY KEY, btree (id)
    "idx_message_store_session_id" btree (session_id)
```

**Salir:**

```sql
\q
```

### 6.2 Verificar Esquema de database164

```bash
# Conectarse a database164
psql -U postgres -d database164
```

**Verificar tablas:**

```sql
\dt
```

**Salida esperada (antes de cargar PDFs):**
```
Did not find any relations.
```

**O después de cargar PDFs:**
```
             List of relations
 Schema |          Name           | Type  |  Owner
--------+-------------------------+-------+----------
 public | langchain_pg_collection | table | postgres
 public | langchain_pg_embedding  | table | postgres
(2 rows)
```

**Verificar estructura de langchain_pg_collection:**

```sql
\d langchain_pg_collection
```

**Salida esperada:**
```
            Table "public.langchain_pg_collection"
  Column   |       Type        | Collation | Nullable | Default
-----------+-------------------+-----------+----------+---------
 name      | character varying |           |          |
 cmetadata | json              |           |          |
 uuid      | uuid              |           | not null |
Indexes:
    "langchain_pg_collection_pkey" PRIMARY KEY, btree (uuid)
Referenced by:
    TABLE "langchain_pg_embedding" CONSTRAINT "langchain_pg_embedding_collection_id_fkey" 
    FOREIGN KEY (collection_id) REFERENCES langchain_pg_collection(uuid) ON DELETE CASCADE
```

**Salir:**

```sql
\q
```

---

## 7. Carga y Procesamiento de PDFs

### 7.1 Colocar PDFs en el Directorio

```bash
# Crear directorio si no existe
mkdir -p pdf-documents

# Copiar tus PDFs al directorio
cp /ruta/a/tus/pdfs/*.pdf pdf-documents/

# Verificar PDFs copiados
ls -lh pdf-documents/
```

**Salida esperada:**
```
total 5.2M
-rw-r--r-- 1 usuario usuario 1.2M oct 27 10:00 documento1.pdf
-rw-r--r-- 1 usuario usuario 850K oct 27 10:00 documento2.pdf
-rw-r--r-- 1 usuario usuario 3.1M oct 27 10:00 documento3.pdf
```

### 7.2 Ejecutar Script de Procesamiento

```bash
# Desde la raíz del proyecto
poetry run python rag-data-loader/rag_load_and_process.py
```

**Salida esperada:**
```
Loading documents: 100%|██████████| 3/3 [00:02<00:00,  1.2it/s]
Created 167 chunks from documents
Vector database created successfully!
```

### 7.3 Verificar Datos Cargados en la Base de Datos

```bash
# Conectarse a database164
psql -U postgres -d database164

# Verificar colección creada
SELECT name, uuid FROM langchain_pg_collection;
```

**Salida esperada:**
```
       name       |                 uuid
------------------+--------------------------------------
 collection164    | 12345678-1234-1234-1234-123456789abc
(1 row)
```

**Verificar embeddings:**

```sql
SELECT COUNT(*) as total_embeddings FROM langchain_pg_embedding;
```

**Salida esperada:**
```
 total_embeddings
------------------
              167
(1 row)
```

**Ver muestra de documentos:**

```sql
SELECT LEFT(document, 100) as document_preview, cmetadata->>'source' as source
FROM langchain_pg_embedding
LIMIT 3;
```

**Salir:**

```sql
\q
```

---

## 8. Ejecución del Backend

### 8.1 Iniciar Servidor Backend

```bash
# Desde la raíz del proyecto
# Asegurarse de que el entorno virtual está activado
pyenv activate rag-v1-166-env

# Iniciar servidor con hot-reload
poetry run uvicorn app.server:app --reload --port 8000
```

**Salida esperada:**
```
INFO:     Will watch for changes in these directories: ['/ruta/proyecto']
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process [12345] using WatchFiles
INFO:     Started server process [12346]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

### 8.2 Verificar Salud del Backend

```bash
# En otra terminal
curl http://localhost:8000/docs
```

Deberías ver la interfaz de Swagger UI con los siguientes endpoints:
- `/rag/invoke` - Consulta simple
- `/rag/stream` - Consulta con streaming
- `/upload` - Subir archivos PDF
- `/load-and-process-pdfs` - Procesar PDFs subidos

### 8.3 Probar Endpoint Básico

```bash
curl -X POST "http://localhost:8000/rag/invoke" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "question": "¿Qué contienen estos documentos?"
    },
    "config": {
      "configurable": {
        "sessionId": "test-session-123"
      }
    }
  }'
```

---

## 9. Ejecución del Frontend

### 9.1 Iniciar Servidor Frontend

```bash
# En una nueva terminal, navegar al frontend
cd frontend

# Iniciar servidor de desarrollo
npm start
```

**Salida esperada:**
```
Compiled successfully!

You can now view frontend in the browser.

  Local:            http://localhost:3000
  On Your Network:  http://192.168.1.100:3000

Note that the development build is not optimized.
To create a production build, use npm run build.

webpack compiled successfully
```

### 9.2 Verificar Frontend en el Navegador

Abrir en el navegador:
```
http://localhost:3000
```

**Deberías ver:**
- Header: "A Basic CHAT WITH YOUR PRIVATE PDFS Rag LLM App"
- Área de mensajes vacía
- Campo de texto para preguntas
- Botón "Send"
- Sección de carga de archivos PDF con botones:
  - "Upload PDFs"
  - "Load and Process PDFs"

---

## 10. Pruebas del Sistema

### 10.1 Prueba Básica de Consulta

**En el navegador (http://localhost:3000):**

1. **Escribe en el campo de texto:**
   ```
   ¿Qué información contienen estos documentos?
   ```

2. **Presiona Enter o click en "Send"**

**Comportamiento esperado:**
- Mensaje del usuario aparece en azul claro (bg-blue-50)
- Respuesta del AI aparece palabra por palabra (streaming)
- Al final, aparecen las fuentes con enlaces clickeables
- Los enlaces apuntan a `http://localhost:8000/rag/static/nombre-archivo.pdf`

**Salida del backend (terminal):**
```
INFO:     127.0.0.1:41560 - "POST /rag/stream HTTP/1.1" 200 OK
```

### 10.2 Prueba de Subida de PDFs

1. **Click en el input de archivos**
2. **Selecciona uno o varios PDFs**
3. **Click en "Upload PDFs"**
4. **Click en "Load and Process PDFs"**

**Comportamiento esperado:**
- Los archivos se guardan en `/pdf-documents`
- Se ejecuta el script de procesamiento
- Los nuevos documentos se indexan en la base de datos
- Console.log muestra: "Upload successful" y "PDFs loaded and processed successfully"

### 10.3 Prueba con curl

```bash
# Prueba de consulta con streaming
curl -X POST "http://localhost:8000/rag/stream" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "question": "¿Qué es un RAG?"
    },
    "config": {
      "configurable": {
        "sessionId": "test-session-456"
      }
    }
  }'
```

**Salida esperada (parcial):**
```
event: data
data: {"answer": {"content": ""}}

event: data
data: {"answer": {"content": "Un"}}

event: data
data: {"answer": {"content": " RAG"}}

...

event: data
data: {"docs": [{"metadata": {"source": "documento.pdf"}, ...}]}

event: end
```

---

## 11. Verificación de Memoria Conversacional

### 11.1 Prueba de Conversación Secuencial

**Pregunta 1:**
```
¿Qué temas tratan estos documentos?
```

**Respuesta esperada:**
```
Estos documentos tratan sobre [contenido según tus PDFs]...
```

**Pregunta 2 (pregunta contextual con mismo sessionId):**
```
¿Puedes darme más detalles?
```

**Respuesta esperada:**
```
Claro, sobre [contexto de la pregunta anterior]...
```

El sistema debería:
- Usar el mismo `sessionId` en el frontend (mantenido en `sessionIdRef`)
- Generar una pregunta standalone usando el historial
- Responder en contexto

### 11.2 Verificar Historial en la Base de Datos

```bash
# Conectarse a pdf_rag_history
psql -U postgres -d pdf_rag_history

# Ver conversaciones guardadas
SELECT 
    session_id,
    message->>'type' as type,
    LEFT(COALESCE(message->'data'->>'content', message->>'content'), 60) as content,
    created_at
FROM message_store
ORDER BY created_at DESC
LIMIT 10;
```

**Salida esperada:**
```
           session_id           | type  |                           content                            |         created_at
--------------------------------+-------+--------------------------------------------------------------+----------------------------
 cbecb465-9fba-42ca-a432-c0f... | ai    | Claro, sobre [contexto]...                                   | 2025-10-27 16:35:20.123456
 cbecb465-9fba-42ca-a432-c0f... | human | ¿Puedes darme más detalles?                                  | 2025-10-27 16:35:15.654321
 cbecb465-9fba-42ca-a432-c0f... | ai    | Estos documentos tratan sobre...                             | 2025-10-27 16:34:10.654321
 cbecb465-9fba-42ca-a432-c0f... | human | ¿Qué temas tratan estos documentos?                          | 2025-10-27 16:34:05.123456
(4 rows)
```

**Salir:**

```sql
\q
```

---

## 12. Solución de Problemas

### 12.1 Error: "Module 'psycopg' not found"

**Problema:**
```
ModuleNotFoundError: No module named 'psycopg'
```

**Solución:**
```bash
poetry add psycopg
```

### 12.2 Error: "Connection refused" al Conectar con PostgreSQL

**Verificar que PostgreSQL está corriendo:**

```bash
sudo systemctl status postgresql
```

**Si no está corriendo:**

```bash
sudo systemctl start postgresql
```

### 12.3 Error: "Extension 'vector' does not exist"

**Instalar pgvector:**

```bash
# Ubuntu/Debian
sudo apt install postgresql-16-pgvector

# Verificar instalación
psql -U postgres -c "SELECT * FROM pg_available_extensions WHERE name = 'vector';"
```

### 12.4 Frontend No Se Conecta al Backend (CORS)

**Verificar configuración CORS en `app/server.py`:**

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:3001",
        "http://localhost:3002"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

**Nota:** Hay un error de sintaxis en el código original (falta una coma después de `"http://localhost:3000"`). Corrígelo:

```python
allow_origins=[
    "http://localhost:3000",  # <-- agregar coma aquí
    "http://localhost:3001",
    "http://localhost:3002"
],
```

### 12.5 Error: "OPENAI_API_KEY not set"

**Verificar archivo .env:**

```bash
cat .env | grep OPENAI_API_KEY
```

**Si no está configurada:**

```bash
echo "OPENAI_API_KEY=sk-proj-TU_CLAVE_AQUI" >> .env
```

### 12.6 No Se Guardan Conversaciones en la DB

**Verificar conexión a pdf_rag_history:**

```bash
psql -U postgres -d pdf_rag_history -c "SELECT COUNT(*) FROM message_store;"
```

**Si la tabla no existe:**

```sql
-- Volver a ejecutar la creación de tabla (Sección 3.5)
CREATE TABLE IF NOT EXISTS message_store (
    id SERIAL PRIMARY KEY,
    session_id TEXT NOT NULL,
    message JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_message_store_session_id ON message_store(session_id);
```

### 12.7 Error: "pydantic version mismatch"

El proyecto requiere `pydantic = "<2"`. Si tienes problemas:

```bash
poetry add "pydantic<2"
poetry lock
poetry install
```

### 12.8 Frontend: uuid is not defined

El código usa `uuidv4` pero falta instalar la dependencia:

```bash
cd frontend
npm install uuid @types/uuid
```

---

## 📊 Anexo A: Arquitectura del Sistema

### A.1 Flujo de Datos

```
Usuario → Frontend (React + TypeScript)
    ↓
    ├─ Genera sessionId (UUID)
    ├─ Envía POST /rag/stream con question + config
    ↓
Backend (FastAPI + LangChain)
    ↓
    ├─ RunnableWithMessageHistory recibe request
    ├─ SQLChatMessageHistory carga historial desde pdf_rag_history
    ├─ Genera standalone question (si hay historial)
    ├─ MultiQueryRetriever genera 3 variaciones
    │   ├─ Variación 1
    │   ├─ Variación 2
    │   └─ Variación 3
    ├─ Vector search en database164 (3 búsquedas)
    ├─ Combina documentos únicos
    ├─ LLM genera respuesta (streaming con gpt-4-1106-preview)
    ├─ Guarda conversación en pdf_rag_history
    ↓
Frontend
    ↓
    └─ Muestra respuesta palabra por palabra + fuentes
```

### A.2 Componentes Principales

**Backend:**
- `app/server.py`: FastAPI server con endpoints y CORS
- `app/rag_chain.py`: Lógica de RAG con memoria conversacional
- `rag-data-loader/rag_load_and_process.py`: Procesamiento de PDFs

**Frontend:**
- `frontend/src/App.tsx`: Componente principal de React
- `frontend/src/index.css`: Estilos con Tailwind CSS

**Bases de Datos:**
- `database164`: Almacena embeddings vectoriales
- `pdf_rag_history`: Almacena historial de conversaciones

---

## 📊 Anexo B: Comandos Útiles

### B.1 Verificación Rápida del Sistema

```bash
#!/bin/bash
echo "=== Verificación del Sistema RAG ==="

echo "1. Python version:"
python --version

echo "2. Poetry version:"
poetry --version

echo "3. Entorno virtual:"
poetry env info

echo "4. PostgreSQL:"
psql -U postgres -c "SELECT version();" 2>/dev/null && echo "✅ PostgreSQL OK" || echo "❌ PostgreSQL Error"

echo "5. Bases de datos:"
psql -U postgres -l | grep -E "database164|pdf_rag_history"

echo "6. Backend:"
curl -s http://localhost:8000/docs | grep -q "FastAPI" && echo "✅ Backend OK" || echo "❌ Backend no responde"

echo "7. Frontend:"
curl -s http://localhost:3000 | grep -q "root" && echo "✅ Frontend OK" || echo "❌ Frontend no responde"
```

### B.2 Comandos de Desarrollo

```bash
# Reiniciar backend rápidamente
pkill -f uvicorn && poetry run uvicorn app.server:app --reload --port 8000

# Limpiar historial de conversaciones
psql -U postgres -d pdf_rag_history -c "TRUNCATE TABLE message_store;"

# Ver últimas 10 conversaciones
psql -U postgres -d pdf_rag_history -c "
SELECT 
    session_id,
    message->>'type' as type,
    LEFT(COALESCE(message->'data'->>'content', message->>'content'), 50) as content,
    created_at
FROM message_store
ORDER BY created_at DESC
LIMIT 10;
"

# Contar embeddings en database164
psql -U postgres -d database164 -c "SELECT COUNT(*) FROM langchain_pg_embedding;"

# Ver colecciones disponibles
psql -U postgres -d database164 -c "SELECT name, uuid FROM langchain_pg_collection;"

# Limpiar y reprocesar todos los PDFs
psql -U postgres -d database164 -c "DROP TABLE IF EXISTS langchain_pg_embedding CASCADE; DROP TABLE IF EXISTS langchain_pg_collection CASCADE;"
poetry run python rag-data-loader/rag_load_and_process.py
```

---

## 📊 Anexo C: Estructura del Proyecto

```
v1-166-part5/
│
├── app/
│   ├── __init__.py
│   ├── server.py              # FastAPI server, endpoints, CORS
│   └── rag_chain.py           # Cadena RAG con memoria conversacional
│
├── frontend/
│   ├── public/
│   │   ├── index.html
│   │   └── manifest.json
│   ├── src/
│   │   ├── App.tsx            # Componente principal React
│   │   ├── App.css
│   │   ├── index.tsx
│   │   └── index.css          # Tailwind CSS
│   ├── package.json
│   ├── tailwind.config.js
│   └── tsconfig.json
│
├── pdf-documents/             # Directorio para PDFs (crear)
│   └── *.pdf
│
├── rag-data-loader/
│   └── rag_load_and_process.py  # Script de procesamiento de PDFs
│
├── packages/                  # Directorio para paquetes LangChain
│   └── README.md
│
├── tests/
│   └── __init__.py
│
├── .env                       # Variables de entorno (crear)
├── .gitignore
├── Dockerfile
├── pyproject.toml             # Dependencias Python
├── poetry.lock
└── README.md
```

---

## 📊 Anexo D: Configuración Detallada

### D.1 Archivo pyproject.toml (Configuración del Proyecto)

```toml
[tool.poetry]
name = "164-rag-for-pdfs-v2"
version = "0.1.0"
description = ""
authors = ["Your Name <you@example.com>"]
readme = "README.md"
packages = [
    { include = "app" },
]

[tool.poetry.dependencies]
python = ">=3.11,<3.12"           # Requiere Python 3.11.x
uvicorn = "^0.23.2"               # ASGI server
langserve = {extras = ["server"], version = ">=0.0.30"}
pydantic = "<2"                   # Validación de datos (v1)
tqdm = "^4.66.2"                  # Barras de progreso
unstructured = {extras = ["all-docs"], version = "^0.12.6"}  # Procesamiento de documentos
langchain-experimental = "^0.0.55"
python-dotenv = "^1.0.1"          # Variables de entorno
langchain-openai = "^0.1.1"       # Integración OpenAI
langchain-community = "^0.0.31"   # Herramientas comunitarias
tiktoken = "^0.6.0"               # Tokenizer OpenAI
psycopg = "^3.1.18"               # Driver PostgreSQL (v3)
pgvector = "^0.2.5"               # Extensión pgvector

[tool.poetry.group.dev.dependencies]
langchain-cli = ">=0.0.15"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

### D.2 Archivo package.json (Frontend)

```json
{
  "name": "frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@microsoft/fetch-event-source": "^2.0.1",  // SSE para streaming
    "@testing-library/jest-dom": "^5.17.0",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^13.5.0",
    "@types/jest": "^27.5.2",
    "@types/node": "^16.18.95",
    "@types/react": "^18.2.74",
    "@types/react-dom": "^18.2.24",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "typescript": "^4.9.5",
    "uuid": "^9.0.0",                           // Generación de UUID
    "@types/uuid": "^9.0.8",
    "web-vitals": "^2.1.4"
  },
  "devDependencies": {
    "tailwindcss": "^3.4.3"                     // Framework CSS
  }
}
```

### D.3 Configuración de Tailwind (tailwind.config.js)

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
}
```

---

## 📊 Anexo E: Detalles de Implementación

### E.1 Cadena RAG con Memoria (app/rag_chain.py)

**Componentes Clave:**

1. **Vector Store (PGVector):**
```python
vector_store = PGVector(
    collection_name="collection164",
    connection_string=os.getenv("DATABASE_URL"),
    embedding_function=OpenAIEmbeddings()
)
```

2. **MultiQuery Retriever:**
```python
multiquery = MultiQueryRetriever.from_llm(
    retriever=vector_store.as_retriever(),
    llm=llm,
)
```
- Genera 3 variaciones de cada pregunta
- Mejora recall de documentos relevantes

3. **Chat History (SQLChatMessageHistory):**
```python
postgres_memory_url = "postgresql+psycopg://postgres:postgres@localhost:5432/pdf_rag_history"

get_session_history = lambda session_id: SQLChatMessageHistory(
    connection_string=postgres_memory_url,
    session_id=session_id
)
```
- Almacena conversaciones en PostgreSQL
- Indexadas por `session_id`

4. **Standalone Question Chain:**
```python
template_with_history="""
Given the following conversation and a follow
up question, rephrase the follow up question
to be a standalone question, in its original
language

Chat History:
{chat_history}
Follow Up Input: {question}
Standalone question:"""
```
- Reformula preguntas contextuales usando el historial
- Mantiene el idioma original

5. **Final Chain con Historia:**
```python
final_chain = RunnableWithMessageHistory(
    runnable=standalone_question_mini_chain | old_chain,
    input_messages_key="question",
    history_messages_key="chat_history",
    output_messages_key="answer",
    get_session_history=get_session_history,
)
```

### E.2 Procesamiento de PDFs (rag_load_and_process.py)

**Flujo:**

1. **Carga de documentos:**
```python
loader = DirectoryLoader(
    os.path.abspath("./pdf-documents"),
    glob="**/*.pdf",
    use_multithreading=True,
    show_progress=True,
    max_concurrency=50,
    loader_cls=UnstructuredPDFLoader,
)
docs = loader.load()
```

2. **Chunking semántico:**
```python
text_splitter = SemanticChunker(
    embeddings=embeddings
)
chunks = text_splitter.split_documents(flattened_docs)
```
- Divide documentos en chunks semánticamente coherentes
- Usa embeddings para determinar límites

3. **Creación de vector store:**
```python
PGVector.from_documents(
    documents=chunks,
    embedding=embeddings,
    collection_name="collection164",
    connection_string=os.getenv("DATABASE_URL"),
    pre_delete_collection=True,  # Limpia colección existente
)
```

### E.3 Frontend - Streaming (App.tsx)

**Manejo de SSE (Server-Sent Events):**

```typescript
await fetchEventSource(`http://localhost:8000/rag/stream`, {
  method: 'POST',
  openWhenHidden: true,
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    input: {
      question: message,
    },
    config: {
      configurable: {
        sessionId: sessionIdRef.current  // UUID persistente por sesión
      }
    }
  }),
  onmessage(event) {
    if (event.event === "data") {
      handleReceiveMessage(event.data);
    }
  },
})
```

**Construcción incremental de respuesta:**

```typescript
const setPartialMessage = (chunk: string, sources: string[] = []) => {
  setMessages(prevMessages => {
    let lastMessage = prevMessages[prevMessages.length - 1];
    if (prevMessages.length === 0 || !lastMessage.isUser) {
      return [...prevMessages.slice(0, -1), {
        message: lastMessage.message + chunk,  // Concatena chunks
        isUser: false,
        sources: lastMessage.sources ? [...lastMessage.sources, ...sources] : sources
      }];
    }
    return [...prevMessages, {message: chunk, isUser: false, sources}];
  })
}
```

---

## 📊 Anexo F: Optimizaciones y Mejores Prácticas

### F.1 Mejoras de Rendimiento

**1. Optimizar Vector Search:**

```python
# En rag_chain.py, configurar retriever con parámetros optimizados
vector_store = PGVector(
    collection_name="collection164",
    connection_string=os.getenv("DATABASE_URL"),
    embedding_function=OpenAIEmbeddings()
)

retriever = vector_store.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 4}  # Limitar resultados
)
```

**2. Pool de Conexiones PostgreSQL:**

```python
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

engine = create_engine(
    os.getenv("DATABASE_URL"),
    poolclass=QueuePool,
    pool_size=5,
    max_overflow=10,
    pool_pre_ping=True,
    pool_recycle=3600
)
```

**3. Caché de Embeddings:**

Considera usar `langchain.embeddings.cache` para evitar recalcular embeddings:

```python
from langchain.embeddings import CacheBackedEmbeddings
from langchain.storage import LocalFileStore

store = LocalFileStore("./cache/")
cached_embedder = CacheBackedEmbeddings.from_bytes_store(
    embeddings,
    store,
    namespace=embeddings.model
)
```

### F.2 Seguridad

**1. Variables de Entorno:**
- ✅ Nunca commitear `.env` al repositorio
- ✅ Usar `.env.example` como template
- ✅ Rotar claves API regularmente

**2. Validación de Inputs:**

Agregar validación en `server.py`:

```python
from pydantic import BaseModel, validator

class QueryInput(BaseModel):
    question: str
    
    @validator('question')
    def validate_question(cls, v):
        if len(v) > 1000:
            raise ValueError('Question too long (max 1000 chars)')
        if not v.strip():
            raise ValueError('Question cannot be empty')
        return v.strip()
```

**3. Rate Limiting:**

```bash
poetry add slowapi
```

```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.post("/rag/stream")
@limiter.limit("10/minute")
async def stream_query(request: Request):
    # ...
```

### F.3 Monitoreo con LangSmith

**Configurar en .env:**

```bash
LANGCHAIN_TRACING_V2=true
LANGCHAIN_ENDPOINT=https://api.smith.langchain.com
LANGCHAIN_API_KEY=lsv2_pt_TU_CLAVE
LANGCHAIN_PROJECT=rag-v1-166-part5
```

**Beneficios:**
- 📊 Trazas de ejecución en tiempo real
- ⏱️ Métricas de latencia
- 💰 Costos por consulta
- 🐛 Debugging de cadenas LangChain

---

## 📊 Anexo G: Testing

### G.1 Tests Básicos

Crear `tests/test_database.py`:

```python
import pytest
from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

load_dotenv()

def test_database164_connection():
    """Verificar conexión a database164"""
    engine = create_engine(os.getenv("DATABASE_URL"))
    with engine.connect() as conn:
        result = conn.execute(text("SELECT 1"))
        assert result.scalar() == 1

def test_pdf_rag_history_connection():
    """Verificar conexión a pdf_rag_history"""
    url = "postgresql+psycopg://postgres:postgres@localhost:5432/pdf_rag_history"
    engine = create_engine(url)
    with engine.connect() as conn:
        result = conn.execute(text("SELECT 1"))
        assert result.scalar() == 1

def test_message_store_exists():
    """Verificar tabla message_store"""
    url = "postgresql+psycopg://postgres:postgres@localhost:5432/pdf_rag_history"
    engine = create_engine(url)
    with engine.connect() as conn:
        result = conn.execute(text(
            "SELECT EXISTS (SELECT FROM information_schema.tables "
            "WHERE table_name = 'message_store')"
        ))
        assert result.scalar() is True

def test_pgvector_extension():
    """Verificar extensión pgvector"""
    engine = create_engine(os.getenv("DATABASE_URL"))
    with engine.connect() as conn:
        result = conn.execute(text(
            "SELECT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'vector')"
        ))
        assert result.scalar() is True
```

**Ejecutar tests:**

```bash
# Instalar pytest
poetry add --group dev pytest

# Ejecutar tests
poetry run pytest tests/test_database.py -v
```

**Salida esperada:**

```
tests/test_database.py::test_database164_connection PASSED           [ 25%]
tests/test_database.py::test_pdf_rag_history_connection PASSED       [ 50%]
tests/test_database.py::test_message_store_exists PASSED             [ 75%]
tests/test_database.py::test_pgvector_extension PASSED               [100%]

============================== 4 passed in 0.45s ===============================
```

### G.2 Tests de Endpoints

Crear `tests/test_api.py`:

```python
import pytest
from fastapi.testclient import TestClient
from app.server import app

client = TestClient(app)

def test_docs_endpoint():
    """Verificar endpoint de documentación"""
    response = client.get("/docs")
    assert response.status_code == 200

def test_upload_endpoint():
    """Verificar endpoint de upload"""
    response = client.post(
        "/upload",
        files=[("files", ("test.pdf", b"fake pdf content", "application/pdf"))]
    )
    assert response.status_code == 200
    assert "message" in response.json()

def test_rag_invoke():
    """Verificar endpoint de invocación"""
    response = client.post(
        "/rag/invoke",
        json={
            "input": {
                "question": "test question"
            },
            "config": {
                "configurable": {
                    "sessionId": "test-session-123"
                }
            }
        }
    )
    assert response.status_code == 200
```

---

## 📊 Anexo H: Despliegue con Docker

### H.1 Dockerfile Backend (Ya incluido en el proyecto)

```dockerfile
FROM python:3.11-slim

RUN pip install poetry==1.6.1

RUN poetry config virtualenvs.create false

WORKDIR /code

COPY ./pyproject.toml ./README.md ./poetry.lock* ./

COPY ./package[s] ./packages

RUN poetry install  --no-interaction --no-ansi --no-root

COPY ./app ./app

RUN poetry install --no-interaction --no-ansi

EXPOSE 8080

CMD exec uvicorn app.server:app --host 0.0.0.0 --port 8080
```

### H.2 Docker Compose Completo

Crear `docker-compose.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: ankane/pgvector:latest
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build: .
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      - DATABASE_URL=postgresql+psycopg://postgres:postgres@postgres:5432/database164
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    ports:
      - "8000:8080"
    volumes:
      - ./pdf-documents:/code/pdf-documents

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend
    environment:
      - REACT_APP_API_URL=http://localhost:8000

volumes:
  postgres_data:
```

### H.3 Script de Inicialización de DB

Crear `init-db.sql`:

```sql
-- Crear database164
CREATE DATABASE database164;

\c database164;
CREATE EXTENSION IF NOT EXISTS vector;

\c postgres;

-- Crear pdf_rag_history
CREATE DATABASE pdf_rag_history;

\c pdf_rag_history;

CREATE TABLE IF NOT EXISTS message_store (
    id SERIAL PRIMARY KEY,
    session_id TEXT NOT NULL,
    message JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_message_store_session_id ON message_store(session_id);
```

### H.4 Levantar con Docker

```bash
# Construir y levantar servicios
docker-compose up --build

# En segundo plano
docker-compose up -d

# Ver logs
docker-compose logs -f backend

# Detener servicios
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v
```

---

## 🎉 Conclusión

Has completado exitosamente la configuración del sistema RAG Chat History PDF v1-166-part5.

### ✅ Checklist Final

- [ ] Python 3.11.4 instalado con pyenv
- [ ] Poetry 1.8.2 instalado con pipx
- [ ] Entorno virtual creado y activado
- [ ] PostgreSQL con pgvector instalado
- [ ] Bases de datos `database164` y `pdf_rag_history` creadas
- [ ] Tabla `message_store` creada con índices
- [ ] Archivo `.env` configurado
- [ ] Dependencias backend instaladas
- [ ] Dependencias frontend instaladas (incluyendo uuid)
- [ ] PDFs colocados en `pdf-documents/`
- [ ] PDFs procesados correctamente
- [ ] Backend corriendo en http://localhost:8000
- [ ] Frontend corriendo en http://localhost:3000
- [ ] Consultas funcionando con streaming
- [ ] Memoria conversacional persistiendo en DB
- [ ] Fuentes mostrándose con enlaces

### 🚀 Próximos Pasos

1. **Mejorar la UI:**
   - Agregar indicador de "escribiendo..."
   - Mejorar diseño de las fuentes
   - Agregar botón para nueva conversación

2. **Optimizar Performance:**
   - Implementar caché de embeddings
   - Configurar pool de conexiones
   - Agregar rate limiting

3. **Agregar Funcionalidades:**
   - Autenticación de usuarios
   - Múltiples colecciones de documentos
   - Exportar conversaciones
   - Búsqueda en historial

4. **Desplegar en Producción:**
   - Usar Docker Compose
   - Configurar HTTPS con Nginx
   - Usar bases de datos gestionadas
   - Implementar monitoring con LangSmith

---

## 📚 Recursos Adicionales

- **LangChain Docs:** https://python.langchain.com/docs/
- **FastAPI Docs:** https://fastapi.tiangolo.com/
- **PostgreSQL Docs:** https://www.postgresql.org/docs/
- **pgvector GitHub:** https://github.com/pgvector/pgvector
- **React Docs:** https://react.dev/
- **Tailwind CSS:** https://tailwindcss.com/docs

---

**Documento creado:** Octubre 2025  
**Versión del sistema:** 0.1.0  
**Basado en:** v1-166-part5  
**Python:** 3.11.4 | Poetry: 1.8.2 | PostgreSQL: 14+ | React: 18.2.0