
## How to run

1. Clone repo
2. ```git submodule init```
3. ```git submodule update --remote --recursive```
   Please use V2 version of docker compose if possible
5. ```docker compose --profile [with selected services (see compose file)] up -d```
6. ```docker compose watch``` *for development only 

#### IF IT DOESN'T WORK DO THE FOLLOWING:

7. ```cd .\thesis-backend\```
8. Run commands:
- ```git submodule init```
- ```git submodule update --remote --recursive```

9. ```cd .\thesis-backend\thesis-sensors-py-service\```
10. Run commands:
- `python -m grpc_tools.protoc -I ./protos --python_out=. --grpc_python_out=. sensor.proto`

- `python -m grpc_tools.protoc -I ./protos --python_out=. --grpc_python_out=. user.proto`

- `python -m grpc_tools.protoc -I ./protos --python_out=. --grpc_python_out=. workout.proto`
9. ```cd .\thesis-backend\```
10. ```cd .\thesis-backend\```


> If it still won't work message [@MxPy](https://github.com/MxPy) or [@iraszewska](https://github.com/iraszewska)



C4 Architecture diagram is in Documentation folder
you can render it here: https://structurizr.com/dsl
