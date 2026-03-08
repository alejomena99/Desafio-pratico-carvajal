<template>
  <div class="dashboard-page">
    <div class="line-color">
      alejomena99@gmail.com
    </div>

    <div class="line-text">
      Desafío Práctico Implementación DevOps Carvajal Digital
    </div>

    <div class="dashboard">
      <div class="card-left">
        <JokeCard />
      </div>

      <div class="card-right">
        <FoxCard />
      </div>
    </div>
  </div>
</template>

<script>
import JokeCard from "../components/JokeCard.vue";
import FoxCard from "../components/FoxCard.vue";

export default {
  name: "Dashboard",
  components: {
    JokeCard,
    FoxCard,
  },
};
</script>

<style scoped>
:global(body) {
  margin: 0;
  padding: 0;
  font-family: 'Montserrat', sans-serif;
}

.line-color {
  width: 100%;
  height: 30px;
  background-color: #00B5FF;
  color: white;
  font-size: 0.9rem;
  font-weight: 300;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding-right: 2rem;
  box-sizing: border-box;
}

.line-text {
  width: 100%;
  background-color: #753BBD;
  color: white;
  font-size: 2rem;
  font-weight: 300;
  padding: 1rem 0;
  text-align: center;
}

.dashboard {
  display: flex;
  gap: 3rem; 
  justify-content: center;
  margin-top: 2rem;
  flex-wrap: wrap;
}

.card-left,
.card-right {
  width: 500px;
  display: flex;
  flex-direction: column;
}

.card-left > *,
.card-right > * {
  width: 100%;
}
</style>