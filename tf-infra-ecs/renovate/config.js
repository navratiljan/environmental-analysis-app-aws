module.exports = {
    platform: 'azure',
    endpoint: 'https://dev.azure.com/Deloitte-CE-IT/',
    token: process.env.TOKEN,
    hostRules: [
        {
            "azureAutoApprove": true,
            "automerge": true
        },
    ],
    repositories: ['CE-CZ-CNS-CLOUD-REFERENCES/project-template-terraform-azure'], // list of repos that should be watched by renovate bot
};