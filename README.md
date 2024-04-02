# environmental-app-analysis-aws-fastapi-app
# Local startup
uvicorn app.main:app --reload

- import variables from .env

```bash
set -o allexport && source .env.development && set +o allexport
```
