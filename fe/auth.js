function login() {
    AWS.config.update({ region: "eu-central-1" });

    const payload = {
        AuthFlow: "USER_PASSWORD_AUTH",
        ClientId: "75i0fnhvj6v9id0eug4brnm3bv",
        AuthParameters: {
            USERNAME: document.getElementById('username').value,
            PASSWORD: document.getElementById('password').value
        }
    }

    var cognito = new AWS.CognitoIdentityServiceProvider();
    cognito.initiateAuth(payload, function (err, data) {
        if (err) {
            alert("Error: " + err);
        }
        else {
            alert("Success!");
            window.location.href = "./index.html";
        }
    })
}

