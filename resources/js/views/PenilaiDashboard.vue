<template>
  <div class="p-6">
    <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold">Dashboard Penilai</h1>
        <button @click="logout" class="bg-red-500 text-white px-4 py-2 rounded">Logout</button>
    </div>
    
    <div>
        <h2 class="text-xl font-semibold mb-4">Daftar Dokumen Masuk</h2>
        <div v-if="projects.length === 0" class="text-gray-500">Tidak ada dokumen yang perlu dinilai.</div>
        <table v-else class="w-full border-collapse">
            <thead>
                <tr class="bg-gray-200">
                    <th class="border p-2 text-left">Pemohon</th>
                    <th class="border p-2 text-left">Judul</th>
                    <th class="border p-2 text-left">Status</th>
                    <th class="border p-2 text-left">Aksi Penilaian</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="project in projects" :key="project.id">
                    <td class="border p-2">{{ project.user ? project.user.name : '-' }}</td>
                    <td class="border p-2">{{ project.title }}</td>
                    <td class="border p-2">
                        <span class="px-2 py-1 rounded bg-yellow-200 font-bold text-sm">{{ project.status.toUpperCase() }}</span>
                    </td>
                    <td class="border p-2">
                        <div class="flex flex-col gap-2">
                            <input v-model="notes[project.id]" placeholder="Catatan penilaian..." class="border p-1 text-sm w-full">
                            <div class="flex gap-2">
                                <button @click="nilai(project, 'approved')" class="bg-green-500 text-white px-2 py-1 rounded text-xs">Setuju</button>
                                <button @click="nilai(project, 'revision')" class="bg-orange-500 text-white px-2 py-1 rounded text-xs">Revisi</button>
                                <button @click="nilai(project, 'rejected')" class="bg-red-600 text-white px-2 py-1 rounded text-xs">Tolak</button>
                            </div>
                        </div>
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
const notes = ref({});

const fetchProjects = async () => {
    try {
        const res = await axios.get('/api/assessments', {
            headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
        });
        projects.value = res.data.data;
    } catch(e) {
        if(e.response && e.response.status === 401) router.push('/login');
    }
};

const nilai = async (project, statusTarget) => {
    if(!confirm(`Yakin ingin mengubah status menjadi ${statusTarget}?`)) return;
    
    try {
        await axios.post(`/api/assessments/${project.id}/evaluate`, {
            status: statusTarget,
            notes: notes.value[project.id] || ''
        }, {
            headers: { Authorization: `Bearer ${localStorage.getItem('token')}` }
        });
        alert('Penilaian berhasil disimpan');
        fetchProjects();
    } catch(e) {
        alert('Gagal menyimpan penilaian');
    }
};

const logout = () => {
    localStorage.clear();
    router.push('/login');
};

onMounted(() => {
    fetchProjects();
});
</script>
