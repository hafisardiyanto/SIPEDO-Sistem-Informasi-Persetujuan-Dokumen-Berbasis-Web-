<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'

const router = useRouter()
const user = ref(JSON.parse(localStorage.getItem('user')) || {})

const projects = ref([])
const loading = ref(false)

// Modals state
const showFormModal = ref(false)
const showHistoryModal = ref(false)

// Form state
const isEdit = ref(false)
const formError = ref('')
const formUploading = ref(false)
const formData = ref({
  id: null,
  title: '',
  description: '',
  document: null
})
const fileInput = ref(null)
const selectedProjectHistory = ref(null)

const fetchProjects = async () => {
    loading.value = true
    try {
        const res = await axios.get('/api/projects')
        projects.value = res.data.data
    } catch (err) {
        if(err.response?.status === 401) logout()
        console.error(err)
    } finally {
        loading.value = false
    }
}

onMounted(() => {
    if(!user.value || user.value.role !== 'pemohon') {
        router.push('/')
        return
    }
    fetchProjects()
})

const logout = async () => {
    try {
        await axios.post('/api/logout')
    } catch (e) {}
    localStorage.removeItem('user')
    router.push('/')
}

const openCreateModal = () => {
    isEdit.value = false
    formData.value = { id: null, title: '', description: '', document: null }
    if(fileInput.value) fileInput.value.value = ''
    formError.value = ''
    showFormModal.value = true
}

const openEditModal = (project) => {
    isEdit.value = true
    formData.value = { id: project.id, title: project.title, description: project.description, document: null }
    if(fileInput.value) fileInput.value.value = ''
    formError.value = ''
    showFormModal.value = true
}

const handleFileChange = (e) => {
    formData.value.document = e.target.files[0]
}

const submitForm = async () => {
    formError.value = ''
    formUploading.value = true
    
    const payload = new FormData()
    payload.append('title', formData.value.title)
    payload.append('description', formData.value.description)
    if(formData.value.document) {
        payload.append('document', formData.value.document)
    }

    try {
        if (isEdit.value) {
            // override method to PUT since we are sending FormData
            payload.append('_method', 'PUT')
            await axios.post(`/api/projects/${formData.value.id}`, payload, {
                headers: { 'Content-Type': 'multipart/form-data' }
            })
        } else {
            if(!formData.value.document) {
                throw new Error("Dokumen wajib diunggah untuk pengajuan baru.")
            }
            await axios.post('/api/projects', payload, {
                headers: { 'Content-Type': 'multipart/form-data' }
            })
        }
        showFormModal.value = false
        fetchProjects()
    } catch (err) {
        formError.value = err.response?.data?.message || err.message || 'Gagal menyimpan data.'
    } finally {
        formUploading.value = false
    }
}

const submitProjectToAssessor = async (id) => {
    if(!confirm('Kirim permohonan ini untuk dinilai? Anda tidak dapat merubahnya setelah dikirim.')) return
    try {
        await axios.post(`/api/projects/${id}/submit`)
        fetchProjects()
    } catch (err) {
        alert(err.response?.data?.message || 'Gagal mengirim')
    }
}

const viewHistory = async (project) => {
    try {
        const res = await axios.get(`/api/projects/${project.id}`)
        selectedProjectHistory.value = res.data.data
        showHistoryModal.value = true
    } catch (err) {
        console.error(err)
    }
}

const getStatusBadgeClass = (status) => {
    const map = {
        'draft': 'badge-gray',
        'submitted': 'badge-blue',
        'in_review': 'badge-yellow',
        'revision': 'badge-orange',
        'approved': 'badge-green',
        'rejected': 'badge-red'
    }
    return map[status] || 'badge-gray'
}
import '../assets/pemohon-dashboard.css';
</script>
