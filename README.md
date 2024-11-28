## How to run

1. Clone repo
2. `git submodule init`
3. `git submodule update --remote --recursive`
   Please use V2 version of docker compose if possible

~~5. `docker compose --profile [with selected services (see compose file)] up -d` 6. `docker compose watch` \*for development only~~

7. `cd .\thesis-backend\`
   At this point, just to make sure everything is up-to-date run commands:

- `git submodule init`
- `git submodule update --remote --recursive`

8. `cd .\thesis-sensors-py-service\`
9. `python -m venv venv`
10. `venv/Scripts/activate`
11. `pip install -r requirements.txt`
12. Run commands:

- `python -m grpc_tools.protoc -I ./protos --python_out=. --grpc_python_out=. sensor.proto`

- `python -m grpc_tools.protoc -I ./protos --python_out=. --grpc_python_out=. user.proto`

- `python -m grpc_tools.protoc -I ./protos --python_out=. --grpc_python_out=. workout.proto`

13. `cd ../..`
14. `docker compose up --build` to run base services

> If it still won't work message [@MxPy](https://github.com/MxPy) or [@iraszewska](https://github.com/iraszewska)

## Running only sensors-specific services
Use the `docker compose` command to bring up services associated with the `core` profile:

```docker compose --profile core up```

It's especially useful in terms of managing the [admin panel](https://github.com/iraszewska/thesis-frontend)

## Architecture diagram
C4 Architecture diagram is in Documentation folder
you can render it here: https://structurizr.com/dsl
