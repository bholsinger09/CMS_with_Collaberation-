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
        host: true,
        port: 3000,
        strictPort: true,
        hmr: {
            protocol: 'ws',
            clientPort: 3000
        },
        watch: {
            usePolling: true
        },
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
