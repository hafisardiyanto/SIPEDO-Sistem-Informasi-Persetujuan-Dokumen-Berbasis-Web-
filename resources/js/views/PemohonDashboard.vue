<template>
  <div class="p-6">
    <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold">Dashboard Pemohon</h1>
        <button @click="logout" class="bg-red-500 text-white px-4 py-2 rounded">Logout</button>
    </div>
    
    <div class="bg-white rounded shadow p-6 mb-6">
        <h2 class="text-xl font-semibold mb-4">Buat Permohonan Baru</h2>
        <form @submit.prevent="submitForm">
            <div class="mb-4">
                <label class="block text-sm font-medium mb-1">Judul Project</label>
                <input v-model="form.title" type="text" class="w-full border rounded p-2" required>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium mb-1">Deskripsi</label>
                <textarea v-model="form.description" class="w-full border rounded p-2" required></textarea>
            </div>
            <div class="mb-4">
                <label class="block text-sm font-medium mb-1">Dokumen Lampiran (PDF)</label>
                <input type="file" @change="handleFileUpload" class="w-full" required>
            </div>
            <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded" :disabled="loading">Simpan Draft</button>
        </form>
    </div>

    <div>
        <h2 class="text-xl font-semibold mb-4">Daftar Permohonan Saya</h2>
        <div v-if="projects.length === 0" class="text-gray-500">Belum ada permohonan.</div>
        <table v-else class="w-full border-collapse">
            <thead>
                <tr class="bg-gray-200">
                    <th class="border p-2 text-left">Judul</th>
                    <th class="border p-2 text-left">Status</th>
                    <th class="border p-2 text-left">Tanggal</th>
                    <th class="border p-2 text-left">Aksi</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="project in projects" :key="project.id">
                    <td class="border p-2">{{ project.title }}</td>
                    <td class="border p-2">
                        <span class="px-2 py-1 rounded bg-gray-200 text-sm font-bold">{{ project.status.toUpperCase() }}</span>
                    </td>
                    <td class="border p-2">{{ new Date(project.created_at).toLocaleDateString() }}</td>
                    <td class="border p-2">
                        <button v-if="project.status === 'draft' || project.status === 'revision'" @click="kirimPermohonan(project.id)" class="bg-green-500 text-white px-3 py-1 rounded text-sm mr-2">Submit Penilaian</button>
                        <button @click="lihatDetail(project.id)" class="bg-blue-500 text-white px-3 py-1 rounded text-sm">Lihat History</button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';

const router = useRouter();
const projects = ref([]);
const loading = ref(false);
const file = ref(null);
const form = ref({ title: '', description: '' });

const fetchProjects = async () => {
    try {
        const res = await axios.get('/api/projects', {
            headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
        });
        projects.value = res.data.data;
    } catch(e) {
        if(e.response.status === 401) router.push('/login');
    }
};

const handleFileUpload = (e) => {
    file.value = e.target.files[0];
};

const submitForm = async () => {
    loading.value = true;
    let formData = new FormData();
    formData.append('title', form.value.title);
    formData.append('description', form.value.description);
    if(file.value) formData.append('document', file.value);

    try {
        await axios.post('/api/projects', formData, {
            headers: { 
                Authorization: `Bearer ${localStorage.getItem('token')}`,
                'Content-Type': 'multipart/form-data'
            }
        });
        alert('Draft permohonan berhasil dibuat!');
        form.value = { title: '', description: '' };
        file.value = null;
        fetchProjects();
    } catch(e) {
        alert('Gagal membuat permohonan');
    } finally {
        loading.value = false;
    }
};

const kirimPermohonan = async (id) => {
    if(!confirm('Kirim dokumen ini untuk dinilai?')) return;
    try {
        await axios.post(`/api/projects/${id}/submit`, {}, {
            headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
        });
        alert('Terkirim!');
        fetchProjects();
    } catch(e) {
        alert('Gagal mengirim');
    }
};

const lihatDetail = (id) => {
    alert('Detail view for ID: ' + id + ' belum diimplementasikan di mockup ini');
};

const logout = () => {
    localStorage.clear();
    router.push('/login');
};

onMounted(() => {
    fetchProjects();
});
</script>
