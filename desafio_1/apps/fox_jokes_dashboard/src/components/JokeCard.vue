<template>
  <div class="card">
    <button @click="loadJoke">Recargar</button>
    <h2>Chiste de Programador</h2>
    <p>{{ joke || "Cargando..." }}</p>
  </div>
</template>

<script>
export default {
  name: "JokeCard",
  data() {
    return { joke: "" };
  },
  methods: {
    async loadJoke() {
      this.joke = "";
      try {
        const baseURL = window._env_.API_URL;
        const res = await fetch(`${baseURL}/api/joke`);
        const data = await res.json();
        this.joke = data.joke || "No se pudo cargar el chiste.";
      } catch (error) {
        console.error("Error cargando chiste:", error);
        this.joke = "Error al cargar el chiste.";
      }
    },
  },
  mounted() {
    this.loadJoke();
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

button {
  margin-top: 1rem;       
  padding: 0.5rem 1rem;
  border-radius: 6px;
  border: none;
  background-color: #84BD00;
  color: white;
  cursor: pointer;
}


button:hover {
  background-color: #0056b3;
}
</style>