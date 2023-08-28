let initialized = false;
let settings = { toggle: false };
const toggleState = document.getElementById('toggle-state');
const submitInfo = document.getElementById('submit-info');
const heading = document.querySelector('#article h4');
const content = document.querySelector('#article p');

// V functions (in the scope of this example, prefixed with `window.`)
//
// The `window.` prefix is not required. But it is a common pattern in webview examples.
// For semantic reasons and to help distinguish functions as your project grows, this can be a helpful pattern.
// Just use the style and convention you prefer when naming the webview JS functions.

async function handleToggle() {
	// V function call
	toggleState.innerHTML = (await window.toggle_setting()) ? 'on' : 'off';
}

document.getElementById('login').addEventListener('submit', async (e) => {
	e.preventDefault();
	const user = document.querySelector('#login input').value;
	if (user.trim() === '') {
		submitInfo.innerHTML = 'Please enter a value';
		return;
	}
	// V function call
	const resp = await window.login(user);
	submitInfo.innerHTML = resp;
});

async function fetchArticle() {
	if (!initialized) {
		content.innerHTML = 'Error: not connected to V backend.';
		return;
	}
	heading.innerHTML = 'Loading';
	content.innerHTML = `<span class="dot one">.</span>
					<span class="dot two">.</span>
					<span class="dot three">.</span>`;
	// V function call
	const news = await window.fetch_news();
	heading.innerHTML = news.title;
	content.innerHTML = news.body;
}

(async () => {
	// V function call
	settings = await window.get_settings();
	toggleState.innerHTML = settings.toggle ? 'on' : 'off';
	initialized = true;
})();
