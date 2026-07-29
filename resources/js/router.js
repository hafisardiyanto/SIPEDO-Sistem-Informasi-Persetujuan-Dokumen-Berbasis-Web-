import { createRouter, createWebHistory } from 'vue-router';

import Login from './views/Login.vue';
import DashboardPemohon from './views/PemohonDashboard.vue';
import DashboardPenilai from './views/PenilaiDashboard.vue';

const routes = [
    { path: '/', redirect: '/login' },
    { path: '/login', component: Login, name: 'login' },
    { path: '/pemohon/dashboard', component: DashboardPemohon, name: 'dashboard.pemohon' },
    { path: '/penilai/dashboard', component: DashboardPenilai, name: 'dashboard.penilai' },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

export default router;
