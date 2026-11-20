'use strict';
'require view';

return view.extend({
	render: function() {
		var panel = new URL(window.location.origin);
		panel.protocol = 'http:';
		panel.port = '2023';

		return E('div', {}, [
			E('h2', {}, 'daed'),
			E('p', {}, '打开此设备上的 daed 管理面板。'),
			E('a', {
				'class': 'btn cbi-button cbi-button-action',
				'href': panel.href,
				'target': '_blank',
				'rel': 'noopener noreferrer'
			}, '打开 daed 面板')
		]);
	},

	handleSave: null,
	handleSaveApply: null,
	handleReset: null
});
