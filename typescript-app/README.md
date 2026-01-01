# Custom Installation Manager

A modern web-based interface for managing and executing custom installation scripts across different platforms (Linux, Windows, Kali Linux).

## Features

- **Multi-platform Support**: Execute scripts for Linux, Windows, and Kali Linux
- **Real-time Execution Monitoring**: Live log streaming via WebSocket
- **Modern UI**: Built with React, TypeScript, and Tailwind CSS
- **RESTful API**: Backend powered by Express and Node.js
- **Docker Support**: Easy deployment with Docker and Docker Compose
- **Cross-platform Script Management**: Centralized management of all installation scripts

## Architecture

```
typescript-app/
├── backend/              # Node.js/Express API server
│   ├── src/
│   │   ├── index.ts     # Main entry point
│   │   ├── routes.ts    # API routes
│   │   ├── websocket.ts # WebSocket server
│   │   ├── types.ts     # TypeScript types
│   │   └── services/    # Business logic
│   ├── Dockerfile
│   └── package.json
├── frontend/            # React/Vite application
│   ├── src/
│   │   ├── App.tsx      # Main App component
│   │   ├── api/         # API client
│   │   ├── components/  # React components
│   │   ├── hooks/       # Custom hooks
│   │   ├── pages/       # Page components
│   │   ├── store/       # State management (Zustand)
│   │   └── types/       # TypeScript types
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
└── docker-compose.yml   # Docker orchestration
```

## Prerequisites

- Node.js 20.x or higher
- npm or yarn
- Docker and Docker Compose (for containerized deployment)

## Quick Start

### Development

1. **Clone the repository**
   ```bash
   cd typescript-app
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Setup environment variables**
   ```bash
   # Backend
   cp backend/.env.example backend/.env

   # Frontend
   cp .env.example .env
   ```

4. **Start development servers**
   ```bash
   # Start both frontend and backend
   npm run dev

   # Or separately
   npm run dev:backend
   npm run dev:frontend
   ```

5. **Access the application**
   - Frontend: http://localhost:5173
   - Backend API: http://localhost:3001
   - API Health: http://localhost:3001/health

### Production (Docker)

1. **Build and start containers**
   ```bash
   docker-compose up -d --build
   ```

2. **Access the application**
   - Frontend: http://localhost
   - Backend API: http://localhost:3001

3. **View logs**
   ```bash
   docker-compose logs -f
   ```

4. **Stop containers**
   ```bash
   docker-compose down
   ```

## Available Scripts

### Root Level
- `npm run dev` - Start both frontend and backend in development mode
- `npm run build` - Build both frontend and backend
- `npm run docker:build` - Build Docker images
- `npm run docker:up` - Start Docker containers
- `npm run docker:down` - Stop Docker containers

### Backend
- `npm run dev --workspace=backend` - Start backend dev server
- `npm run build --workspace=backend` - Build backend
- `npm run start --workspace=backend` - Start production backend

### Frontend
- `npm run dev --workspace=frontend` - Start frontend dev server
- `npm run build --workspace=frontend` - Build frontend
- `npm run preview --workspace=frontend` - Preview production build

## API Endpoints

### System
- `GET /api/system/info` - Get system information

### Scripts
- `GET /api/scripts` - Get all scripts (optional `?platform=` filter)
- `GET /api/scripts/:id` - Get specific script

### Executions
- `POST /api/execute` - Execute a script
- `GET /api/executions` - Get all executions
- `GET /api/executions/:id` - Get specific execution

### WebSocket
- `ws://localhost:3001` - WebSocket connection for real-time logs

## Available Installation Scripts

1. **Kali Cyberpunk Theme** (kali-cyberpunk)
   - Platform: Kali Linux
   - Installs Cyberpunk 2077 theme for KDE Plasma

2. **Windows Post-Installation** (windows-post-install)
   - Platform: Windows
   - Complete system configuration and optimization

3. **Windows GUI Configuration** (windows-gui)
   - Platform: Windows
   - Advanced GUI customization

4. **Docker Installation** (debian-docker)
   - Platform: Linux
   - Installs Docker on Debian-based systems

5. **Fail2ban Setup** (debian-fail2ban)
   - Platform: Linux
   - Security hardening with Fail2ban

## Technology Stack

### Backend
- **Runtime**: Node.js 20
- **Framework**: Express.js
- **Language**: TypeScript
- **WebSocket**: ws library
- **Process Management**: child_process

### Frontend
- **Framework**: React 18
- **Build Tool**: Vite
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **HTTP Client**: Axios
- **Icons**: Lucide React
- **Routing**: React Router DOM

### DevOps
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Web Server**: Nginx (production)

## Environment Variables

### Backend (.env)
```env
PORT=3001
CORS_ORIGIN=http://localhost:5173
NODE_ENV=development
```

### Frontend (.env)
```env
VITE_API_URL=http://localhost:3001
```

## Security Considerations

- Scripts are executed with the permissions of the running user
- CORS is configured to restrict API access
- WebSocket connections are monitored and managed
- Nginx security headers are configured in production
- Input validation on all API endpoints

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Submit a pull request

## License

MIT License

## Author

romish17

## Support

For issues and questions, please open an issue on GitHub.
