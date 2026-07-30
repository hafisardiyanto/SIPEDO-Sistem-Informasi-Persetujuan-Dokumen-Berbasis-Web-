<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'
import '../assets/admin-dashboard.css'

const router = useRouter()
const user = ref(JSON.parse(localStorage.getItem('user')) || {})
const stats = ref(null)
const loading = ref(true)
const activeTab = ref('dashboard')

// User Management State
const users = ref([])
const loadingUsers = ref(false)
const docTypes = ref([])
const loadingDocs = ref(false)
const showDocModal = ref(false)
const docForm = ref({ id: null, name: '', description: '' })
const docFormError = ref('')

const getConfigHeaders = () => {
  return { headers: { Authorization: `Bearer ${localStorage.getItem('token')}` } }
}

const fetchStats = async () => {
  try {
    const res = await axios.get('/api/dashboard/stats', getConfigHeaders())
    stats.value = res.data
  } catch (err) {
    if(err.response?.status === 401) handleLogout()
  } finally {
    loading.value = false
  }
}

// USER CRUD LOGIC
const fetchUsers = async () => {
  loadingUsers.value = true
  try {
    const res = await axios.get('/api/admin/users', getConfigHeaders())
    users.value = res.data.data
  } catch(e) {}
  loadingUsers.value = false
}

const openUserModal = (editUser = null) => {
  if (editUser) {
    userForm.value = { ...editUser, password: '' }
  } else {
    userForm.value = { id: null, name: '', email: '', password: '', role: 'pemohon' }
  }
  userFormError.value = ''
  showUserModal.value = true
}

const saveUser = async () => {
  userFormError.value = ''
  try {
    if (userForm.value.id) {
       await axios.put(`/api/admin/users/${userForm.value.id}`, userForm.value, getConfigHeaders())
    } else {
       if(!userForm.value.password) { userFormError.value = 'Password wajib diisi untuk user baru.'; return; }
       await axios.post('/api/admin/users', userForm.value, getConfigHeaders())
    }
    showUserModal.value = false
    fetchUsers()
  } catch (err) {
    userFormError.value = err.response?.data?.message || err.response?.data?.errors?.email?.[0] || 'Gagal menyimpan user.'
  }
}

const toggleUserStatus = async (targetUser) => {
  try {
    await axios.post(`/api/admin/users/${targetUser.id}/toggle`, {}, getConfigHeaders())
    fetchUsers()
  } catch(err) { alert(err.response?.data?.message || 'Gagal toggle') }
}

const deleteUser = async (id) => {
  if(confirm('Yakin ingin menghapus permanen pengguna ini?')) {
     try {
       await axios.delete(`/api/admin/users/${id}`, getConfigHeaders())
       fetchUsers()
     } catch(err) { alert(err.response?.data?.message || 'Gagal menghapus') }
  }
}

const handleLogout = async () => {
  try {
    await axios.post('/api/logout', {}, getConfigHeaders())
  } catch(e) {}
  localStorage.clear()
  router.push('/')
}

// DOC TYPES CRUD LOGIC
const fetchDocTypes = async () => {
  loadingDocs.value = true
  try {
    const res = await axios.get('/api/admin/document-types', getConfigHeaders())
    docTypes.value = res.data.data
  } catch(e) {}
  loadingDocs.value = false
}

const openDocModal = (editDoc = null) => {
  if (editDoc) {
    docForm.value = { ...editDoc }
  } else {
    docForm.value = { id: null, name: '', description: '' }
  }
  docFormError.value = ''
  showDocModal.value = true
}

const saveDocType = async () => {
  docFormError.value = ''
  try {
    if (docForm.value.id) {
       await axios.put(`/api/admin/document-types/${docForm.value.id}`, docForm.value, getConfigHeaders())
    } else {
       await axios.post('/api/admin/document-types', docForm.value, getConfigHeaders())
    }
    showDocModal.value = false
    fetchDocTypes()
  } catch (err) {
    docFormError.value = err.response?.data?.message || 'Gagal menyimpan dokumen.'
  }
}

const toggleDocStatus = async (targetDoc) => {
  try {
    await axios.post(`/api/admin/document-types/${targetDoc.id}/toggle`, {}, getConfigHeaders())
    fetchDocTypes()
  } catch(err) { alert(err.response?.data?.message || 'Gagal toggle') }
}

const deleteDocType = async (id) => {
  if(confirm('Yakin ingin menghapus permanen jenis dokumen ini?')) {
     try {
       await axios.delete(`/api/admin/document-types/${id}`, getConfigHeaders())
       fetchDocTypes()
     } catch(err) { alert(err.response?.data?.message || 'Gagal menghapus') }
  }
}

const switchTab = (tab) => {
  activeTab.value = tab;
  if(tab === 'users') fetchUsers();
  if(tab === 'docs') fetchDocTypes();
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
        <a href="#" :class="['nav-link', activeTab==='dashboard'? 'active':'']" @click.prevent="switchTab('dashboard')">Dashboard Utama</a>
        
        <a href="#" :class="['nav-link', activeTab==='users'? 'active':'']" @click.prevent="switchTab('users')">Master Profile & User</a>
        
        <a href="#" :class="['nav-link', activeTab==='docs'? 'active':'']" @click.prevent="switchTab('docs')">Master Jenis Dokumen</a>
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
        <div class="spinner"></div> Menyinkronkan...
      </div>
      
      <div v-else class="content-wrapper">
        
        <!-- DASHBOARD TAB -->
        <div v-if="activeTab==='dashboard'">
            <div class="stats-grid">
            <div class="stat-card primary"><div class="stat-icon">📄</div><div class="stat-info"><p>Total Permohonan</p><h3>{{ stats?.total || 0 }}</h3></div></div>
            <div class="stat-card success"><div class="stat-icon">✅</div><div class="stat-info"><p>Approved</p><h3>{{ stats?.by_status?.approved || 0 }}</h3></div></div>
            <div class="stat-card danger"><div class="stat-icon">❌</div><div class="stat-info"><p>Rejected</p><h3>{{ stats?.by_status?.rejected || 0 }}</h3></div></div>
            <div class="stat-card warning"><div class="stat-icon">⏳</div><div class="stat-info"><p>In Process</p><h3>{{ (stats?.by_status?.draft || 0) + (stats?.by_status?.in_review || 0) }}</h3></div></div>
            </div>
            <div class="activity-section">
            <h3>Monitoring Status Integritas</h3>
            <div class="empty-state">
                <div class="empty-icon">🔐</div>
                <p>Sistem termonitor aman. Server Database aktif.</p>
            </div>
            </div>
        </div>

        <!-- USERS TAB -->
        <div v-if="activeTab==='users'">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem">
               <h3>Manajemen Pengguna (Pegawai & Klien)</h3>
               <button @click="openUserModal(null)" style="background:#2563eb; color:white; padding:0.6rem 1rem; border:none; border-radius:6px; font-weight:bold; cursor:pointer">+ Entri User Baru</button>
            </div>

            <table style="width:100%; border-collapse:collapse; background:white; border-radius:8px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.1)">
                <thead style="background:#f1f5f9; text-align:left">
                    <tr>
                        <th style="padding:1rem">Nama & Identitas</th>
                        <th style="padding:1rem">Email Log</th>
                        <th style="padding:1rem">Akses Peran (Role)</th>
                        <th style="padding:1rem">Status Akun</th>
                        <th style="padding:1rem; text-align:right">Aksi Manual</th>
                    </tr>
                </thead>
                <tbody>
                     <tr v-for="u in users" :key="u.id" style="border-bottom:1px solid #e2e8f0">
                        <td style="padding:1rem; font-weight:bold">{{ u.name }}</td>
                        <td style="padding:1rem">{{ u.email }}</td>
                        <td style="padding:1rem">
                            <span :style="{padding:'4px 8px', borderRadius:'4px', fontSize:'0.8rem', fontWeight:'bold', 
                            background: u.role==='admin'?'#fee2e2':u.role==='penilai'?'#fef3c7':'#e0e7ff',
                            color: u.role==='admin'?'#ef4444':u.role==='penilai'?'#d97706':'#4f46e5'}">{{ u.role.toUpperCase() }}</span>
                        </td>
                        <td style="padding:1rem">
                             <span :style="{color: u.is_active ? '#10b981':'#ef4444', fontWeight:'bold'}">{{ u.is_active ? '✅ Aktif' : '❌ Diblokir' }}</span>
                        </td>
                        <td style="padding:1rem; text-align:right; display:flex; gap:0.5rem; justify-content:flex-end">
                            <button @click="openUserModal(u)" style="padding:0.4rem 0.8rem; border:1px solid #cbd5e1; border-radius:4px; cursor:pointer; background:white">Edit</button>
                            <button @click="toggleUserStatus(u)" :style="{padding:'0.4rem 0.8rem', border:'1px solid #cbd5e1', borderRadius:'4px', cursor:'pointer', background: u.is_active ? '#fee2e2':'#dcfce3'}">{{ u.is_active ? 'Suspend' : 'Aktivasi' }}</button>
                            <button @click="deleteUser(u.id)" style="padding:0.4rem 0.8rem; border:none; border-radius:4px; cursor:pointer; background:#dc2626; color:white">Hapus</button>
                        </td>
                     </tr>
                </tbody>
            </table>
        </div>

        <!-- DOCS TAB -->
        <div v-if="activeTab==='docs'">
             <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:1.5rem">
               <h3>Konfigurasi Jenis Dokumen (Master Data)</h3>
               <button @click="openDocModal(null)" style="background:#2563eb; color:white; padding:0.6rem 1rem; border:none; border-radius:6px; font-weight:bold; cursor:pointer">+ Formulir Baru</button>
            </div>
            
             <table style="width:100%; border-collapse:collapse; background:white; border-radius:8px; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.1)">
                <thead style="background:#f1f5f9; text-align:left">
                    <tr>
                        <th style="padding:1rem; width:25%">Nama Dokumen</th>
                        <th style="padding:1rem; width:35%">Deskripsi Regulasi</th>
                        <th style="padding:1rem; width:15%">Status Aktif</th>
                        <th style="padding:1rem; text-align:right">Aksi Manual</th>
                    </tr>
                </thead>
                <tbody>
                     <tr v-for="d in docTypes" :key="d.id" style="border-bottom:1px solid #e2e8f0">
                        <td style="padding:1rem; font-weight:bold">{{ d.name }}</td>
                        <td style="padding:1rem; color:#475569; font-size:0.9rem">{{ d.description }}</td>
                        <td style="padding:1rem">
                             <span :style="{color: d.is_active ? '#10b981':'#ef4444', fontWeight:'bold'}">{{ d.is_active ? '✅ Aktif' : '❌ Nonaktif' }}</span>
                        </td>
                        <td style="padding:1rem; text-align:right; display:flex; gap:0.5rem; justify-content:flex-end">
                            <button @click="openDocModal(d)" style="padding:0.4rem 0.8rem; border:1px solid #cbd5e1; border-radius:4px; cursor:pointer; background:white">Edit</button>
                            <button @click="toggleDocStatus(d)" :style="{padding:'0.4rem 0.8rem', border:'1px solid #cbd5e1', borderRadius:'4px', cursor:pointer, background: d.is_active ? '#fee2e2':'#dcfce3'}">{{ d.is_active ? 'Matikan' : 'Aktifkan' }}</button>
                            <button @click="deleteDocType(d.id)" style="padding:0.4rem 0.8rem; border:none; border-radius:4px; cursor:pointer; background:#dc2626; color:white">Hapus</button>
                        </td>
                     </tr>
                </tbody>
            </table>
        </div>

      </div>
    </main>

    <!-- MODAL USER -->
    <div v-if="showUserModal" style="position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.5); display:flex; align-items:center; justify-content:center; z-index:9999" @click.self="showUserModal = false">
        <div style="background:white; width:90%; max-width:500px; border-radius:12px; padding:2rem; box-shadow:0 10px 25px rgba(0,0,0,0.2)">
            <h2 style="margin-top:0">{{ userForm.id ? 'Edit Profil Pengguna' : 'Buat Akses Penugasan Baru' }}</h2>
            <div v-if="userFormError" style="color:red; background:#fee2e2; padding:0.5rem; border-radius:4px; margin-bottom:1rem; font-size:0.9rem">{{ userFormError }}</div>
            
            <div style="margin-bottom:1rem">
                <label style="display:block; font-weight:bold; color:#475569; margin-bottom:0.5rem">Nama Lengkap</label>
                <input v-model="userForm.name" type="text" style="width:100%; border:1px solid #cbd5e1; padding:0.75rem; border-radius:6px; font-family:inherit; font-size:1rem; box-sizing:border-box">
            </div>
            <div style="margin-bottom:1rem">
                <label style="display:block; font-weight:bold; color:#475569; margin-bottom:0.5rem">Alamat Email Log</label>
                <input v-model="userForm.email" type="email" style="width:100%; border:1px solid #cbd5e1; padding:0.75rem; border-radius:6px; font-family:inherit; font-size:1rem; box-sizing:border-box">
            </div>
            <div style="margin-bottom:1rem">
                <label style="display:block; font-weight:bold; color:#475569; margin-bottom:0.5rem">Kasta / Hierarki (Role)</label>
                <select v-model="userForm.role" style="width:100%; border:1px solid #cbd5e1; padding:0.75rem; border-radius:6px; font-family:inherit; font-size:1rem; box-sizing:border-box; background:white">
                    <option value="pemohon">Klien / Pemohon</option>
                    <option value="penilai">Inspektor / Penilai</option>
                    <option value="admin">Administrator Global</option>
                </select>
            </div>
             <div style="margin-bottom:1.5rem">
                <label style="display:block; font-weight:bold; color:#475569; margin-bottom:0.5rem">Kata Sandi Akses {{ userForm.id ? '(Kosongkan jika tidak merubah)' : '' }}</label>
                <input v-model="userForm.password" type="password" style="width:100%; border:1px solid #cbd5e1; padding:0.75rem; border-radius:6px; font-family:inherit; font-size:1rem; box-sizing:border-box">
            </div>

            <div style="display:flex; justify-content:flex-end; gap:1rem">
                 <button @click="showUserModal=false" style="padding:0.75rem 1.5rem; background:transparent; border:none; font-weight:bold; cursor:pointer; color:#64748b">Batal</button>
                 <button @click="saveUser" style="padding:0.75rem 1.5rem; background:#2563eb; color:white; border:none; border-radius:6px; font-weight:bold; cursor:pointer">Injeksi ke Sistem</button>
            </div>
        </div>
    </div>

    <!-- MODAL DOCUMENT TYPE -->
    <div v-if="showDocModal" style="position:fixed; top:0; left:0; width:100vw; height:100vh; background:rgba(0,0,0,0.5); display:flex; align-items:center; justify-content:center; z-index:9999" @click.self="showDocModal = false">
        <div style="background:white; width:90%; max-width:500px; border-radius:12px; padding:2rem; box-shadow:0 10px 25px rgba(0,0,0,0.2)">
            <h2 style="margin-top:0">{{ docForm.id ? 'Edit Kategori Dokumen' : 'Buat Kategori Dokumen Baru' }}</h2>
            <div v-if="docFormError" style="color:red; background:#fee2e2; padding:0.5rem; border-radius:4px; margin-bottom:1rem; font-size:0.9rem">{{ docFormError }}</div>
            
            <div style="margin-bottom:1rem">
                <label style="display:block; font-weight:bold; color:#475569; margin-bottom:0.5rem">Judul/Nama Sertifikasi</label>
                <input v-model="docForm.name" type="text" style="width:100%; border:1px solid #cbd5e1; padding:0.75rem; border-radius:6px; font-family:inherit; font-size:1rem; box-sizing:border-box" placeholder="Contoh: Izin Lingkungan (AMDAL)">
            </div>
            <div style="margin-bottom:1.5rem">
                <label style="display:block; font-weight:bold; color:#475569; margin-bottom:0.5rem">Deskripsi Singkat / Syarat</label>
                <textarea v-model="docForm.description" rows="4" style="width:100%; border:1px solid #cbd5e1; padding:0.75rem; border-radius:6px; font-family:inherit; font-size:1rem; box-sizing:border-box; resize:vertical" placeholder="Jelaskan kegunaan dokumen ini..."></textarea>
            </div>

            <div style="display:flex; justify-content:flex-end; gap:1rem">
                 <button @click="showDocModal=false" style="padding:0.75rem 1.5rem; background:transparent; border:none; font-weight:bold; cursor:pointer; color:#64748b">Batal</button>
                 <button @click="saveDocType" style="padding:0.75rem 1.5rem; background:#2563eb; color:white; border:none; border-radius:6px; font-weight:bold; cursor:pointer">Simpan Ke Sistem</button>
            </div>
        </div>
    </div>
  </div>
</template>
