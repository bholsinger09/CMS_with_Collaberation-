import axios from 'axios'

// Create axios instance
const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL || '',
})

// Request interceptor to add auth token
api.interceptors.request.use(
    (config) => {
        // Get token from localStorage (where zustand persist stores it)
        const authStorage = localStorage.getItem('auth-storage')
        if (authStorage) {
            try {
                const { state } = JSON.parse(authStorage)
                const token = state?.user?.token
                if (token) {
                    config.headers.Authorization = `Bearer ${token}`
                }
            } catch (error) {
                console.error('Error parsing auth storage:', error)
            }
        }
        return config
    },
    (error) => {
        return Promise.reject(error)
    }
)

// Response interceptor to handle 401 errors
api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            // Clear auth storage and redirect to login
            localStorage.removeItem('auth-storage')
            window.location.href = '/login'
        }
        return Promise.reject(error)
    }
)

export default api
