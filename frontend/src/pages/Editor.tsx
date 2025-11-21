import { useEffect, useState, useRef } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import ReactQuill from 'react-quill'
import 'react-quill/dist/quill.snow.css'
import { useCollaborationStore } from '../store/collaborationStore'
import { useAuthStore } from '../store/authStore'
import api from '../lib/axios'

export default function Editor() {
    const { id } = useParams()
    const navigate = useNavigate()
    const { user } = useAuthStore()
    const { initConnection, disconnect, activeUsers, sendContentChange } = useCollaborationStore()

    const [title, setTitle] = useState('')
    const [content, setContent] = useState('')
    const [status, setStatus] = useState('draft')
    const [isSaving, setIsSaving] = useState(false)
    const quillRef = useRef<ReactQuill>(null)

    useEffect(() => {
        if (id && user) {
            // Load existing document
            loadDocument(id)
            // Note: Real-time collaboration disabled until backend is rebuilt
            // Uncomment when backend has the CollaborationHub fix deployed
            // initConnection(id, user.id)
        }

        return () => {
            // disconnect()
        }
    }, [id, user])

    const loadDocument = async (documentId: string) => {
        try {
            const response = await api.get(`/api/content/${documentId}`)
            setTitle(response.data.title)
            setContent(response.data.content)
            setStatus(response.data.status)
        } catch (error) {
            console.error('Failed to load document:', error)
        }
    }

    const handleContentChange = (value: string) => {
        setContent(value)
        sendContentChange(value)
    }

    const handleSave = async () => {
        setIsSaving(true)
        try {
            if (id) {
                await api.put(`/api/content/${id}`, {
                    title,
                    content,
                    status,
                })
            } else {
                const response = await api.post('/api/content', {
                    title,
                    content,
                    status,
                })
                navigate(`/editor/${response.data.id}`)
            }
        } catch (error) {
            console.error('Failed to save document:', error)
        } finally {
            setIsSaving(false)
        }
    }

    const handlePublish = async () => {
        setStatus('published')
        setIsSaving(true)
        try {
            await api.put(`/api/content/${id}/publish`, {
                title,
                content,
            })
        } catch (error) {
            console.error('Failed to publish document:', error)
        } finally {
            setIsSaving(false)
        }
    }

    const modules = {
        toolbar: [
            [{ header: [1, 2, 3, 4, 5, 6, false] }],
            ['bold', 'italic', 'underline', 'strike'],
            [{ list: 'ordered' }, { list: 'bullet' }],
            [{ color: [] }, { background: [] }],
            ['link', 'image'],
            ['clean'],
        ],
    }

    return (
        <div className="px-4 py-6 sm:px-0">
            <div className="mb-4 flex justify-between items-center">
                <div className="flex-1">
                    <input
                        type="text"
                        value={title}
                        onChange={(e) => setTitle(e.target.value)}
                        placeholder="Document Title"
                        className="text-3xl font-bold border-0 border-b-2 border-gray-200 focus:border-primary-500 focus:ring-0 w-full"
                    />
                </div>
                <div className="flex space-x-2 ml-4">
                    <button
                        onClick={handleSave}
                        disabled={isSaving}
                        className="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50"
                    >
                        {isSaving ? 'Saving...' : 'Save Draft'}
                    </button>
                    {id && (
                        <button
                            onClick={handlePublish}
                            disabled={isSaving}
                            className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50"
                        >
                            Publish
                        </button>
                    )}
                </div>
            </div>

            {activeUsers.length > 0 && (
                <div className="mb-4 flex items-center space-x-2">
                    <span className="text-sm text-gray-600">Active editors:</span>
                    {activeUsers.map((user) => (
                        <div
                            key={user.id}
                            className="flex items-center space-x-1 px-2 py-1 rounded-full text-xs"
                            style={{ backgroundColor: user.color + '20', color: user.color }}
                        >
                            <span className="w-2 h-2 rounded-full" style={{ backgroundColor: user.color }}></span>
                            <span>{user.username}</span>
                        </div>
                    ))}
                </div>
            )}

            <div className="bg-white shadow rounded-lg p-6">
                <ReactQuill
                    ref={quillRef}
                    theme="snow"
                    value={content}
                    onChange={handleContentChange}
                    modules={modules}
                    className="min-h-[500px]"
                />
            </div>

            <div className="mt-4 text-sm text-gray-500">
                Status: <span className="font-medium">{status}</span>
                {id && <span className="ml-4">ID: {id}</span>}
            </div>
        </div>
    )
}
