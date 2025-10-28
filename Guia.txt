¡Claro! Te ayudaré a poner en marcha este proyecto de RAG (Retrieval-Augmented Generation) con PDFs. Vamos paso a paso.
📋 Pre-requisitos
Antes de empezar, asegúrate de tener instalado:

Python 3.11.4
Node.js y npm
PostgreSQL
pyenv (para gestionar versiones de Python)
poetry (para gestionar dependencias de Python)

🚀 Pasos de Instalación
1. Configurar PostgreSQL
Primero, crea las bases de datos necesarias:
bashpsql -U postgres
CREATE DATABASE pdf_rag_history;
CREATE DATABASE pdf_rag;  # Para los vectores
\q
2. Configurar Variables de Entorno
Crea un archivo .env en el directorio raíz del proyecto (v1-166-part5/) con:
envOPENAI_API_KEY=tu_api_key_aqui
DATABASE_URL=postgresql+psycopg://postgres:postgres@localhost:5432/pdf_rag
LANGCHAIN_TRACING_V2=true
LANGCHAIN_API_KEY=tu_langsmith_key_aqui
LANGCHAIN_PROJECT=pdf-rag-project
3. Instalar Backend
Abre una terminal en el directorio raíz del proyecto:
bash# Crear y activar entorno virtual con pyenv
pyenv virtualenv 3.11.4 pdf-rag-env
pyenv activate pdf-rag-env

# Instalar dependencias con pip
pip install -r requirements.txt

# Ir al directorio backend e instalar con poetry
cd v1-166-part5
poetry install
4. Instalar Frontend
Abre una segunda terminal en el directorio raíz:
bash# Ir al directorio frontend
cd v1-166-part5/frontend

# Instalar dependencias exactas
npm ci

# Si npm ci falla, usa:
npm install
5. Crear Directorio para PDFs
En el directorio raíz de v1-166-part5/:
bashmkdir -p pdf-documents
6. Iniciar el Proyecto
Terminal 1 - Backend:
bash# Desde v1-166-part5/
pyenv activate pdf-rag-env
python -m uvicorn app.server:app --reload --host 0.0.0.0 --port 8000
Terminal 2 - Frontend:
bash# Desde v1-166-part5/frontend/
npm start
7. Usar la Aplicación

Abre tu navegador en http://localhost:3000
Sube PDFs: Usa el botón "Upload PDFs" para subir tus documentos
Procesa los PDFs: Haz clic en "Load and Process PDFs" para indexarlos
Haz preguntas: Escribe tu pregunta y presiona "Send"

🔍 Verificar que Todo Funciona
Verificar Backend:
bashcurl http://localhost:8000/docs
Verificar Base de Datos:
bashpsql -U postgres
\c pdf_rag_history
SELECT * FROM message_store;
\q
⚠️ Posibles Problemas y Soluciones
Error: "Module not found"
bash# Reinstalar dependencias
pip install -r requirements.txt
cd v1-166-part5 && poetry install
Error: "Cannot connect to database"

Verifica que PostgreSQL esté corriendo: pg_ctl status
Verifica la URL en el archivo .env

Error en el Frontend
bash# Limpiar cache y reinstalar
cd v1-166-part5/frontend
rm -rf node_modules package-lock.json
npm install
Error: "Port already in use"
bash# Matar proceso en puerto 8000
lsof -ti:8000 | xargs kill -9

# Matar proceso en puerto 3000
lsof -ti:3000 | xargs kill -9
🎯 Características Principales

Multiquery Technique: Genera múltiples consultas para mejorar la recuperación
Chat History: Mantiene el contexto de la conversación usando PostgreSQL
Streaming: Respuestas en tiempo real
Source Citations: Muestra las fuentes de los PDFs utilizados

📊 Monitoreo con LangSmith
Si configuraste LangSmith, puedes ver las trazas en: https://smith.langchain.com