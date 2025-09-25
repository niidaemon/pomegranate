#!/usr/bin/env bash
set -euo pipefail

npm init -y

echo "Installing dependencies..."
npm install express cors helmet morgan dotenv
npm install -D typescript @types/node @types/express @types/cors @types/morgan nodemon ts-node

mkdir -p src/{routes,middleware,types,utils}
mkdir -p dist

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
EOF

cat > package.json << EOF
{
  "name": "",
  "version": "1.0.0",
  "description": "The notification service for the pomegranate platform",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "nodemon src/index.ts",
    "clean": "rm -rf dist",
    "prebuild": "npm run clean"
  },
  "keywords": ["typescript", "express", "api"],
  "author": "niidaemon",
  "license": "",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "typescript": "^5.2.2",
    "@types/node": "^20.8.0",
    "@types/express": "^4.17.20",
    "@types/cors": "^2.8.15",
    "@types/morgan": "^1.9.7",
    "nodemon": "^3.0.1",
    "ts-node": "^10.9.1"
  }
}
EOF

cat > src/index.ts << 'EOF'
import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import dotenv from "dotenv";
import { apiRoutes } from "./routes/api";
import { errorHandler } from "./middleware/errorHandler";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 8010;

app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "OK",
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.use("/api", apiRoutes);

app.get("/", (req, res) => {
  res.json({
    message: "TypeScript Express API Server",
    version: "1.0.0",
    endpoints: {
      health: "/health",
      api: "/api"
    }
  });
});

app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📋 Health check: http://localhost:${PORT}/health`);
});

export default app;
EOF

cat > src/routes/api.ts << 'EOF'
import { Router } from "express";

export const apiRoutes = Router();

apiRoutes.get("/", (req, res) => {
  res.json({
    message: "API is working!",
    version: "1.0.0"
  });
});

apiRoutes.get("/users", (req, res) => {
  res.json({
    users: [
      { id: 1, name: "John Doe", email: "john@example.com" },
      { id: 2, name: "Jane Smith", email: "jane@example.com" }
    ]
  });
});

apiRoutes.post("/users", (req, res) => {
  const { name, email } = req.body;
  
  if (!name || !email) {
    return res.status(400).json({
      error: "Name and email are required"
    });
  }
  
  res.status(201).json({
    message: "User created successfully",
    user: { id: Date.now(), name, email }
  });
});
EOF

cat > src/middleware/errorHandler.ts << 'EOF'
import { Request, Response, NextFunction } from "express";

export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

export const errorHandler = (
  err: AppError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const statusCode = err.statusCode || 500;
  const message = err.message || "Internal Server Error";

  console.error(`Error ${statusCode}: ${message}`);
  console.error(err.stack);

  res.status(statusCode).json({
    error: {
      message,
      status: statusCode,
      timestamp: new Date().toISOString()
    }
  });
};
EOF

cat > src/types/index.ts << 'EOF'
export interface User {
  id: number;
  name: string;
  email: string;
  createdAt?: Date;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}
EOF

cat > .env << 'EOF'
PORT=8010
NODE_ENV=development
EOF

cat > nodemon.json << 'EOF'
{
  "watch": ["src"],
  "ext": "ts,json",
  "ignore": ["src/**/*.spec.ts"],
  "exec": "ts-node src/index.ts"
}
EOF

npm install

npm run dev