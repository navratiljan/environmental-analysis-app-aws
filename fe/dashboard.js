document.addEventListener('DOMContentLoaded', function() {
    // Function to handle the dashboard URL retrieval
    function fetchDashboardURL() {
        const apiUrl = 'https://envstats.navaws.ceacpoc.cloud/environemental-data/dashboard-embedded-url';
        fetch(apiUrl, { method: 'GET', headers: { 'Accept': 'application/json' } })
         .then(response => response.json())
         .then(data => {
                const embedUrl = data.EmbedUrl;
                const button = document.getElementById('openDashboard');
                button.textContent = 'Open Dashboard'; // Optional: Update button text after fetching
                button.onclick = function() {
                    window.open(embedUrl, '_blank');
                };
            })
         .catch(error => console.error('Error fetching dashboard URL:', error));
    }

    // Call the function to start the process
    fetchDashboardURL();
});