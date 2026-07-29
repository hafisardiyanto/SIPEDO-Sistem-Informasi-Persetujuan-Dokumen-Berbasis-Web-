<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import '../assets/pemohon-dashboard.css'

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

const showFormModal = ref(false)
const showDetailModal = ref(false)
const selectedProject = ref(null)
const isEdit = ref(false)
const formError = ref('')
const formUploading = ref(false)

const viewingTrash = ref(false)
const toggleTrash = () => {
    viewingTrash.value = !viewingTrash.value
    fetchProjects(1)
}

const logout = async () => {
    try { 
        await axios.post('/api/logout', {}, {
            headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
        }) 
    } catch (e) {}
    localStorage.removeItem('user')
    localStorage.removeItem('token')
    router.push('/')
}

const fetchProjects = async (page = 1) => {
    loading.value = true
    try {
        const endpoint = viewingTrash.value ? '/api/projects/trash/view' : '/api/projects'
        const res = await axios.get(`${endpoint}?page=${page}&search=${searchQ.value}&status=${filterStatus.value}`)
        paginatedData.value = res.data
    } catch (err) {
        if(err.response?.status === 401) logout()
    } finally {
        loading.value = false
    }
}

const restoreProject = async (projId) => {
    try {
        await axios.post(`/api/projects/${projId}/restore`)
        fetchStats()
        fetchProjects()
    } catch (err) { alert('Gagal memulihkan dokumen.') }
}

const deleteProject = async (projId) => {
    if(!confirm('Kirim ke Recycle Bin?')) return;
    try {
        await axios.delete(`/api/projects/${projId}`)
        fetchStats()
        fetchProjects()
    } catch (err) { alert('Gagal menghapus dokumen.') }
}

const cancelProject = async (projId) => {
    if(!confirm('Apakah Anda yakin ingin membatalkan permohonan ini? Setelah dibatalkan, dokumen akan kembali ke status Draft sehingga dapat diperbaiki atau diajukan kembali.')) return;
    try {
        await axios.post(`/api/projects/${projId}/cancel`)
        fetchStats()
        fetchProjects()
    } catch (err) { alert('Gagal membatalkan. Status mungkin sudah masuk proses evaluasi Assigned.') }
}

const formData = ref({
    title: '', description: '', company_name: '', pic_name: '', phone: '', email_pic: '', doc_type: '', additional_notes: ''
})
const selectedProjectEditId = ref(null)
const filesToUpload = ref({
    document_utama: null, document_lampiran: null, document_pengantar: null, document_pendukung: null
})

const openCreateModal = () => {
    isEdit.value = false
    formError.value = ''
    formData.value = { title: '', description: '', company_name: '', pic_name: '', phone: '', email_pic: '', doc_type: '', additional_notes: '' }
    filesToUpload.value = { document_utama: null, document_lampiran: null, document_pengantar: null, document_pendukung: null }
    showFormModal.value = true
}

const openEditModal = (proj) => {
    isEdit.value = true
    selectedProjectEditId.value = proj.id
    formError.value = ''
    formData.value = { 
        title: proj.title, description: proj.description, company_name: proj.company_name, 
        pic_name: proj.pic_name, phone: proj.phone, email_pic: proj.email_pic, 
        doc_type: proj.doc_type, additional_notes: proj.additional_notes 
    }
    filesToUpload.value = { document_utama: null, document_lampiran: null, document_pengantar: null, document_pendukung: null }
    showFormModal.value = true
}

const handleFile = (e, category) => {
    filesToUpload.value[category] = e.target.files[0]
}

const submitForm = async (action) => {
    formError.value = ''
    formUploading.value = true
    try {
        const payload = new FormData()
        Object.keys(formData.value).forEach(key => {
            if(formData.value[key]) payload.append(key, formData.value[key])
        });
        Object.keys(filesToUpload.value).forEach(key => {
            if (filesToUpload.value[key]) payload.append(key, filesToUpload.value[key])
        });

        let savedProjId = selectedProjectEditId.value;

        if (isEdit.value) {
            // Need logical spoofing for PUT in multipart/form-data
            // payload.append('_method', 'PUT') -- Laravel route explicitly uses POST for updates with files!
            const res = await axios.post(`/api/projects/${selectedProjectEditId.value}`, payload, {
                headers: { 'Content-Type': 'multipart/form-data' }
            })
        } else {
            const res = await axios.post('/api/projects', payload, {
                headers: { 'Content-Type': 'multipart/form-data' }
            })
            savedProjId = res.data.data.id
        }
        
        // If "Kirim" is chosen, submit immediately
        if(action === 'submit') {
            await axios.post(`/api/projects/${savedProjId}/submit`)
        }

        showFormModal.value = false
        fetchStats()
        fetchProjects(paginatedData.value.current_page)
    } catch (err) {
        formError.value = err.response?.data?.message || 'Error occurred.'
    } finally {
        formUploading.value = false
    }
}

const viewDetails = async (proj) => {
    selectedProject.value = null
    showDetailModal.value = true
    try {
        const res = await axios.get(`/api/projects/${proj.id}`)
        selectedProject.value = res.data.data
        
        // Fetch History
        const hist = await axios.get(`/api/projects/${proj.id}/history`)
        selectedProject.value.history = hist.data.data
    } catch(err) {
        alert("Gagal mengambil detail")
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
</script>

<template>
  <div class="dashboard layout-row">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="brand">
        <h2>SIPEDO</h2>
        <span class="role-badge">PEMOHON ENTERPRISE</span>
      </div>
      <nav class="menu">
        <a href="#" class="menu-item active">🏠 Dashboard Analytics</a>
        <a href="#" @click.prevent="openCreateModal" class="menu-item">📄 Form Pengajuan</a>
      </nav>
      <div class="sidebar-bottom">
        <div class="user-profile">
            <div class="avatar">{{ user.name?.charAt(0) }}</div>
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
        <h1>Dashboard Statistik & Data {{ viewingTrash ? '(Trash Mode)' : '' }}</h1>
        <div>
            <button @click="toggleTrash" class="btn-secondary" style="margin-right: 1rem;">
                {{ viewingTrash ? '🔙 Kembali ke Dashboard' : '🗑️ Recycle Bin' }}
            </button>
            <button v-if="!viewingTrash" @click="openCreateModal" class="btn-primary">+ Buat Permohonan</button>
        </div>
      </header>
      
      <div class="content-wrapper">
        
        <div class="stats-grid">
            <div class="stat-card">
                <span class="stat-title">Total Draft</span>
                <span class="stat-value">{{ stats.draft }}</span>
            </div>
            <div class="stat-card primary">
                <span class="stat-title">Total Submitted</span>
                <span class="stat-value">{{ stats.submitted }}</span>
            </div>
            <div class="stat-card warning">
                <span class="stat-title">Total Revision</span>
                <span class="stat-value">{{ stats.revision }}</span>
            </div>
            <div class="stat-card success">
                <span class="stat-title">Total Approved</span>
                <span class="stat-value">{{ stats.approved }}</span>
            </div>
            <div class="stat-card danger">
                <span class="stat-title">Total Rejected</span>
                <span class="stat-value">{{ stats.rejected }}</span>
            </div>
        </div>

        <!-- Toolbar -->
        <div class="toolbar">
            <input type="text" v-model="searchQ" class="search-input" placeholder="Cari ID, Judul, Perusahaan..." />
            <select v-model="filterStatus" class="filter-select">
                <option value="">Semua Status</option>
                <option value="draft">Draft</option>
                <option value="submitted">Submitted</option>
                <option value="in_review">In Review</option>
                <option value="revision">Revision</option>
                <option value="approved">Approved</option>
                <option value="rejected">Rejected</option>
            </select>
        </div>

        <div v-if="loading" class="loading">Sinkronisasi Database...</div>
        <div v-else>
            <table class="data-table" v-if="paginatedData.data.length > 0">
            <thead>
                <tr>
                <th>No Registrasi</th>
                <th>Informasi Pemohon</th>
                <th>Status Berkas</th>
                <th>Tgl Dibuat</th>
                <th>Aksi Interaktif</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="proj in paginatedData.data" :key="proj.id">
                <td><strong>{{ proj.project_number || 'DRAFT-UNKNOWN' }}</strong></td>
                <td>
                    <strong>{{ proj.title }}</strong><br/>
                    <div class="text-sm text-gray">{{ proj.company_name }} | {{ proj.pic_name }}</div>
                </td>
                <td>
                    <span :class="['badge', getStatusBadgeClass(proj.status)]">{{ proj.status.toUpperCase() }}</span>
                </td>
                <td class="text-sm">{{ new Date(proj.created_at).toLocaleDateString('id-ID') }}</td>
                <td class="actions">
                    <button v-if="viewingTrash" @click="restoreProject(proj.id)" class="btn-icon btn-view" style="color:#10b981">♻️ Pulihkan</button>
                    <template v-else>
                        <button v-if="proj.status === 'draft'" @click="deleteProject(proj.id)" class="btn-icon btn-edit" style="color:#ef4444; margin-right:5px">🗑️ Hapus Draft</button>
                        <button v-if="proj.status === 'draft'" @click="openEditModal(proj)" class="btn-icon btn-edit">Edit</button>
                        <button v-if="proj.status === 'submitted'" @click="cancelProject(proj.id)" class="btn-icon btn-edit" style="color:#f59e0b; margin-right:5px">🚫 Batalkan Permohonan</button>
                        <button v-if="proj.status === 'revision'" @click="openEditModal(proj)" class="btn-icon btn-edit">📥 Unggah Versi Baru</button>
                        <button @click="viewDetails(proj)" class="btn-icon btn-view">👀 Lihat Detail</button>
                    </template>
                </td>
                </tr>
            </tbody>
            </table>
            
            <div v-else class="empty-state">
                <p>Data tidak ditemukan dengan filter tersebut.</p>
            </div>

            <!-- Server Pagination -->
            <div class="pagination" v-if="paginatedData.last_page > 1">
                <button class="page-btn" :disabled="paginatedData.current_page === 1" @click="fetchProjects(paginatedData.current_page - 1)">«</button>
                <button v-for="p in generatePages()" :key="p" :class="['page-btn', paginatedData.current_page === p ? 'active' : '']" @click="fetchProjects(p)">{{ p }}</button>
                <button class="page-btn" :disabled="paginatedData.current_page === paginatedData.last_page" @click="fetchProjects(paginatedData.current_page + 1)">»</button>
                <span class="text-sm text-gray" style="margin-left:1rem">Menampilkan Total {{ paginatedData.total }} Data</span>
            </div>
        </div>
      </div>
    </main>

    <!-- FORM MODAL ENTERPRISE -->
    <div v-if="showFormModal" class="modal-overlay" @click.self="showFormModal = false">
        <div class="modal-content" style="max-width: 800px">
            <h2>{{ isEdit ? 'Revisi Permohonan' : 'Form Aplikasi Dokumen Legal' }}</h2>
            <form @submit.prevent>
                <div v-if="formError" class="alert-error">{{ formError }}</div>
                
                <div class="form-grid">
                    <div class="form-group form-group-full">
                        <label>Judul / Nama Proyek Dokumen <span style="color:red">*</span></label>
                        <input type="text" v-model="formData.title" required>
                    </div>
                    <div class="form-group">
                        <label>Nama Perusahaan (Entity)</label>
                        <input type="text" v-model="formData.company_name">
                    </div>
                    <div class="form-group">
                        <label>Jenis Dokumen</label>
                        <select v-model="formData.doc_type">
                            <option value="">Pilih Jenis</option>
                            <option value="legalitas">Legalitas Usaha</option>
                            <option value="lingkungan">Izin Lingkungan</option>
                            <option value="bangunan">IMB / Surat Bangunan</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Nama Penanggung Jawab (PIC)</label>
                        <input type="text" v-model="formData.pic_name">
                    </div>
                    <div class="form-group">
                        <label>Email PIC</label>
                        <input type="email" v-model="formData.email_pic">
                    </div>
                    <div class="form-group">
                        <label>Nomor Telepon</label>
                        <input type="text" v-model="formData.phone">
                    </div>
                    <div class="form-group" style="border: 2px dashed #cbd5e1; padding: 1.5rem; text-align: center; border-radius: 8px;">
                        <label>Unggah Dokumen Utama (Max 20MB)</label><br/>
                        <input type="file" @change="e => handleFile(e, 'document_utama')" accept=".pdf,.docx">
                    </div>
                    <div class="form-group" style="border: 2px dashed #cbd5e1; padding: 1.5rem; text-align: center; border-radius: 8px;">
                        <label>Unggah Dokumen Lampiran (Max 20MB)</label><br/>
                        <input type="file" @change="e => handleFile(e, 'document_lampiran')" accept=".zip,.rar,.pdf">
                    </div>
                    <div class="form-group" style="border: 2px dashed #cbd5e1; padding: 1.5rem; text-align: center; border-radius: 8px;">
                        <label>Unggah Surat Pengantar (Max 20MB)</label><br/>
                        <input type="file" @change="e => handleFile(e, 'document_pengantar')" accept=".pdf,.doc">
                    </div>
                    <div class="form-group form-group-full">
                        <label>Deskripsi Tujuan Dokumen</label>
                        <textarea v-model="formData.description" rows="3"></textarea>
                    </div>
                </div>
                
                <div class="modal-actions">
                    <button type="button" @click="showFormModal = false" class="btn-secondary">Batal</button>
                    <button type="button" @click="submitForm('draft')" :disabled="formUploading" class="btn-secondary">
                        Simpan Draft
                    </button>
                    <button type="button" @click="submitForm('submit')" :disabled="formUploading" class="btn-primary" style="background: linear-gradient(135deg, #10b981, #059669)">
                        {{ formUploading ? 'Memproses...' : 'Ajukan Permohonan' }}
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- DETAIL / TIMELINE MODAL -->
    <div v-if="showDetailModal && selectedProject" class="modal-overlay" @click.self="showDetailModal = false">
        <div class="modal-content" style="max-width: 900px; display: grid; grid-template-columns: 1fr 1fr; gap: 2rem;">
            
            <!-- Left Side: Data -->
            <div>
                <h2 style="font-size:1.2rem; border-bottom: 2px solid #4f46e5; display:inline-block">Lembar Analisis</h2>
                <div class="detail-row" style="margin-top:1rem">
                    <span class="detail-label">Nomor Resi</span>
                    <strong class="detail-value" style="color: #4f46e5;font-size:1.1rem">{{ selectedProject.project_number }}</strong>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Tanggal Masuk</span>
                    <span class="detail-value">{{ new Date(selectedProject.created_at).toLocaleString('id-ID') }}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Entitas</span>
                    <span class="detail-value">{{ selectedProject.company_name }} ({{ selectedProject.pic_name }})</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Status Inkrah</span>
                    <span class="detail-value">
                        <span :class="['badge', getStatusBadgeClass(selectedProject.status)]">{{ selectedProject.status.toUpperCase() }}</span>
                    </span>
                </div>

                <h3 style="margin-top:2rem">📦 Arsip Digital</h3>
                <ul v-if="selectedProject.documents && selectedProject.documents.length > 0" style="padding-left:1rem; color:#475569">
                    <li v-for="doc in selectedProject.documents" :key="doc.id" style="margin-bottom:0.5rem">
                        <strong>{{ doc.category.toUpperCase() }}:</strong> 
                        <a :href="'http://localhost:8000/storage/' + doc.file_path" target="_blank" class="link" style="margin-left:0.5rem">{{ doc.file_name }}</a>
                    </li>
                </ul>
                <div v-else class="text-gray" style="font-style:italic">Tidak ada arsip yang terlampir.</div>
            </div>

            <!-- Right Side: Workflow Timeline -->
            <div style="background: #f8fafc; padding: 1.5rem; border-radius:12px; border:1px solid #e2e8f0">
                <h2 style="font-size:1.2rem; margin-bottom:1.5rem">Visualisasi Timeline Audit</h2>
                
                <div class="timeline-modern">
                    <div class="timeline-step completed">
                        <div class="timeline-marker"></div>
                        <div class="timeline-content">
                            <div class="timeline-title">Berkas Terbuat (Draft)</div>
                            <div class="timeline-date">{{ new Date(selectedProject.created_at).toLocaleString('id-ID') }}</div>
                        </div>
                    </div>

                    <div v-for="log in selectedProject.history" :key="log.id" 
                         :class="['timeline-step', 
                            log.status_to === 'approved' ? 'completed' : 
                            log.status_to === 'rejected' ? 'danger' : 'active'
                         ]">
                        <div class="timeline-marker"></div>
                        <div class="timeline-content">
                            <div class="timeline-title">Diproses oleh {{ log.assessor?.name }}</div>
                            <div class="timeline-date">{{ new Date(log.created_at).toLocaleString('id-ID') }} - Berpindah ke: <strong>{{ log.status_to.toUpperCase() }}</strong></div>
                            <div class="timeline-desc" v-if="log.notes">"{{ log.notes }}"</div>
                        </div>
                    </div>

                    <div v-if="selectedProject.status === 'approved'" class="timeline-step completed">
                        <div class="timeline-marker"></div>
                        <div class="timeline-content">
                            <div class="timeline-title" style="color: #10b981">✨ Tersertifikasi Penuh</div>
                        </div>
                    </div>
                </div>

                <div class="modal-actions" style="border:none; margin-top:2rem">
                    <button @click="showDetailModal = false" class="btn-secondary" style="width:100%">Tutup Penelusuran</button>
                </div>
            </div>
        </div>
    </div>
  </div>
</template>
