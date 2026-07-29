<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'

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

<style scoped>
.admin-layout {
  display: flex;
  min-height: 100vh;
  background: #f4f7fa;
  font-family: 'Inter', sans-serif;
  margin: 0;
}

.sidebar {
  width: 260px;
  background: #1e293b;
  color: white;
  display: flex;
  flex-direction: column;
}

.brand {
  padding: 24px;
  font-size: 1.5rem;
  font-weight: 700;
  border-bottom: 1px solid rgba(255,255,255,0.1);
  letter-spacing: 1px;
}

.nav-menu {
  flex: 1;
  padding: 20px 0;
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.nav-link {
  padding: 12px 24px;
  color: #94a3b8;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.3s;
}

.nav-link:hover, .nav-link.active {
  background: rgba(255,255,255,0.05);
  color: #fff;
  border-left: 4px solid #3b82f6;
}

.sidebar-footer {
  padding: 20px;
  border-top: 1px solid rgba(255,255,255,0.1);
}

.btn-logout {
  width: 100%;
  padding: 10px;
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  border: 1px solid rgba(239, 68, 68, 0.2);
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}
.btn-logout:hover {
  background: #ef4444;
  color: white;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.top-nav {
  background: white;
  padding: 20px 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
}

.top-nav h2 {
  margin: 0;
  font-size: 1.25rem;
  color: #1e293b;
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 12px;
  font-weight: 500;
  color: #64748b;
}

.avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #3b82f6;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}

.content-wrapper {
  padding: 30px;
  flex: 1;
  overflow-y: auto;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
  display: flex;
  align-items: center;
  gap: 20px;
  transition: transform 0.2s;
}
.stat-card:hover {
  transform: translateY(-2px);
}

.stat-icon {
  font-size: 2rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
}

.primary .stat-icon { background: #eff6ff; color: #3b82f6; }
.success .stat-icon { background: #f0fdf4; color: #22c55e; }
.danger .stat-icon { background: #fef2f2; color: #ef4444; }
.warning .stat-icon { background: #fffbeb; color: #f59e0b; }

.stat-info p {
  margin: 0;
  color: #64748b;
  font-size: 0.875rem;
  font-weight: 600;
}
.stat-info h3 {
  margin: 5px 0 0 0;
  font-size: 1.75rem;
  color: #0f172a;
}

.activity-section {
  background: white;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
  min-height: 300px;
}
.activity-section h3 {
  margin-top: 0;
  margin-bottom: 20px;
  color: #1e293b;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 200px;
  color: #94a3b8;
}
.empty-icon {
  font-size: 3rem;
  margin-bottom: 15px;
  opacity: 0.5;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex: 1;
  color: #64748b;
  font-weight: 500;
  gap: 15px;
}
.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e2e8f0;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}
@keyframes spin { 100% { transform: rotate(360deg); } }
</style>
