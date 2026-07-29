<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'
import '../assets/admin-dashboard.css'

const router = useRouter()
const user = ref(JSON.parse(localStorage.getItem('user')) || {})
const stats = ref(null)
const loading = ref(true)

const fetchStats = async () => {
  try {
    const res = await axios.get('/api/dashboard/stats', {
      headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
    })
    stats.value = res.data
  } catch (err) {
    if(err.response?.status === 401) handleLogout()
  } finally {
    loading.value = false
  }
}

const handleLogout = async () => {
  try {
    await axios.post('/api/logout', {}, {
      headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
    })
  } catch(e) {}
  localStorage.clear()
  router.push('/')
}

onMounted(() => {
  if (!localStorage.getItem('token') || user.value.role !== 'admin') {
    router.push('/')
  } else {
    fetchStats()
  }
})
</script>

<template>
  <div class="admin-layout">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="brand">Control Panel</div>
      <nav class="nav-menu">
        <a href="#" class="nav-link active">Dashboard Utama</a>
        <a href="#" class="nav-link">Monitoring Permohonan</a>
        <a href="#" class="nav-link">Master Profile & User</a>
        <div style="padding-left:1rem; display:flex; flex-direction:column; gap:0.2rem">
            <a href="#" class="nav-link" style="font-size:0.8rem">➕ Tambah User</a>
            <a href="#" class="nav-link" style="font-size:0.8rem">🔑 Aktifkan / Nonaktifkan Akun</a>
        </div>
        <a href="#" class="nav-link">Master Jenis Dokumen</a>
        <div style="padding-left:1rem; display:flex; flex-direction:column; gap:0.2rem">
            <a href="#" class="nav-link" style="font-size:0.8rem">📝 Tambah / Edit Dokumen</a>
        </div>
        <a href="#" class="nav-link">Lihat Assignment History</a>
        <a href="#" class="nav-link">Log Status Histori</a>
      </nav>
      <div class="sidebar-footer">
        <button @click="handleLogout" class="btn-logout">Logout</button>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
      <header class="top-nav">
        <h2>Administrator Overview</h2>
        <div class="user-profile">
          <span>{{ user.name }} (Super Admin)</span>
          <div class="avatar">A</div>
        </div>
      </header>

      <div v-if="loading" class="loading-state">
        <div class="spinner"></div> Mengambil data analitik...
      </div>
      
      <div v-else class="content-wrapper">
        <div class="stats-grid">
          <!-- Total Permohonan -->
          <div class="stat-card primary">
            <div class="stat-icon">📄</div>
            <div class="stat-info">
              <p>Total Permohonan</p>
              <h3>{{ stats?.total || 0 }}</h3>
            </div>
          </div>
          
          <!-- Approved -->
          <div class="stat-card success">
            <div class="stat-icon">✅</div>
            <div class="stat-info">
              <p>Approved</p>
              <h3>{{ stats?.by_status?.approved || 0 }}</h3>
            </div>
          </div>

          <!-- Rejected -->
          <div class="stat-card danger">
            <div class="stat-icon">❌</div>
            <div class="stat-info">
              <p>Rejected</p>
              <h3>{{ stats?.by_status?.rejected || 0 }}</h3>
            </div>
          </div>

           <!-- Draft & Review -->
          <div class="stat-card warning">
            <div class="stat-icon">⏳</div>
            <div class="stat-info">
              <p>In Process</p>
              <h3>{{ (stats?.by_status?.draft || 0) + (stats?.by_status?.in_review || 0) }}</h3>
            </div>
          </div>
        </div>

        <!-- Activity Log Placeholder -->
        <div class="activity-section">
          <h3>Recent System Activity</h3>
          <div class="empty-state">
            <div class="empty-icon">📊</div>
            <p>Integrasi grafik dan activity log akan ditampilkan di sini.</p>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
