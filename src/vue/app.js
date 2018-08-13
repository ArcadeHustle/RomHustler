import VueRouter from "vue-router"
import Vue from "vue"
import Viewport from "./viewport/viewport.vue"
import VueMaterial from 'vue-material'
import RomSelectorForm from './RomSelector/RomSelectorForm.vue'
export default class App{
  constructor(id){
    Vue.use(VueMaterial);
    let routes = [
      {
        path: '/',
        component: Viewport,
        children: [{
          path:'/',
          component: RomSelectorForm
        }]
      }
    ]
    let router = new VueRouter({
      mode: "history",
      routes: routes
    });
    window.app = new Vue({
      router
    });
    window.app.$mount(id);
  }
}