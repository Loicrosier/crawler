// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "@fortawesome/fontawesome-free/css/all"

Rails.start()
Turbolinks.start()
ActiveStorage.start()



import { printScreen } from "../controller/printscreen";
// import { compteRendu } from "../controller/compte_rendu";
import { copyLink } from "../controller/copy_link";



// import { emojiPicker } from "../controllers/emojipicker";


document.addEventListener('turbolinks:load', () => {

  // Call your functions here, e.g:
printScreen()
// compteRendu()
copyLink()


  // disable pinch-zoom on smartphone -------------------------
  document.addEventListener('gesturestart', function (e) {
    e.preventDefault();
    // special hack to prevent zoom-to-tabs gesture in safari
    document.body.style.zoom = 0.99;
  });

  document.addEventListener('gesturechange', function (e) {
    e.preventDefault();
    // special hack to prevent zoom-to-tabs gesture in safari
    document.body.style.zoom = 0.99;
  });

  document.addEventListener('gestureend', function (e) {
    e.preventDefault();
    // special hack to prevent zoom-to-tabs gesture in safari
    document.body.style.zoom = 0.99;
  });

  // initSelect2();
});
