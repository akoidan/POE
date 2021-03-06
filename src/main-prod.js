// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './components/App.vue'
import CurrencyApp from './components/CurrencyApp.vue'
import './assets/stylesheets/main.sass'
import {init} from "./helpers/poe.trade";
Vue.config.productionTip = false;

(function() {
  let loadTries = 0;
  function loader() {
    loadTries++;
    const holder = document.getElementById('contentstart');
    if (loadTries > 50) {
      console.error(`Unable to load poe-trade extension plugin cause 
        document.querySelector('#contentstart') didnt find any wrappers`);
      clearInterval(rfLoader);
    } else if (holder) {
      if (window.location.hostname === 'poe.trade') {
        new Vue({
          el: '#contentstart',
          render: h => h(App),
        });
        init();
      } else if (window.location.hostname === "currency.poe.trade") {
        new Vue({
          el: '#contentstart',
          render: h => h(CurrencyApp),
        });
      } else {
        alert("Current domain neither poe.trade nor currency.poe.trade");
      }
      clearInterval(rfLoader);
    }
  }
  const rfLoader = setInterval(loader, 400);
  loader();
})();

