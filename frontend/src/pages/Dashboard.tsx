import { useQuery } from '@tanstack/react-query'
import api from '../lib/axios'
import { format } from 'date-fns'

interface DashboardStats {
    totalDocuments: number
    activeCollaborations: number
    recentEdits: number
    totalUsers: number
}

interface RecentActivity {
    id: string
    documentTitle: string
    username: string
    action: string
    timestamp: string
}

export default function Dashboard() {
    const { data: stats } = useQuery<DashboardStats>({
        queryKey: ['dashboard-stats'],
        queryFn: async () => {
            const response = await api.get('/api/dashboard/stats')
            return response.data
        },
    })

    const { data: activities } = useQuery<RecentActivity[]>({
        queryKey: ['recent-activities'],
        queryFn: async () => {
            const response = await api.get('/api/dashboard/recent-activities')
            return response.data
        },
    })

    return (
        <div className="px-4 py-6 sm:px-0">
            <h1 className="text-3xl font-bold text-gray-900 mb-8">Dashboard</h1>

            <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4 mb-8">
                <div className="bg-white overflow-hidden shadow rounded-lg">
                    <div className="px-4 py-5 sm:p-6">
                        <dt className="text-sm font-medium text-gray-500 truncate">Total Documents</dt>
                        <dd className="mt-1 text-3xl font-semibold text-gray-900">
                            {stats?.totalDocuments || 0}
                        </dd>
                    </div>
                </div>

                <div className="bg-white overflow-hidden shadow rounded-lg">
                    <div className="px-4 py-5 sm:p-6">
                        <dt className="text-sm font-medium text-gray-500 truncate">Active Collaborations</dt>
                        <dd className="mt-1 text-3xl font-semibold text-gray-900">
                            {stats?.activeCollaborations || 0}
                        </dd>
                    </div>
                </div>

                <div className="bg-white overflow-hidden shadow rounded-lg">
                    <div className="px-4 py-5 sm:p-6">
                        <dt className="text-sm font-medium text-gray-500 truncate">Recent Edits (24h)</dt>
                        <dd className="mt-1 text-3xl font-semibold text-gray-900">
                            {stats?.recentEdits || 0}
                        </dd>
                    </div>
                </div>

                <div className="bg-white overflow-hidden shadow rounded-lg">
                    <div className="px-4 py-5 sm:p-6">
                        <dt className="text-sm font-medium text-gray-500 truncate">Total Users</dt>
                        <dd className="mt-1 text-3xl font-semibold text-gray-900">
                            {stats?.totalUsers || 0}
                        </dd>
                    </div>
                </div>
            </div>

            <div className="bg-white shadow overflow-hidden sm:rounded-md">
                <div className="px-4 py-5 sm:px-6">
                    <h3 className="text-lg leading-6 font-medium text-gray-900">Recent Activity</h3>
                </div>
                <ul className="divide-y divide-gray-200">
                    {activities?.map((activity) => (
                        <li key={activity.id}>
                            <div className="px-4 py-4 sm:px-6">
                                <div className="flex items-center justify-between">
                                    <p className="text-sm font-medium text-primary-600 truncate">
                                        {activity.documentTitle}
                                    </p>
                                    <div className="ml-2 flex-shrink-0 flex">
                                        <p className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                                            {activity.action}
                                        </p>
                                    </div>
                                </div>
                                <div className="mt-2 sm:flex sm:justify-between">
                                    <div className="sm:flex">
                                        <p className="flex items-center text-sm text-gray-500">
                                            {activity.username}
                                        </p>
                                    </div>
                                    <div className="mt-2 flex items-center text-sm text-gray-500 sm:mt-0">
                                        <p>{format(new Date(activity.timestamp), 'PPp')}</p>
                                    </div>
                                </div>
                            </div>
                        </li>
                    ))}
                </ul>
            </div>
        </div>
    )
}
