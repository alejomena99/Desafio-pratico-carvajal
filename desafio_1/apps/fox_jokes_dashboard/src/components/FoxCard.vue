<template>
  <div class="card">
    <button @click="loadFox">Recargar</button>
    <h2>Zorro Aleatorio</h2>
    <img :src="foxImage" alt="Zorro" v-if="foxImage" />
    <p v-else>Cargando...</p>
    
  </div>
</template>

<script>
export default {
  name: "FoxCard",
  data() {
    return {
      foxImage: "",
    };
  },
  methods: {
    async loadFox() {
      this.foxImage = "";
      try {
        const baseURL = window._env_.API_URL;
        const res = await fetch(`${baseURL}/api/fox`);
        const data = await res.json();
        this.foxImage = data.image || "";
      } catch (error) {
        console.error("Error cargando imagen de zorro:", error);
        this.foxImage = "";
      }
    },
  },
  mounted() {
    this.loadFox();
  },
};
</script>

<style scoped>
.card {
  display: flex;     
  flex-direction: column;
  padding: 1rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  width: 300px;
  text-align: center;
}

img {
  max-width: 100%;
  border-radius: 8px;
  margin-top: 1rem;
}

button {
  margin-top: 1rem;       
  padding: 0.5rem 1rem;
  border-radius: 6px;
  border: none;
  background-color: #FF8200;
  color: white;
  cursor: pointer;
}

button:hover {
  background-color: #0056b3;
}
</style>