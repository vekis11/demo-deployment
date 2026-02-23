(function () {
  const healthEl = document.getElementById('health-status');
  const timeEl = document.getElementById('health-time');

  function checkHealth() {
    fetch('/health')
      .then(function (res) { return res.json(); })
      .then(function (data) {
        healthEl.textContent = 'Healthy – ' + (data.version || '');
        healthEl.className = 'healthy';
        timeEl.textContent = 'Last check: ' + new Date().toLocaleTimeString();
      })
      .catch(function () {
        healthEl.textContent = 'Unable to reach server';
        healthEl.className = 'error';
        timeEl.textContent = '';
      });
  }

  checkHealth();
  setInterval(checkHealth, 10000);
})();
