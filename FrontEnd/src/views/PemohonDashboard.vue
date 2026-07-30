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
        const res = await axios.get('/api/dashboard/stats', {
            headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
        })
        stats.value = res.data.data
    } catch(err) {}
}

const docTypes = ref([])
const fetchDocTypes = async () => {
    try {
        const res = await axios.get('/api/admin/document-types', {
            headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
        })
        docTypes.value = res.data.data.filter(d => d.is_active)
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

watch([searchQ, filterStatus, viewingTrash], () => {
    fetchProjects(1)
})

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
    if(!confirm('Apakah Anda yakin batal? Permohonan akan kembali ke Draft.')) return;
    try {
        await axios.post(`/api/projects/${projId}/cancel`)
        fetchStats()
        fetchProjects()
    } catch (err) { alert('Gagal membatalkan.') }
}

const formData = ref({
    title: '', description: '', company_name: '', pic_name: '', phone: '', email_pic: '', doc_type: '', deadline_date: '', additional_notes: '', agreement: false
})

// Store reference for auto-generated read-only form data
const formMeta = ref({
    project_number: 'AUTO GENERATED',
    status: 'DRAFT',
    created_at: '',
    revisionNote: ''
})

const selectedProjectEditId = ref(null)
const filesToUpload = ref({
    document_utama: null, document_lampiran: null, document_pengantar: null, document_pendukung: null
})

// Store previously uploaded files to show in UI
const existingFiles = ref({
    document_utama: null, document_lampiran: null, document_pengantar: null, document_pendukung: null
})

const openCreateModal = () => {
    isEdit.value = false
    formError.value = ''
    formMeta.value = { project_number: 'AUTO GENERATED (Setelah Disubmit)', status: 'DRAFT', created_at: '-', revisionNote: ''}
    formData.value = { title: '', description: '', company_name: '', pic_name: '', phone: '', email_pic: '', doc_type: '', deadline_date: '', additional_notes: '', agreement: false }
    filesToUpload.value = { document_utama: null, document_lampiran: null, document_pengantar: null, document_pendukung: null }
    existingFiles.value = { document_utama: null, document_lampiran: null, document_pengantar: null, document_pendukung: null }
    showFormModal.value = true
}

const openEditModal = async (proj) => {
    isEdit.value = true
    selectedProjectEditId.value = proj.id
    formError.value = ''
    
    // Simulate loading details if missing
    let fullProj = proj;
    if(!proj.documents) {
        try {
            const res = await axios.get(`/api/projects/${proj.id}`);
            fullProj = res.data.data;
        }catch(e){}
    }

    formMeta.value = { 
        project_number: fullProj.project_number || 'AUTO GENERATED', 
        status: fullProj.status, 
        created_at: new Date(fullProj.created_at).toLocaleDateString('id-ID'),
        revisionNote: ''
    }

    if (fullProj.status === 'revision') {
        try {
            const hist = await axios.get(`/api/projects/${proj.id}/history`);
            if(hist.data.data.length > 0) formMeta.value.revisionNote = hist.data.data[0].notes;
        }catch(e){}
    }

    formData.value = { 
        title: fullProj.title, description: fullProj.description, company_name: fullProj.company_name, 
        pic_name: fullProj.pic_name, phone: fullProj.phone, email_pic: fullProj.email_pic, 
        doc_type: fullProj.doc_type, deadline_date: fullProj.deadline_date, additional_notes: fullProj.additional_notes, agreement: false 
    }
    
    filesToUpload.value = { document_utama: null, document_lampiran: null, document_pengantar: null, document_pendukung: null }
    existingFiles.value = { document_utama: null, document_lampiran: null, document_pengantar: null, document_pendukung: null }
    
    // Map existing documents
    if (fullProj.documents) {
        fullProj.documents.forEach(d => {
            if(d.category === 'utama') existingFiles.value.document_utama = d;
            if(d.category === 'lampiran') existingFiles.value.document_lampiran = d;
            if(d.category === 'pengantar') existingFiles.value.document_pengantar = d;
            if(d.category === 'pendukung') existingFiles.value.document_pendukung = d;
        });
    }

    showFormModal.value = true
}

const removeExistingFile = (category) => {
    if(confirm('Apakah Anda yakin ingin menghapus arsip file ini dari formulir?')) {
        existingFiles.value[category] = null;
    }
}

const handleDrop = (e, category) => {
    e.preventDefault();
    if(e.dataTransfer.files.length) filesToUpload.value[category] = e.dataTransfer.files[0];
}
const handleFile = (e, category) => {
    if(e.target.files.length) filesToUpload.value[category] = e.target.files[0]
}

const submitForm = async (action) => {
    formError.value = ''
    
    if (action === 'submit' && !formData.value.agreement) {
        formError.value = 'Anda wajib menyetujui pernyataan kebenaran data di bagian bawah form.';
        return;
    }

    formUploading.value = true
    try {
        const payload = new FormData()
        Object.keys(formData.value).forEach(key => {
            if(key === 'agreement') return; // backend doesnt need this checkbox flag
            if(formData.value[key]) payload.append(key, formData.value[key])
        });
        Object.keys(filesToUpload.value).forEach(key => {
            if (filesToUpload.value[key]) payload.append(key, filesToUpload.value[key])
        });

        let savedProjId = selectedProjectEditId.value;

        if (isEdit.value) {
            await axios.post(`/api/projects/${selectedProjectEditId.value}`, payload, {
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
        formError.value = err.response?.data?.message || 'Error form submission.'
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
        const hist = await axios.get(`/api/projects/${proj.id}/history`)
        selectedProject.value.history = hist.data.data
    } catch(err) {}
}

const getStatusBadgeClass = (status) => {
    const map = { 'draft': 'badge-gray', 'submitted': 'badge-blue', 'assigned': 'badge-blue', 'in_review': 'badge-yellow', 'revision': 'badge-orange', 'approved': 'badge-green', 'rejected': 'badge-red' }
    return map[status] || 'badge-gray'
}

const generatePages = () => {
    const pages = [];
    for (let i = 1; i <= paginatedData.value.last_page; i++) pages.push(i);
    return pages;
}

onMounted(() => {
    if(!user.value || user.value.role !== 'pemohon') {
        router.push('/')
        return
    }
    fetchStats()
    fetchProjects()
    fetchDocTypes()
})
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
        <a href="#" class="menu-item active">🏠 Dasbor Statistik</a>
        <a href="#" @click.prevent="openCreateModal" class="menu-item" style="color:#10b981">📝 Buat Pengajuan Baru</a>
      </nav>
      <div class="sidebar-bottom">
        <div class="user-profile">
            <div class="avatar">{{ user.name?.charAt(0) }}</div>
            <div class="info">
                <strong>{{ user.name }}</strong>
                <small>{{ user.email }}</small>
            </div>
        </div>
        <button @click="logout" class="btn-logout">Keluar Sistem</button>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
      <header class="header">
        <h1>Overview Permohonan Saya {{ viewingTrash ? '(Recycle Bin)' : '' }}</h1>
        <div>
            <button @click="toggleTrash" class="btn-secondary" style="margin-right: 1rem;">
                {{ viewingTrash ? '🔙 Keluar dari Recycle Bin' : '🗑️ Buka Recycle Bin' }}
            </button>
            <button v-if="!viewingTrash" @click="openCreateModal" class="btn-primary" style="background:#10b981; border:none">+ Buat Berkas Permohonan</button>
        </div>
      </header>
      
      <div class="content-wrapper">
        <div class="stats-grid">
            <div class="stat-card">
                <span class="stat-title">Dalam Draft</span>
                <span class="stat-value" style="color:#64748b">{{ stats.draft }}</span>
            </div>
            <div class="stat-card primary">
                <span class="stat-title">Proses Evaluasi (Submit)</span>
                <span class="stat-value">{{ stats.submitted + stats.in_review }}</span>
            </div>
            <div class="stat-card warning">
                <span class="stat-title">Menunggu Revisi</span>
                <span class="stat-value">{{ stats.revision }}</span>
            </div>
            <div class="stat-card success">
                <span class="stat-title">Dokumen Disetujui</span>
                <span class="stat-value">{{ stats.approved }}</span>
            </div>
            <div class="stat-card danger">
                <span class="stat-title">Permanen Ditolak</span>
                <span class="stat-value">{{ stats.rejected }}</span>
            </div>
        </div>

        <!-- Toolbar -->
        <div class="toolbar" style="background:white; padding:1rem; border-radius:12px; margin-bottom:1.5rem; display:flex; gap:1rem">
            <input type="text" v-model="searchQ" class="search-input" style="flex:1; padding:0.75rem; border-radius:8px; border:1px solid #cbd5e1" placeholder="🔍 Cari Nomor Registrasi, Judul Proyek..." />
            <select v-model="filterStatus" class="filter-select" style="padding:0.75rem; border-radius:8px; border:1px solid #cbd5e1">
                <option value="">Semua Status Pengajuan</option>
                <option value="draft">Draft (Belum Submit)</option>
                <option value="submitted">Submitted (Antre)</option>
                <option value="in_review">In Review (Dievaluasi)</option>
                <option value="revision">Permintaan Revisi</option>
                <option value="approved">Approved (Selesai)</option>
                <option value="rejected">Rejected (Ditutup)</option>
            </select>
        </div>

        <div v-if="loading" class="loading">Memuat siklus data dokumen dari server...</div>
        <div v-else>
            <table class="data-table" v-if="paginatedData.data.length > 0">
            <thead>
                <tr>
                <th>No Resi Dokumen</th>
                <th>Judul Pengajuan</th>
                <th>Status Audit</th>
                <th>Tgl Dibuat</th>
                <th>Aksi Dokumen</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="proj in paginatedData.data" :key="proj.id">
                <td><strong style="color:#7c3aed">{{ proj.project_number || 'DRAFT-XXX' }}</strong></td>
                <td>
                    <strong>{{ proj.title }}</strong><br/>
                    <div class="text-sm text-gray">{{ proj.company_name }} | {{ proj.doc_type || 'Umum' }}</div>
                </td>
                <td>
                    <span :class="['badge', getStatusBadgeClass(proj.status)]" style="text-transform:uppercase">{{ proj.status }}</span>
                </td>
                <td class="text-sm">{{ new Date(proj.created_at).toLocaleDateString('id-ID') }}</td>
                <td class="actions">
                    <button v-if="viewingTrash" @click="restoreProject(proj.id)" class="btn-icon btn-view" style="color:#10b981">♻️ Pulihkan</button>
                    <template v-else>
                        <button v-if="proj.status === 'draft'" @click="deleteProject(proj.id)" class="btn-icon btn-edit" style="color:#ef4444; margin-right:5px">🗑️ Hapus Draft</button>
                        <button v-if="proj.status === 'draft'" @click="openEditModal(proj)" class="btn-icon btn-edit" style="background:#f1f5f9;border:1px solid #cbd5e1">✏️ Edit Draft</button>
                        <button v-if="proj.status === 'submitted'" @click="cancelProject(proj.id)" class="btn-icon btn-edit" style="color:#f59e0b; margin-right:5px">🚫 Batalkan Permohonan</button>
                        <button v-if="proj.status === 'revision'" @click="openEditModal(proj)" class="btn-icon btn-edit" style="background:#fee2e2; color:#ef4444; border:1px solid #fca5a5; font-weight:bold">📤 Unggah Revisi</button>
                        <button @click="viewDetails(proj)" class="btn-icon btn-view" style="background:#f3e8ff; color:#7c3aed">� Lihat Detail</button>
                    </template>
                </td>
                </tr>
            </tbody>
            </table>
            
            <div v-else class="empty-state" style="background:white; padding:3rem; text-align:center; border-radius:12px">
                <div style="font-size:3rem; margin-bottom:1rem">📭</div>
                <h3>Ruang Dokumen Anda Masih Kosong</h3>
                <p>Klik tombol '+ Buat Berkas Permohonan' di sudut kanan atas untuk memulai.</p>
            </div>

            <!-- Server Pagination -->
            <div class="pagination" v-if="paginatedData.last_page > 1" style="display:flex; justify-content:flex-end; margin-top:1.5rem">
                <button class="page-btn" :disabled="paginatedData.current_page === 1" @click="fetchProjects(paginatedData.current_page - 1)">« Prev</button>
                <button v-for="p in generatePages()" :key="p" :class="['page-btn', paginatedData.current_page === p ? 'active' : '']" @click="fetchProjects(p)">{{ p }}</button>
                <button class="page-btn" :disabled="paginatedData.current_page === paginatedData.last_page" @click="fetchProjects(paginatedData.current_page + 1)">Next »</button>
            </div>
        </div>
      </div>
    </main>

    <!-- FORM MODAL PEMOHON ADVANCED LAYOUT -->
    <div v-if="showFormModal" class="modal-overlay" style="z-index:9999" @click.self="showFormModal = false">
        <div class="modal-content" style="width: 90vw; max-width: 900px; max-height:85vh; overflow-y:auto; padding:2rem; background:#f8fafc">
            
            <!-- Header Judul Form -->
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:2rem; border-bottom:2px solid #e2e8f0; padding-bottom:1rem">
                <div>
                    <h2 style="margin:0; font-size:1.5rem; color:#1e293b">{{ isEdit ? 'Rubah/Revisi Permohonan Berkas' : 'Form Pengajuan Dokumen Baru' }}</h2>
                    <p style="color:#64748b; margin:0; margin-top:0.25rem">Isilah meta-data berikut dengan penuh ketelitian.</p>
                </div>
                <!-- Warning Revisi Banner -->
                <div v-if="formMeta.status === 'revision'" style="background:#fee2e2; border: 2px solid #ef4444; padding:0.75rem 1.5rem; border-radius:8px">
                    <strong style="color:#ef4444; display:block; font-size:1.1rem">⚠ BERKAS SEDANG DIREVISI</strong>
                    <div style="font-size:0.9rem; margin-top:0.5rem; max-width:300px; color:#991b1b">
                        <strong>Catatan Penilai:</strong><br/>
                        <em>"{{ formMeta.revisionNote }}"</em>
                    </div>
                </div>
            </div>

            <!-- Error Banner -->
            <div v-if="formError" style="background:#fee2e2; color:#ef4444; padding:1rem; border-radius:8px; border:1px solid #fca5a5; margin-bottom:2rem; font-weight:bold">
                ⛔ {{ formError }}
            </div>

            <form @submit.prevent>
                
                <!-- GRUP A: INFORMASI PERMOHONAN -->
                <h3 style="background:#e0e7ff; color:#1e40af; padding:0.75rem; border-radius:8px; margin-bottom:1.5rem">A. Kuitansi & Informasi Permohonan</h3>
                <div class="form-grid" style="column-gap: 2rem">
                    <div class="form-group">
                        <label>Nomor Permohonan (Auto Generate)</label>
                        <input type="text" :value="formMeta.project_number" disabled style="background:#e2e8f0; color:#475569; font-weight:bold; cursor:not-allowed">
                    </div>
                    <div class="form-group" style="display:flex; gap:1rem">
                        <div style="flex:1">
                            <label>Status Dokumen</label>
                            <input type="text" :value="formMeta.status.toUpperCase()" disabled style="background:#e2e8f0; color:#475569; font-weight:bold; cursor:not-allowed">
                        </div>
                        <div style="flex:1">
                            <label>Batas Waktu (SLA)</label>
                            <input type="date" v-model="formData.deadline_date" required style="border-radius:8px; border:1px solid #cbd5e1; padding:0.75rem; width:100%">
                        </div>
                    </div>
                </div>

                <div class="form-grid" style="column-gap: 2rem; margin-top:1rem">
                    <div class="form-group form-group-full">
                        <label>Judul Sertifikasi / Nama Dokumen Proyek <span style="color:red">*</span></label>
                        <input type="text" v-model="formData.title" required placeholder="Contoh: Pengajuan Amdal Pabrik Sektor A">
                    </div>
                    <div class="form-group">
                        <label>Jenis Dokumen Registrasi</label>
                        <select v-model="formData.doc_type" required>
                            <option value="">-- Pilih Jenis Dokumen --</option>
                            <option v-for="d in docTypes" :key="d.id" :value="d.name">{{ d.name }}</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Nama Perusahaan / Entitas Hukum</label>
                        <input type="text" v-model="formData.company_name" placeholder="PT. / CV. ABC...">
                    </div>
                </div>

                <!-- GRUP B: INFORMASI PIC -->
                <h3 style="background:#e0e7ff; color:#1e40af; padding:0.75rem; border-radius:8px; margin-bottom:1.5rem; margin-top:2rem">B. Informasi PIC (Perwakilan)</h3>
                <div class="form-grid" style="column-gap: 2rem">
                    <div class="form-group">
                        <label>Nama Penanggung Jawab (PIC)</label>
                        <input type="text" v-model="formData.pic_name" placeholder="Nama lengkap staf kuasa...">
                    </div>
                    <div class="form-group">
                        <label>Alamat Email Institusi (PIC)</label>
                        <input type="email" v-model="formData.email_pic" placeholder="akun@perusahaan.com">
                    </div>
                    <div class="form-group form-group-full">
                        <label>Nomor Telepon Seluler (Validasi Format)</label>
                        <input type="text" v-model="formData.phone" placeholder="Contoh: 0812xxxxxx atau +62821xxxx" pattern="^(\+62|08)[0-9]{8,12}$">
                    </div>
                </div>

                <!-- GRUP C: LAMPIRAN DIGITAL -->
                <h3 style="background:#e0e7ff; color:#1e40af; padding:0.75rem; border-radius:8px; margin-bottom:1.5rem; margin-top:2rem">C. Kotak Unggah Berkas Digital (Drag & Drop)</h3>
                
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:2rem">
                    
                    <!-- Dokumen Utama -->
                    <div class="form-group">
                        <label>Dokumen Utama <strong style="color:red">*</strong></label>
                        <div v-if="existingFiles.document_utama" style="padding:1rem; border:1px solid #cbd5e1; border-radius:8px; background:white; display:flex; justify-content:space-between; align-items:center">
                            <span style="font-size:0.85rem">📄 {{ existingFiles.document_utama.file_name }}</span>
                            <div style="display:flex; gap:0.5rem">
                                <a :href="'http://localhost:8000/storage/'+existingFiles.document_utama.file_path" target="_blank" style="font-size:0.8rem; color:#3b82f6; text-decoration:none">👁 Preview</a>
                                <button type="button" @click="removeExistingFile('document_utama')" style="border:none; background:none; color:#ef4444; font-size:0.8rem; cursor:pointer">🗑 Hapus</button>
                            </div>
                        </div>
                        <div v-else class="upload-zone" @dragover.prevent @drop="e => handleDrop(e, 'document_utama')" style="border: 2px dashed #94a3b8; border-radius: 8px; padding: 2rem; text-align: center; background:white; cursor:pointer; transition:background 0.3s">
                            <input type="file" @change="e => handleFile(e, 'document_utama')" accept=".pdf,.doc,.docx" style="display:block; width:100%; margin-bottom:1rem">
                            <p style="margin:0; font-weight:bold; color:#1e293b">Tarik & Letakkan File Di Sini (Zona Utama)</p>
                            <small style="color:#64748b">Format: PDF, DOCX (Maks 20MB)</small>
                            <div v-if="filesToUpload.document_utama" style="margin-top:1rem; color:#10b981; font-weight:bold">✅ Target Dipilih: {{ filesToUpload.document_utama.name }}</div>
                        </div>
                    </div>

                    <!-- Dokumen Lampiran -->
                    <div class="form-group">
                        <label>Dokumen Lampiran Pembantu</label>
                        <div v-if="existingFiles.document_lampiran" style="padding:1rem; border:1px solid #cbd5e1; border-radius:8px; background:white; display:flex; justify-content:space-between; align-items:center">
                            <span style="font-size:0.85rem">📦 {{ existingFiles.document_lampiran.file_name }}</span>
                            <div>
                                <a :href="'http://localhost:8000/storage/'+existingFiles.document_lampiran.file_path" download style="font-size:0.8rem; color:#3b82f6; text-decoration:none">⬇ Download Lama</a>
                                <button type="button" @click="removeExistingFile('document_lampiran')" style="border:none; background:none; color:#ef4444; font-size:0.8rem; cursor:pointer; margin-left:0.5rem">🗑 Hapus</button>
                            </div>
                        </div>
                        <div v-else class="upload-zone" @dragover.prevent @drop="e => handleDrop(e, 'document_lampiran')" style="border: 2px dashed #94a3b8; border-radius: 8px; padding: 2rem; text-align: center; background:white">
                            <input type="file" @change="e => handleFile(e, 'document_lampiran')" accept=".pdf,.docx,.zip,.rar" style="display:block; width:100%; margin-bottom:1rem">
                            <p style="margin:0; font-weight:bold; color:#1e293b">Tarik File / Arsip Di Sini (Zona Bebas)</p>
                            <small style="color:#64748b">Format: ZIP, RAR, PDF, DOCX (Maks 20MB)</small>
                            <div v-if="filesToUpload.document_lampiran" style="margin-top:1rem; color:#10b981; font-weight:bold">✅ Target Dipilih: {{ filesToUpload.document_lampiran.name }}</div>
                        </div>
                    </div>

                </div>

                <!-- GRUP D: DESKRIPSI -->
                <h3 style="background:#e0e7ff; color:#1e40af; padding:0.75rem; border-radius:8px; margin-bottom:1.5rem; margin-top:2rem">D. Penjelasan Motif & Naratif</h3>
                <div class="form-group form-group-full">
                    <label>Deskripsi Latar Belakang (Tujuan) <span style="color:red">*</span></label>
                    <textarea v-model="formData.description" required rows="4" placeholder="Jelaskan secara terperinci apa muara sasaran di balik pengunggahan dokumen ini..."></textarea>
                </div>
                <div class="form-group form-group-full" style="margin-top:1rem">
                    <label>Catatan Tambahan (Opsional Pengirim)</label>
                    <textarea v-model="formData.additional_notes" rows="3" placeholder="Contoh: Dokumen ini merupakan revisi minor dari kontrak bangunan tahun sebelumnya..."></textarea>
                </div>

                <!-- PERNYATAAN CONSENT -->
                <div style="background:#f0fdf4; border:1px solid #86efac; padding:1.5rem; border-radius:8px; margin-top:2rem; margin-bottom:2rem; display:flex; align-items:flex-start; gap:1rem">
                    <input type="checkbox" v-model="formData.agreement" id="consent_checkbox" style="width:24px; height:24px; margin-top:0.25rem">
                    <label for="consent_checkbox" style="color:#166534; font-size:1rem; line-height:1.5; cursor:pointer">
                        <strong>Pernyataan Kekuatan Hukum:</strong><br/>
                        Saya dengan ini menyatakan dengan sadar bahwa mutlak seluruh rincian dan arsip data yang saya isikan / lampirkan secara elektronik pada layar ini adalah sah, benar, tulen, dan dapat dipertanggungjawabkan di mata audit sistem.
                    </label>
                </div>

                <!-- GRUP E: ACTIONS -->
                <div style="border-top:2px solid #e2e8f0; padding-top:1.5rem; display:flex; justify-content:flex-end; gap:1rem; flex-wrap:wrap">
                    <button type="button" @click="showFormModal = false" style="padding:1rem 2rem; border-radius:8px; border:1px solid #cbd5e1; background:white; color:#475569; font-weight:bold; cursor:pointer">
                        ❌ Tutup
                    </button>
                    <!-- Draft Button Only Available if not submitted or revision status -->
                    <button v-if="!['revision','submitted'].includes(formMeta.status)" type="button" @click="submitForm('draft')" :disabled="formUploading" style="padding:1rem 2rem; border-radius:8px; border:1px solid #3b82f6; background:#eff6ff; color:#3b82f6; font-weight:bold; cursor:pointer">
                        💾 Simpan Draft
                    </button>
                    <!-- Submit Application Button -->
                    <button type="button" @click="submitForm('submit')" :disabled="formUploading" style="padding:1rem 2rem; border-radius:8px; border:none; background:#10b981; color:white; font-size:1.1rem; font-weight:bold; min-width:300px; cursor:pointer; text-align:center">
                        {{ formUploading ? '🚀 Meluncurkan Ke Server (Uploading...)' : '🚀 Ajukan Permohonan' }}
                    </button>
                </div>

            </form>
        </div>
    </div>

    <!-- DETAIL / TIMELINE MODAL (Pemohon Minimalis View) -->
    <div v-if="showDetailModal && selectedProject" class="modal-overlay" @click.self="showDetailModal = false">
        <div class="modal-content" style="max-width: 900px; display: grid; grid-template-columns: 1fr 1fr; gap: 2rem;">
            <!-- Left Side: Data Basic -->
            <div>
                <h2 style="font-size:1.2rem; border-bottom: 2px solid #4f46e5; display:inline-block">Lembar Jejak</h2>
                <div class="detail-row" style="margin-top:1rem">
                    <span class="detail-label">Nomor Resi</span>
                    <strong class="detail-value" style="color: #4f46e5;font-size:1.1rem">{{ selectedProject.project_number }}</strong>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Tanggal Masuk</span>
                    <span class="detail-value">{{ new Date(selectedProject.created_at).toLocaleString('id-ID') }}</span>
                </div>
                <!-- Status Badge -->
                <div class="detail-row">
                    <span class="detail-label">Status Inkrah</span>
                    <span class="detail-value">
                        <span :class="['badge', getStatusBadgeClass(selectedProject.status)]">{{ selectedProject.status.toUpperCase() }}</span>
                    </span>
                </div>

                <h3 style="margin-top:2rem">📦 Arsip Terekam Utama</h3>
                <ul v-if="selectedProject.documents && selectedProject.documents.length > 0" style="padding-left:1rem; color:#475569">
                    <li v-for="doc in selectedProject.documents" :key="doc.id" style="margin-bottom:0.5rem">
                        <a :href="'http://localhost:8000/storage/' + doc.file_path" target="_blank" style="color:#059669; text-decoration:none; font-weight:bold">{{ doc.category.toUpperCase() }} FILE 👁</a>
                    </li>
                </ul>
            </div>

            <!-- Right Side: Workflow Timeline -->
            <div style="background: #f8fafc; padding: 1.5rem; border-radius:12px; border:1px solid #e2e8f0">
                <h2 style="font-size:1.2rem; margin-bottom:1.5rem">Visualisasi Timeline</h2>
                <div class="timeline-modern">
                    <div class="timeline-step completed">
                        <div class="timeline-marker"></div>
                        <div class="timeline-content">
                            <div class="timeline-title">Berkas Terbuat (Draft)</div>
                            <div class="timeline-date">{{ new Date(selectedProject.created_at).toLocaleString('id-ID') }}</div>
                        </div>
                    </div>
                    <div v-for="log in selectedProject.history" :key="log.id" 
                         :class="['timeline-step', log.status_to === 'approved' ? 'completed' : log.status_to === 'rejected' ? 'danger' : 'active']">
                        <div class="timeline-marker"></div>
                        <div class="timeline-content">
                            <div class="timeline-title">Diproses oleh Penilai ({{ log.assessor?.name }})</div>
                            <div class="timeline-date">{{ new Date(log.created_at).toLocaleString('id-ID') }} ➔ <strong>{{ log.status_to.toUpperCase() }}</strong></div>
                            <div class="timeline-desc" v-if="log.notes" style="background:#fee2e2; padding:0.5rem; border-radius:4px; border:1px solid #fca5a5; margin-top:0.5rem">"{{ log.notes }}"</div>
                        </div>
                    </div>
                </div>
                <button @click="showDetailModal = false" class="btn-secondary" style="width:100%; margin-top:2rem">Tutup Penelusuran</button>
            </div>
        </div>
    </div>
  </div>
</template>
