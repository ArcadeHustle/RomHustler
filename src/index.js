import App from './vue/app.js'
import {$,jQuery} from 'jquery';
(()=>{
  window.$ = $; // export for others scripts to use
  window.jQuery = jQuery;
  const app = new App('#rs-app'); //eslint-disable-line no-unused-vars
})