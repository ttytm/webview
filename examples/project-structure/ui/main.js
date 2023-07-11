let initialized = false;
const toggleState = document.querySelector('#toggle-state');
const submitInfo = document.querySelector('#submit-info');
const heading = document.querySelector('h3');
const content = document.querySelector('p');

/**
 * A JS function that will be called by our V program.
 * @param {Object} settings
 * @param {boolean} settings.toggle
 */
function init(settings) {
	initialized = true;
	toggleState.innerHTML = settings.toggle ? 'on' : 'off';
	console.log('Initiated JS!');
}

// V function calls
//
// We don't need to use the `window.` prefix. But it is a common pattern in webview examples.
// Here it is done for semantic reasons. It can help to make the origin more immediately visible
// when things get more crowded. Alternatively, just keeping the `snake_case` function names
// or adding a prefix `v_init_js`, might be sufficient to differentiate functions.
// Just use the style you prefer.

window.connect();

async function handleToggle() {
	toggleState.innerHTML = (await window.toggle_setting()) ? 'on' : 'off';
}

document.getElementById('login').addEventListener('submit', async (e) => {
	e.preventDefault();
	const user = document.querySelector('#login input').value;
	if (user.trim() === '') {
		submitInfo.innerHTML = 'Please enter a value';
		return;
	}
	// Call V funciton
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
	// Call V funciton
	const news = await window.fetch_news();
	heading.innerHTML = news.title;
	content.innerHTML = news.body;
}
