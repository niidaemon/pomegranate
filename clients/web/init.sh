#!/usr/bin/env bash
set -euo pipefail

echo "Creating React TypeScript Vite + TailwindCSS project..."

npm create vite@latest . -- --template react-ts

echo "Installing TailwindCSS and additional dependencies..."
npm install -D tailwindcss postcss autoprefixer @types/node
npm install lucide-react clsx tailwind-merge

npx tailwindcss init -p

cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: "#eff6ff",
          100: "#dbeafe",
          200: "#bfdbfe",
          300: "#93c5fd",
          400: "#60a5fa",
          500: "#3b82f6",
          600: "#2563eb",
          700: "#1d4ed8",
          800: "#1e40af",
          900: "#1e3a8a",
          950: "#172554",
        }
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
      },
    },
  },
  plugins: [],
}
EOF

cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import url("https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap");

@layer base {
  * {
    @apply border-border;
  }
  
  body {
    @apply bg-background text-foreground font-sans;
  }
}

@layer components {
  .btn {
    @apply inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50;
  }
  
  .btn-primary {
    @apply btn bg-primary-600 text-white shadow hover:bg-primary-700;
  }
  
  .btn-secondary {
    @apply btn bg-gray-100 text-gray-900 shadow-sm hover:bg-gray-200;
  }
  
  .card {
    @apply rounded-lg border bg-card text-card-foreground shadow-sm;
  }
}
EOF

cat > src/App.tsx << 'EOF'
import React, { useState } from "react";
import { Heart, Github, ExternalLink, Code2, Palette, Zap } from "lucide-react";

interface FeatureCardProps {
  icon: React.ReactNode
  title: string
  description: string
}

const FeatureCard: React.FC<FeatureCardProps> = ({ icon, title, description }) => (
  <div className="card p-6 hover:shadow-md transition-shadow">
    <div className="flex items-center gap-3 mb-3">
      <div className="p-2 bg-primary-100 rounded-lg text-primary-600">
        {icon}
      </div>
      <h3 className="font-semibold text-gray-900">{title}</h3>
    </div>
    <p className="text-gray-600 text-sm">{description}</p>
  </div>
)

function App() {
  const [count, setCount] = useState(0);

  const features = [
    {
      icon: <Zap className="w-5 h-5" />,
      title: "Lightning Fast",
      description: "Built with Vite for instant hot module replacement and blazing fast builds."
    },
    {
      icon: <Code2 className="w-5 h-5" />,
      title: "TypeScript",
      description: "Full TypeScript support with excellent developer experience and type safety."
    },
    {
      icon: <Palette className="w-5 h-5" />,
      title: "TailwindCSS",
      description: "Utility-first CSS framework for rapid UI development with beautiful designs."
    }
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      {/* Header */}
      <header className="bg-white/80 backdrop-blur-sm border-b border-gray-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-primary-600 rounded-lg flex items-center justify-center">
                <Code2 className="w-5 h-5 text-white" />
              </div>
              <span className="font-bold text-xl text-gray-900">React Vite App</span>
            </div>
            <div className="flex items-center gap-4">
              <a
                href="https://github.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-600 hover:text-gray-900 transition-colors"
              >
                <Github className="w-5 h-5" />
              </a>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        {/* Hero Section */}
        <div className="text-center mb-16">
          <h1 className="text-4xl md:text-6xl font-bold text-gray-900 mb-6">
            Welcome to{' '}
            <span className="bg-gradient-to-r from-primary-600 to-purple-600 bg-clip-text text-transparent">
              React + Vite
            </span>
          </h1>
          <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
            A modern React application built with TypeScript, Vite, and TailwindCSS. 
            Fast, type-safe, and beautifully designed.
          </p>
          
          {/* Counter Demo */}
          <div className="card p-8 max-w-md mx-auto mb-8">
            <h2 className="text-2xl font-semibold mb-4">Interactive Counter</h2>
            <div className="text-4xl font-bold text-primary-600 mb-4">{count}</div>
            <div className="flex gap-3 justify-center">
              <button
                className="btn-secondary px-4 py-2"
                onClick={() => setCount(count - 1)}
              >
                Decrease
              </button>
              <button
                className="btn-primary px-4 py-2"
                onClick={() => setCount(count + 1)}
              >
                Increase
              </button>
              <button
                className="btn-secondary px-4 py-2"
                onClick={() => setCount(0)}
              >
                Reset
              </button>
            </div>
          </div>
        </div>

        {/* Features Grid */}
        <div className="grid md:grid-cols-3 gap-6 mb-16">
          {features.map((feature, index) => (
            <FeatureCard
              key={index}
              icon={feature.icon}
              title={feature.title}
              description={feature.description}
            />
          ))}
        </div>

        {/* Links Section */}
        <div className="text-center">
          <h2 className="text-2xl font-semibold text-gray-900 mb-6">Learn More</h2>
          <div className="flex flex-wrap justify-center gap-4">
            {[
              { name: "React", url: "https://react.dev" },
              { name: "Vite", url: "https://vitejs.dev" },
              { name: "TypeScript", url: "https://www.typescriptlang.org" },
              { name: "TailwindCSS", url: "https://tailwindcss.com" },
            ].map((link) => (
              <a
                key={link.name}
                href={link.url}
                target="_blank"
                rel="noopener noreferrer"
                className="btn-secondary px-4 py-2 flex items-center gap-2"
              >
                {link.name}
                <ExternalLink className="w-4 h-4" />
              </a>
            ))}
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-gray-50 border-t border-gray-200 mt-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="text-center text-gray-600">
            <p className="flex items-center justify-center gap-1">
              Made with <Heart className="w-4 h-4 text-red-500" /> using React + Vite + TypeScript + TailwindCSS
            </p>
          </div>
        </div>
      </footer>
    </div>
  )
}

export default App
EOF

cat > vite.config.ts << 'EOF'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: "0.0.0.0",
    port: 5173,
  },
  preview: {
    host: "0.0.0.0",
    port: 4173,
  },
  build: {
    outDir: "dist",
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ["react", "react-dom"],
          utils: ["lucide-react", "clsx", "tailwind-merge"]
        }
      }
    }
  }
})
EOF

npm pkg set scripts.dev="vite --host"
npm pkg set scripts.build="tsc && vite build"
npm pkg set scripts.preview="vite preview --host"
npm pkg set scripts.lint="eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0"

npm install

echo "✅ React TypeScript Vite + TailwindCSS project created successfully!"