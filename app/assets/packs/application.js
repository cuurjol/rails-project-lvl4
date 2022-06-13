// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import * as bootstrap from 'bootstrap'
import "../stylesheets/application.scss"
import "@fortawesome/fontawesome-free/css/all"
import Rails from "@rails/ujs"

Rails.start()

function closeFlashMessage() {
	let flash_element = document.getElementById('flashMessage')
	if (flash_element) {
		setTimeout(() => { flash_element.style.display = 'none'; }, 4000);
	}
}

document.addEventListener('DOMContentLoaded', function() {
	closeFlashMessage();
});
