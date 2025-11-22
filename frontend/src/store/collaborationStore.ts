import { create } from 'zustand'
import * as signalR from '@microsoft/signalr'

export interface ActiveUser {
    id: string
    username: string
    color: string
    cursorPosition?: number
}

interface CollaborationState {
    connection: signalR.HubConnection | null
    activeUsers: ActiveUser[]
    isConnected: boolean
    initConnection: (documentId: string, userId: string) => Promise<void>
    disconnect: () => Promise<void>
    updateCursor: (position: number) => void
    sendContentChange: (content: string) => void
}

export const useCollaborationStore = create<CollaborationState>((set, get) => ({
    connection: null,
    activeUsers: [],
    isConnected: false,

    initConnection: async (documentId: string, userId: string) => {
        const connection = new signalR.HubConnectionBuilder()
            .withUrl(`${import.meta.env.VITE_API_URL || 'http://localhost:5000'}/collaborationHub`)
            .withAutomaticReconnect()
            .build()

        connection.on('UserJoined', (user: ActiveUser) => {
            set((state) => ({
                activeUsers: [...state.activeUsers, user],
            }))
        })

        connection.on('UserLeft', (userId: string) => {
            set((state) => ({
                activeUsers: state.activeUsers.filter((u) => u.id !== userId),
            }))
        })

        connection.on('ContentChanged', (_content: string, userId: string) => {
            // Handle content update from other users
            console.log('Content changed by', userId)
        })

        connection.on('CursorMoved', (userId: string, position: number) => {
            set((state) => ({
                activeUsers: state.activeUsers.map((u) =>
                    u.id === userId ? { ...u, cursorPosition: position } : u
                ),
            }))
        })

        try {
            await connection.start()
            await connection.invoke('JoinDocument', documentId, userId)
            set({ connection, isConnected: true })
        } catch (error) {
            console.error('SignalR connection error:', error)
        }
    },

    disconnect: async () => {
        const { connection } = get()
        if (connection) {
            await connection.stop()
            set({ connection: null, isConnected: false, activeUsers: [] })
        }
    },

    updateCursor: (position: number) => {
        const { connection } = get()
        if (connection && connection.state === signalR.HubConnectionState.Connected) {
            connection.invoke('UpdateCursor', position).catch((err) => console.error(err))
        }
    },

    sendContentChange: (content: string) => {
        const { connection } = get()
        if (connection && connection.state === signalR.HubConnectionState.Connected) {
            connection.invoke('UpdateContent', content).catch((err) => console.error(err))
        }
    },
}))
