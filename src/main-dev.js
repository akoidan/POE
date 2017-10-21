// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './components/App.vue'
//import CurrencyApp from './components/CurrencyApp.vue'
import './assets/stylesheets/main.sass'
import {init} from "./helpers/poe.trade";

function fillBody(cb) {
  let xobj = new XMLHttpRequest();
  // special for IE
  xobj.open('GET', '/static/dev_content.html', true);
  xobj.onload = res => {
    document.getElementById('contentbody').innerHTML = xobj.responseText;
    cb();
  };
  xobj.send();
}
Vue.config.productionTip = false;

fillBody(() => {
  window.app = new Vue({
    el: '#contentstart',
    render: h => h(App),
  });
  init();
});


