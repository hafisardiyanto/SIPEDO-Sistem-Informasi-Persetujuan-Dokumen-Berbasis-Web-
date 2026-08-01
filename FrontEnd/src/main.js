import './assets/main.css'

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import axios from 'axios'

// Set default axios configurations for Laravel Sanctum SPA Auth
axios.defaults.withCredentials = true;
axios.defaults.withXSRFToken = true;
axios.defaults.baseURL = 'http://43.133.157.230:8000';

axios.interceptors.request.use(config => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

import VueApexCharts from "vue3-apexcharts";

const app = createApp(App)
app.use(router)
app.use(VueApexCharts)
app.mount('#app')
