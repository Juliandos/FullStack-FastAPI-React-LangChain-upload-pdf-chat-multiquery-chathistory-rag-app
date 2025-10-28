-- Crear database164 (para embeddings)
CREATE DATABASE database164;

-- Conectar a database164 y habilitar pgvector
\c database164;
CREATE EXTENSION IF NOT EXISTS vector;

-- Volver a postgres
\c postgres;

-- Crear pdf_rag_history (para historial de chat)
CREATE DATABASE pdf_rag_history;

-- Conectar a pdf_rag_history
\c pdf_rag_history;

-- Crear tabla message_store
CREATE TABLE IF NOT EXISTS message_store (
    id SERIAL PRIMARY KEY,
    session_id TEXT NOT NULL,
    message JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índice para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_message_store_session_id ON message_store(session_id);

-- Mostrar mensaje de confirmación
\echo 'Databases initialized successfully!'
