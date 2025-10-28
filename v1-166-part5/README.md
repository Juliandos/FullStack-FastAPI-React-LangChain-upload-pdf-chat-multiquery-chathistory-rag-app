📚 RAG Chat History PDF - v1-166-part5
Mostrar imagen
Mostrar imagen
Mostrar imagen
Mostrar imagen
Mostrar imagen
A powerful RAG (Retrieval-Augmented Generation) system with conversational memory that allows you to chat with your PDF documents using natural language. Built with LangChain, FastAPI, and React.
✨ Features

🤖 Intelligent Document Q&A: Ask questions about your PDF documents in natural language
💬 Conversational Memory: Maintains context across multiple questions using PostgreSQL-backed chat history
🔍 Multi-Query Retrieval: Automatically generates multiple query variations for better document retrieval
📄 PDF Processing: Upload and process multiple PDF documents with semantic chunking
⚡ Real-time Streaming: Get responses word-by-word using Server-Sent Events (SSE)
🎯 Source Citations: Every answer includes clickable links to source documents
🔒 Private & Secure: Your documents stay on your infrastructure

🏗️ Architecture
┌─────────────┐      ┌──────────────┐      ┌─────────────────┐
│   Frontend  │─────▶│   Backend    │─────▶│   PostgreSQL    │
│   (React)   │      │  (FastAPI)   │      │   - Embeddings  │
│             │◀─────│              │◀─────│   - Chat History│
└─────────────┘      └──────────────┘      └─────────────────┘
      │                      │                       │
      │                      ▼                       │
      │              ┌──────────────┐               │
      │              │   LangChain  │               │
      │              │   - RAG      │               │
      │              │   - Memory   │               │
      │              └──────────────┘               │
      │                      │                       │
      └──────────────────────┼───────────────────────┘
                             ▼
                    ┌──────────────┐
                    │  OpenAI API  │
                    │  - GPT-4     │
                    │  - Embeddings│
                    └──────────────┘
🚀 Quick Start
Prerequisites

Python 3.11.4
Poetry 1.8.2
PostgreSQL 14+ with pgvector extension
Node.js 18+
OpenAI API key

Installation

Clone the repository

bashgit clone <repository-url>
cd v1-166-part5

Set up Python environment

bash# Install pyenv and Python 3.11.4
pyenv install 3.11.4
pyenv global 3.11.4

# Install Poetry
pipx install poetry==1.8.2

# Create and activate virtual environment
pyenv virtualenv 3.11.4 rag-v1-166-env
pyenv activate rag-v1-166-env

# Configure Poetry
poetry env use $(pyenv which python)

Set up databases

bash# Connect to PostgreSQL
psql -U postgres

# Create embeddings database
CREATE DATABASE database164;
\c database164
CREATE EXTENSION IF NOT EXISTS vector;

# Create chat history database
\c postgres
CREATE DATABASE pdf_rag_history;
\c pdf_rag_history

CREATE TABLE message_store (
    id SERIAL PRIMARY KEY,
    session_id TEXT NOT NULL,
    message JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_message_store_session_id ON message_store(session_id);
\q

Configure environment variables

bash# Create .env file
cp .env.example .env  # or create manually

# Edit .env with your credentials
OPENAI_API_KEY=sk-proj-YOUR_KEY_HERE
DATABASE_URL=postgresql+psycopg://postgres:YOUR_PASSWORD@localhost:5432/database164

Install dependencies

bash# Backend
poetry install

# Frontend
cd frontend
npm install
npm install uuid @types/uuid  # Additional required packages
cd ..

Process your PDFs

bash# Place your PDF files in pdf-documents/
mkdir -p pdf-documents
cp /path/to/your/pdfs/*.pdf pdf-documents/

# Run the processing script
poetry run python rag-data-loader/rag_load_and_process.py

Start the application

bash# Terminal 1 - Backend
poetry run uvicorn app.server:app --reload --port 8000

# Terminal 2 - Frontend
cd frontend
npm start
```

8. **Access the application**
```
Frontend: http://localhost:3000
Backend API: http://localhost:8000/docs
```

## 📖 Usage

### Asking Questions

1. Type your question in the text area
2. Press Enter or click "Send"
3. Watch as the AI streams its response in real-time
4. Click on source links to view the original PDF documents

### Uploading New PDFs

1. Click "Choose File" and select one or more PDF files
2. Click "Upload PDFs"
3. Click "Load and Process PDFs" to index the documents
4. Start asking questions about your newly uploaded documents

### Conversational Context

The system maintains conversation history automatically:
- Ask follow-up questions without repeating context
- The AI understands references to previous messages
- Each session has its own isolated conversation thread

## 🛠️ Technology Stack

### Backend
- **FastAPI**: Modern, high-performance web framework
- **LangChain**: RAG orchestration and memory management
- **OpenAI**: GPT-4 for generation, text-embedding-ada-002 for embeddings
- **PostgreSQL + pgvector**: Vector storage and similarity search
- **psycopg**: PostgreSQL driver for chat history

### Frontend
- **React + TypeScript**: Type-safe UI development
- **Tailwind CSS**: Utility-first styling
- **Server-Sent Events**: Real-time streaming responses

### Key Components

#### Backend (`app/`)
- `server.py`: FastAPI application with CORS, file upload, and endpoint routing
- `rag_chain.py`: RAG chain with conversational memory implementation
- Multi-query retrieval for improved document recall
- Standalone question generation from chat history

#### Frontend (`frontend/src/`)
- `App.tsx`: Main React component with SSE streaming
- `index.css`: Tailwind configuration
- UUID-based session management

#### Data Processing (`rag-data-loader/`)
- `rag_load_and_process.py`: PDF loading and semantic chunking
- Unstructured PDF parsing
- Vector embedding generation and storage

## 📁 Project Structure
```
v1-166-part5/
├── app/
│   ├── server.py              # FastAPI server
│   └── rag_chain.py           # RAG chain with memory
├── frontend/
│   ├── src/
│   │   ├── App.tsx            # Main React component
│   │   └── index.css          # Tailwind styles
│   └── package.json
├── pdf-documents/             # PDF storage directory
├── rag-data-loader/
│   └── rag_load_and_process.py  # PDF processing script
├── pyproject.toml             # Python dependencies
├── .env                       # Environment variables
├── Dockerfile                 # Container configuration
├── Guia.md                    # Detailed setup guide (Spanish)
└── README.md                  # This file
🔧 Configuration
Environment Variables
bash# Required
OPENAI_API_KEY=sk-proj-...              # Your OpenAI API key
DATABASE_URL=postgresql+psycopg://...   # Embeddings database

# Optional (for monitoring)
LANGCHAIN_TRACING_V2=true
LANGCHAIN_ENDPOINT=https://api.smith.langchain.com
LANGCHAIN_API_KEY=lsv2_pt_...
LANGCHAIN_PROJECT=rag-chat-history-project
Database Connections

Embeddings: Configured via DATABASE_URL environment variable
Chat History: Hardcoded in app/rag_chain.py as:

python  postgres_memory_url = "postgresql+psycopg://postgres:postgres@localhost:5432/pdf_rag_history"
🐛 Troubleshooting
Common Issues
1. "Module 'psycopg' not found"
bashpoetry add psycopg
2. PostgreSQL connection refused
bashsudo systemctl status postgresql
sudo systemctl start postgresql
3. pgvector extension missing
bashsudo apt install postgresql-16-pgvector
psql -U postgres -d database164 -c "CREATE EXTENSION vector;"
4. CORS errors
Check app/server.py and ensure your origin is in the allow_origins list. Note: Fix the missing comma after "http://localhost:3000".
5. Frontend: uuid is not defined
bashcd frontend
npm install uuid @types/uuid
Verification Commands
bash# Check Python version
python --version  # Should be 3.11.4

# Check Poetry version
poetry --version  # Should be 1.8.2

# Verify databases
psql -U postgres -l | grep -E "database164|pdf_rag_history"

# Check embeddings count
psql -U postgres -d database164 -c "SELECT COUNT(*) FROM langchain_pg_embedding;"

# View recent conversations
psql -U postgres -d pdf_rag_history -c "SELECT session_id, message->>'type', created_at FROM message_store ORDER BY created_at DESC LIMIT 5;"
📚 Documentation
For detailed setup instructions, see Guia.md (Spanish).
API Endpoints

POST /rag/invoke - Single query with full response
POST /rag/stream - Streaming query with SSE
POST /upload - Upload PDF files
POST /load-and-process-pdfs - Process uploaded PDFs
GET /docs - Interactive API documentation

Example API Call
bashcurl -X POST "http://localhost:8000/rag/stream" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "question": "What is this document about?"
    },
    "config": {
      "configurable": {
        "sessionId": "test-session-123"
      }
    }
  }'
🚢 Deployment
Docker Deployment
bash# Build and run with Docker Compose
docker-compose up --build

# Access the application
Frontend: http://localhost:3000
Backend: http://localhost:8000
Production Considerations

Use managed PostgreSQL databases
Configure HTTPS with Nginx reverse proxy
Implement rate limiting
Set up monitoring with LangSmith
Use environment-specific .env files
Implement user authentication
Set up backup strategies for databases

🤝 Contributing
Contributions are welcome! Please:

Fork the repository
Create a feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request

📝 License
This project is licensed under the MIT License - see the LICENSE file for details.
🙏 Acknowledgments

LangChain for the RAG framework
FastAPI for the backend framework
pgvector for vector similarity search
OpenAI for LLM and embeddings

📧 Support
For detailed setup instructions and troubleshooting, refer to Guia.md.

Built with ❤️ using LangChain, FastAPI, and React