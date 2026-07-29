import { createRouter, createWebHistory } from 'vue-router'

const routes = [
    {
        path: '/',
        name: 'Login',
        component: () => import('./views/LoginView.vue')
    },
    {
        path: '/pemohon/dashboard',
        name: 'PemohonDashboard',
        component: () => import('./views/PemohonDashboard.vue')
    },
    {
        path: '/penilai/dashboard',
        name: 'PenilaiDashboard',
        component: () => import('./views/PenilaiDashboard.vue')
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

export default router
