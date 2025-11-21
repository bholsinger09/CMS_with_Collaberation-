import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import api from '../lib/axios'

interface Media {
    id: string
    fileName: string
    filePath: string
    fileType: string
    fileSize: number
    altText?: string
    description?: string
    uploadedBy: string
    uploadedAt: string
}

interface MediaResponse {
    media: Media[]
    total: number
    page: number
    pageSize: number
    totalPages: number
}

export default function MediaLibrary() {
    const [selectedFile, setSelectedFile] = useState<File | null>(null)
    const [altText, setAltText] = useState('')
    const [description, setDescription] = useState('')
    const [page, setPage] = useState(1)
    const [filterType, setFilterType] = useState<string>('')
    const queryClient = useQueryClient()

    const { data: mediaData, isLoading } = useQuery<MediaResponse>({
        queryKey: ['media', page, filterType],
        queryFn: async () => {
            const params = new URLSearchParams({ page: page.toString() })
            if (filterType) params.append('type', filterType)
            const response = await api.get(`/api/media?${params}`)
            return response.data
        },
    })

    const uploadMutation = useMutation({
        mutationFn: async () => {
            if (!selectedFile) throw new Error('No file selected')
            
            const formData = new FormData()
            formData.append('file', selectedFile)
            if (altText) formData.append('altText', altText)
            if (description) formData.append('description', description)

            const response = await api.post('/api/media/upload', formData, {
                headers: { 'Content-Type': 'multipart/form-data' }
            })
            return response.data
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['media'] })
            setSelectedFile(null)
            setAltText('')
            setDescription('')
        },
    })

    const deleteMutation = useMutation({
        mutationFn: async (id: string) => {
            await api.delete(`/api/media/${id}`)
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['media'] })
        },
    })

    const formatFileSize = (bytes: number) => {
        if (bytes < 1024) return bytes + ' B'
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
        return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
    }

    const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files[0]) {
            setSelectedFile(e.target.files[0])
        }
    }

    return (
        <div className="px-4 py-6 sm:px-0">
            <div className="sm:flex sm:items-center sm:justify-between mb-6">
                <div>
                    <h1 className="text-3xl font-bold text-gray-900">Media Library</h1>
                    <p className="mt-2 text-sm text-gray-700">
                        Upload and manage your media files
                    </p>
                </div>
            </div>

            {/* Upload Section */}
            <div className="bg-white shadow rounded-lg p-6 mb-6">
                <h2 className="text-lg font-medium mb-4">Upload New Media</h2>
                <div className="space-y-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            Select File
                        </label>
                        <input
                            type="file"
                            onChange={handleFileSelect}
                            accept="image/*,video/*,application/pdf"
                            className="block w-full text-sm text-gray-500
                                file:mr-4 file:py-2 file:px-4
                                file:rounded-md file:border-0
                                file:text-sm file:font-semibold
                                file:bg-primary-50 file:text-primary-700
                                hover:file:bg-primary-100"
                        />
                        {selectedFile && (
                            <p className="mt-2 text-sm text-gray-600">
                                Selected: {selectedFile.name} ({formatFileSize(selectedFile.size)})
                            </p>
                        )}
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            Alt Text
                        </label>
                        <input
                            type="text"
                            value={altText}
                            onChange={(e) => setAltText(e.target.value)}
                            className="w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
                            placeholder="Descriptive text for accessibility"
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            Description
                        </label>
                        <textarea
                            value={description}
                            onChange={(e) => setDescription(e.target.value)}
                            rows={3}
                            className="w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
                            placeholder="Optional description"
                        />
                    </div>

                    <button
                        onClick={() => uploadMutation.mutate()}
                        disabled={!selectedFile || uploadMutation.isPending}
                        className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        {uploadMutation.isPending ? 'Uploading...' : 'Upload'}
                    </button>
                </div>
            </div>

            {/* Filter Section */}
            <div className="mb-4 flex space-x-2">
                <button
                    onClick={() => setFilterType('')}
                    className={`px-3 py-1 rounded-md text-sm ${!filterType ? 'bg-primary-600 text-white' : 'bg-gray-200 text-gray-700'}`}
                >
                    All
                </button>
                <button
                    onClick={() => setFilterType('image')}
                    className={`px-3 py-1 rounded-md text-sm ${filterType === 'image' ? 'bg-primary-600 text-white' : 'bg-gray-200 text-gray-700'}`}
                >
                    Images
                </button>
                <button
                    onClick={() => setFilterType('video')}
                    className={`px-3 py-1 rounded-md text-sm ${filterType === 'video' ? 'bg-primary-600 text-white' : 'bg-gray-200 text-gray-700'}`}
                >
                    Videos
                </button>
            </div>

            {/* Media Grid */}
            {isLoading ? (
                <div className="text-center py-12">Loading media...</div>
            ) : (
                <>
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 mb-6">
                        {mediaData?.media.map((item) => (
                            <div key={item.id} className="bg-white rounded-lg shadow overflow-hidden">
                                {item.fileType.startsWith('image/') ? (
                                    <img
                                        src={`${import.meta.env.VITE_API_URL}${item.filePath}`}
                                        alt={item.altText || item.fileName}
                                        className="w-full h-48 object-cover"
                                    />
                                ) : (
                                    <div className="w-full h-48 bg-gray-200 flex items-center justify-center">
                                        <span className="text-4xl">📄</span>
                                    </div>
                                )}
                                <div className="p-4">
                                    <p className="text-sm font-medium text-gray-900 truncate">
                                        {item.fileName}
                                    </p>
                                    <p className="text-xs text-gray-500 mt-1">
                                        {formatFileSize(item.fileSize)}
                                    </p>
                                    <div className="mt-3 flex space-x-2">
                                        <button
                                            onClick={() => {
                                                navigator.clipboard.writeText(`${import.meta.env.VITE_API_URL}${item.filePath}`)
                                            }}
                                            className="flex-1 text-xs px-2 py-1 bg-gray-100 text-gray-700 rounded hover:bg-gray-200"
                                        >
                                            Copy URL
                                        </button>
                                        <button
                                            onClick={() => deleteMutation.mutate(item.id)}
                                            className="text-xs px-2 py-1 bg-red-100 text-red-700 rounded hover:bg-red-200"
                                        >
                                            Delete
                                        </button>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* Pagination */}
                    {mediaData && mediaData.totalPages > 1 && (
                        <div className="flex justify-center space-x-2">
                            <button
                                onClick={() => setPage(p => Math.max(1, p - 1))}
                                disabled={page === 1}
                                className="px-4 py-2 border rounded-md disabled:opacity-50"
                            >
                                Previous
                            </button>
                            <span className="px-4 py-2">
                                Page {page} of {mediaData.totalPages}
                            </span>
                            <button
                                onClick={() => setPage(p => Math.min(mediaData.totalPages, p + 1))}
                                disabled={page === mediaData.totalPages}
                                className="px-4 py-2 border rounded-md disabled:opacity-50"
                            >
                                Next
                            </button>
                        </div>
                    )}
                </>
            )}
        </div>
    )
}
