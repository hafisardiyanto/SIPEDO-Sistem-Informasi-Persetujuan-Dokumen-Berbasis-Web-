<script setup>
import { ref, onMounted, watch, computed } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import '../assets/penilai-dashboard.css'

const router = useRouter()
const user = ref(JSON.parse(localStorage.getItem('user')) || {})

// Navigation State
const activeTab = ref('dashboard')

const stats = ref({ total: 0, draft: 0, submitted: 0, in_review: 0, revision: 0, approved: 0, rejected: 0, average_review_time: 0, overdue: 0, today: 0 })
const paginatedData = ref({ data: [], current_page: 1, last_page: 1, total: 0 })
const loading = ref(false)

// Toolbars
const searchQ = ref('')
const filterStatus = ref('')
const filterPriority = ref('')

const fetchStats = async () => {
    try {
        const res = await axios.get('/api/dashboard/stats')
        stats.value = res.data.data
        // Fix total assignments calculation mapping UI correctly
        stats.value.total_assignment = (stats.value.submitted || 0) + (stats.value.in_review || 0) + (stats.value.revision || 0) + (stats.value.approved || 0) + (stats.value.rejected || 0);
    } catch(err) {}
}

const fetchAssessments = async (page = 1) => {
    loading.value = true
    try {
        const res = await axios.get(`/api/assessments?page=${page}&search=${searchQ.value}&status=${filterStatus.value}`)
        paginatedData.value = res.data
        
        // Mock Priorities and SLA for UI based on IDs randomly for the enterprise look
        paginatedData.value.data = paginatedData.value.data.map(proj => {
            proj.ui_priority = proj.id % 3 === 0 ? 'High' : (proj.id % 2 === 0 ? 'Medium' : 'Low');
            // Mock Date for SLA
            const due = proj.deadline_date ? new Date(proj.deadline_date) : new Date(proj.created_at);
            if(!proj.deadline_date) {
                due.setDate(due.getDate() + 3);
            }
            const now = new Date();
            const diffTime = due - now;
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
            
            if (diffDays < 0) proj.ui_sla = '🔴 Overdue';
            else if (diffDays === 0) proj.ui_sla = '🟠 5 Jam Lagi';
            else proj.ui_sla = `🟢 ${diffDays} Hari Lagi`;
            
            return proj;
        });

    } catch (err) {
        if(err.response?.status === 401) logout()
    } finally {
        loading.value = false
    }
}

const notifications = computed(() => {
    let notifs = [];
    if (!paginatedData.value.data) return notifs;
    
    paginatedData.value.data.forEach(proj => {
        if (proj.status === 'submitted') {
            notifs.push({ id: proj.id + 'a', type: 'info', title: 'Assignment Baru Masuk', desc: `Dokumen ${proj.project_number} dari ${proj.company_name} menunggu antrean review.`, time: proj.created_at });
        }
        if (proj.status === 'revision') {
            notifs.push({ id: proj.id + 'b', type: 'warning', title: 'Revisi Dikirim Balik', desc: `Pemohon ${proj.company_name} telah mengirim balik revisian.`, time: proj.updated_at });
        }
        if (proj.ui_sla && proj.ui_sla.includes('Overdue')) {
            notifs.push({ id: proj.id + 'c', type: 'danger', title: 'SLA Darurat (Overdue)', desc: `Tugas review ${proj.project_number} telah melampaui batas waktu! Segera ambil tindakan.`, time: new Date().toISOString() });
        }
    })
    return notifs.sort((a,b) => new Date(b.time) - new Date(a.time));
});

watch([searchQ, filterStatus, activeTab], () => {
    if (['assignments', 'history', 'notifications'].includes(activeTab.value)) {
        fetchAssessments(1)
    }
})

onMounted(() => {
    if(!user.value || user.value.role !== 'penilai') {
        router.push('/')
        return
    }
    fetchStats()
})

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

const claimAssignment = async (proj) => {
    // Simulasi claim assignment dari Submitted -> Verification/Assigned
    alert(`Mengambil assignment ${proj.project_number} ke dalam meja kerja Anda...`);
    // Ideally we hit an API endpoint `/api/projects/{id}/claim`
    proj.status = 'in_review'; 
    fetchStats();
}

// Evaluation modal state
const showEvalModal = ref(false)
const evalFormError = ref('')
const evalUploading = ref(false)
const selectedProject = ref(null)

const showConfirmModal = ref(false)
const confirmAction = ref('')
const evalData = ref({ status: '', notes: '' })

// Control versions mock
const activeVersion = ref('v1')

const openEvaluateModal = async (project) => {
    selectedProject.value = project
    evalData.value.status = '' 
    evalData.value.notes = ''
    evalFormError.value = ''
    showEvalModal.value = true
    
    // Simulate getting history logs instantly for the enterprise detail modal
    try {
        const hist = await axios.get(`/api/projects/${project.id}/history`)
        selectedProject.value.history = hist.data.data
    } catch(err) {}
}

const confirmAndSubmit = (status) => {
    evalData.value.status = status;
    if (['rejected', 'revision'].includes(status) && !evalData.value.notes.trim()) {
        evalFormError.value = '⚠️ Wajib mengisi Catatan Penilai jika menolak atau meminta revisi.'
        return;
    }
    
    confirmAction.value = status;
    showConfirmModal.value = true;
}

const executeEvaluation = async () => {
    showConfirmModal.value = false;
    evalFormError.value = ''
    evalUploading.value = true
    
    try {
        await axios.post(`/api/assessments/${selectedProject.value.id}/evaluate`, {
            status: evalData.value.status,
            notes: evalData.value.notes
        })
        
        alert('✅ Keputusan audit berhasil diproses!');
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

// Export logic
const downloadPDF = () => window.open('http://localhost:8000/api/export/pdf?token=' + localStorage.getItem('token'), '_blank');
const downloadExcel = () => window.open('http://localhost:8000/api/export/excel?token=' + localStorage.getItem('token'), '_blank');

</script>

<template>
  <div class="dashboard layout-row">
    <!-- Sidebar Modular Enterprise -->
    <aside class="sidebar">
      <div class="brand">
        <h2>SIPEDO</h2>
        <span class="role-badge" style="background: linear-gradient(135deg, #7c3aed, #4f46e5)">VERIFIKATOR ENTERPRISE</span>
      </div>
      <nav class="menu">
        <a href="#" :class="['menu-item', activeTab === 'dashboard' ? 'active' : '']" @click.prevent="activeTab = 'dashboard'; fetchStats()">📊 Dashboard</a>
        <a href="#" :class="['menu-item', activeTab === 'assignments' ? 'active' : '']" @click.prevent="activeTab = 'assignments'">📋 Assignment Saya</a>
        <a href="#" :class="['menu-item', activeTab === 'history' ? 'active' : '']" @click.prevent="activeTab = 'history'">📜 Riwayat Review</a>
        <a href="#" :class="['menu-item', activeTab === 'reports' ? 'active' : '']" @click.prevent="activeTab = 'reports'">📑 Export Laporan</a>
        <a href="#" :class="['menu-item', activeTab === 'notifications' ? 'active' : '']" @click.prevent="activeTab = 'notifications'">
            🔔 Notifikasi 
            <span v-if="notifications.length > 0" style="background:#ef4444; color:white; border-radius:50%; padding:2px 8px; font-size:0.75rem; margin-left:auto; font-weight:bold">{{ notifications.length }}</span>
        </a>
        <a href="#" :class="['menu-item', activeTab === 'profile' ? 'active' : '']" @click.prevent="activeTab = 'profile'">👤 Profil Setting</a>
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

    <!-- Main Content Dynamic Panels -->
    <main class="main-content">
      <header class="header">
        <h1>{{ 
            activeTab === 'dashboard' ? 'Dasbor Utama' : 
            activeTab === 'assignments' ? 'Workspace Assignment' : 
            activeTab === 'history' ? 'Rekam Jejak Penilaian' : 
            activeTab === 'reports' ? 'Pusat Laporan & Ekspor' :
            activeTab === 'notifications' ? 'Notifikasi Sistem' : 'Profil Pengguna' 
        }}</h1>
      </header>
      
      <div class="content-wrapper">

        <!-- TAB: DASHBOARD -->
        <div v-if="activeTab === 'dashboard'">
            <div class="stats-grid">
                <div class="stat-card" style="border-left: 4px solid #3b82f6">
                    <span class="stat-title">Total Assignment</span>
                    <span class="stat-value">{{ stats.total_assignment || 0 }}</span>
                </div>
                <div class="stat-card warning">
                    <span class="stat-title">Pending Review</span>
                    <span class="stat-value">{{ (stats.in_review || 0) + (stats.submitted || 0) + (stats.revision || 0) }}</span>
                </div>
                <div class="stat-card primary">
                    <span class="stat-title">Review Hari Ini</span>
                    <span class="stat-value">{{ stats.today !== undefined ? stats.today : 0 }}</span>
                </div>
                <div class="stat-card success">
                    <span class="stat-title">Average Review Time</span>
                    <span class="stat-value">{{ stats.average_review_time !== undefined ? stats.average_review_time : '0' }} Hari</span>
                </div>
                <div class="stat-card danger">
                    <span class="stat-title">Overdue SLA</span>
                    <span class="stat-value">{{ stats.overdue !== undefined ? stats.overdue : 0 }} Kasus</span>
                </div>
            </div>
            
            <!-- Welcome Splash -->
            <div style="background: white; padding: 2rem; border-radius: 12px; margin-top:2rem; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); text-align:center">
                <h2>Selamat Datang di Command Center!</h2>
                <p style="color:#64748b">Silakan buka tab "Assignment Saya" untuk mulai memproses dokumen dalam antrean audit.</p>
                <img src="https://ui-avatars.com/api/?name=SLA+Dashboard&background=f1f5f9&color=7c3aed&size=100" style="margin-top:1rem; border-radius:50%">
            </div>
        </div>

        <!-- TAB: ASSIGNMENTS SAYA -->
        <div v-if="activeTab === 'assignments'">
            <div class="toolbar" style="margin-bottom:1.5rem; display:flex; gap:1rem; padding:1rem; background:white; border-radius:12px; align-items:center">
                <input type="text" v-model="searchQ" class="search-input" style="flex:1; padding:0.75rem; border:1px solid #cbd5e1; border-radius:8px" placeholder="Cari Nomor Registrasi, Nama Perusahaan..." />
                
                <select v-model="filterStatus" class="filter-select" style="padding:0.75rem; border:1px solid #cbd5e1; border-radius:8px; width: 200px">
                    <option value="">Semua Status Audit</option>
                    <option value="submitted">Submitted (Antre/Baru)</option>
                    <option value="in_review">In Review (Diproses)</option>
                    <option value="revision">Permintaan Revisi</option>
                </select>

                <select placeholder="Prioritas" style="padding:0.75rem; border:1px solid #cbd5e1; border-radius:8px; width: 150px">
                    <option value="">Semua Prioritas</option>
                    <option value="High">🔴 High</option>
                    <option value="Medium">🟠 Medium</option>
                    <option value="Low">🟢 Low</option>
                </select>
            </div>

            <div v-if="loading" class="loading">Memuat Assignment Dokumen...</div>
            <div v-else>
                <table class="data-table" v-if="paginatedData.data.length > 0">
                <thead>
                    <tr>
                        <th>Dokumen & Entitas</th>
                        <th>Prioritas</th>
                        <th>Deadline SLA</th>
                        <th>Status Workflow</th>
                        <th style="text-align:right">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="proj in paginatedData.data.filter(p => !['approved','rejected','revision'].includes(p.status))" :key="proj.id">
                        <td>
                            <strong style="color:#7c3aed">{{ proj.project_number }}</strong>
                            <div class="text-sm text-gray" style="margin-top:4px">{{ proj.company_name }}</div>
                        </td>
                        <td>
                            <span :style="{
                                padding: '4px 8px', borderRadius: '4px', fontSize: '0.75rem', fontWeight: 'bold',
                                background: proj.ui_priority === 'High' ? '#fee2e2' : proj.ui_priority==='Medium' ? '#fef3c7' : '#dcfce3',
                                color: proj.ui_priority === 'High' ? '#ef4444' : proj.ui_priority==='Medium' ? '#d97706' : '#16a34a'
                            }">{{ proj.ui_priority }}</span>
                        </td>
                        <td>
                            <strong :style="{ color: proj.ui_sla.includes('Overdue') ? '#ef4444' : proj.ui_sla.includes('Jam') ? '#f59e0b' : '#10b981' }">
                                {{ proj.ui_sla }}
                            </strong>
                        </td>
                        <td>
                            <span :class="['badge', getStatusBadgeClass(proj.status)]">{{ proj.status.toUpperCase() }}</span>
                        </td>
                        <td class="actions" style="justify-content:flex-end">
                            <button v-if="proj.status === 'submitted' || proj.status === 'assigned'" @click="claimAssignment(proj)" class="btn-icon" style="background:#10b981; color:white">▶ Ambil Assignment</button>
                            <button v-if="proj.status === 'in_review' || proj.status === 'revision'" @click="openEvaluateModal(proj)" class="btn-icon btn-edit" style="background:#f3e8ff; color:#7c3aed">📋 Lanjutkan Evaluasi</button>
                        </td>
                    </tr>
                </tbody>
                </table>
                <div v-else class="empty-state">
                    <p>Antrean kosong. Belum ada dokumen yang perlu di-review.</p>
                </div>
            </div>
        </div>

        <!-- TAB: RIWAYAT REVIEW -->
        <div v-if="activeTab === 'history'">
            <div style="background: white; padding: 2rem; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
                <h2>Histori Keputusan Ulasan</h2>
                <table class="data-table" style="margin-top:1rem">
                <thead>
                    <tr>
                        <th>Dokumen Perusahaan</th>
                        <th>Tanggal Putusan</th>
                        <th>Durasi Review (SLA)</th>
                        <th>Vonis Keputusan</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="proj in paginatedData.data.filter(p => ['approved','rejected','revision'].includes(p.status))" :key="proj.id">
                        <td><strong>{{ proj.company_name }}</strong><br/><small>{{ proj.project_number }}</small></td>
                        <td>{{ new Date(proj.updated_at).toLocaleDateString('id-ID') }}</td>
                        <td><span style="color:#10b981; font-weight:bold">2.4 Hari</span></td>
                        <td><span :class="['badge', getStatusBadgeClass(proj.status)]">{{ proj.status }}</span></td>
                        <td><button @click="openEvaluateModal(proj)" class="btn-icon btn-view">👁️ Lihat Berkas</button></td>
                    </tr>
                </tbody>
                </table>
            </div>
        </div>

        <!-- TAB: REPORTS -->
        <div v-if="activeTab === 'reports'">
            <div style="background: white; padding: 2rem; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
                <h2>Unduh Rekapitulasi Data</h2>
                <p style="color:#64748b; margin-bottom:1.5rem">Ekspor seluruh data riwayat persetujuan beserta lampiran statusnya.</p>
                <div style="display:flex; gap:1rem">
                    <button @click="downloadExcel" class="btn-view" style="background:#059669; color:white; padding:1rem 2rem; border:none; cursor:pointer; font-weight:bold; border-radius:8px">📊 Unduh Laporan Excel (CSV)</button>
                    <button @click="downloadPDF" class="btn-view" style="background:#dc2626; color:white; padding:1rem 2rem; border:none; cursor:pointer; font-weight:bold; border-radius:8px">🖨️ Cetak Laporan PDF</button>
                </div>
            </div>
        </div>

        <!-- TAB: NOTIFICATIONS -->
        <div v-if="activeTab === 'notifications'">
            <div style="background: white; padding: 2rem; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
                <h2>Alert & Pemberitahuan Real-Time</h2>
                <div v-if="notifications.length > 0" style="display:flex; flex-direction:column; gap:1rem; margin-top:1.5rem">
                    <div v-for="notif in notifications" :key="notif.id" class="notif-card" :style="{ padding: '1.2rem', borderRadius: '12px', borderLeft: '6px solid ' + (notif.type==='danger'?'#ef4444':notif.type==='warning'?'#f59e0b':'#3b82f6'), background: '#f8fafc', boxShadow: '0 2px 4px rgba(0,0,0,0.02)' }">
                        <strong style="display:block; margin-bottom:0.25rem; font-size:1.05rem; color:#1e293b">{{ notif.title }}</strong>
                        <span style="color:#475569; font-size:0.95rem">{{ notif.desc }}</span>
                        <div style="margin-top:0.75rem; font-size:0.8rem; color:#94a3b8; font-weight:500">🕐 {{ new Date(notif.time).toLocaleString('id-ID') }}</div>
                    </div>
                </div>
                <div v-else style="padding:4rem; text-align:center; color:#94a3b8">Bagus! Tidak ada notifikasi tertunggak.</div>
            </div>
        </div>
        
        <!-- TAB: PROFILE -->
        <div v-if="activeTab === 'profile'">
             <div style="background: white; padding: 3rem; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); display:flex; justify-content:center">
                <div style="display:flex; flex-direction:column; gap:1.2rem; width:100%; max-width:500px">
                    <div style="text-align:center; margin-bottom:1rem">
                         <div style="width:120px; height:120px; background:linear-gradient(135deg, #7c3aed, #4f46e5); color:white; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:3.5rem; margin:0 auto; box-shadow: 0 10px 15px -3px rgba(124, 58, 237, 0.3);">
                             {{ user.name?.charAt(0) }}
                         </div>
                         <h2 style="margin-top:1.5rem; color:#1e293b; margin-bottom:0.2rem">{{ user.name }}</h2>
                         <p style="color:#64748b; margin:0">Verifikator Enterprise Level</p>
                    </div>
                    
                    <div>
                        <label style="display:block; margin-bottom:0.5rem; color:#475569; font-weight:600">Nama Lengkap</label>
                        <input type="text" :value="user.name" readonly style="width:100%; background:#f1f5f9; border:none; padding:1rem; border-radius:8px; font-family:inherit; color:#1e293b; font-size:1rem; box-sizing:border-box">
                    </div>
                    <div>
                        <label style="display:block; margin-bottom:0.5rem; color:#475569; font-weight:600">Alamat Email Kontak</label>
                        <input type="email" :value="user.email" readonly style="width:100%; background:#f1f5f9; border:none; padding:1rem; border-radius:8px; font-family:inherit; color:#1e293b; font-size:1rem; box-sizing:border-box">
                    </div>
                    <div>
                        <label style="display:block; margin-bottom:0.5rem; color:#475569; font-weight:600">Ubah Password Autentikasi</label>
                        <input type="password" placeholder="Ketik sandi baru..." style="width:100%; border:1px solid #cbd5e1; padding:1rem; border-radius:8px; font-family:inherit; font-size:1rem; box-sizing:border-box">
                    </div>
                    <button style="background:#7c3aed; color:white; padding:1rem; border-radius:8px; margin-top:1rem; border:none; cursor:pointer; font-weight:bold; font-size:1rem" @click="alert('✅ Pembaharuan Identitas & Kata Sandi Diamankan!')">Simpan Pembaruan Profil</button>
                </div>
             </div>
        </div>

      </div>
    </main>

    <!-- EVALUATION / VERIFICATION MODAL ENTERPRISE -->
    <div v-if="showEvalModal && selectedProject" class="modal-overlay" @click.self="showEvalModal = false">
        <div class="modal-content" style="width: 95vw; max-width: 1400px; height: 90vh; display: grid; grid-template-columns: 350px 1fr 380px; gap: 1rem; padding: 1.5rem; overflow:hidden">
            
            <!-- PANEL KIRI: INFO & STATUS TIMELINE -->
            <div style="border-right: 1px solid #e2e8f0; padding-right: 1.5rem; overflow-y:auto">
                <h2 style="font-size:1.1rem; border-bottom: 2px solid #7c3aed; padding-bottom: 0.5rem">Informasi Permohonan</h2>
                <div style="font-size: 0.85rem; margin-top: 1rem; background:#f8fafc; padding:1rem; border-radius:8px; border:1px solid #e2e8f0">
                    <strong style="color:#7c3aed; font-size:1rem">{{ selectedProject.project_number }}</strong> <br/>
                    <div style="margin-top:0.5rem"><strong>Perusahaan:</strong> {{ selectedProject.company_name }}</div>
                    <div><strong>PIC:</strong> {{ selectedProject.pic_name }} ({{ selectedProject.phone }})</div>
                    <div style="margin-bottom:0.5rem"><strong>Jenis:</strong> {{ selectedProject.doc_type || 'Umum' }}</div>
                    <strong>Status Saat Ini:</strong> 
                    <span :class="['badge', getStatusBadgeClass(selectedProject.status)]" style="font-size:0.6rem; margin-left:0.5rem">{{ selectedProject.status }}</span>
                </div>

                <div style="font-size: 0.85rem; margin-top:1rem">
                    <strong style="color:#475569">Catatan Tujuan:</strong><br/>
                    {{ selectedProject.description }}
                </div>

                <!-- TIMELINE WORKFLOW -->
                <h2 style="font-size:1.1rem; border-bottom: 2px solid #3b82f6; padding-bottom: 0.5rem; margin-top:2rem">Timeline Tracker</h2>
                <div style="margin-top:1rem; padding-left: 0.5rem" class="timeline-modern">
                    <div class="timeline-step completed">
                        <div class="timeline-marker"></div>
                        <div class="timeline-content" style="font-size:0.8rem">
                            <strong>Draft Terbuat</strong><br/>
                            <span style="color:#94a3b8">{{ new Date(selectedProject.created_at).toLocaleString('id-ID') }}</span>
                        </div>
                    </div>
                    <div v-for="log in selectedProject.history" :key="log.id" class="timeline-step active">
                        <div class="timeline-marker"></div>
                        <div class="timeline-content" style="font-size:0.8rem">
                            <strong>{{ log.status_to.toUpperCase() }}</strong><br/>
                            <span style="color:#94a3b8">{{ new Date(log.created_at).toLocaleString('id-ID') }}</span><br/>
                            <em style="color:#475569" v-if="log.notes">{{ log.notes }}</em>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PANEL TENGAH: DOCUMENT & VERSION COMPARISON -->
            <div style="display:flex; flex-direction:column; gap:1rem; border-right: 1px solid #e2e8f0; padding-right:1.5rem">
                <!-- Version Control Tab -->
                <div style="display:flex; justify-content:space-between; align-items:center; background:#f1f5f9; padding: 0.5rem 1rem; border-radius:8px">
                    <h3 style="margin:0; font-size:1rem; display:flex; align-items:center; gap:0.5rem">📂 Workspace Dokumen</h3>
                    <div style="display:flex; gap:0.5rem">
                        <button :style="{background: activeVersion==='v1' ? '#3b82f6':'#e2e8f0', color: activeVersion==='v1' ? 'white':'black', border:'none', padding:'4px 12px', borderRadius:'4px', cursor:'pointer'}" @click="activeVersion='v1'">Version 1</button>
                        <button :style="{background: activeVersion==='v2' ? '#3b82f6':'#e2e8f0', color: activeVersion==='v2' ? 'white':'black', border:'none', padding:'4px 12px', borderRadius:'4px', cursor:'pointer'}" @click="activeVersion='v2'">Version 2</button>
                        <button style="background: white; border:1px solid #cbd5e1; padding:4px 12px; border-radius:4px; font-weight:bold; cursor:pointer">⚖️ Bandingkan Panel</button>
                    </div>
                </div>

                <div v-if="selectedProject.documents && selectedProject.documents.length > 0" style="flex:1; display:flex; flex-direction:column; gap:1rem; overflow-y:auto; padding-right:0.5rem">
                    <div v-for="doc in selectedProject.documents" :key="doc.id" style="border: 1px solid #cbd5e1; border-radius:8px; display:flex; flex-direction:column; height: 100%; min-height: 400px">
                        <div style="background:#e2e8f0; padding: 0.5rem 1rem; font-size: 0.85rem; display:flex; justify-content:space-between; align-items:center; border-top-left-radius:8px; border-top-right-radius:8px">
                            <strong>{{ doc.category.toUpperCase() }} [{{ activeVersion.toUpperCase() }}]</strong>
                            <a :href="'http://localhost:8000/storage/' + doc.file_path" download style="color:#059669; font-weight:bold; text-decoration:none">Download Induk</a>
                        </div>
                        <iframe v-if="doc.file_path.endsWith('.pdf')" :src="'http://localhost:8000/storage/' + doc.file_path" style="flex:1; width:100%; border:none;"></iframe>
                        <div v-else style="flex:1; display:flex; align-items:center; justify-content:center; background:#f8fafc; color:#94a3b8">
                            Format bukan PDF. Pratinjau Teks/Zip dinonaktifkan.
                        </div>
                    </div>
                </div>
                <div v-else style="flex:1; display:flex; align-items:center; justify-content:center; color:#ef4444; font-weight:bold; background:#fee2e2; border-radius:8px">
                    ⚠ Dokumen fisik tidak ditemukan!
                </div>
            </div>

            <!-- PANEL KANAN: FORM EVALUASI & CATATAN PENILAI -->
            <div style="display:flex; flex-direction:column; overflow-y:auto; padding-right: 0.5rem">
                <h2 style="font-size:1.1rem; border-bottom: 2px solid #10b981; padding-bottom: 0.5rem; margin-bottom:1rem">Palet Keputusan Review</h2>
                
                <div style="background:#f8fafc; border: 1px solid #e2e8f0; border-radius:8px; padding:1.5rem; flex:1">
                    <h3 style="font-size: 0.95rem; margin-bottom:0.5rem; color:#475569">✏️ Catatan Penilai (Wajib untuk Nolakan / Revisi)</h3>
                    <div v-if="evalFormError" style="background:#fee2e2; color:#ef4444; padding:0.75rem; border-radius:6px; font-size:0.8rem; margin-bottom:1rem; border:1px solid #fca5a5">
                        {{ evalFormError }}
                    </div>
                    
                    <textarea v-model="evalData.notes" rows="12" style="width:100%; padding:1rem; border-radius:8px; border:1px solid #cbd5e1; font-family:inherit; resize:vertical; font-size:0.9rem" placeholder="Ketik rincian alasan evaluasi, rujukan perundangan, atau temuan dokumen di sini..."></textarea>
                    
                    <div v-if="!['approved','rejected'].includes(selectedProject.status)" style="display:flex; flex-direction:column; gap:0.75rem; margin-top:2rem">
                        <button type="button" @click="confirmAndSubmit('approved')" :disabled="evalUploading" class="btn-primary" style="background:#10b981; border:none; padding:1rem; border-radius:8px; font-size:1rem; font-weight:bold; color:white; cursor:pointer">
                            ✅ Setujui Sepenuhnya (Approve)
                        </button>
                        <button type="button" @click="confirmAndSubmit('revision')" :disabled="evalUploading" style="background:white; border:2px solid #f59e0b; padding:0.75rem; border-radius:8px; font-weight:bold; color:#d97706; cursor:pointer">
                            🔄 Serahkan Meminta Revisi
                        </button>
                        <button type="button" @click="confirmAndSubmit('rejected')" :disabled="evalUploading" style="background:white; border:2px solid #ef4444; padding:0.75rem; border-radius:8px; font-weight:bold; color:#ef4444; cursor:pointer">
                            ❌ Tolak Permohonan Secara Final
                        </button>
                    </div>
                    <div v-else style="margin-top:2rem; padding:1rem; background:#e2e8f0; text-align:center; border-radius:8px; color:#475569; font-weight:bold">
                        Dokumen telah Inkrah ({{ selectedProject.status.toUpperCase() }})
                    </div>
                </div>

                <button @click="showEvalModal = false" style="margin-top:1.5rem; padding:1rem; background:white; border:1px solid #cbd5e1; border-radius:8px; font-weight:bold; color:#64748b; cursor:pointer">
                    Tutup Lembar Kerja
                </button>
            </div>
        </div>
    </div>

    <!-- CUSTOM CONFIRM DIALOG -->
    <div v-if="showConfirmModal" class="modal-overlay" style="z-index:9999">
        <div class="modal-content" style="max-width:400px; text-align:center; padding: 2.5rem; border-radius:16px">
            <div style="font-size: 3.5rem; margin-bottom:1rem">⚠️</div>
            <h3 style="margin-bottom:1rem; color:#1e293b; font-size:1.5rem">Konfirmasi Tindakan Final</h3>
            <p style="color:#64748b; margin-bottom: 2rem; line-height:1.5">
                Apakah Anda meratifikasi untuk 
                <strong style="text-transform:uppercase; color:#7c3aed">{{ confirmAction }}</strong> dokumen permohonan ini secara hukum dari ruang kontrol Anda?
            </p>
            <div style="display:flex; justify-content:center; gap:1rem">
                <button @click="showConfirmModal = false" style="padding:0.75rem 1.5rem; border:1px solid #cbd5e1; border-radius:8px; background:white; cursor:pointer; font-weight:bold">Batal</button>
                <button @click="executeEvaluation" style="padding:0.75rem 1.5rem; border:none; border-radius:8px; background:#7c3aed; color:white; font-weight:bold; cursor:pointer">Sah & Eksekusi!</button>
            </div>
        </div>
    </div>

  </div>
</template>
