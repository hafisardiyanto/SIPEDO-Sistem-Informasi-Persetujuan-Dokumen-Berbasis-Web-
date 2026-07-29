<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import '../assets/penilai-dashboard.css'

const router = useRouter()
const user = ref(JSON.parse(localStorage.getItem('user')) || {})

const stats = ref({ total: 0, draft: 0, submitted: 0, in_review: 0, revision: 0, approved: 0, rejected: 0 })
const paginatedData = ref({ data: [], current_page: 1, last_page: 1, total: 0 })
const loading = ref(false)

// Toolbars
const searchQ = ref('')
const filterStatus = ref('')

const fetchStats = async () => {
    try {
        const res = await axios.get('/api/dashboard/stats')
        stats.value = res.data.data
    } catch(err) {}
}

const fetchAssessments = async (page = 1) => {
    loading.value = true
    try {
        const res = await axios.get(`/api/assessments?page=${page}&search=${searchQ.value}&status=${filterStatus.value}`)
        paginatedData.value = res.data
    } catch (err) {
        if(err.response?.status === 401) logout()
    } finally {
        loading.value = false
    }
}

watch([searchQ, filterStatus], () => {
    fetchAssessments(1)
})

onMounted(() => {
    if(!user.value || user.value.role !== 'penilai') {
        router.push('/')
        return
    }
    fetchStats()
    fetchAssessments()
})

const logout = async () => {
    try { await axios.post('/api/logout') } catch (e) {}
    localStorage.removeItem('user')
    localStorage.removeItem('token')
    router.push('/')
}

// Evaluation modal state
const showEvalModal = ref(false)
const evalFormError = ref('')
const evalUploading = ref(false)

const showConfirmModal = ref(false)
const confirmAction = ref('')

const evalData = ref({
    status: '',
    notes: ''
})

const openEvaluateModal = (project) => {
    selectedProject.value = project
    evalData.value.status = '' 
    evalData.value.notes = ''
    evalFormError.value = ''
    showEvalModal.value = true
}

const confirmAndSubmit = (status) => {
    evalData.value.status = status;
    // Advanced Logic: Required notes
    if (['rejected', 'revision'].includes(status) && !evalData.value.notes.trim()) {
        evalFormError.value = 'Wajib mengisi Catatan Penilai jika menolak atau meminta revisi.'
        return;
    }
    
    confirmAction.value = status;
    showConfirmModal.value = true;
}

const executeEvaluation = () => {
    showConfirmModal.value = false;
    submitEvaluation();
}

const submitEvaluation = async () => {
    evalFormError.value = ''
    evalUploading.value = true
    
    try {
        await axios.post(`/api/assessments/${selectedProject.value.id}/evaluate`, {
            status: evalData.value.status,
            notes: evalData.value.notes
        })
        
        // Simulasikan success popup kecil (bisa dikembangkan dengan sweetalert)
        alert('Keputusan audit berhasil dijatuhkan!');

        showEvalModal.value = false
        fetchStats()
        fetchAssessments(paginatedData.value.current_page)
    } catch (err) {
        evalFormError.value = err.response?.data?.message || err.message || 'Gagal menyimpan evaluasi.'
    } finally {
        evalUploading.value = false
    }
}

const getStatusBadgeClass = (status) => {
    const map = { 'draft': 'badge-gray', 'submitted': 'badge-blue', 'in_review': 'badge-yellow', 'revision': 'badge-orange', 'approved': 'badge-green', 'rejected': 'badge-red' }
    return map[status] || 'badge-gray'
}

const generatePages = () => {
    const pages = [];
    for (let i = 1; i <= paginatedData.value.last_page; i++) pages.push(i);
    return pages;
}

// Export logic (Placeholder that will link to API routes)
const downloadPDF = () => {
    window.open('http://localhost:8000/api/export/pdf?token=' + localStorage.getItem('token'), '_blank');
}
const downloadExcel = () => {
    window.open('http://localhost:8000/api/export/excel?token=' + localStorage.getItem('token'), '_blank');
}
</script>

<template>
  <div class="dashboard layout-row">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="brand">
        <h2>SIPEDO</h2>
        <span class="role-badge" style="background: linear-gradient(135deg, #7c3aed, #4f46e5)">VERIFIKATOR ENTERPRISE</span>
      </div>
      <nav class="menu">
        <a href="#" class="menu-item active">📋 Review Dokumen</a>
        <a href="#" @click.prevent="downloadExcel" class="menu-item" style="color: #059669">📊 Export Excel</a>
        <a href="#" @click.prevent="downloadPDF" class="menu-item" style="color: #dc2626">🖨️ Export PDF</a>
      </nav>
      <div class="sidebar-bottom">
        <div class="user-profile">
            <div class="avatar" style="background:#7c3aed">{{ user.name?.charAt(0) }}</div>
            <div class="info">
                <strong>{{ user.name }}</strong>
                <small>{{ user.email }}</small>
            </div>
        </div>
        <button @click="logout" class="btn-logout">Sign Out</button>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
      <header class="header">
        <h1>Command Center Penilai</h1>
      </header>
      
      <div class="content-wrapper">

        <!-- Stats Widgets -->
        <div class="stats-grid">
            <div class="stat-card primary">
                <span class="stat-title">Total Audit Data</span>
                <span class="stat-value">{{ stats.total }}</span>
            </div>
            <div class="stat-card primary">
                <span class="stat-title">Masuk (Unprocessed)</span>
                <span class="stat-value">{{ stats.submitted }}</span>
            </div>
            <div class="stat-card warning">
                <span class="stat-title">Sedang Direview</span>
                <span class="stat-value">{{ stats.in_review }}</span>
            </div>
            <div class="stat-card success">
                <span class="stat-title">Lolos Verifikasi</span>
                <span class="stat-value">{{ stats.approved }}</span>
            </div>
            <div class="stat-card danger">
                <span class="stat-title">Permohonan Gugur</span>
                <span class="stat-value">{{ stats.rejected }}</span>
            </div>
        </div>

        <!-- Toolbar -->
        <div class="toolbar" style="margin-bottom:1.5rem; display:flex; gap:1rem; padding:1rem; background:white; border-radius:12px">
            <input type="text" v-model="searchQ" class="search-input" style="flex:1; padding:0.75rem; border:1px solid #cbd5e1; border-radius:8px" placeholder="Cari Nomor Permohonan / Perusahaan..." />
            <select v-model="filterStatus" class="filter-select" style="padding:0.75rem; border:1px solid #cbd5e1; border-radius:8px">
                <option value="">Semua Status Audit</option>
                <option value="submitted">Submitted (Antre)</option>
                <option value="in_review">In Review</option>
                <option value="revision">Menunggu Revisi</option>
                <option value="approved">Approved (Final)</option>
                <option value="rejected">Rejected (Final)</option>
            </select>
        </div>

        <div v-if="loading" class="loading">Menarik log aktivitas...</div>
        <div v-else>
            <table class="data-table" v-if="paginatedData.data.length > 0">
            <thead>
                <tr>
                <th>No Proyek</th>
                <th>Pemohon & Entitas</th>
                <th>Jenis Rekam</th>
                <th>Status Audit</th>
                <th>Waktu Masuk</th>
                <th>Aksi Verifikasi</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="proj in paginatedData.data" :key="proj.id">
                <td><strong style="color:#7c3aed">{{ proj.project_number }}</strong></td>
                <td>
                    <strong>{{ proj.user?.name || 'Unknown' }}</strong>
                    <div class="text-sm text-gray">{{ proj.company_name }}</div>
                </td>
                <td>
                    <strong>{{ proj.title }}</strong>
                    <div class="text-sm text-gray">{{ proj.doc_type || 'Umum' }}</div>
                </td>
                <td>
                    <span :class="['badge', getStatusBadgeClass(proj.status)]">{{ proj.status.toUpperCase() }}</span>
                </td>
                <td class="text-sm">{{ new Date(proj.created_at).toLocaleString('id-ID') }}</td>
                <td class="actions">
                    <button @click="openEvaluateModal(proj)" class="btn-icon btn-edit" style="background:#f3e8ff; color:#7c3aed">Review Permohonan</button>
                </td>
                </tr>
            </tbody>
            </table>
            
            <div v-else class="empty-state">
                <p>Sistem audit bersih. Tidak ada data yang sesuai filter.</p>
            </div>

            <!-- Server Pagination -->
            <div class="pagination" v-if="paginatedData.last_page > 1" style="display:flex; justify-content:flex-end; gap:0.5rem; margin-top:1.5rem">
                <button class="page-btn" :disabled="paginatedData.current_page === 1" @click="fetchAssessments(paginatedData.current_page - 1)">« Prev</button>
                <button class="page-btn active" style="background:#7c3aed; color:white; border:none; padding:0.5rem 1rem">{{ paginatedData.current_page }} / {{ paginatedData.last_page }}</button>
                <button class="page-btn" :disabled="paginatedData.current_page === paginatedData.last_page" @click="fetchAssessments(paginatedData.current_page + 1)">Next »</button>
            </div>
        </div>
      </div>
    </main>

    <!-- EVALUATION / VERIFICATION MODAL -->
    <div v-if="showEvalModal && selectedProject" class="modal-overlay" @click.self="showEvalModal = false">
        <div class="modal-content" style="max-width: 800px; display: grid; grid-template-columns: 1fr 1fr; gap: 2rem;">
            
            <!-- Left Side: Data & Docs -->
            <div style="border-right: 1px solid #e2e8f0; padding-right: 2rem">
                <h2 style="font-size:1.2rem; margin-bottom:1rem; color:#7c3aed">Berita Acara Permohonan</h2>
                
                <div style="font-size: 0.9rem; margin-bottom: 1rem">
                    <strong>ID Resolusi:</strong> {{ selectedProject.project_number }} <br/>
                    <strong>PIC Perusahaan:</strong> {{ selectedProject.pic_name }} <br/>
                    <strong>Email:</strong> {{ selectedProject.email_pic }} <br/>
                    <strong>Status:</strong> <span :class="['badge', getStatusBadgeClass(selectedProject.status)]" style="font-size:0.6rem">{{ selectedProject.status }}</span>
                </div>

                <div style="font-size: 0.9rem; padding: 1rem; background: #f8fafc; border-radius:8px; margin-bottom:1rem">
                    <strong>Tujuan Bukti:</strong><br/>
                    {{ selectedProject.description }}
                </div>

                <h3 style="font-size:1rem; margin-top:1.5rem; margin-bottom:0.5rem">Preview Inline Berkas Dokumen</h3>
                <div v-if="selectedProject.documents && selectedProject.documents.length > 0" style="display:flex; flex-direction:column; gap:10px;">
                    <div v-for="doc in selectedProject.documents" :key="doc.id" style="border: 1px solid #cbd5e1; border-radius:8px; overflow:hidden">
                        <div style="background:#f1f5f9; padding: 0.5rem; font-weight:bold; font-size: 0.85rem; border-bottom:1px solid #cbd5e1">
                            {{ doc.category.toUpperCase() }} - {{ doc.file_name }}
                        </div>
                        <iframe :src="'http://localhost:8000/storage/' + doc.file_path" 
                                style="width:100%; height:300px; border:none;" 
                                v-if="doc.file_path.endsWith('.pdf')">
                        </iframe>
                        <div v-else style="padding:1rem; text-align:center; font-size:0.85rem">
                            File bukan PDF. <a :href="'http://localhost:8000/storage/' + doc.file_path" target="_blank">Unduh & Buka</a>
                        </div>
                    </div>
                </div>
                <div v-else style="font-size:0.85rem; color:#ef4444; font-weight:bold">⚠ Tidak ada file terlampir. Wajib tolak/revisi.</div>
            </div>

            <!-- Right Side: Decision Tools -->
            <div>
                <h2 style="font-size:1.2rem; margin-bottom:1rem; color:#475569">Catatan Penilai</h2>
                
                <div>
                    <div v-if="evalFormError" class="alert-error" style="padding:0.75rem; font-size:0.8rem">{{ evalFormError }}</div>
                    
                    <div class="form-group">
                        <textarea v-model="evalData.notes" rows="6" style="width:100%; border-radius:6px; padding:0.75rem" placeholder="Catatan penilaian..."></textarea>
                    </div>
                    
                    <div class="modal-actions" style="margin-top:2rem; justify-content: flex-start; flex-wrap: wrap;">
                        <button type="button" @click="confirmAndSubmit('rejected')" :disabled="evalUploading" class="btn-secondary" style="border:1px solid #ef4444; color:#ef4444; background:white; padding:0.6rem 1.2rem; border-radius:6px; cursor:pointer">Tolak</button>
                        <button type="button" @click="confirmAndSubmit('revision')" :disabled="evalUploading" class="btn-secondary" style="border:1px solid #f59e0b; color:#d97706; background:white; padding:0.6rem 1.2rem; border-radius:6px; cursor:pointer">Minta Revisi</button>
                        <button type="button" @click="confirmAndSubmit('approved')" :disabled="evalUploading" class="btn-primary" style="background:#10b981; color:white; border:none; padding:0.6rem 1.2rem; border-radius:6px; cursor:pointer; font-weight:bold">
                            {{ evalUploading ? 'Memproses...' : 'Setujui' }}
                        </button>
                        <button type="button" @click="showEvalModal = false" class="btn-secondary" style="margin-left:auto; border:1px solid #cbd5e1; background:white; padding:0.6rem 1.2rem; border-radius:6px; cursor:pointer">Batal</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- CUSTOM CONFIRM DIALOG ENTERPRISE -->
    <div v-if="showConfirmModal" class="modal-overlay" style="z-index:999">
        <div class="modal-content" style="max-width:400px; text-align:center; padding: 2rem">
            <div style="font-size: 3rem; margin-bottom:1rem">⚠️</div>
            <h3 style="margin-bottom:1rem; color:#1e293b">Konfirmasi Tindakan</h3>
            <p style="color:#64748b; margin-bottom: 2rem">
                Apakah Anda yakin ingin menjatuhkan putusan 
                <strong style="text-transform:uppercase; color:#7c3aed">{{ confirmAction }}</strong> pada dokumen ini?
            </p>
            <div style="display:flex; justify-content:center; gap:1rem">
                <button @click="showConfirmModal = false" style="padding:0.75rem 1.5rem; border:1px solid #cbd5e1; border-radius:6px; background:white; cursor:pointer">Batal</button>
                <button @click="executeEvaluation" style="padding:0.75rem 1.5rem; border:none; border-radius:6px; background:#7c3aed; color:white; font-weight:bold; cursor:pointer">Ya, Eksekusi!</button>
            </div>
        </div>
    </div>

  </div>
</template>
