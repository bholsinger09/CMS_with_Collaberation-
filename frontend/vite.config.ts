import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
    plugins: [react()],
    resolve: {
        alias: {
            '@': path.resolve(__dirname, './src'),
        },
    },
    server: {
        host: '0.0.0.0',
        port: 3000,
        strictPort: true,
        hmr: {
            protocol: 'ws',
            host: 'cmscallabration.duckdns.org',
            port: 3000,
            clientPort: 3000
        },
        watch: {
            usePolling: true
        },
        allowedHosts: [
            'localhost',
            'cmscallabration.duckdns.org',
            '.duckdns.org'
        ],
        proxy: {
            '/api': {
                target: 'http://backend:8080',
                changeOrigin: true,
            },
            '/php-api': {
                target: 'http://php-server:80',
                changeOrigin: true,
                rewrite: (path) => path.replace(/^\/php-api/, '/api'),
            },
        },
    },
})
