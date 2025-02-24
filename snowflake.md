# Snowpark Container Services Overview 
Feature — Generally Available

Available to accounts in AWS and Microsoft Azure commercial regions, with some exceptions. For more information, see Available regions and considerations.

About Snowpark Container Services
Snowpark Container Services is a fully managed container offering designed to facilitate the deployment, management, and scaling of containerized applications within the Snowflake ecosystem. This service enables users to run containerized workloads directly within Snowflake, ensuring that data doesn’t need to be moved out of the Snowflake environment for processing. Unlike traditional container orchestration platforms like Docker or Kubernetes, Snowpark Container Services offers an OCI runtime execution environment specifically optimized for Snowflake. This integration allows for the seamless execution of OCI images, leveraging Snowflake’s robust data platform.

As a fully managed service, Snowpark Container Services streamlines operational tasks. It handles the intricacies of container management, including security and configuration, in line with best practices. This ensures that users can focus on developing and deploying their applications without the overhead of managing the underlying infrastructure.

Snowpark Container Services is fully integrated with Snowflake. For example, your application can easily perform these tasks:

Connect to Snowflake and run SQL in a Snowflake virtual warehouse.

Access data files in a Snowflake stage.

Process data sent from SQL queries.

Snowpark Container Services is also integrated with third-party tools. It lets you use third-party clients (such as Docker) to easily upload your application images to Snowflake. Seamless integration makes it easier for teams to focus on building data applications.

You can run and scale your application container workloads across Snowflake regions and cloud platforms without the complexity of managing a control plane or worker nodes, and you have quick and easy access to your Snowflake data.

Snowpark Container Services unlocks a wide array of new functionality, including these features:

Create long-running services.

Use GPUs to boost the speed and processing capabilities of a system.

Write your application code in any language (for example, C++).

Use any libraries with your application.

All of this comes with Snowflake platform benefits, most notably ease-of-use, security, and governance features. And you now have a scalable, flexible compute layer next to the powerful Snowflake data layer without needing to move data off the platform.

How does it work?
To run containerized applications in Snowpark Container Services, in addition to working with the basic Snowflake objects, such as databases and warehouses, you work with these objects: image repository, compute pool, and service.

Snowflake offers image registry, an OCIv2 compliant service, for storing your images. This enables OCI clients (such as Docker CLI and SnowSQL) to access an image registry in your Snowflake account. Using these clients, you can upload your application images to a repository (a storage unit) in your Snowflake account. For more information, see Working with an image registry and repository.

After you upload your application image to a repository, you can run your application by creating a long-running service or executing a job service.

A service is long-running and, as with a web service, you explicitly stop it when it is no longer needed. If a service container exits (for whatever reason), Snowflake restarts that container. To create a service, such as a full stack web application, use the CREATE SERVICE command.

A job service has a finite lifespan, similar to a stored procedure. When all containers exit, the job service is done. Snowflake does not restart any job service containers. To start a job service, such as training a machine learning model with GPUs, use the EXECUTE JOB SERVICE command.

For more information, see Working with services.

Your services (including job services) run in a compute pool, which is a collection of one or more virtual machine (VM) nodes. You first create a compute pool using the CREATE COMPUTE POOL command, and then specify the compute pool when you create a service or a job service. The required information to create a compute pool includes the machine type, the minimum number of nodes to launch the compute pool with, and the maximum number of nodes the compute pool can scale to. Some of the supported machine types provide GPU. For more information, see Working with compute pools.

You can use service functions to communicate with a service from a SQL query. You can configure public endpoints to allow access with the service from outside Snowflake, with Snowflake-managed access control. Snowpark Container Services also supports service-to-service communications. For more information, see Using a service.

Note

The Snowpark Container Services documentation primarily uses SQL commands and functions in explanations of concepts and in examples. Snowflake also provides other interfaces, including Python APIs, REST APIs, and the Snowflake CLI command-line tool for most operations.

Available regions and considerations
Snowpark Container Services is in all regions except the following:

Snowpark Container Services is not available for Google Cloud Platform (GCP).

Snowpark Container Services is not available for Government regions in AWS or Azure.

Snowpark Container Services is not available for trial accounts.

What’s next?
If you’re new to Snowpark Container Services, we suggest that you first explore the tutorials and then continue with other topics to learn more and create your own containerized applications. The following topics provide more information:

Tutorials: These introductory tutorials provide step-by-step instructions for you to explore Snowpark Container Services. After initial exploration, you can continue with advanced tutorials.

Service specification reference: This reference explains the YAML syntax to create a service specification.

Working with services and job services: These topics provide details about the Snowpark Container Services components that you use in developing services and job services:

Working with an image registry and repository

Working with compute pools

Working with services

Troubleshooting

Reference: Snowpark Container Services provides the following SQL commands and system functions:

For SQL commands, see Snowpark Container Services commands and CREATE FUNCTION (Snowpark Container Services)

For SQL functions: SYSTEM$GET_SERVICE_LOGS.

The Snowpark Container Services specification is in YAML (https://yaml.org/spec/). It gives Snowflake the necessary information to configure and run your service. You provide the specification at the time of creating a service.

The general syntax is:

spec:
  containers:                           # container list
  - name: <name>
    image: <image-name>
    command:                            # optional list of strings
      - <cmd>
      - <arg1>
    args:                               # optional list of strings
      - <arg2>
      - <arg3>
      - ...
    env:                                # optional
        <key>: <value>
        <key>: <value>
        ...
    readinessProbe:                     # optional
        port: <TCP port-num>
        path: <http-path>
    volumeMounts:                       # optional list
      - name: <volume-name>
        mountPath: <mount-path>
      - name: <volume-name>
        ...
    resources:                          # optional
        requests:
          memory: <amount-of-memory>
          nvidia.com/gpu: <count>
          cpu: <cpu-units>
        limits:
          memory: <amount-of-memory>
          nvidia.com/gpu: <count>
          cpu: <cpu-units>
    secrets:                                # optional list
      - snowflakeSecret:
          objectName: <object-name>         # specify this or objectReference
          objectReference: <reference-name> # specify this or objectName
        directoryPath: <path>               # specify this or envVarName
        envVarName: <name>                  # specify this or directoryPath
        secretKeyRef: username | password | secret_string # specify only with envVarName
  endpoints:                             # optional endpoint list
    - name: <name>
      port: <TCP port-num>                     # specify this or portRange
      portRange: <TCP port-num>-<TCP port-num> # specify this or port
      public: <true / false>
      protocol : < TCP / HTTP / HTTPS >
    - name: <name>
      ...
  volumes:                               # optional volume list
    - name: <name>
      source: local | @<stagename> | memory | block
      size: <bytes-of-storage>           # specify if memory or block is the volume source
      blockConfig:                       # optional
        initialContents:
          fromSnapshot: <snapshot-name>
        iops: <number-of-operations>
        throughput: <MiB per second>
      uid: <UID-value>                   # optional, only for stage volumes
      gid: <GID-value>                   # optional, only for stage volumes
    - name: <name>
      source: local | @<stagename> | memory | block
      size: <bytes-of-storage>           # specify if memory or block is the volume source
      ...
  logExporters:
    eventTableConfig:
      logLevel: <INFO | ERROR | NONE>
  platformMonitor:                      # optional, platform metrics to log to the event table
    metricConfig:
      groups:
      - <group-1>
      - <group-2>
      ...
capabilities:
  securityContext:
    executeAsCaller: <true / false>     # optional, indicates whether application intends to use caller’s rights
serviceRoles:                   # Optional list of service roles
- name: <service-role-name>
  endpoints:
  - <endpoint_name1>
  - <endpoint_name2>
  - ...
- ...
Note that the spec and serviceRoles are the top-level fields in the specification.

spec: Use this field to provide specification details. It includes these top-level fields:

spec.containers (required): A list of one or more application containers. Your containerized application must have at least one container.

spec.endpoints (optional): A list of endpoints that the service exposes. You might choose to make an endpoint public, allowing network ingress access to the service.

spec.volumes (optional): A list of storage volumes for the containers to use.

spec.logExporters (optional): This field manages the level of container logs exported to the event table in your account.

serviceRoles: Use this field to define one or more service roles. The service role is the mechanism you use to manage privileges to endpoints the service exposes.

General guidelines
The following format guidelines apply for the name fields (container, endpoint, and volume names):

Can be up to 63 characters long.

Can contain a sequence of lowercase alphanumeric or - characters.

Must start with an alphabetic character.

Must end with an alphanumeric character.

Customers should ensure that no personal data, sensitive data, export-controlled data, or other regulated data is entered as metadata in the specification file. For more information, see Metadata Fields in Snowflake.

The following sections explain each of the top-level spec fields.

spec.containers field (required)
Use the spec.containers field to describe each of the OCI containers in your application.

Note the following:

When you create a service, Snowflake runs these containers on a single node in the specified compute pool, sharing the same network interface.

You might choose to run multiple service instances to load-balance incoming requests. Snowflake might choose to run these service instances on the same node or different nodes in the specified compute pool. All containers for a given instance always run on one node.

Currently, Snowpark Container Services requires linux/amd64 platform images.

The following sections explain the types of containers fields.

containers.name and containers.image fields
For each container, only name and image are required fields.

name is the image name. This name can be used to identify a specific container for the purposes of observability (for example, logs, metrics).

image is the name of the image you uploaded to a Snowflake image repository in your Snowflake account.

For example:

spec:
  containers:
    - name: echo
      image: /tutorial_db/data_schema/tutorial_repository/echo_service:dev
containers.command and containers.args fields
Use these optional fields to control what executable is started in your container and the arguments that are passed to that executable. You can configure defaults for these at the time of creating the image, typically in a Dockerfile. Using these service specification fields let you to change these defaults (and thus change the container behavior) without having to rebuild your container image:

containers.command overrides the Dockerfile ENTRYPOINT. This allows you to run a different executable in the container.

containers.args overrides the Dockerfile CMD. This allows you to provide different arguments to the command (the executable).

Example

Your Dockerfile includes the following code:

ENTRYPOINT ["python3", "main.py"]
CMD ["Bob"]
These Dockerfile entries execute the python3 command and pass two arguments: main.py and Bob. You can override these values in the specification file as follows:

To override the ENTRYPOINT, add the containers.command field in the specification file:

spec:
  containers:
  - name: echo
    image: <image_name>
    command:
    - python3.9
    - main.py
To override the argument “Bob”, add the containers.args field in the specification file:

spec:
  containers:
  - name: echo
    image: <image_name>
    args:
      - Alice
containers.env field
Use the containers.env field to define container environment variables. All processes in the container have access to these environment variables:

spec:
  containers:
  - name: <name>
    image: <image_name>
    env:
      ENV_VARIABLE_1: <value1>
      ENV_VARIABLE_2: <value2>
      …
      …
Example

In Tutorial 1, the application code (echo_service.py) reads the environment variables as shown:

CHARACTER_NAME = os.getenv('CHARACTER_NAME', 'I')
SERVER_PORT = os.getenv('SERVER_PORT', 8080)
Note that the example passes default values for the variables to the getenv function. If the environment variables are not defined, these defaults are used.

CHARACTER_NAME: When the Echo service receives an HTTP POST request with a string (for example, “Hello”), the service returns “I said Hello”. You can overwrite this default value in the specification file. For example, set the value to “Bob”; the Echo service returns a “Bob said Hello” response.

SERVER_PORT: In this default configuration, the Echo service listens on port 8080. You can override the default value and specify another port.

The following service specification overrides both of these environment variable values:

spec:
  containers:
  - name: echo
    image: <image_name>
    env:
      CHARACTER_NAME: Bob
      SERVER_PORT: 8085
  endpoints:
  - name: echo-endpoint
    port: 8085
Note that, because you changed the port number your service listens on, the specification must also update the endpoint (endpoints.port field value) as shown.

containers.readinessProbe field
Use the containers.readinessProbe field to identify a readiness probe in your application. Snowflake calls this probe to determine when your application is ready to serve requests.

Snowflake makes an HTTP GET request to the specified readiness probe, at the specified port and path, and looks for your service to return an HTTP 200 OK status to ensure that only healthy containers serve traffic.

Use the following fields to provide the required information:

port: The network port on which the service is listening for the readiness probe requests. You need not declare this port as an endpoint.

path: Snowflake makes HTTP GET requests to the service with this path.

Example

In Tutorial 1, the application code (echo_python.py) implements the following readiness probe:

@app.get("/healthcheck")
def readiness_probe():
Accordingly, the specification file includes the containers.readinessProbe field:

spec:
  containers:
  - name: echo
    image: <image_name>
    env:
      SERVER_PORT: 8088
      CHARACTER_NAME: Bob
    readinessProbe:
      port: 8088
      path: /healthcheck
  endpoints:
  - name: echo-endpoint
    port: 8088
The port specified by the readiness probe does not have to be a configured endpoint. Your service could listen on a different port solely for the purpose of the readiness probe.

containers.volumeMounts field
Because the spec.volumes and spec.containers.volumeMounts fields work together, they are explained together in one section. For more information, see spec.volumes field (optional).

containers.resources field
A compute pool defines a set of available resources (CPU, memory, and storage) and Snowflake determines where in the compute pool to run your services.

It is recommended that you explicitly indicate resource requirements for the specific container and set appropriate limits in the specification. Note that the resources you specify are constrained by the instance family of the nodes in your compute pool. For more information, see CREATE COMPUTE POOL.

Use containers.resources field to specify explicit resource requirements for the specific application container:

containers.resources.requests: The requests you specify should be the average resource usage you anticipate by your service. Snowflake uses this information to determine placement of the service instance in the compute pool. Snowflake ensures that the sum of the resource requests placed on a given node fits within the available resources on the node.

containers.resources.limits: The limits you specify direct Snowflake to not allocate resources more than the specified limits. Thus, you can prevent cost overruns.

You can specify requests and limits for the following resources:

memory: This is the memory required for your application container. You can use either decimal or binary units to express the values. For example, 2G represents a request for 2,000,000,000 bytes and 2Gi represents a requests for 2 x 1024 x 1024 x 1024 bytes.

When specifying memory, a unit is required. For example, 100M or 5Gi. The supported units are: M, Mi, G, Gi.

cpu: This refers to virtual core (vCPU) units. For example, 1 CPU unit is equivalent to 1 vCPU. Fractional requests are allowed, such as 0.5, which can also be expressed as 500m.

nvidia.com/gpu: If GPUs are required, they must be requested, and there must also be a limit specified for the same quantity. If your container does not specify requests and limits for GPU capacity, it cannot access any GPUs. The number of GPUs you can request is limited by the maximum GPUs supported by the INSTANCE_TYPE you choose when creating a compute pool.

resource.requests and resource.limits are relative to the node capacity (vCPU and memory) of the instance family of the associated compute pool.

If a resource request (cpu, memory, or both) is not provided, Snowflake derives one for you:

For cpu, the derived value is either 0.5 or the cpu limit you provided, whichever is smaller.

For memory, the derived value is either 0.5 GiB or the memory limit you provided, whichever is smaller.

If a resource limit (cpu, memory, or both) is not provided, Snowflake defaults the limits to the node capacity for the instance family of the associated compute pool.

If you do provide resource.limits and they exceed the node capacity, Snowflake will cap the limit to the node capacity.

Snowflake evaluates these resource requirements independently for cpu and memory.

Note that if it’s theoretically impossible for Snowflake to schedule the service on the given compute pool, CREATE SERVICE will fail. Theoretically impossible assumes the compute pool has the maximum number of allowed nodes and there are no other services running on the compute pool. That is, there is no way Snowflake could allocate the requested resources within the compute pool limits. If it’s theoretically possible, but required resources are in use, then CREATE SERVICE will succeed. Some service instances will report status indicating that the service cannot be scheduled due to insufficient resources until resources become available.

Example 1

In the following specification, the containers.resources field describes the resource requirements for the container:

spec:
  containers:
  - name: resource-test-gpu
    image: ...
    resources:
      requests:
        memory: 2G
        cpu: 0.5
        nvidia.com/gpu: 1
      limits:
        memory: 4G
        nvidia.com/gpu: 1
In this example, Snowflake is asked to allocate at least 2 GB of memory, one GPU, and a half CPU core for the container. At the same time, the container is not allowed to use more than 4 GB of memory and one GPU.

Example 2

Suppose:

You create a compute pool of two nodes; each node has 27 GB of memory and one GPU:

CREATE COMPUTE POOL tutorial_compute_pool
  MIN_NODES = 2
  MAX_NODES = 2
  INSTANCE_FAMILY = gpu_nv_s
You create a service that asks Snowflake to run two instances of the service:

CREATE SERVICE echo_service
  MIN_INSTANCES=2
  MAX_INSTANCES=2
  IN COMPUTE POOL tutorial_compute_pool
  FROM @<stage_path>
  SPEC=<spec-file-stage-path>;
Both MIN_INSTANCES and MAX_INSTANCES are set to 2. Therefore, Snowflake will run two instances of the service.

Now, consider these scenarios:

If your service does not explicitly include resource requirements in your application specification, Snowflake decides whether to run these instances on the same node or different nodes in the compute pool.

You do include resource requirements in the service specification and request 10 GB of memory for the container:

- name: resource-test
  image: ...
  resources:
    requests:
      memory: 15G
Your compute pool node has 27 GB of memory, and Snowflake cannot run two containers on the same node. Snowflake will run the two service instances on separate nodes in the compute pool.

You include resource requirements in the service specification and request 1 GB of memory and one GPU for the container:

spec:
  containers:
  - name: resource-test-gpu
    image: ...
    resources:
      requests:
        memory: 2G
        nvidia.com/gpu: 1
      limits:
        nvidia.com/gpu: 1
You are requesting one GPU per container, and each node has only one GPU. In this case, although memory is not an issue, Snowflake cannot schedule both service instances on one node. This requirement forces Snowflake to run the two service instances on two separate compute pool nodes.

containers.secrets field
secrets:                                # optional list
  - snowflakeSecret:
      objectName: <object-name>         # specify this or objectReference
      objectReference: <reference-name> # specify this or objectName
    directoryPath: <path>               # specify this or envVarName
    envVarName: <name>                  # specify this or directoryPath
    secretKeyRef: username | password | secret_string # specify only with envVarName
  - snowflakeSecret: <object-name>      # equivalent to snowflakeSecret.objectName
    ...
Use the containers.secrets field in your service specification to provide Snowflake-managed credentials to your application containers. Start by storing the credentials in Snowflake secret objects. Then, in the service specification, reference the secret object and specify where to place the credentials inside the container.

The following is a summary of how to use the containers.secrets fields:

Specify Snowflake secret: Use the snowflakeSecret field to specify either a Snowflake secret object name or object reference. Object references are applicable when using Snowpark Container Services to create a Native App (an app with containers).

Use secretKeyRef to provide the name of the key in the Snowflake secret.

Specify the secret placement in the application container: Use the envVarName field to pass the secret as environment variables or directoryPath to write the secrets to local container files.

For more information, see Passing credentials to a container using Snowflake secrets.

Note that, the role that is creating the service (owner role) will need the READ privilege on the secrets referenced.

spec.endpoints field (optional)
Use the spec.endpoints field to specify a list of TCP network ports that your application exposes. A service might expose zero to many endpoints. Use the following fields to describe an endpoint:

name: Unique name of the endpoint. The name is used to identify the endpoint in service function and service role specification.

port: The network port on which your service is listening. You must specify this field or the portRange field.

portRange: The network port range on which your application is listening. You must specify this field or the port field.

Ports defined in portRange can only be accessed by directly calling service instance IP addresses. To get service instance IP addresses, use the instances. prefixed DNS name.

instances.<Snowflake_assigned_service_DNS_name>
For more information, see Service-to-service communications.

Note that you can only specify the portRange field if the protocol field is set to TCP and the public field is false.

public: If you want this endpoint to be accessible from the internet, set this field to true. Public endpoints are not supported with the TCP protocol.

protocol: The protocol that the endpoint supports. The supported values are TCP, HTTP, and HTTPS. By default, the protocol is HTTP. When specifying the protocol, the following apply:

When this endpoint is public or the target of a service function (see Using a service), the protocol must be HTTP or HTTPS.

The job services require all specified endpoints to use the TCP protocol; HTTP/HTTPS protocols are not supported.

Note

Snowflake performs authentication and authorization checks for public access that allow only Snowflake users that have permission to use the service. Public access to an endpoint requires Snowflake authentication. The authenticated user must also have authorization to this service endpoint (user has usage permission of a role which has access to the endpoint).

Example

The following is the application specification used in Tutorial 1:

spec:
  container:
  - name: echo
    image: <image-name>
    env:
      SERVER_PORT: 8000
      CHARACTER_NAME: Bob
    readinessProbe:
      port: 8000
      path: /healthcheck
  endpoint:
  - name: echoendpoint
    port: 8000
    public: true
This application container exposes one endpoint. It also includes the optional public field to enable access to the endpoint from outside of Snowflake (internet access). By default, public is false.

spec.volumes field (optional)
This section explains both spec.volumes and spec.containers.volumeMounts specification fields because they’re closely related.

spec.volumes defines a shared file system. These volumes can be made available in your containers.

spec.containers.volumeMount defines where a volume appears in specific containers.

Note that, the volumes field is specified at the spec level, but since multiple containers can share the same volume, volumeMounts becomes a spec.containers-level field.

Use these fields to describe both the volumes and volume mounts.

spec.volumes: There can be zero or more volumes. Use the following fields to describe a volume:

Required fields for all volume types:

name: Unique name of the volume. It is referred to by spec.containers.volumeMounts.name.

source: This can be local, memory, block, or "@<stagename>". The next section explains these volume types.

size (required only for the memory and block volume types): For memory and block volumes, this is the size of the volume in bytes. For block storage, the value must always be an integer, specified using the Gi unit suffix. For example, 5Gi means 5*1024*1024*1024 bytes.

For the block type volume, you can specify the following optional fields. For more information, see Specifying block storage in service specification.

blockConfig.initialContents.fromSnapshot: Specify a previously taken snapshot of another volume to initialize the block volume. The snapshot must be in the CREATED state before it can be used to create a volume, or else the service creation will fail. Use the DESCRIBE SNAPSHOT command to get the snapshot’s status.

blockConfig.iops: Specify the number of supported peak input/output operations per second. The supported range 3000-16000 in AWS and 3000-80000 in Azure, with a default of 3000. Note that the data size per operation is capped at 256 KiB for block volumes.

blockConfig.throughput: Specify the peak throughput, in MiB/second, to provision for the volume. The supported range is 125-1000 in AWS and 125-1200 in Azure, with a default of 125.

spec.containers.volumeMounts: Each container can have zero or more volume mounts. containers.volumeMounts is also a list. That is, each container can have multiple volume mounts. Use the following fields to describe a volume mount:

name: The name of the volume to mount. A single container can reference the same volume multiple times.

mountPath: The file path to where the volume for the container should be mounted.

About the supported volume types
Snowflake supports these volume types for application containers to use: local, memory, block, and Snowflake stage.

Local volume: Containers in a service instance can use a local disk to share files. For example, if your application has two containers—an application container and a log analyzer— the application can write logs to the local volume, and the log analyzer can read the logs.

Note that, if you are running multiple instances of a service, only containers belonging to a service instance can share volumes. Containers that belong to different service instances do not share volumes.

Memory: You can use a RAM-backed file system for container use.

Block: Containers can also use block storage volumes. For more information, see Using block storage volumes with services.

Snowflake stage: You can also give containers convenient access to files on a Snowflake stage in your account. For more information, see Using Snowflake stage volumes with services.

Example

Your machine learning application includes the following two containers:

An app container for the main application

A logger-agent container that collects logs and uploads them to Amazon S3

These containers use the following two volumes:

local volume: This application writes logs that the log agent reads.

Snowflake stage, @model_stage: The main application reads files from this stage.

In the following example specification, the app container mounts both the logs and models volumes, and the logging-agent container mounts only the logs volume:

spec:
  containers:
  - name: app
    image: <image1-name>
    volumeMounts:
    - name: logs
      mountPath: /opt/app/logs
    - name: models
      mountPath: /opt/models
  - name: logging-agent
    image: <image2-name>
    volumeMounts:
    - name: logs
      mountPath: /opt/logs
  volumes:
  - name: logs
    source: local
  - name: models
    source: "@model_stage"
If multiple instances of the service are running, the logging-agent and the app containers within a service instance share the logs volume. The logs volume is not shared across service instances.

If, in addition to these volumes, your app container also uses a 2-GB memory volume, revise the specification to include the volume in the volumes list and also add another volume mount in the app containers volumeMounts list:

spec:
  containers:
  - name: app
    image: <image1-name>
    volumeMounts:
    - name: logs
      mountPath: /opt/app/logs
    - name: models
      mountPath: /opt/models
    - name: my-mem-volume
      mountPath: /dev/shm
  - name: logging-agent
    image: <image2-name>
    volumeMounts:
    - name: logs
      mountPath: /opt/logs
  volumes:
  - name: logs
    source: local
  - name: models
    source: "@model_stage"
  - name: "my-mem-volume"
    source: memory
    size: 2G
Note that when you specify memory as the volume source, you must also specify the volumes.size field to indicate the memory size. For information about the memory size units you can specify, see About units.

About file permissions on mounted volumes
A container that mounts a Snowflake stage or a block storage volume typically runs as a root user. However, sometimes your container might run as a non-root user. For example:

If your application uses a third-party library, the library uses a non-root user to run application code inside the container.

For other reasons, such as security, you might run your application as a non-root user inside the container.

To avoid potential errors related to file user permissions, it’s important to set the UID (User ID) and GID (Group ID) of the container as part of the specification. This is particularly relevant for containers that use a specific user and group for launching or running the application within the container. By setting the appropriate UID and GID, you can use a container running as a non-root user. For example:

spec:
  ...

  volumes:
  - name: stagemount
    source: "@test"
    uid: <UID-value>
    gid: <GID-value>
Snowflake uses this information to mount the stage with appropriate permissions.

To obtain the UID and GID of the container, do the following:

Run the container locally using docker run.

Look up the container ID using the docker container list command. Partial sample output:

CONTAINER ID   IMAGE                       COMMAND
—----------------------------------------------------------
a6a1f1fe204d  tutorial-image         "/usr/local/bin/entr…"
Run the docker id command inside the container to get the UID and GID:

docker exec -it <container-id> id
Sample output:

uid=0(root) gid=0(root) groups=0(root)
spec.logExporters field (optional)
Snowflake collects your applications output to standard output or standard error. For more information, see Accessing local container logs. Use spec.logExporters to configure which of these outputs Snowflake exports to your event table.

logExporters:
  eventTableConfig:
    logLevel: < INFO | ERROR | NONE >
The supported logLevel values are:

INFO (default): Export all the user logs.

ERROR: Export only the error logs. Snowflake exports only the logs from stderr stream.

NONE: Do not export logs to the event table.

spec.platformMonitor field (optional)
Individual services publish metrics. These Snowflake-provided metrics are also referred to as the platform metrics. You add the spec.platformMonitor field in the specification to direct Snowflake to send metrics from the service to the event table configured for your account. The target use case for this is to observe resource utilization of a specific service.

platformMonitor:
  metricConfig:
    groups:
    - <group_1>
    - <group_2>
    ...
group_N refers to a predefined metrics groups that you are interested in. While the service is running, Snowflake logs metrics from specified groups to the event table. You can then query the metrics from the event table. For more information, see Monitoring Services.

About units
A service specification takes numeric values in several places. A variety of units are supported to express these values. For large and small values, you can use binary and decimal units as shown. In the following list, “#” represents an integer value.

Binary units:

numberKi means number*1024. For example, 4Ki is equivalent to 4096.

numberMi means number*1024*1024.

numberGi means number*1024*1024*1024.

Decimal units:

numberk means number*1000. For example, 4k is equivalent to 4000.

numberM means number*1000*1000.

numberG mean number*1000*1000*1000.

Fractional units:

numberm means number*0.001. For example, cpu: 500m is equivalent to cpu: 0.5.

capabilities field (optional)
In the capabilities top-level field in the specification, use the securityContext.executeAsCaller field to indicate the application intends to use caller’s rights.

capabilities:
  securityContext:
    executeAsCaller: <true / false>    # optional, indicates whether application intends to use caller’s rights
By default, executeAsCaller is false.

serviceRoles field (optional)
Use the serviceRoles top-level field in the specification to define one or more service roles. For each service role, provide a name and a list of one or more endpoints (defined in the spec.endpoints) you want the service role to grant USAGE privilege on.

serviceRoles:                   # Optional list of service roles
- name: <name>
  endpoints:
  - <endpoint-name>
  - <endpoint-name>
  - ...
- ...
Note the following:

Both the name and endpoints are required.

The service role name must adhere to the following format:

Must contain alphanumeric or _ characters.

Must start with an alphabetic character.

Must end with an alphanumeric character.

author: Charles Yorek
id: build-a-native-app-with-spcs
summary: This is a sample Snowflake Guide
categories: Getting-Started
environments: web
status: Published 
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Data Applications, Native Apps, Snowpark Container Services, SPCS 

# Build a Snowflake Native App with Snowpark Container Services
<!-- ------------------------ -->
## Overview
Duration: 5

The Snowflake Native App Framework is a powerful way for application providers to build, deploy and market applications via the Snowflake Marketplace.  In this example you will learn how to incorporate Snowpark Container Services into a Snowflake Native App allowing you to deploy a variety of new capabilities to a consumers Snowflake account.  


### Prerequisites
- A Snowflake account with ACCOUNTADMIN access
- Familiarity with Snowflake Snowsight Interface
- Basic Knowledge of Docker and Container Concepts
- Ability to install and run software on your computer
- Basic experience using git

> aside positive
>
> Snowpark Container Services is currently in a Public Preview and is available across a [range of Snowflake AWS accounts](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview#label-snowpark-containers-overview-available-regions). For this lab ensure that you have an account in one of the supported regions.


### What You’ll Learn 
- How to create an app using the Snowflake Native App framework
- How to build and push container images to a Snowflake account
- How to integrate those images into a Snowflake Native App and allow consumers to create Services
- How to test the Snowflake Native App Provider and Consumer experience within a single Snowflake account


### What You’ll Need 
- A [GitHub](https://github.com/) Account 
- [VSCode](https://code.visualstudio.com/download) Installed
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) Installed


### What You’ll Build 
In this quickstart we'll create a Snowflake Native App that uses Snowpark Container Services to deploy the following into a Snowflake account: 
- Vue-based JavaScript frontend
- Flask-based Python middle tier 
- nginx as a router

Once deployed, the application can be access via a [Service Endpoint](https://docs.snowflake.com/en/sql-reference/sql/show-endpoints) which then queries the 
TPC-H 100 data set and returns the top sales clerks. The frontend provides date pickers to restrict the range of the sales data and a slider to determine how many top clerks to display. The data is presented in a table sorted by highest seller to lowest.

<!-- ------------------------ -->
## Snowflake Application Code
Duration: 5
### Overview
In preparation for building our Snowflake Native App we need to download the code artifacts for the Native App along with the files to create our Container images from Github.  

### Step 2.1 - Clone or Download Github Repo
The code for the Native App and Container Images are on Github. Start by cloning or downloading the repository into a separate folder. 
```shell
git clone https://github.com/Snowflake-Labs/sfguide-build-a-native-app-with-spcs
```

<!-- ------------------------ -->
## Native App Provider Setup 
Duration: 5
### Overview
To simulate a Native App provider experience we will create a role called 'naspcs_role' and grant it the necessary privileges required to create an [Application Package](https://docs.snowflake.com/en/developer-guide/native-apps/creating-app-package) as well as create a database that will store both our app code and Snowpark Container Service Images.  

### Step 3.1 - Create NASPCS role and Grant Privileges

```sql
use role accountadmin;
create role if not exists naspcs_role;
grant role naspcs_role to role accountadmin;
grant create integration on account to role naspcs_role;
grant create compute pool on account to role naspcs_role;
grant create warehouse on account to role naspcs_role;
grant create database on account to role naspcs_role;
grant create application package on account to role naspcs_role;
grant create application on account to role naspcs_role with grant option;
grant bind service endpoint on account to role naspcs_role;
```

### Step 3.2 - Create SCPS_APP Database to Store Application Files and Container Images
```sql
use role naspcs_role;
create database if not exists spcs_app;
create schema if not exists spcs_app.napp;
create stage if not exists spcs_app.napp.app_stage;
create image repository if not exists spcs_app.napp.img_repo;
create warehouse if not exists wh_nap with warehouse_size='xsmall';
```

<!-- ------------------------ -->
## Consumer Privilege Setup 
Duration: 5
### Overview
To simulate the app consumer experience we will create a role called 'nac' and grant it the necessary privileges required to create Applications as well as set up a database to house the data we'll be querying with our Snowflake Native App.  

### Step 4.1 - Create NAC role and Grant Privileges
```sql
use role accountadmin;
create role if not exists nac;
grant role nac to role accountadmin;
create warehouse if not exists wh_nac with warehouse_size='xsmall';
grant usage on warehouse wh_nac to role nac with grant option;
grant imported privileges on database snowflake_sample_data to role nac;
grant create database on account to role nac;
grant bind service endpoint on account to role nac with grant option;
grant create compute pool on account to role nac;
grant create application on account to role nac;
```

### Step 4.2 - Create Consumer Test Data Database
```sql
use role nac;
create database if not exists nac_test;
create schema if not exists nac_test.data;
use schema nac_test.data;
create view if not exists orders as select * from snowflake_sample_data.tpch_sf10.orders;
```

<!-- ------------------------ -->
## Build and Upload Container Images
Duration: 10
### Overview
Now that we have a place in our Snowflake account to house our application code and images we need to build the images and push them to our Image Repository.  We'll then upload our app files that detail how to install, setup and configure the Snowflake Native App.  

### Step 5.1 - Get Image Repository URL 
The code for this Quickstart has shipped with a shell script called 'configuration.sh' that you will use to tell our build process where to upload our Images.  The first step is to find our Image Repository URL which can be accomplished by running the following queries in your Snowflake account. 

```sql
use role naspcs_role;
show image repositories in schema spcs_app.napp;
```


### Step 5.2 - Build and Push Images
There are two options to Build and Push Images to your Snowflake account.  If you have the ability to run a Makefile you can use Step 5.2.1, otherwise you can use Step 5.2.2 to run the individual Docker commands required to build and push each Image. 

#### Step 5.2.1 - Makefile Apprach 
Copy the 'repository_url' value after you run the above commands.  After this switch to Terminal/Command Prompt and navigate to where you cloned or downloaded and unzipped the Github Repository in step 2.2.  When you are at the folder run the following command: 
```shell
./configure.sh
```
You will be prompted to paste the 'repository_url' into the command prompt and press enter to complete this configuration step.  

Ensure that Docker is running and in a Terminal/Command Prompt run the following command in the root of the Github repo you cloned or downloaded. 
```shell
make all
```
This should begin the process of running the required Docker BUILD and PUSH commands to upload the images to your Snowflake account.  

#### Step 5.2.2 - Individual Docker Commands
If the Makefile approach doesn't work you can run the following commands to build and push each image.  Make sure Docker is running and execute the following commands using a Terminal/Command prompt starting at the root of the Github repo you cloned or downloaded. In each step replace the **<SNOWFLAKE_REPO>** value with the 'repository_url' value you acquired in Step 5.1. 

```shell 
# login to Image Repository
    docker login <SNOWFLAKE_REPO>

# Build and Push backend
    cd backend
    docker build --platform linux/amd64 -t eap_backend .
    cd ..
    docker tag eap_backend <SNOWFLAKE_REPO>/eap_backend
    docker push <SNOWFLAKE_REPO>/eap_backend

# Build and Push frontend 
    cd frontend  
    docker build --platform linux/amd64 -t eap_frontend . 
    cd ..
    docker tag eap_frontend <SNOWFLAKE_REPO>/eap_frontend
    docker push <SNOWFLAKE_REPO>/eap_frontend

# Build and Push router
    cd router 
    docker build --platform linux/amd64 -t eap_router . 
    cd ..
    docker tag eap_router <SNOWFLAKE_REPO>/eap_router
    docker push <SNOWFLAKE_REPO>/eap_router
```

### Step 5.3 - Upload Native App Code
After the Image upload process completes the code we'll use to build our App package needs to be uploaded to the **SPCS_APP.NAPP.APP_STAGE** stage.  This can be accomplished by navigating to this stage using Snowsight - click on the 'Database' icon on the left side navigation bar and then on the **SPCS_APP database > NAPP schema > APP_STAGE stage**.  You will need to do the following: 
1. Click on 'Select Warehouse' and choose 'WH_NAP' for the Warehouse 
2. Click on the '+ Files' button in the top right corner 
3. Browse to the location where you cloned or downloaded the Github repo and into the '/app/src' folder
4. Select all 4 files (setup.sql, fullstack.yaml, manifest.yml, readme.md) 
5. Click the 'Upload' button

When this is done succesfully your SPCS_APP.NAPP.APP_STAGE should look like the following in Snowsight:

![APP_STAGE](assets/app_stage.png)

<!-- ------------------------ -->
## Create Application Package
Duration: 10 
### Overview
With all of our Snowflake Native App assets uploaded to our Snowflake account we can now create our Application Package using our Provider role.  Since we're doing this in a single Snowflake account we will also grant the Consumer role privileges to install it. 

### Step 6.1 - Create Application Package and Grant Consumer Role Privileges
```sql
use role naspcs_role;
create application package spcs_app_pkg;
alter application package spcs_app_pkg add version v1 using @spcs_app.napp.app_stage;
grant install, develop on application package spcs_app_pkg to role nac;
```

<!-- ------------------------ -->
## Install & Run Application 
Duration: 10 
### Overview
We can now use the Consumer role to install our Snowflake Native App - but to get it fully deployed we will also need to create a Compute Pool for our Snowpark Containers to run on as well as start the Service.  

### Step 7.1 - Install App as the Consumer
```sql 
use role nac;
create application spcs_app_instance from application package spcs_app_pkg using version v1;
```

### Step 7.2 - Create Compute Pool and Grant Privileges 
```sql 
use database nac_test;
use role nac;
create  compute pool pool_nac for application spcs_app_instance
    min_nodes = 1 max_nodes = 1
    instance_family = cpu_x64_s
    auto_resume = true;

grant usage on compute pool pool_nac to application spcs_app_instance;
grant usage on warehouse wh_nac to application spcs_app_instance;
grant bind service endpoint on account to application spcs_app_instance;
CALL spcs_app_instance.v1.register_single_callback(
  'ORDERS_TABLE' , 'ADD', SYSTEM$REFERENCE('VIEW', 'NAC_TEST.DATA.ORDERS', 'PERSISTENT', 'SELECT'));
```

### Step 7.3 - Start App Service 
With the Compute Pool created and the App configured we can now run the START_APP Stored Procedure installed with the Native App to create the Service using the POOL_NAC Compute Pool and the WH_NAC Virtual Warehouse to execute queries against the Snowflake account. 

```sql 
call spcs_app_instance.app_public.start_app('POOL_NAC', 'WH_NAC');

--After running the above command you can run the following command to determine when the Service Endpoint is ready 
--Copy the endpoint, paste into a browser, and authenticate to the Snowflake account using the same credentials you've been using to log into Snowflake
call spcs_app_instance.app_public.app_url();
```

When up and running you should see a screen like this at your service endpoint. 
![CLERKS](assets/CLERKS.png)


<!-- ------------------------ -->
## Cleanup 
Duration: 5
### Overview

To clean up your environment you can run the following series of commands.
### Step 8.1 - Clean Up
```sql
--clean up consumer objects
use role nac;
drop application spcs_app_instance;
drop compute pool pool_nac;
drop database nac_test;

--clean up provider objects
use role naspcs_role;
drop application package spcs_app_pkg;
drop database spcs_app;
drop warehouse wh_nap;

--clean up prep objects
use role accountadmin;
drop warehouse wh_nac;
drop role naspcs_role;
drop role nac;
```


<!-- ------------------------ -->
## Conclusion and Resources
Duration: 5

Congratulations!  You've now deployed a Snowflake Native App that includes Snowpark Container Service hosting a customer Frontend and Backend for a web application.  

### What we've covered
In this Quickstart we covered the following: 
- How to create a app using the Snowflake Native App framework
- How to build and push container images to a Snowflake account
- How to integrate those images into a Snowflake Native App and allow consumers to create Services
- How to test the Snowflake Native App Provider and Consumer experience within a single Snowflake account

This Quickstart can provide a template for you to accomplish the basic steps of building a Snowflake Native App that includes a Snowpark Container Service to deploy & monetize whatever unique code to your Snowflake consumers accounts.  

### Related Resources
- [Snowflake Native Apps](https://www.snowflake.com/en/data-cloud/workloads/applications/native-apps/?_fsi=vZHZai1N&_fsi=vZHZai1N&_fsi=vZHZai1N)
- [Snowflake Native Apps Documentation](https://docs.snowflake.com/en/developer-guide/native-apps/native-apps-about)
- [Snowpark Container Services](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview?_fsi=vZHZai1N&_fsi=vZHZai1N&_fsi=vZHZai1N)

author: Fredrik Göransson, Allan Mitchell
id: build_a_data_app_and_run_it_on_Snowpark_container_services
summary: Build a Data App and run it on Snowpark Container Services
categories: Getting-Started
environments: web
status: Published 
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Data Applications, API 


# Build a Data App and run it on Snowpark Container Services
<!-- ------------------------ -->
## Overview 
Duration: 1

Snowflake is a terrific platform on which to build data applications. The unique characteristics and cloud-based design allow for building applications that scale with data and workload. This tutorial will go through how to build and deploy both the Processing Layer and the User Interface Layer paired with Snowflake as the Persistence Layer.

Our example will be using a fictional food truck franchise website, Tasty Bytes. We will be building a graphical user interface with charts and graphs for franchisees to be able to examine sales data related to their franchise of food trucks. After logging in via a login page, each franchisee will have one page that will show metrics at the franchise level, and another that will show metrics around the food truck brands for that franchise.

The Processing and User Interface Layers will be built using Node.js. The dataset is an orders history for Tasty Bytes. 

The application itself will be built using containers and deployed to Snowflake. Snowpark Container Services (SPCS) allows the running of containerized workloads directly within Snowflake, ensuring that data doesn’t need to be moved out of the Snowflake environment for processing. 

This lab builds directly on the same code and solution as the [Build a Data App with Snowflake](https://quickstarts.snowflake.com/guide/build_a_data_app_with_snowflake) quickstart, for in depth walk-through of the use case and the data, and how the application is built using Node Express and React you can review each step in that guide as well. 

### Prerequisites
- A Snowflake account, and familiarity with the Snowsight interface
- Privileges necessary to create a user, database, and warehouse in Snowflake
- Basic experience using git
- Intermediate knowledge of Node.js and React JS
- Intermediate knowledge of containerised applications

- GitHub Codespaces -or- Ability to install and run software on your computer


> aside positive
> **Snowpark Container Services availability**
> 
>  Snowpark Container Services is currently in a *Public Preview* and is available across a [range of Snowflake AWS accounts](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview#label-snowpark-containers-overview-available-regions). For this lab ensure that you have an account in one of the supported regions.

### What You’ll Learn 
- How to configure and build a custom API Powered by Snowflake, written in Node.js
- How to configure and build a custom frontend website to communicate with the API, written in React and Node.js
- How to deploy a containerised application to Snowpark Container Services
- How to run and test the frontend and API on your machine

### What You’ll Need 
#### Option 1, using GitHub Codespaces:
- [GitHub Codespaces](https://github.com/) GitHub Account with credits for GitHub Codespaces
#### Option 2, local build:
- [VSCode](https://code.visualstudio.com/download) Installed
- [Docker](https://docs.docker.com/get-docker/) Installed
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) Installed
- [NodeJS](https://nodejs.org/en/download/) Installed
- [NPM](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) Installed

### What You’ll Build 
In this quickstart we will build and deploy a Data Application running on Snowpark Container Services.

![Service Overview](./assets/build-a-data-app-spcs-overview.png)

The solution consists of two services hosted on Snowpark Container Services:
- **The backend service** - which hosts the API built on Node Express - API Powered by Snowflake built in Node.js
- **The frontend service** - which hosts the React JS Web Application that connects to that API, and a router service in NGINX that allows calls from the browser-based React frontend to be routed to the backend services also.

Without the router part of the frontend service, CORS would actually prevent the browser from talking to the backend service, even if we opened up a public endpoint for it. This is due to the fact that we cannot add our own headers to requests coming to the service endpoints - for security reasons Snowpark Container Services networking strips out any headers (but adds a few useful ones that we will use for authentication later).







<!-- ------------------------ -->


## Set up the Data
Duration: 5

### Overview
In this part of the lab we'll set up our Snowflake account, create database structures to house our data, create a Virtual Warehouse to use for data loading and finally load our Tasty Bytes Food Truck orders data into our ORDERS table and run a few queries to get familiar with the data.

> aside negative
>
> The sample data for the quickstart that we load will only cover the dates between 2022-01-01 to 2022-10-31. Don't be alarmed if a query on a data later or earlier than that returns an empty response


### Step 2.1 Initial Snowflake Setup

For this part of the lab we will want to ensure we run all steps as the ACCOUNTADMIN role 
```sql
--change role to accountadmin
use role accountadmin;
```

First we can create a [Virtual Warehouse](https://docs.snowflake.com/en/user-guide/warehouses-overview) that can be used for data exploration and general querying in this lab.  We'll create this warehouse with a size of `Medium` which is right sized for that use case in this lab.  
```sql
--create a virtual warehouse for data exploration
create or replace warehouse query_wh with 
	warehouse_size = 'medium' 
	warehouse_type = 'standard' 
	auto_suspend = 300 
	auto_resume = true 
	min_cluster_count = 1 
	max_cluster_count = 1 
	scaling_policy = 'standard';
```

### Step 2.2 Load Data

Next we will create a database and schema that will house the tables that store our application data.
```sql
--create the application database and schema
create or replace database frostbyte_tasty_bytes;
create or replace schema app;
```

This DDL will create the structure for the ORDERS table which is the main source of data for our application in this lab. 
```sql
--create table structure for order data 
create or replace table orders (
	order_id number(38,0),
	truck_id number(38,0),
	order_ts timestamp_ntz(9),
	order_detail_id number(38,0),
	line_number number(38,0),
	truck_brand_name varchar(16777216),
	menu_type varchar(16777216),
	primary_city varchar(16777216),
	region varchar(16777216),
	country varchar(16777216),
	franchise_flag number(38,0),
	franchise_id number(38,0),
	franchisee_first_name varchar(16777216),
	franchisee_last_name varchar(16777216),
	location_id number(19,0),
	customer_id number(38,0),
	first_name varchar(16777216),
	last_name varchar(16777216),
	e_mail varchar(16777216),
	phone_number varchar(16777216),
	children_count varchar(16777216),
	gender varchar(16777216),
	marital_status varchar(16777216),
	menu_item_id number(38,0),
	menu_item_name varchar(16777216),
	quantity number(5,0),
	unit_price number(38,4),
	price number(38,4),
	order_amount number(38,4),
	order_tax_amount varchar(16777216),
	order_discount_amount varchar(16777216),
	order_total number(38,4)
);
```

For loading data into the ORDERS table we will create a new Virtual Warehouse sized as a `Large` to help us quickly ingest the data we have stored in an S3 bucket. 
```sql
--create a virtual warehouse for data loading
create or replace warehouse load_wh with 
	warehouse_size = 'large' 
	warehouse_type = 'standard' 
	auto_suspend = 300 
	auto_resume = true 
	min_cluster_count = 1 
	max_cluster_count = 1 
	scaling_policy = 'standard';
```
Next we have to create a [STAGE](https://docs.snowflake.com/en/user-guide/data-load-overview) which is a Snowflake object that points to a cloud storage location Snowflake can access to both ingest and query data.  In this lab the data is stored in a publicly accessible AWS S3 bucket which we are referencing when creating the Stage object. 
```sql
--create stage for loading orders data
create or replace stage tasty_bytes_app_stage
	url = 's3://sfquickstarts/frostbyte_tastybytes/app/orders/';
```
Once we've created both the Virtual Warehouse we want to use for loading data and the Stage which points to where the data resides in cloud storage we can simply [COPY](https://docs.snowflake.com/en/sql-reference/sql/copy-into-table) the data from that Stage into our ORDERS table. 
```sql
--copy data into orders table using the load wh
 copy into orders from @tasty_bytes_app_stage;
```


### Step 2.3 Explore Data
Now that we've loaded our data into the ORDERS table we can run a few queries to get familiar with it - but first we will want to change the Virtual Warehouse we're using from the `LOAD_WH` back to the `QUERY_WH` created earlier in the lab. 
```sql
--change our Virtual Warehouse context to use our query_wh
 use warehouse query_wh;
```

To begin with we can simply look at a sample of the entire table.
```sql 
--simple query to look at 10 rows of data 
select * from orders limit 10;
```

Next we can see how many records we've loaded into the table.  Notice how quickly the query executes - this is due to Snowflake's unique architecture which enables a certain class of queries like this one to pull results from metadata instead of requiring compute to generate the result. 
```sql 
--query to count all records in the table
select count(*) from orders;
```

Finally we can run a more complex query to look at the total revenue by month where we will use a couple of [functions](https://docs.snowflake.com/en/sql-reference-functions) to parse the month number and name from the ORDER_TS column in the ORDERS table. 
```sql
--sales by month
select month(order_ts),monthname(order_ts), sum(price)
from orders 
group by month(order_ts), monthname(order_ts)
order by month(order_ts);
```
### Step 2.4 Further explore the Data

To understand and explore the data even more, you can look through the [Quickstart for Building a Data Application - Lab 2: Queries](https://quickstarts.snowflake.com/guide/build_a_data_app_with_snowflake/#2) that offers a number of steps to explore it.

If you already have done that, you can move directly to the next step in this guide. If not, you can continue below and explore the data further.

Our queries will be broken into two groups - `Franchise` queries and `Truck Brand` level queries.  For the sake of ease we will focus on the following Franchise, Truck Brand and Date Range for this part of the lab.

* Franchise:  `1`
* Truck Brand: `Guac 'n Roll`
* Date Range: `1/1/2023 - 3/31/2023`

### Setting Snowsight Context
To ensure the correct context is use for these queries we will set our database, schema and Virtual Warehouse using the following SQL:
```sql
--set query context
use database frostbyte_tasty_bytes;
use schema app;
use warehouse query_wh;
```

### Franchise Queries
To answer the business questions about how our overall Franchise business is doing we'll need to create the three following queries.  All of the columns required for these exist in the ORDERS table and no joining of tables are required. 

1. Top 10 Countries Based on Revenue in a Time Window
2. Top 10 Truck Brands Based on Revenue in a Time Window
3. Year-to-Date Revenue, by Month, per Truck Brand

You can spend some time creating the queries for each of these and then check your answers against the provided queries below by expanding each section. 

<strong>Top 10 Countries Based on Revenue in a Time Window</strong>

```sql
    SELECT
        TOP 10 country,
        sum(price) AS revenue
    FROM
        app.orders
    WHERE
        date(order_ts) >= '2023-01-01'
        AND date(order_ts) <= '2023-03-31'
        AND franchise_id = 1
    GROUP BY
        country
    ORDER BY
        sum(price) desc;
```
<strong>Top 10 Truck Brands Based on Revenue in a Time Window</strong>

```sql
    SELECT
        TOP 10 truck_brand_name,
        sum(price) AS revenue
    FROM
        app.orders
    WHERE
        date(order_ts) >= '2023-01-01'
        AND date(order_ts) <= '2023-03-31'
        AND franchise_id = 1
    GROUP BY
        truck_brand_name
    ORDER BY
        sum(price) desc;
```
<strong>Year-to-Date Revenue, by Month, per Truck Brand</strong>

```sql
    SELECT
        country,
        month(order_ts) as date,
        sum(price) AS revenue
    FROM
        app.orders
    WHERE
         year(order_ts) = 2023
        AND franchise_id = 1
    GROUP BY
        country,
        month(order_ts)
    ORDER BY
        sum(price) desc;
```

### Truck Brand Queries
To answer the business questions about how our overall Franchise business is doing we'll need to create the three following queries.  All of the columns required for these exist in the ORDERS table and no joining of tables are required. 

1. Total Sales by Day-of-Week
2. Top Selling Items
3. Top Selling items by Day-of-Week
4. 

You can spend some time creating the queries for each of these and then check your answers against the provided queries below by expanding each section. 

<strong>Top 10 Countries Based on Revenue in a Time Window</strong>

```sql
    SELECT
        TOP 10 country,
        sum(price) AS revenue
    FROM
        app.orders
    WHERE
        date(order_ts) >= '2023-01-01'
        AND date(order_ts) <= '2023-03-31'
        AND franchise_id = 1
    GROUP BY
        country
    ORDER BY
        sum(price) desc;
```
<strong>Top 10 Truck Brands Based on Revenue in a Time Window</strong>

```sql
    SELECT
        TOP 10 truck_brand_name,
        sum(price) AS revenue
    FROM
        app.orders
    WHERE
        date(order_ts) >= '2023-01-01'
        AND date(order_ts) <= '2023-03-31'
        AND franchise_id = 1
    GROUP BY
        truck_brand_name
    ORDER BY
        sum(price) desc;
```
<strong>Total Sales by City and Day-of-Week</strong>

```sql
    SELECT
        country,
        month(order_ts) as date,
        sum(price) AS revenue
    FROM
        app.orders
    WHERE
         year(order_ts) = 2023
        AND franchise_id = 1
    GROUP BY
        country,
        month(order_ts)
    ORDER BY
        sum(price) desc;
```









<!-- ------------------------ -->

## Setup Snowflake
Duration: 10

### Overview
Now that we've created our database, loaded data and developed the queries needed to answer our business questions, the last step before getting into application code is setting up the necessary objects so that the application can connect to Snowflake securely and query data on its own Virtual Warehouse. We will also set up the objects required to create and run services. The objects we will look at are:

- [Compute Pools](https://docs.snowflake.com/developer-guide/snowpark-container-services/working-with-compute-pool) that are responsible for providing compute to the services once they run.
- [Image Repositories](https://docs.snowflake.com/developer-guide/snowpark-container-services/working-with-registry-repository) that can hold docker images used by the services we create
- [Services Ingress Security Integration](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-services?utm_source=legacy&utm_medium=serp&utm_term=snowservices_ingress#ingress-using-a-service-from-outside-snowflake)

### Step 3.1 Creating roles, permissions and virtual warehouse for running the application

Much like we created separate Virtual Warehouses for exploring and loading data, we will create one specifically for our service to use when executing queries on Snowflake.

We start by creating a role that can be responsible for administering the setup of the services and everything else. There are a number of permissions that can be granted, and in a production build environment, these permissions may instead be granted to different roles with different responsibilities.

```sql
USE DATABASE frostbyte_tasty_bytes;
USE SCHEMA APP;

CREATE ROLE tasty_app_admin_role;

GRANT ALL ON DATABASE frostbyte_tasty_bytes TO ROLE tasty_app_admin_role;
GRANT ALL ON SCHEMA frostbyte_tasty_bytes.app TO ROLE tasty_app_admin_role;
GRANT SELECT ON ALL TABLES IN SCHEMA frostbyte_tasty_bytes.app TO ROLE tasty_app_admin_role;
GRANT SELECT ON FUTURE TABLES IN SCHEMA frostbyte_tasty_bytes.app TO ROLE tasty_app_admin_role;
```

We can now create a Virtual Warehouse that the application will use to execute queries.
```sql
CREATE OR REPLACE WAREHOUSE tasty_app_warehouse WITH
WAREHOUSE_SIZE='X-SMALL'
AUTO_SUSPEND = 180
AUTO_RESUME = true
INITIALLY_SUSPENDED=false;

GRANT ALL ON WAREHOUSE tasty_app_warehouse TO ROLE tasty_app_admin_role;
```

### Step 3.2 Creating Compute Pools for service to run on

The Compute Pools are used to run the services. We can create different pools for different purposes. In this example we create two different pools to run the services, one for the backend and one for the frontend. We could technically allow both services to use the same Compute Pool, in fact for this demo it would work very well, but in many scenarios the scaling requirements for the frontend and a backend may be different. Here we can see that the backend is given a pool of compute nodes that is slightly more scaled up than the nodes for the compute pool used for the frontend. There are multiple options for choosing the right instance family for a Compute Pool [Create Compute Pool](https://docs.snowflake.com/sql-reference/sql/create-compute-pool). This would be even more relevant if the backend needed to do some more compute heavy work, even to the point where it needed to have GPU enabled nodes.
```sql
CREATE COMPUTE POOL tasty_app_backend_compute_pool
MIN_NODES = 1
MAX_NODES = 1
INSTANCE_FAMILY = CPU_X64_S;

GRANT USAGE ON COMPUTE POOL tasty_app_backend_compute_pool TO ROLE tasty_app_admin_role;
GRANT MONITOR ON COMPUTE POOL tasty_app_backend_compute_pool TO ROLE tasty_app_admin_role;

CREATE COMPUTE POOL tasty_app_frontend_compute_pool
MIN_NODES = 1
MAX_NODES = 1
INSTANCE_FAMILY = CPU_X64_XS;

GRANT USAGE ON COMPUTE POOL tasty_app_frontend_compute_pool TO ROLE tasty_app_admin_role;
GRANT MONITOR ON COMPUTE POOL tasty_app_frontend_compute_pool TO ROLE tasty_app_admin_role;
```

The `tasty_app_admin_role` role must also be given the permission to bind service endpoints for services.
```sql 
GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE tasty_app_admin_role;
```

### Step 3.3 Set up docker image repositories and stage for service specifications

We can now ensure that the current user can use the admin role.
```sql 
SET sql = ('GRANT ROLE tasty_app_admin_role TO USER ' || CURRENT_USER() || '');
EXECUTE IMMEDIATE $sql;
USE ROLE tasty_app_admin_role;
```

Here we create the [`IMAGE REPOSITORY`](https://docs.snowflake.com/developer-guide/snowpark-container-services/working-with-registry-repository) to hold images for services.
```sql
-- Create image repository  
CREATE OR REPLACE IMAGE REPOSITORY tasty_app_repository;
-- Show the repo we just created
SHOW IMAGE REPOSITORIES;
-- List images in repo (can be called later to verify that images have been pushed to the repo)
call system$registry_list_images('/frostbyte_tasty_bytes/app/tasty_app_repository');
```

We can also create a stage to hold service specification files, although for this guide we will provide the specifications inline with the service creation. 
```sql
-- Create a stage to hold service specification files
CREATE STAGE tasty_app_stage DIRECTORY = ( ENABLE = true );
```


### Step 3.4 Create external users role and users for the external access

In order to allow the application users to access the application we can create dedicated `USERS` for each user. In the guide [Build a Data App with Snowflake](https://quickstarts.snowflake.com/guide/build_a_data_app_with_snowflake) users were actually stored in a `USERS` table that was created, where hashed passwords were stored and could be used to check the login from the frontend. Create that table by running the following SQL:

```sql
-- Create Users table for the Website
create or replace table users (
	user_id number(38,0) autoincrement,
	user_name varchar(16777216) not null,
	hashed_password varchar(16777216),
	franchise_id number(38,0),
	password_date timestamp_ntz(9),
	status boolean,
	unique (user_name)
);

 -- Add Franchisee logins 
insert into users
    values
    (1,'user1','$2b$10$v0IoU/pokkiM13e.eayf1u3DkgtIBMGO1uRO2O.mlb2K2cLztV5vy',1,current_timestamp,TRUE), 
    (2,'user2','$2b$10$e2TXM/kLlazbH1xl31SeOe6RTyfL3E9mE8sZZsU33AE52rO.u44JC',120,current_timestamp,TRUE),
    (3,'user3','$2b$10$WX4e1LAC.rAabBJV58RuKerEK4T/U4htgXrmedTa5oiGCWIRHwe0e',271,current_timestamp,TRUE);
```


In this guide, we will create those users as actual Snowflake Users and give them a role that is allowed to access the services we later create. This allows us to utilize the OAuth sign-in we created earlier to authenticate users.

We can create the users like this:
```sql
USE ROLE ACCOUNTADMIN;
CREATE ROLE tasty_app_ext_role;

GRANT USAGE ON DATABASE frostbyte_tasty_bytes TO ROLE tasty_app_ext_role;
GRANT USAGE ON SCHEMA app TO ROLE tasty_app_ext_role;

CREATE USER IF NOT EXISTS user1 PASSWORD='password1' MUST_CHANGE_PASSWORD=TRUE DEFAULT_ROLE=tasty_app_ext_role;
GRANT ROLE tasty_app_ext_role TO USER user1;
```

Not that we force the user to change the password on the first login here. When testing it you can choose to set `MUST_CHANGE_PASSWORD=FALSE`, but in a real scenario these passwords should be changed on first login.

Just for reference, the users that were created in the earlier database set up lab are the following:

| User name | Hashed password | Franchise id | Plaintext password |
| ------- | --------- | --------------- | ------------ |
| user1	| $2b$10$3/teX....iH7NI1SjoTjhi74a	| 1	| password1 |
| user2	| $2b$10$9wdGi....U8qeK/nX3c9HV8VW	| 120	| password120 |
| user3	| $2b$10$CNZif....IXZFepwrGtZbGqIO	| 271	| password271 |

We can create all the users this way:
```sql
CREATE USER IF NOT EXISTS user2 PASSWORD='password120' MUST_CHANGE_PASSWORD=TRUE DEFAULT_ROLE=tasty_app_ext_role;
GRANT ROLE tasty_app_ext_role TO USER user2;

CREATE USER IF NOT EXISTS user3 PASSWORD='password270' MUST_CHANGE_PASSWORD=TRUE DEFAULT_ROLE=tasty_app_ext_role;
GRANT ROLE tasty_app_ext_role TO USER user3;
```









<!-- ------------------------ -->

## Building the backend code
Duration: 5

### Overview
We now look at the code for the backend and frontend to adapt it to run in Snowpark Container Services.

#### Option 1 - Build using GitHub Codespaces
If you have access to GitHub and credits on an account that let's you run GitHub Codespaces, you can directly build the entire code and push the containerized images to the image repository in the cloud environment.

If you don't have access to this, or prefer to build this locally, go to Option 2 instead.

First, create your on fork of the main repository, go to the GitHub repository at [GitHub: Snowflake-Labs/sfguide-tasty-bytes-zero-to-app-with-spcs](https://github.com/Snowflake-Labs/sfguide-tasty-bytes-zero-to-app-with-spcs.git) and create your own fork of the repo.
![Fork Repository](assets/fork_repository.png)

Once you have your own fork, go to the '<> CODE' button and select 'Codespaces' and create a new.
![Create Codespace](assets/create_codespace.png)



The code for this lab is hosted on GitHub. Start by cloning the repository into a separate folder. Note that we are cloning a specific branch `spcs` here that contains the code adapted for this guide.
```bash
git clone https://github.com/Snowflake-Labs/sfguide-tasty-bytes-zero-to-app-with-spcs.git zero-to-app-spcs
```

Change directory to the `zero-to-app-spcs/` directory that is created in the clone above. You should now have a directory with a `/src` subdirectory that contains `/backend` and `/frontend` directories. 

### Step 4.1 The backend service
Let's start with looking at the backend code. Open a terminal and go to the `/src/backend` directory.

First ensure that you have Docker installed on you environment:
```bash
docker --version
-- Docker version 24.0.6, build ed223bc
```

For local testing, we can then let the backend connect to the Snowflake account using credentials we supply in the environment variables. Copy the `.env.example` file to `.env` and fill out the details for your account there. 
```bash
cp .env.example .env
sed -i -e "s/{INSERT A RANDOM STRING HERE}/$(openssl rand -base64 12)/" .env
sed -i -e "s/{INSERT ANOTHER RANDOM STRING HERE}/$(openssl rand -base64 12)/" .env
```
:
```bash
SNOWFLAKE_ACCOUNT={INSERT_ACCOUNT_NAME_HERE}
SNOWFLAKE_USERNAME={INSERT_USER_NAME_HERE}
SNOWFLAKE_PASSWORD={INSERT_PASSWORD_HERE}
SNOWFLAKE_ROLE=TASTY_APP_ADMIN_ROLE
SNOWFLAKE_WAREHOUSE=TASTY_APP_WAREHOUSE
SNOWFLAKE_DATABASE=frostbyte_tasty_bytes
SNOWFLAKE_SCHEMA=app

ACCESS_TOKEN_SECRET=a1to.....9wlnNq
REFRESH_TOKEN_SECRET=KVDq9.....icVNh

PORT=3000

CLIENT_VALIDATION=Dev 
```

There is a `docker-compose.yaml` file in this folder that we will use to spin up a local service using this environment:
```bash
docker compose up
```

Try to access the API by calling the endpoint now. If you are in GitHub Codespaces, you will be offered a unique URL that is generated for you, like 'https://<random-generated-identifier>-3000.app.github.dev/' that you can access, if you are on your local environment, it will be a localhost URL, like 'http://localhost:3000/'
![Forwarded ports](assets/forwarded_port_host.png)
```bash
curl https://<random-generated-identifier>-3000.app.github.dev/franchise/1
```
or, open up a new terminal and access it (this will also work inside Codespaces)
```bash
curl http://localhost:3000/franchise/1
```

This should return the following JSON response:
```json
{
   "TRUCK_BRAND_NAMES":[
      "The Mac Shack",
      "Smoky BBQ",
      "Freezing Point",
      "Guac n' Roll",
      "The Mega Melt",
      "Plant Palace",
      "Tasty Tibs",
      "Nani's Kitchen",
      "Better Off Bread",
      "Peking Truck",
      "Kitakata Ramen Bar",
      "Cheeky Greek",
      "Le Coin des Crêpes",
      "Revenge of the Curds",
      "Not the Wurst Hot Dogs"
   ],
   "START_DATE":"2022-01-01 08:00:01.000",
   "END_DATE":"2022-10-31 22:59:29.000"
}
```

### Step 4.2 Authenticating and authorizing service users

Currently there is no authentication of the user calling this endpoint. We will change that to take advantage of the mechanism built into Snowflake Container Services.

In the earlier guide [Build a Data App with Snowflake](https://quickstarts.snowflake.com/guide/build_a_data_app_with_snowflake) authentication was implemented using JWT tokens, where the client frontend called a login endpoint and provider user name and password, and the service looked that up in the database (the `USERS` table that is also created for this lab.) and then supplied the client with an accesstoken that could be passed along with future calls to the API. With SPCS this will not work because the environment strips any request headers from calls to the public endpoints as they are routed to the service, meaning we cannot evaluate a Bearer Authentication token in calls from the client to the backend. Remember, with a React application, the frontend is running directly as javascript in the client's browser, even if the code is served from the frontend service, so calls to the API are coming from the end users' browsers, not from the internal service hosting the frontend.

> aside positive
>
> While React.js mainly relies on Client-Side Rendering, other frontend frameworks may rely on Server-Side Rendering, which changes this a little bit. CSR is very lightweight and makes it easy for the frontend service to serve static content to the end users, so for this solution it works well.

What Snowpark Container Services offers is a different authentication model. Any user accessing the public endpoints for the services, needs to log in with a `USER` to the Snowflake interface. 

![User authentication](./assets/authenticating_with_snowservices_ingress.png)

In this example, one of the users we created in the earlier steps (`user1`, `user2`, `user3`,...) can now log in here. Once the user is authenticated, Snowpark Container Services adds that user name as a special header `Sf-Context-Current-User` to any request to the public endpoints. Since the environment strips away any other headers, there is no risk that the client can tamper with the value of this either, so from the perspective of the backend service, we can trust that the value in that header represents the user that authenticated with Snowflake.

The request headers reaching the service endpoint will look something like this for a normal call:

```bash
host: 'backend-service:3000'
referer: 'https://randomlygeneratedendpointname.snowflakecomputing.app/login'
content-type: 'application/json'
user-agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
accept: '*/*'
'sf-context-current-user': 'USER1'
...
...
```

With this we can then look up that user and ensure that they have access to the application.

Go to the code for `auth.js`, it contains code to validate this header and look up the user in the database, in order to check its association with a franchise. The following code does that:

```js
function lookupUser(user_name) {
    return new Promise(async function (result, error) {
        snowflake.getConnection().then(conn =>
            conn.execute({
                sqlText: sql_queries.verify_user,
                binds: [user_name],
                complete: (err, stmt, rows) => {
                    if (err) {
                        error({result: false, message: 'Unable to lookup user', error:err});
                    } else {
                        if (rows.length == 0) {
                            result({message: 'User does not exist'});
                        } else {
                            user_row = rows[0]
                            user_name = user_row.USER_NAME;
                            franchise_id = user_row.FRANCHISE_ID;
                            hashed_password = user_row.HASHED_PASSWORD;
                            data = {result: true, validation: 'Snowflake', user_name: user_name, franchise_id: franchise_id, hashed_password: hashed_password };
                            result(data);
                        }
                    }
                },
            }));
    });
}

...

function validateSnowflakeHeader(req, res, next) {

    if (!req.headers['sf-context-current-user']) {
        console.warn('Validation mode is Snowflake but sf-context-current-user header is missing - user is not validated');
        res.status(422).send("Incorrect data");
        return
    }

    const login_user = req.headers['sf-context-current-user']
    console.log('sf-context-current-user: ' + login_user);
    lookupUser(login_user).then(result => {
        if (result.result === true){
            console.log('Authorizing user ' + result.user_name + ' for franchise: ' + result.franchise_id);
            req.user = { validation: 'Snowflake', user: result.user_name, franchise: result.franchise_id };
            next();
        } else {
            console.warn('User does not exist: ' + login_user);
            res.status(401).json('Invalid user or password');
            return
        }
    }, error => {
        console.error(error.message, error.error);
        res.status(500).json({ error: error.message });
        return
    });
};
```

Comparing this to the code that validates a JWT access token it is similar, but we here also have to look up the user in a database call, because unlike the JWT we cannot securely pass any additional information (like the `franchise_id` in the toke), the only value we can trust here is the user header, since it is securely set by the SPCS environment and cannot be tampered with by a javascript client. The rest of the code in that file is supporting the authentication using other methods, but this is the only one that will be used in this guide and when we deploy the services to Snowflake.

Also review the file `/routes/login.js` that introduces a new endpoint `/authorize` that responds with an accesstoken containing the `user id` and `franchise id` when called with a header of `Sf-Context-Current-User`. This can be used by the frontend later on to check what franchise to set in the UI. Note that this endpoint also returns a JWT token, but we are only using that format to keep the code in the frontend as similar to the original code as possible, we are not using the JWT access token for future authorization of calls from the frontend to the backend.

This endpoint is similar to the code in `auth.js` for validating a user.
```js
router.get("/authorize", async (req, res) => {

    console.log('Authorize with request headers:')
    if (!req.headers['sf-context-current-user']) {
        res.status(422).send("Incorrect data");
        return
    }

    const login_user = req.headers['sf-context-current-user']
    console.log(`Authorizing user ${login_user} from context header`);
    auth.lookupUser(login_user).then(result => {
        if (result.result === true) {            
            console.log('Authorizing user ' + result.user_name + ' for franchise: ' + result.franchise_id);
            const accessToken = auth.generateAccessToken({ user: result.user_name, franchise: result.franchise_id, preauthorized: true });
            const refreshToken = auth.generateRefreshToken({ user: result.user_name, franchise: result.franchise_id, preauthorized: true });
            res.status(200).json({ accessToken: accessToken, refreshToken: refreshToken });
            return
        } else {
            console.warn('User does not exist: ' + login_user);
            res.status(401).json('Invalid user or password');
            return
        }
    }, error => {
        console.error(error.message, error.error);
        res.status(500).json({ error: error.message });
        return
    });
});
```

With this we test run the application locally and simulate the SPCS environment. Change the `.env` file to use Snowflake authentication instead:

```bash
CLIENT_VALIDATION=Snowflake
```

Restart the service running by pressing `CTRL+c` in the terminal where you started the docker service. Restart it again with `docker compose up` again. Once running you should now see the output:

```bash
backend-backend_service-1  | Starting up Node Express, build version 00013
backend-backend_service-1  | Server running on port 3000
backend-backend_service-1  | Environment: development
backend-backend_service-1  | CORS origin allowed: http://localhost:4000
backend-backend_service-1  | Client validation: Snowflake
backend-backend_service-1  | Using warehouse: TASTY_APP_WAREHOUSE
backend-backend_service-1  | Using role: TASTY_APP_ADMIN_ROLE
```

Calling one of the endpoints now results in a `HTTP 422` response and the test `Incorrect data` (which is what we expect from the `validateSnowflakeHeader` in `auth.js`). If we provide a header that looks like the SPCS authentication header it now uses that to validate the user:

```bash
curl --header "Sf-Context-Current-User:user1"  http://localhost:3000/franchise/1
```

This now responds with a the expected `HTTP 200` response:
```json
{
   "TRUCK_BRAND_NAMES":["The Mac Shack","Smoky BBQ","Freezing Point","Guac n' Roll","The Mega Melt","Plant Palace","Tasty Tibs","Nani's Kitchen","Better Off Bread","Peking Truck","Kitakata Ramen Bar","Cheeky Greek","Le Coin des Crêpes","Revenge of the Curds","Not the Wurst Hot Dogs"
   ],
   "START_DATE":"2022-01-01 08:00:01.000",
   "END_DATE":"2022-10-31 22:59:29.000"
}
```

You can now terminate the service with `CTRL+c` and we can then destroy the local Docker service and images we just used for testing:

```bash
docker rm backend-backend_service-1
docker image rm backend-backend_service
```

### Step 4.3 Connecting to Snowflake data

With this update, we can now look at how the backend service can access the data in the Snowflake tables and views. In the self hosted version of of the code (as in the [Build a Data App with Snowflake](https://quickstarts.snowflake.com/guide/build_a_data_app_with_snowflake)) we use a key pair authentication schema to connect the service to Snowflake. For a service running on Snowpark Container Services, we can benefit from the service already running on Snowflake and we can use a provided and pre-loaded authentication model based on OAuth. This is available for every service running on SPCS.

Open the file `connect.js` and look at how the code is sending the options for the connection to Snowflake:

```js
    const options = {
        database: process.env.SNOWFLAKE_DATABASE,
        schema: process.env.SNOWFLAKE_SCHEMA,
        warehouse: process.env.SNOWFLAKE_WAREHOUSE,
    };

    if (fs.existsSync('/snowflake/session/token')) {
        options.token = fs.readFileSync('/snowflake/session/token', 'ascii');
        options.authenticator = "OAUTH";
        options.account = process.env.SNOWFLAKE_ACCOUNT;
        options.accessUrl = 'https://' + process.env.SNOWFLAKE_HOST;
    } else {
        options.account = process.env.SNOWFLAKE_ACCOUNT;
        options.username = process.env.SNOWFLAKE_USERNAME;
        options.role = process.env.SNOWFLAKE_ROLE;
        options.password = process.env.SNOWFLAKE_PASSWORD;
    };
```

When the service is running on SPCS, the file located at `/snowflake/session/token` will contain an OAuth token that is pre-validated for accessing Snowflake. This means we don't need to supply a user and password for the connection. This token is authenticated for a temporary user that is given the same role as the `OWNER` for the Service being called. This is an important detail, as the service will be connecting as the very role that created it (here it will be `tasty_app_admin_role`), so think of it as a service account type of user that is connecting. This is analogous to how the original solution worked, but in there we created a dedicated user that the service connected as.

Once connected, the rest of the backend code is working the same, regardless if it is running in the SPCS environment or somewhere else, like a local testing environment.








<!-- ------------------------ -->

## Building the frontend code
Duration: 3

### Overview
We can now look at how the frontend has been updated to take advantage of the changes and for us to be able to run it on SPCS.

There are two areas that is updated here to allow it to run in the new environment:

- Authentication - by placing the service behind a public endpoint that forces users to login, it no longer makes sense to keep the login form in the client, the required authentication is already captured by the Snowflake OAuth login form
- Routing from client to the backend API, we can no longer directly control the CORS directives for the services, and calls from the client are actually made directly from the users' browsers.

The routing is something that changes somewhat significantly from the original solution. Instead of adding a CORS directive to the backend (e.g. allowing calls from another origin), we introduce a router service that takes calls from the public endpoint and _routes_ them to either the frontend service, or the backend service, allowing us to maintain a single public endpoint.

> aside negative
>
> The frontend service and backend service are here hosted as two separate services, with a router bundled together with the frontend. For this simple application that may not be a necessary requirement to fulfill, but in a more complex and demanding application, it would be a good approach to separate the frontend and backend as they would have different non-functional requirements.

The router ensures that calls made to routes starting with `/api` are forwarded to the `backend-service`, whereas any other calls `/*` are routed to the frontend container running in the same service as the router:
![Routing](./assets/frontend-routing.png)

### Step 5.1 Building the router

The router is a simple service based on [*NGINX*](https://www.nginx.com/). The code is very simple and serves a NGINX server that is given a configuration that defines the different routes, open `/src/frontend/router/nginx.conf.template`:

```yaml
events {
  worker_connections  1024;
}
http {
  server {
    listen 8000;
    listen [::]:8000;
    server_name localhost;

    location / {
      proxy_pass  http://$FRONTEND_SERVICE/;
    }

    location /api {
        rewrite     /api/(.*) /$1  break;
        proxy_pass  http://$BACKEND_SERVICE/;
    }

    location /test {
        add_header Content-Type text/html;

        return 200 '<html><body><h1>This is the router testpage</h1><li>Sf-Context-Current-User: $http_sf_context_current_user</li><li>Host: $http_host</li><li>Frontend Server: $FRONTEND_SERVICE</li><li>Backend Server: $BACKEND_SERVICE</li></body></html>';
    }
  } 
}
```

There are three routes in here, `/`, `/api` `/test`. The last one simply outputs debug information and can help to understand that the setup is correct (it should be removed when not testing out the services).

The `/api` route means that anything prefixed with that gets rewritten to remove the "`/api`" part and then passed forward to the backend service URL. For all other calls they should be forwarded directly to the frontend service URL (which should be running on the same service as the router, in a different container).

The `$FRONTEND_SERVICE` and `$BACKEND_SERVICE` variables allow us to dynamically replace these values when the Docker image is being used. If we look at the Dockerfile:

```bash
FROM nginx:alpine

ARG required FRONTEND_SERVICE
ARG required BACKEND_SERVICE

RUN apk update && apk add bash

EXPOSE 8000

COPY nginx.conf.template /nginx.conf.template

CMD ["/bin/sh" , "-c" , "envsubst '$FRONTEND_SERVICE $BACKEND_SERVICE' < /nginx.conf.template > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'"]
```

The last line substitutes these variables for values taken from the `environment` it is running in, before copying the contents into the `nginx.conf` file and starting up the server.

You can test the router by running the container locally. From `/src/frontend` run the following:
bash
```
docker compose --env-file .env.local.example up
```
This should run the router and the frontend on local ports. Test it out by running:
bash
```
curl http://localhost:8888/test
```
It should return HTLM, like:
html
```
<html><body><h1>This is the router testpage</h1><li>Sf-Context-Current-User: </li><li>Host: localhost:8888</li><li>Frontend Server: localhost:4000</li><li>Backend Server: localhost:3000</li></body></html>
```
Terminate the running containers byt pressing `ctrl+c` in the terminal again.

### Step 5.2 Updating the frontend code

The frontend code itself needs fewer changes to adapt to the new environment. Primarily here we are looking at removing the actual login form and user management in favor of using the built in login capability.

![Tasty App UI](./assets/tasty-app-ui.png)

> aside negative
>
> The original React code is actually built on older package dependencies. In order to keep this guide as similar to the original guide no changes to the React framework have been introduced, only minor changes are done as part of this guide. There are many ways to update the general React code to later standards, but this guide will focus on the core parts of connecting the services,

In a commonly shared file `Utils.js` we can provide some methods that will help check how to communicate with the backend and to verify if the login button should be visible. 

```js
export function enableLogin() {
    if (clientValidation === 'JWT') {
        return true;
    } else if (clientValidation === 'Snowflake') {
        return false;
    }
    console.log(` - Login disabled`);
    return false;
}

export function isLoggedIn(state) {
    if (clientValidation === 'JWT') {
        if (state){
            return (state.accessToken != null);
        }
    } else if (clientValidation === 'Snowflake') {
        if (state){
            return (state.accessToken != null);
        }
    } else if (clientValidation === 'Dev') {
        if (state){
            return (state.franchise != null);
        }
    }
    return false;
}
```

We can then use these functions to decide if the Login button should be visible or not:

E.g. in `Home.js`, the logout button is conditionally shown using the above function:
```html
            <div className='home-header'>
                <Image src='bug-sno-R-blue.png' className='homeLogo' />
                <h1 className="homeTitle"> Tasty App</h1>

                <Button className='backBtn' onClick={gotoDetails}>  🚚 Truck Details</Button>
                { enableLogin() &&
                    <Button className='home-logoutBtn' onClick={logout}>⎋ Logout</Button>
                }
            </div>
```

And in the `App.js` routing we can use the same functions to conditionally route the user depending on if they are logged in or not.

```js
function App() {

  const LoginWrapper = () => {
    const location = useLocation();
    return isLoggedIn(location.state) ? <Outlet /> : <Navigate to="/login" replace />;
  };

  return (
    // Routing for the App.
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={ <Login />  } />
        <Route element={<LoginWrapper />}>
          <Route path="/" element={ <Home /> } />
          <Route path="/home" element={ <Home /> } />
          <Route path="/details" element={ <Details /> } />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
```

Finally we add a call in `Login.js` to check the `/authenticate` endpoint of the backend.

```js
const clientValidation = process.env.REACT_APP_CLIENT_VALIDATION;

...

    function checkAuthentication() {
        if (clientValidation === 'JWT') {
            //console.log(` - Validation enabled`);
        } else if (clientValidation === 'Snowflake') {
            console.log(`Checking client validation ${clientValidation} - Checking authorize endpoint of API`);
            const requestOptions = {
                method: 'GET',
                headers: { 'Content-Type': 'application/json', 'Sf-Context-Current-User': 'user1' }
            };
            fetch(backendURL + '/authorize', requestOptions)
                .then((result) => {
                    if (result.ok) {
                        result.json()
                            .then((data) => {
                                const token = decodeToken(data.accessToken);
                                data.franchise = token.franchise;
                                navigate("/", { state: data });
                            });
                    } else {
                        console.warn('Current user is not authorized to use the application');
                    }

                });
        } else {
            console.warn(`Checking client validation ${clientValidation} - Validation disabled - hard coding franchise "1"`);
            const data = { franchise: 1 };
            navigate("/", { state: data });
        }
        return false;

    };
```

When the `/login` page shows, this call is run and if the result is that a user context is returned then it navigates to the default route `/`. This all ensures that the same code runs both in the SPCS environment and in another hosting environment. By setting the `ENVIRONMENT` variable `REACT_APP_CLIENT_VALIDATION` to `Snowflake` when deploying this we ensure the method is called and evaluated.

Remember, the `/authorize` endpoint of the backend service should return a JWT access token containing the user name and franchise when called from an authenticated context in SPCS, like the following result:
```json
{
    "accessToken": "eyJhbGc....goa_RUCl85NeM",
    "refreshToken": "eyJhbGc.....VR5fnViRksNI"
}
```

And when decoded, that token should look something like this:
```json
{
  "user": "user1",
  "franchise": 1,
  "preauthorized": true,
  "iat": 1705924945,
  "exp": 1705946545
}
```

You can try this if you like, by starting up the backend again in a new Terminal window:
```bash
cd src/backend
docker compose up
```
And then directly call the `authorize` endpoint:
```bash
curl --header "Sf-Context-Current-User:user1" http://localhost:3000/authorize
```
Copy the content of the `accessToken` attribute in the JSON response, and then go to [https://jwt.io/](https://jwt.io/) and paste the response there. This should decode the token for you and show an output like above.

Additionally, if you want to verify this token, you can supply the random string we added to the `.env` file for the backend.

Throughout the `Home.js` and `Details.js` we then update all call to the backend to use the common helper function from `Utils.js` to call the backend, like this:
```js
const url = `${backendURL}/franchise/${franchise}/trucks?start=${fromDate}&end=${toDate}`;
fetch(url, getRequestOptions(location.state))
    .then((result) => result.json())
        .then((data) => {
            setTop10Trucks(data)
            let t = [];

            for (let i=0; i<data.length; i++) {
                t.push(data[i].TRUCK_BRAND_NAME);
            }
            setTrucks(t);
    })
```

With those changes, the code should be ready to be Dockerized and then deployed in Snowpark Container Services.








<!-- ------------------------ -->

## Containerize the Application
Duration: 5

Now we can prepare the services for deployment, and we will do that by building Docker container images for each service to deploy.

Ensure that you have Docker installed on you environment:

```bash
docker --version
-- Docker version 24.0.6, build ed223bc
```

### Step 6.1 Defining Dockerfiles for services

Each service that we will spin up consists of one or more containers, and each container is built on a Docker image. 

Let's start with the Dockerfile for the backend service. In the `/backend/Dockerfile` we are exposing the port this service is exposed on. By putting it in as a variable `${PORT}` we can set it through the service definition.
```bash
FROM node:18

ARG PORT

WORKDIR /src/app
COPY package.json /src/app/package.json

RUN npm install

ENV PORT=${PORT}
EXPOSE ${PORT}

COPY . /src/app

CMD ["npm", "run", "serve"]
```

Ensure that there is a `.env` file there that will be picked up by the Docker build. It should look like this:
```bash
SNOWFLAKE_WAREHOUSE=TASTY_APP_WAREHOUSE
SNOWFLAKE_DATABASE=FROSTBUTE_TASTY_BYTES
SNOWFLAKE_SCHEMA=APP

ACCESS_TOKEN_SECRET={INSERT A RANDOM STRING HERE}
REFRESH_TOKEN_SECRET={INSERT A RANDOM STRING HERE}

PORT=3000

CLIENT_VALIDATION=Snowflake 
```

The frontend service will contain two containers, so we will have two Dockerfiles, one for each image we are building.

The frontend itself is here `/frontend/frontend/Dockerfile`:
```bash
FROM node:latest

ARG FRONTEND_SERVICE_PORT
ARG REACT_APP_BACKEND_SERVICE_URL

WORKDIR /src/
COPY package.json /src/package.json

RUN npm install

ENV REACT_APP_BACKEND_SERVICE_URL=${REACT_APP_BACKEND_SERVICE_URL}

ENV PORT=${FRONTEND_SERVICE_PORT}
EXPOSE ${FRONTEND_SERVICE_PORT}

COPY ./src /src/src
COPY ./public /src/public

CMD ["npm", "start"]
```
Here we also allow the service to expose a port that is set through an environment variable `${FRONTEND_SERVICE_PORT}`. Additionally we inject the actual URL to the backend, i.e. what is the URL that the frontend is calling when connecting to the backend service, is also a variable `${REACT_APP_BACKEND_SERVICE_URL}`.

The router that accompanies the frontend is built from a simple Dockerfile, `/frontend/router/Dockerfile`:
```bash
FROM nginx:alpine

ARG required FRONTEND_SERVICE
ARG required BACKEND_SERVICE

RUN apk update && apk add bash

EXPOSE 8000

COPY nginx.conf.template /nginx.conf.template

CMD ["/bin/sh" , "-c" , "envsubst '$FRONTEND_SERVICE $BACKEND_SERVICE' < /nginx.conf.template > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'"]
```
The last line is where the `$FRONTEND_SERVICE` and `$BACKEND_SERVICE` variables are replaced into the configuration for the NGINX server.

### Step 6.2 Login to the repo

We need to connect our local Docker to the remote [Image repository](https://docs.snowflake.com/developer-guide/snowpark-container-services/working-with-registry-repository) that we created in Step 4. Start by grabbing the url for the repository by running the following SQL:

```sql
USE DATABASE FROSTBYTE_TASTY_BYTES;
USE SCHEMA APP;
USE ROLE tasty_app_admin_role;

SHOW IMAGE REPOSITORIES;
```
Now copy the value from the `repository_url` for the row for `TASTY_APP_REPOSITORY` (there should only be one row). The URL should look something like this:
```bash
<ACCOUNT_NAME>.registry.snowflakecomputing.com/frostbyte_tasty_bytes/app/tasty_app_repository
```

Open up a terminal now and enter:
```bash
export repo_url=<insert repo url here>
```

The user then you will use to login to this Docker image repository should be a user that is granted the role `tasty_app_admin_role`:
```bash
# Snowflake user name
export admin_user= <your user name>
# login to the repo.  You'll need this for the push later.
docker login ${repo_url} --username ${admin_user}
```
Type in the password for that user when prompted.
```bash
Password: 
Login Succeeded
```

With this, you can now push Docker images to this repository.

### Step 6.3 Build and push up the image

When building and pushing an image to the repo, we do a number of steps to ensure we build the image locally, tag it and then push it to the remote repository. Here is how the backend service is build in the `./build-all.sh` file:

```bash
export image_name=backend_service_image
docker image rm ${image_name}:${tag}
docker build --rm --platform linux/amd64 -t ${image_name}:${tag} ./backend
docker image rm ${repo_url}/${image_name}:${tag}
docker tag ${image_name}:${tag} ${repo_url}/${image_name}:${tag}
docker push ${repo_url}/${image_name}:${tag}
echo ${repo_url}/${image_name}:${tag}
```

Note here that we are specifying to build the image directly for the `linux/amd64` architecture, this is needed for running it on the nodes in the compute pool for Snowpark Container Services. This may not be an image that can then be run on your local system, depending on the CPU architecture on that. It is important that we build it using this flag, otherwise it will not run on SPCS.

We can now build and push all images to the Snowflake repository, from `/src` run:
```bash
./build-all.sh 
```

Once that finishes, you can verify in a Snowflake worksheet that the images have been pushed to the repository:
```sql
call system$registry_list_images('/frostbyte_tasty_bytes/app/tasty_app_repository');
```

The output should be similar to this:
```json
{
   "images":[
      "backend_service_image",
      "frontend_service_image",
      "router_service_image"
   ]
}
```








<!-- ------------------------ -->

## Create the Services
Duration: 5

### Step 7.1 Creating the Service in Snowflake

The services can now be created in Snowflake. Go back to Snowflake and open a worksheet. Enter the following to create the backend service. The `CREATE SERVICE` command creates a new service.

```sql
USE DATABASE FROSTBYTE_TASTY_BYTES;
USE SCHEMA APP;
USE ROLE tasty_app_admin_role;

CREATE SERVICE backend_service
  IN COMPUTE POOL tasty_app_backend_compute_pool
  FROM SPECIFICATION $$
spec:
  container:
  - name: backend
    image: /frostbyte_tasty_bytes/app/tasty_app_repository/backend_service_image:tutorial
    env:
      PORT: 3000
      ACCESS_TOKEN_SECRET: {INSERT A RANDOM STRING HERE}
      REFRESH_TOKEN_SECRET: {INSERT ANOTHER RANDOM STRING HERE}
      CLIENT_VALIDATION: Snowflake
  endpoint:
  - name: apiendpoint
    port: 3000
    public: true
$$
  MIN_INSTANCES=1
  MAX_INSTANCES=1
;
GRANT USAGE ON SERVICE backend_service TO ROLE tasty_app_ext_role;
```
This creates the backend service using the image `backend_service_image:tutorial` that we should now have pushed to the repository. Note how we can supply overriding environment variables to the services.

We also set this service to use the `tasty_app_backend_compute_pool` as the [COMPUTE POOL](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-compute-pool) to run the service on. At the end we can set the scaling behavior of this service in the pool. In order to test this service we don't need any additional scaling setup here, but in a real scenario we may want to increase the number of instances available in case the load on the service goes up.

Lastly we call `GRANT USAGE ON SERVICE` to allow the `tasty_app_ext_role` role and users with that role granted access to the service.

We can then call `SHOW SERVICES` to look at the services created. In order to check the status of the newly created service we can call:
```sql
SELECT SYSTEM$GET_SERVICE_STATUS('backend_service'); 
```
Which will return the status of the service. After a few moments the service should report status `READY` and that it is running:

```json
[
   {
      "status":"READY",
      "message":"Running",
      "containerName":"backend",
      "instanceId":"0",
      "serviceName":"BACKEND_SERVICE",
      "image":"<ACCOUNT_NAME>.registry.snowflakecomputing.com/frostbyte_tasty_bytes/app/tasty_app_repository/backend_service_image:tutorial",
      "restartCount":0,
      "startTime":"<CREATE TIME>"
   }
]
```

We can also look directly at the [logs from the service itself](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-services#accessing-local-container-logs), anything that is written to the standard logging can be retrieved from the service logs:
```sql
CALL SYSTEM$GET_SERVICE_LOGS('backend_service', '0', 'backend', 50);
```

Should show a log looking like this:
```bash
> serve
> node app.js

Starting up Node Express, build version 00014
Server running on port 3000
Environment: development
Client validation: Snowflake
Using warehouse: tasty_app_warehouse
Using role: TASTY_APP_ADMIN_ROLE
```

The frontend service can now be created in a similar fashion. The difference here is that it will contain two different containers, we are using both the image for the router and the frontend React app inside the same service.

```sql
CREATE SERVICE frontend_service
  IN COMPUTE POOL tasty_app_frontend_compute_pool
  FROM SPECIFICATION $$
spec:
  container:
  - name: frontend
    image: /frostbyte_tasty_bytes/app/tasty_app_repository/frontend_service_image:tutorial
    env:    
      PORT: 4000
      FRONTEND_SERVICE_PORT: 4000
      REACT_APP_BACKEND_SERVICE_URL: /api
      REACT_APP_CLIENT_VALIDATION: Snowflake
  - name: router
    image: /frostbyte_tasty_bytes/app/tasty_app_repository/router_service_image:tutorial
    env:
      FRONTEND_SERVICE: localhost:4000
      BACKEND_SERVICE: backend-service:3000
  endpoint:
  - name: routerendpoint
    port: 8000
    public: true
$$
  MIN_INSTANCES=1
  MAX_INSTANCES=1
;
GRANT USAGE ON SERVICE frontend_service TO ROLE tasty_app_ext_role;
```

In the same way we can check the status of the service and read the logs. Note that there are two logs to read, one for each container in the service.
```sql
SELECT SYSTEM$GET_SERVICE_STATUS('frontend_service'); 
CALL SYSTEM$GET_SERVICE_LOGS('frontend_service', '0', 'frontend', 50);
CALL SYSTEM$GET_SERVICE_LOGS('frontend_service', '0', 'router', 50);
```

The log for the `frontend` container in the `frontend_service` should look something like this:
```bash
> tasty_app@0.1.0 start
> react-scripts start
  
Compiled successfully!

You can now view tasty_app in the browser.

  Local:            http://localhost:4000
  On Your Network:  http://10.244.2.15:4000
```

### Step 7.2 Testing the service

We are now finally ready to test the application in a browser. In order to do that we need the public endpoint exposed by the frontend_service. Call `SHOW ENDPOINTS` to retrieve that:

```sql
SHOW ENDPOINTS IN SERVICE frontend_service;
```

The `ingress_url` in the response is the public endpoint URL, it should look similar to this, the first part is randomly generated for each endpoint and service:

```bash
<RANDOM>-<ACCOUNT NAME>.snowflakecomputing.app
```

Now open up that URL in a browser. You will be prompted for a login, and here we can choose any of the users created earlier. You can use `user1` with password `password1`. Note that you will be forced to change this on first login.
![Tasty App UI](./assets/authenticating_with_snowservices_ingress.png)

Once logged in, the application loads the authorization status, and then redirects the user to the logged in `Home` page. After a few moments the data is loaded also and the charts for the current franchise (Franchise 1, if you logged in with user1) is shown. 

![Tasty App UI](./assets/tasty-app-ui.png)

<!-- ------------------------ -->

## Clean up resources
Duration: 1

Once we have tested the application we can tear down any resources that we have created. The following resouces should be removed:

- Services
- Compute Pools
- Warehouses
- Image Repositories
- Database and Schema
- Security Integration (NOTE: this may be used by other services, you can only have one active per ACCOUNT)
- Roles
- Users
- Local Docker images

Open a worksheet in Snowflake and run the following SQL:

```sql
USE DATABASE FROSTBYTE_TASTY_BYTES;
USE SCHEMA APP;
USE ROLE tasty_app_admin_role;

-- Delete services
SHOW SERVICE;
DROP SERVICE BACKEND_SERVICE;
DROP SERVICE FRONTEND_SERVICE;

-- Delete compute pools
SHOW COMPUTE POOLS;
USE ROLE ACCOUNTADMIN;
DROP COMPUTE POOL TASTY_APP_BACKEND_COMPUTE_POOL;
DROP COMPUTE POOL TASTY_APP_FRONTEND_COMPUTE_POOL;

-- Delete warehouses
SHOW WAREHOUSES;
DROP WAREHOUSE LOAD_WH;
DROP WAREHOUSE QUERY_WH;
DROP WAREHOUSE TASTY_APP_WAREHOUSE;

-- Delete the Image repository
USE ROLE tasty_app_admin_role;
SHOW IMAGE REPOSITORIES;
DROP IMAGE REPOSITORY TASTY_APP_REPOSITORY;

-- Delete the database
USE ROLE ACCOUNTADMIN;
SHOW DATABASES;
DROP DATABASE FROSTBYTE_TASTY_BYTES;

-- Delete the OAuth security integration
USE ROLE tasty_app_admin_role;
SHOW SECURITY INTEGRATIONS;
DROP SECURITY INTEGRATION "Application Authentication";

-- Delete the roles
USE ROLE ACCOUNTADMIN;
SHOW ROLES;
DROP ROLE TASTY_APP_ADMIN_ROLE;
DROP ROLE TASTY_APP_EXT_ROLE;

-- Delete the users
SHOW USERS;
DROP USER USER1;
DROP USER USER2;
DROP USER USER3;
```

From a terminal, we can now also remove the built images:
```bash
docker image prune --all
```

> aside negative
>
> Warning, the above removes _all_ unused Docker images. If you have other Docker images that you don't want to remove, then manually remove the images created in this guide using `docker image rm <IMAGE NAME>`.








<!-- ------------------------ -->

## Conclusion and Resources

Good work! You have now successfully built, deployed and run a data application on Snowpark Container Services.

You now have gone through the basic concepts of building a a Data Application that can run directly on Snowflake, we have looked through how to adapt existing code to cover:
- Authentication and Authorization and user management
- Public endpoints for service
- Service to service communication
- Services connecting to Snowflake accounts

Using this you should be able to build your own Data Application and run it direclty on Snowpark Container Services, directly connected to your data.

We would love your feedback on this QuickStart Guide! Please submit your feedback using this Feedback Form.

### What You Learned

### Related Resources
- [Source Code on GitHub](https://github.com/Snowflake-Labs/sfguide-tasty-bytes-zero-to-app-with-spcs)
- [Snowpark Container Services documentation](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview)
- [Snowpark Container Services tutorials](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview-tutorials)
- [Quickstart: Build a Data App with Snowflake](https://quickstarts.snowflake.com/guide/build_a_data_app_with_snowflake)

<!-- ------------------------ -->

author: Daniel Myers
id: getting_started_with_native_apps
summary: Follow this tutorial to get up and running with your first Snowflake Native Application
categories: Getting-Started
environments: web
status: Published 
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Data Science, Data Engineering, Native Apps 

# Getting Started with Snowflake Native Apps
<!-- ------------------------ -->
## Overview 
Duration: 3

> aside negative
> 
> **Important**
> Snowflake Native Apps are currently not supported in Google Cloud Platform.  Ensure your Snowflake deployment or trial account uses AWS or Azure as the cloud provider.

![Native Apps Framework](assets/app_framework.png)

In this Quickstart, you'll build your first Snowflake Native Application. 

Snowflake Native Applications provide developers a way to package applications for consumption by other Snowflake users. The Snowflake Marketplace is a central place for Snowflake users to discover and install Snowflake Native Applications. 

 The application you'll build will visualize data from suppliers of raw material, used for inventory and supply chain management. Let's explore the application from the perspective of the application provider and an application consumer.

– **Provider** – In this Quickstart, the provider of the app is a supply chain management company. They have proprietary data on all sorts of shipments. They've built the app, bundled it with access to their shipping data, and listed it on the Snowflake Marketplace so that manufacturers can use it in combination with manufacturing supply chain data to get a view of the supply chain.

– **Consumer** – The consumer of the app manufactures a consumer product – in this case it's ski goggles. They work with several suppliers of the raw material used to manufacture the ski goggles. When the consumer runs the application in their account, the application will render multiple charts to help them visualize information related to:

- **Lead Time Status** The lead time status of the raw material procurement process.
- **Raw Material Inventory** Inventory levels of the raw materials. 
- **Purchase Order Status** The status of all the purchase orders (shipped, in transit; completed)
- **Supplier Performance** The performance of each raw material supplier, measured in terms lead time, quality, and cost of raw materials delivered by the supplier.

The data powering the charts is a combination of the consumer's own supply chain data (orders and site recovery data) in their Snowflake account, while the provider is sharing shipping data to provide an enriched view of the overall supply chain.

Note that this Quickstart is limited to a single-account installation. You'll use a single Snowflake account to experience the app from the provider's perspective and from the consumer's perspective. Listing to the Snowflake Marketplace and versions / release directives are outside of the scope of this guide.

Let's get started!

![streamlit](assets/streamlit.png)

### Prerequisites
- Snowflake trial account on AWS
- Beginner Python knowledge

> aside negative
> 
> **Important**
> Snowflake Native Apps are currently only available on AWS.  Ensure your Snowflake deployment or trial account uses AWS as the cloud provider. Native Apps will be available on other major cloud providers soon.

### What You’ll Learn 
- Snowflake Native App Framework
- Snowflake Native App deployment
- Snowflake Native App sharing and Marketplace Listing


### What You’ll Need 
- [VSCode](https://code.visualstudio.com/download) Installed
- [Snowflake CLI](https://docs.snowflake.com/developer-guide/snowflake-cli-v2/installation/installation) Latest version Installed

### What You’ll Build 
- A Snowflake Native Application

<!-- ------------------------ -->
## Architecture & Concepts
Duration: 2

Snowflake Native Apps are a new way to build data intensive applications. Snowflake Native Apps benefit from running *inside* Snowflake and can be installed from the Snowflake Marketplace, similar to installing an app on a smart phone. Snowflake Native Apps can read and write data to a user's database (when given permission to do so). Snowflake Native Apps can even bring in new data to their users, providing new insights. 

When discussing Snowflake Native Apps, there are two personas to keep in mind: **Providers** and **Consumers**.

- **Providers:** Developers of the app. The developer or company publishing an app to the Snowflake Marketplace is an app provider.

- **Consumer:** Users of an app. When a user installs an app from the Snowflake Marketplace, they are a consumer of the app.

The diagram below demonstrates this model:
 
![diagram](assets/deployment.png)

<!-- ------------------------ -->
## Clone Sample Repo & Directory Structure
Duration: 3

To create our Snowflake Native Application, we will first clone the [starter project](https://github.com/Snowflake-Labs/sfguide-getting-started-with-native-apps) by running this command:

```bash
git clone git@github.com:Snowflake-Labs/sfguide-getting-started-with-native-apps.git
```
This command is going to create an application project folder on your local machine, cloned from the github repo.

If you do not have Snowflake CLI or Git installed, you can also download the code directly from [GitHub](https://github.com/Snowflake-Labs/sfguide-getting-started-with-native-apps/archive/refs/heads/main.zip) and extract it to a local folder.

This repository contains all of our starter code for our native app. Throughout the rest of this tutorial we will be modifying various parts of the code to add functionality and drive a better understanding of what is happening at each step in the process.


Let's explore the directory structure:

```plaintext
|-- repos
    |-- .gitignore
    |-- LICENSE
    |-- app
        |-- data
        |   |-- order_data.csv
        |   |-- shipping_data.csv
        |   |-- site_recovery_data.csv
        |-- src
        |   |-- manifest.yml
        |   |-- setup.sql
        |   |-- libraries
        |   |   |-- environment.yml
        |   |   |-- procs.py
        |   |   |-- streamlit.py
        |   |   |-- udf.py
    |-- scripts
    |   |-- setup-package-script.sql
    |-- prepare_data.sh
    |-- snowflake.yml
```

There `src` directory is used to store all of our various source code including stored procedures, user defined functions (UDFs), our streamlit application, and even our installation script `setup.sql`.


<!-- ------------------------ -->
## Upload Necessary Data
Duration: 2

### Upload provider shipping data 

Now, let's create a database that we will use to store provider's shipping data. This is the data that we will share with the application so that the consumer can enrich their own supply chain data with it when they install the app in their account.

This commands are run by executing the **prepare_data.sh** file. But first we are going to explain its contents.

First the file creates the database, warehouse, schema, and defines the table that will hold the shipping data.

```
snow sql -q "
CREATE OR REPLACE WAREHOUSE NATIVE_APP_QUICKSTART_WH WAREHOUSE_SIZE=SMALL INITIALLY_SUSPENDED=TRUE;

-- this database is used to store our data
CREATE OR REPLACE DATABASE NATIVE_APP_QUICKSTART_DB;
USE DATABASE NATIVE_APP_QUICKSTART_DB;

CREATE OR REPLACE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;
USE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;

CREATE OR REPLACE TABLE MFG_SHIPPING (
  order_id NUMBER(38,0), 
  ship_order_id NUMBER(38,0),
  status VARCHAR(60),
  lat FLOAT,
  lon FLOAT,
  duration NUMBER(38,0)
);"
```

### Upload Consumer Supply Chain Data

In this scenario, consumers will provide their own supply chain data (orders and site recovery data) from their own Snowflake account. The app will use the consumer's data to render graphs representing different aspects of the supply chain.

We'll use the `NATIVE_APP_QUICKSTART_DB` to store the consumer supply chain data.

```
snow sql -q "
USE WAREHOUSE NATIVE_APP_QUICKSTART_WH;

-- this database is used to store our data
USE DATABASE NATIVE_APP_QUICKSTART_DB;

USE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;

CREATE OR REPLACE TABLE MFG_ORDERS (
  order_id NUMBER(38,0), 
  material_name VARCHAR(60),
  supplier_name VARCHAR(60),
  quantity NUMBER(38,0),
  cost FLOAT,
  process_supply_day NUMBER(38,0)
);


CREATE OR REPLACE TABLE MFG_SITE_RECOVERY (
  event_id NUMBER(38,0), 
  recovery_weeks NUMBER(38,0),
  lat FLOAT,
  lon FLOAT
);"
```

Once we have created the necessary tables in the provider and consumer side, the next step is to load the csv files to the corresponding tables.
A stage is available and directly linked to every table created in Snowflake,  so we are going to take advantage of that dedicated stage and upload the files directly to the table associated stage. You can find more information about stages types **[here](https://docs.snowflake.com/en/user-guide/data-load-overview)**
That is accomplished using the `snow stage copy` command:

```bash
# loading shipping data into table stage
snow stage copy ./app/data/shipping_data.csv @%MFG_SHIPPING --database NATIVE_APP_QUICKSTART_DB --schema NATIVE_APP_QUICKSTART_SCHEMA

# loading orders data into table stage
snow stage copy ./app/data/order_data.csv @%MFG_ORDERS --database NATIVE_APP_QUICKSTART_DB --schema NATIVE_APP_QUICKSTART_SCHEMA

# loading site recovery data into table stage
snow stage copy ./app/data/site_recovery_data.csv @%MFG_SITE_RECOVERY --database NATIVE_APP_QUICKSTART_DB --schema NATIVE_APP_QUICKSTART_SCHEMA
```

Now the data is in the table stage, but its not yet loaded inside the table, for that, the following commands are run in the file:

```
snow sql -q"USE WAREHOUSE NATIVE_APP_QUICKSTART_WH;
-- this database is used to store our data
USE DATABASE NATIVE_APP_QUICKSTART_DB;

USE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;

COPY INTO MFG_SHIPPING
FILE_FORMAT = (TYPE = CSV
FIELD_OPTIONALLY_ENCLOSED_BY = '\"');

COPY INTO MFG_ORDERS
FILE_FORMAT = (TYPE = CSV
FIELD_OPTIONALLY_ENCLOSED_BY = '\"');

COPY INTO MFG_SITE_RECOVERY
FILE_FORMAT = (TYPE = CSV
FIELD_OPTIONALLY_ENCLOSED_BY = '\"');
"
```

## Share the Provider Shipping Data
Duration: 2

In order for this data to be available to the application consumer, we'll need to share it in the application package via reference usage.

The following steps are performed by the **setup-package-script.sql** file, which is automatically run whenever we deploy the application:

- Creates a schema in the application package that will be used for sharing the shipping data

- Create a view within that schema

- Grants usage on the schema to the application package

- Grants reference usage on the database holding the provider shipping data to the application package

- Grants SELECT privileges on the view to the application package, meaning the app will be able to SELECT on the view once it is installed

```sql
-- ################################################################
-- Create SHARED_CONTENT_SCHEMA to share in the application package
-- ################################################################
use database NATIVE_APP_QUICKSTART_PACKAGE;
create schema shared_content_schema;

use schema shared_content_schema;
create or replace view MFG_SHIPPING as select * from NATIVE_APP_QUICKSTART_DB.NATIVE_APP_QUICKSTART_SCHEMA.MFG_SHIPPING;

grant usage on schema shared_content_schema to share in application package NATIVE_APP_QUICKSTART_PACKAGE;
grant reference_usage on database NATIVE_APP_QUICKSTART_DB to share in application package NATIVE_APP_QUICKSTART_PACKAGE;
grant select on view MFG_SHIPPING to share in application package NATIVE_APP_QUICKSTART_PACKAGE;
```

This flow ensures that the data is able to be shared securely with the consumer through the application. The objects containing the provider's proprietary shipping data are **never** shared directly with the consumer via a Snowflake Native Application. This means the provider's proprietary data remains safe, secure, and in the provider's Snowflake account. Instead, the application package has reference usage on objects (databases) corresponding to the provider's data, and when a consumer install the app (i.e., instantiates the application package), they are able to use the shared data through the application.

<!-- ------------------------ -->
## Manifest.yml
Duration: 3

The `manifest.yml` file is an important aspect of a Snowflake Native App. This file defines some metadata about the app, configuration options, and provides references to different artifacts of the application.

Let's take a look at the one provided in the GitHub repository:

```
#version identifier
manifest_version: 1

version:
  name: V1
  label: Version One
  comment: The first version of the application

#artifacts that are distributed from this version of the package
artifacts:
  setup_script: scripts/setup.sql
  default_streamlit: app_instance_schema.streamlit
  extension_code: true

#runtime configuration for this version
configuration:
  log_level: debug
  trace_level: off

references:
  - order_table:
      label: "Orders Table" 
      description: "Select table"
      privileges:
        - SELECT
      object_type: Table 
      multi_valued: false 
      register_callback: app_instance_schema.update_reference 
  - site_recovery_table:
      label: "Site Recovery Table" 
      description: "Select table"
      privileges:
        - SELECT
      object_type: Table 
      multi_valued: false 
      register_callback: app_instance_schema.update_reference

```

`manifest_version`

- this is the Snowflake defined manifest file version. If there are new configuration options or additions, the version number will change.

`version`

- this is a user-defined version for the application. This version identifier is used when creating the app package.

`artifacts`

- this contains options and definitions for where various parts of our package is located. In particular the `setup_script` option is required.

`configuration`

- this is used to define what logging we want to use in our application. During development we will want a log level of `debug`. 

`references`

-  this part of the manifest file contains all the references to Snowflake objects that the Native App needs access to. The Native App Consumer will grant access to the objects when installing or using the application. We will use this in our native app to gain access to the `order_table` and `site_recovery_table`. 

<!-- ------------------------ -->
## Installation Script
Duration: 3

The installation script **setup.sql** defines all Snowflake objects used within the application. This script runs every time a user installs the application into their environment. 

```
-- ==========================================
-- This script runs when the app is installed 
-- ==========================================

-- Create Application Role and Schema
create application role if not exists app_instance_role;
create or alter versioned schema app_instance_schema;

-- Share data
create or replace view app_instance_schema.MFG_SHIPPING as select * from shared_content_schema.MFG_SHIPPING;

-- Create Streamlit app
create or replace streamlit app_instance_schema.streamlit from '/libraries' main_file='streamlit.py';

-- Create UDFs
create or replace function app_instance_schema.cal_lead_time(i int, j int, k int)
returns float
language python
runtime_version = '3.8'
packages = ('snowflake-snowpark-python')
imports = ('/libraries/udf.py')
handler = 'udf.cal_lead_time';

create or replace function app_instance_schema.cal_distance(slat float,slon float,elat float,elon float)
returns float
language python
runtime_version = '3.8'
packages = ('snowflake-snowpark-python','pandas','scikit-learn==1.1.1')
imports = ('/libraries/udf.py')
handler = 'udf.cal_distance';

-- Create Stored Procedure
create or replace procedure app_instance_schema.billing_event(number_of_rows int)
returns string
language python
runtime_version = '3.8'
packages = ('snowflake-snowpark-python')
imports = ('/libraries/procs.py')
handler = 'procs.billing_event';

create or replace procedure app_instance_schema.update_reference(ref_name string, operation string, ref_or_alias string)
returns string
language sql
as $$
begin
  case (operation)
    when 'ADD' then
       select system$set_reference(:ref_name, :ref_or_alias);
    when 'REMOVE' then
       select system$remove_reference(:ref_name, :ref_or_alias);
    when 'CLEAR' then
       select system$remove_all_references();
    else
       return 'Unknown operation: ' || operation;
  end case;
  return 'Success';
end;
$$;

-- Grant usage and permissions on objects
grant usage on schema app_instance_schema to application role app_instance_role;
grant usage on function app_instance_schema.cal_lead_time(int,int,int) to application role app_instance_role;
grant usage on procedure app_instance_schema.billing_event(int) to application role app_instance_role;
grant usage on function app_instance_schema.cal_distance(float,float,float,float) to application role app_instance_role;
grant SELECT on view app_instance_schema.MFG_SHIPPING to application role app_instance_role;
grant usage on streamlit app_instance_schema.streamlit to application role app_instance_role;
grant usage on procedure app_instance_schema.update_reference(string, string, string) to application role app_instance_role;
```

<!-- ------------------------ -->
## Create App Package
Duration: 2

A Snowflake Application Package is conceptually similar to that of an application installer for a desktop computer (like `.msi` for Windows or `.pkg` for Mac). An app package for Snowflake contains all the material used to install the application later, including the setup scripts. In fact, we will be using this app package in future steps to test our app!

Now that we've understood our project files, lets create the Snowflake Application Package so we can upload our project:

To create an application package you can go through the manual UI process or you can run:


```
snow app run
```

>aside negative
>
> This code is going to actually create the entire application, not only the application package.
<!-- ------------------------ -->
## Update UDF.py
Duration: 3

To add some new functionality to our application we will modify **UDF.py**. This is the Python file we use to create all our User Defined Functions (UDFs).

```python
def cal_distance(lat1,lon1,lat2,lon2):
   import math
   radius = 3959 # miles == 6371 km
   dlat = math.radians(lat2-lat1)
   dlon = math.radians(lon2-lon1)
   a = math.sin(dlat/2) * math.sin(dlat/2) + math.cos(math.radians(lat1)) \
        * math.cos(math.radians(lat2)) * math.sin(dlon/2) * math.sin(dlon/2)
   c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
   d = radius * c
   return dw

# process_supply_day + duration + recovery_weeks * 7 (days)
def cal_lead_time(i,j,k):
   return i + j + k

```

> aside positive
> 
> You can import any package in the `https://repo.anaconda.com/pkgs/snowflake` channel from [Anaconda](https://docs.conda.io/en/latest/miniconda.html)

Let's add a new function that simply outputs "Hello World!"

To do this, copy and paste the code below into **UDF.py**:

```python
def hello_world():
   return "Hello World!"
```

In the next step, we will expose this function to Consumers by adding it to our installation script.

<!-- ------------------------ -->
## Update Installation Script
Duration: 3


Let's add the following code snippet to our `setup.sql` script so we can use the python function we created in the previous step:

```python
create or replace function app_instance_schema.hello_world()
returns string
language python
runtime_version = '3.8'
packages = ('snowflake-snowpark-python')
imports = ('/libraries/udf.py')
handler = 'udf.hello_world';

grant usage on function app_instance_schema.hello_world() to application role app_instance_role;
```

<!-- ------------------------ -->
## Create App Package Version
Duration: 4

We've now added some basic functionality to the native app. From here, we will create the first version of our application package. You can have multiple versions available. 

To create a version in our application package, execute the following command:

```
snow app version create V1
```

Executing this command will create a version `V1` in our application package.
You can explicitly number the patch by adding `--patch <number>` as an argument to `snow app version create`. Because this version does not yet exist and because we did not specify the patch number, the system is going to add our code as patch 0 in this version.

As explained before, you can also set the version information inside of manifest.yml. In that case, running `snow app version create` without any arguments will automatically use that version. It would look something like this:

```
version:
  name: V1
  label: Version One
  comment: The first version of the application
```


<!-- ------------------------ -->
## Install the Application
Duration: 3

To use the application, we'll first need to install it in the account. Normally you would click an install button in the Snowflake Marketplace, but since we're building the application and using a single account to demonstrate the provider and consumer experiences, you'll run the same `snow app run` CLI command as we mentioned before. This command creates and/or updates the application package and also deploys the application. If you'd like to instead install the application yourself, you can do so like this:

```
-- ################################################################
-- INSTALL THE APP IN THE ACCOUNT
-- ################################################################

USE DATABASE NATIVE_APP_QUICKSTART_DB;
USE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;
USE WAREHOUSE NATIVE_APP_QUICKSTART_WH;

-- This executes "setup.sql"; This is also what gets executed when installing the app
CREATE APPLICATION NATIVE_APP_QUICKSTART_APP FROM application package NATIVE_APP_QUICKSTART_PACKAGE using version V1 patch 0;
```

When it finishes running, it is going to show you a link to open the app directly. Alternatively, you can see the NATIVE_APP_QUICKSTART_APP listed under Apps in the UI.

<!-- ------------------------ -->
## Run the Streamlit App
Duration: 1

Click on the app to launch it and give it a few seconds to warm up. 

When running the app for the first time, you'll be prompted to do some first-time setup by granting the app access to certain tables (i.e., create object-level bindings). The bindings link references defined in the manifest file to corresponding objects in the Snowflake account. These bindings ensure that the application can run as intended.

Upon running the application, you will see this:

![streamlit](assets/streamlit.png)

### Teardown

To delete the application you just created, you can run this command:

`snow app teardown`

And to delete the database you used to populate the application, this command will do:

`snow sql -q "DROP DATABASE NATIVE_APP_QUICKSTART_DB"`

<!-- ------------------------ -->
## Conclusion & Next Steps
Duration: 1

Congratulations, you have now developed your first Snowflake Native Application! As next steps and to learn more, checkout additional documentation at [docs.snowflake.com](https://docs.snowflake.com) and demos of other Snowflake Native Apps at [developers.snowflake.com/solutions](https://developers.snowflake.com/solutions/?_sft_technology=native-apps).

For a slightly more advanced Snowflake Native Application, see the following Quickstart: [Build a Snowflake Native App to Analyze Chairlift Sensor Data](https://quickstarts.snowflake.com/guide/native-app-chairlift/#0).

### Additional resources

- [Snowflake Native App Developer Toolkit](https://www.snowflake.com/snowflake-native-app-developer-toolkit/?utm_cta=na-us-en-eb-native-app-quickstart)
- [Native Apps Examples](https://github.com/snowflakedb/native-apps-examples)

### What we've covered
- Prepare data to be included in your application.
- Create an application package that contains the data and business logic of your application.
- Share data with an application package.
- Add business logic to an application package.
- View and test the application in Snowsight.

# Example Native App with Snowpark Container Services

This is a simple three-tiered web app that can be deployed
in Snowpark Container Services. It queries the TPC-H 100 
data set and returns the top sales clerks. The web app
provides date pickers to restrict the range of the sales
data and a slider to determine how many top clerks to display.
The data is presented in a table sorted by highest seller
to lowest.

This app was built with 3 containers:
* Frontend written in JavaScript using the Vue framework
* Backend written in Python using the Flask framework
* Router using nginx to allow the Frontend and Backend to 
  be on the same URL and avoid CORS issues.

This app is deployed as 2 separate `SERVICE`s:
* The Frontend and Router containers are deployed in one service.
* The Backend container is deployed in its own service.

The reason to split them this way is so that the Frontend and 
Backend can autoscale differently. Moreover, you could deploy
the Frontend and Backend to different `COMPUTE POOL`s, which would
support the case where the Backend needs more compute power than 
the Frontend, which is typically pretty light.

## Getting Started

### Prerequisites

1. Install Docker
    - [Windows](https://docs.docker.com/desktop/install/windows-install/)
    - [Mac](https://docs.docker.com/desktop/install/mac-install/)
    - [Linux](https://docs.docker.com/desktop/install/linux-install/)

2. Setup connection

    Before running the **setup.sh** file you should run the following command to set a snowflake default connection by choosing it from your config.toml file.

    ```bash
    export SNOWFLAKE_DEFAULT_CONNECTION_NAME=<your_connection>
    ```

    Replacing `<your_connection>` with you actual connection name, without the `<>`.

### Setup

Execute the shell script named `setup.sh` in the root folder:

```bash
./setup.sh
```

The setup script runs the following scripts:

- Snowpark Container Services setup (`spcs_setup.sql`)
- Provider side setup (`provider_setup.sql`)
- Consumer side setup (`consumer_setup.sql`)
- Image repository setup by executing `make all` command

### Deploy application package

Run the following command in your opened terminal:

```bash
./deploy.sh
```
This bash file performs two operations:

- `snow app run`
- Creates a reference to the `orders` view.

For this command to function, your shell must be in the same directory as `snowflake.yml` (the project root).

### Run application

When you enter the application UI for the first time, an initial setup screen will appear:

#### Step 1: Grant Account Privileges

This step allows the application to bind `SERVICE ENDPOINT`s and create `COMPUTE POOL`s. Click the `Grant` button to grant these privileges on the account to the application object.

#### Step 2: Allow Connections

The second step creates a new `EXTERNAL ACCESS INTEGRATION` targeting the `upload.wikimedia.org` website. Click on `Review`, then on `Connect`.

#### Activate the application

Once all the steps are completed, you can activate the application by clicking the `Activate` button. When the button is clicked, the `grant_callback` defined in the [manifest.yml](app/manifest.yml) is executed.
In this example, our callback creates two `COMPUTE POOL`s in the account and two `SERVICE`s inside of the application object.

#### Launch Application

Once all these dependencies have been met, you can launch the app by clicking on the `Launch App` button. A new window will be displayed with the URL provided by the service and endpoint defined by `default_web_endpoint` in the [manifest.yml](app/manifest.yml).

#### Cleanup
To clean up the Native App test install, you can execute `cleanup.sh`, which will stop the services and run `snow app teardown`:

```bash
./cleanup.sh
```

### Publishing / Sharing your Native App
Your Native App is now ready on the Provider Side. You can make the Native App available
for installation in other Snowflake Accounts by creating a version and release directive, then setting
the default patch and Sharing the App in the Snowsight UI.

See the [documentation](https://other-docs.snowflake.com/en/native-apps/provider-publishing-app-package) for more information.

1. Navigate to the "Apps" tab and select "Packages" at the top.

2. Now click on your App Package (`NA_SPCS_PYTHON_PKG`).

3. From here you can click on "Set release default" and choose the latest patch (the largest number) for version `v1`. 

4. Next, click "Share app package". This will take you to the Provider Studio.

5. Give the listing a title, choose "Only Specified Consumers", and click "Next".

6. For "What's in the listing?", select the App Package (`NA_SPCS_PYTHON_PKG`). Add a brief description.

7. Lastly, add the Consumer account identifier to the "Add consumer accounts".

8. Click "Publish".

### Debugging
There are some Stored Procedures to allow the Consumer to see the status
and logs for the containers and services. These procedures are granted to the `app_admin`
role and are in the `app_public` schema:
* `GET_SERVICE_STATUS()` which takes the same arguments and returns the same information as `SYSTEM$GET_SERVICE_STATUS()`
* `GET_SERVICE_LOGS()` which takes the same arguments and returns the same information as `SYSTEM$GET_SERVICE_LOGS()`

The permissions to debug are managed on the Provider in the 
`NA_SPCS_PYTHON_PKG.SHARED_DATA.FEATURE_FLAGS` table. 
It has a very simple schema:
* `acct` - the Snowflake account to enable. This should be set to the value of `SELECT current_account()` in that account.
* `flags` - a VARIANT object. For debugging, the object should have a field named `debug` which is an 
  array of strings. These strings enable the corresponding stored procedure:
  * `GET_SERVICE_STATUS`
  * `GET_SERVICE_LOGS`

An example of how to enable logging for a particular account (for example, account 
`ABC12345`) to give them all the debugging permissions would be

```sql
INSERT INTO llama2_pkg.shared_data.feature_flags 
  SELECT parse_json('{"debug": ["GET_SERVICE_STATUS", "GET_SERVICE_LOGS"]}') AS flags, 
         'ABC12345' AS acct;
```

To enable on the Provider account for use while developing on the Provider side, you could run

```sql
INSERT INTO llama2_pkg.shared_data.feature_flags 
  SELECT parse_json('{"debug": ["GET_SERVICE_STATUS", "GET_SERVICE_LOGS"]}') AS flags,
         current_account() AS acct;
```

# External Access Integration

This Snowflake Native Application sample demonstrates how to add external access integrations as references within a native application.

## Getting Started

This application shows a line chart based on the price timeline of each crypto coin by accessing the [Coincap API](https://docs.coincap.io/) that provides the price timeline in real time of each coin in the market.

To connect to the API, the native application creates a secure connection by creating an [External Access Integration](https://docs.snowflake.com/en/sql-reference/sql/create-external-access-integration) from the application to the external API.

The setup script contains some key steps to pay attention to:

- Define an EAI reference in the [manifest.yml](app/manifest.yml).
- Define a `configuration_callback` and `register_callback` in the [setup](app/setup_script.sql) script file.
- Define a stored procedure that creates `function` or `stored procedure` objects binding the EAI reference after it is set.

### Installation

Execute the following command:

```bash
snow app run
```

### First-time setup

You must bind a reference before using the app:

   - *external_access_reference:* The EAI reference will create a [NETWORK RULE](https://docs.snowflake.com/en/sql-reference/sql/create-network-rule) and an External Access Integration with the `json` defined in the `configuration_callback`.

> These references and permissions are defined in [manifest.yml](app/manifest.yml).

Once the EAI reference is created, you can continue to the app by clicking the button. Before the app is loaded, the `create_eai_objects` is called, and creates two new procedures that uses the EAI created to get data from the API.

### Test the app

When you continue to the app, you must see two different controls:

- A date picker that select a date range.
- A select box that contains all the crypto coin names.

The date picker selects the range on where you want to get the price timeline of the choosen coin in the select box and the select box choose the coin which you want to see the price timeline.

When you change the values from both controls, the line chart below will be refreshed with the new information.

### Additional Resources

- [Grant access to a Snowflake Native App](https://other-docs.snowflake.com/en/native-apps/consumer-granting-privs)
- [Create a user interface to request privileges and references](https://docs.snowflake.com/en/developer-guide/native-apps/requesting-ui)
- [CREATE EXTERNAL ACCESS INTEGRATION](https://docs.snowflake.com/en/sql-reference/sql/create-external-access-integration)
- [CREATE NETWORK RULE](https://docs.snowflake.com/en/sql-reference/sql/create-network-rule)

# Reference Usage

This Snowflake Native Application sample demonstrates how to share a provider table with a native application whose data is replicated to any consumer in the data cloud.

## Getting Started

In this application, you will see how to add readonly access to a provider table using the [shared-content.sql](scripts/shared-content.sql) of a package script by using an intermediate view. For more information, see "How does the package script work?" below.

### Prepare objects in account

Make sure you already have a warehouse and it is used in the current connection. If not, you can create one with the following command, then set it in your `connections.toml` file:

```sql
CREATE WAREHOUSE IF NOT EXISTS provider_warehouse;
```

Execute the [setup.sql](prepare/setup.sql) file as the `ACCOUNTADMIN` role. This script sets up the table that is going to be shared:

```bash
snow sql -f 'prepare/provider.sql'
```

### Installation

Execute the following command, which deploys the application package, runs the package script, then creates an instance of the application in your configured Snowflake account:

```bash
snow app run
```

### Test the app

When you are inside the app, you will see a dataframe with the values of the provider table that were inserted before installing the application. You can modify the table's data as desired, and the changes will be reflected here. If you were to list this application on the Snowflake Marketplace, changes will also reflect in application objects installed in consumer accounts!

### How does the package script work?

As mentioned previously, the package script works by creating an intermediate view in a schema that exists on the application package, then sharing that schema and view "through" the application object. By doing so, the schema and view are available to the running application and its setup script. In [shared-content.sql](scripts/shared-content.sql), we have the following to create the view:

```sql
create view if not exists package_shared.view_shared
  as select * from reference_usage_app_sample.provider_schema.provider_table;
```

After the view has been created, we share it in the application package:

```sql
grant select on view package_shared.view_shared
  to share in application package {{ package_name }};
```

To work, this "package script" must be referenced by the [snowflake.yml](snowflake.yml) file. This file uses Jinja templating to interpolate in the resolved name of the application package object that Snowflake CLI creates when you deploy the app.

The script is then run every time you (re-)deploy your application, meaning it is important that it is written in an idempotent fashion. Avoid constructs like `CREATE OR REPLACE`!

### Additional Resources

- [Add shared data content to an application package](https://docs.snowflake.com/en/developer-guide/native-apps/preparing-data-content)

About the Snowflake Native App Framework
Feature — Generally Available

The Snowflake Native App Framework is generally available on supported cloud platforms. For additional information, see Support for private connectivity, VPS, and government regions.

This topic provides general information about the Snowflake Native App Framework.

Introduction to the Snowflake Native App Framework
The Snowflake Native App Framework allows you to create data applications that leverage core Snowflake functionality. The Snowflake Native App Framework allows you to:

Expand the capabilities of other Snowflake features by sharing data and related business logic with other Snowflake accounts. The business logic of an application can include a Streamlit app, stored procedures, and functions written using Snowpark API, JavaScript, and SQL.

Share an application with consumers through listings. A listing can be either free or paid. You can distribute and monetize your apps in the Snowflake Marketplace or distribute them to specific consumers using private listings.

Include rich visualizations in your application using Streamlit.

The Snowflake Native App Framework also supports an enhanced development experience that provides:

A streamlined testing environment where you can test your applications from a single account.

A robust developer workflow. While your data and related database objects remain within Snowflake, you can manage supporting code files and resources within source control using your preferred developer tools.

The ability to release versions and patches for your application that allows you, as a provider, to change and evolve the logic of your applications and release them incrementally to consumers.

Support for logging of structured and unstructured events so that you can troubleshoot and monitor your applications.

Components of the Snowflake Native App Framework
The following diagram shows a high-level view of the Snowflake Native App Framework.

../../_images/native-apps-overview.png
The Snowflake Native App Framework is built around the concept of provider and consumer used by other Snowflake features, including Snowflake Collaboration and Secure Data Sharing

Provider
A Snowflake user who wants to share data content and application logic with other Snowflake users.

Consumer
A Snowflake user who wants to access the data content and application logic shared by providers.

Develop and Test an Application Package
To share data content and application logic with a consumer, providers create an application package.

Application package
An application package encapsulates the data content, application logic, metadata, and setup script required by an application. An application package also contains information about versions and patch levels defined for the application. See Create an application package for details.

An application package can include references to data content and external code files that a provider wants to include in the application. An application package requires a manifest file and a setup script.

Manifest file
Defines the configuration and setup properties required by the application, including the location of the setup script, versions, etc. See Create the manifest file for an application package for details.

Setup script
Contains SQL statements that are run when the consumer installs or upgrades an application or when a provider installs or upgrades an application for testing. The location of the setup script is specified in the manifest.yml file. See Create a setup script for details.

Publish an Application Package
After developing and testing an application package, a provider can share an application with consumers by publishing a listing containing the application package as the data product of a listing. The listing can be a Snowflake Marketplace listing or a private listing.

Snowflake Marketplace listing
Allows providers to market applications across the Snowflake Data Cloud. Offering a listing on the Snowflake Marketplace lets providers share applications with many consumers simultaneously, rather than maintain sharing relationships with each individual consumer.

Private listing
Allows providers to take advantage of the capabilities of listings to share applications directly with another Snowflake account in any Snowflake region supported by the Snowflake Native App Framework.

See About Listings for details.

Install and Manage an Application
After a provider publishes a listing containing an application package, consumers can discover the listing and install the application.

Snowflake Native App
A Snowflake Native App is the database object installed in the consumer account. When a consumer installs the Snowflake Native App, Snowflake creates the application and runs the setup script to create the required objects within the application. See Install and test an app locally for details.

After installing the application, consumers can perform additional tasks, including:

Enable logging and event sharing to help providers troubleshoot the application.

Grant privileges required by the application.

See Working with Applications as a Consumer for details on how consumers install and manage an application.

About Snowflake Native Apps with Snowpark Container Services
A Snowflake Native App with Snowpark Container Services (app with containers) is a Snowflake Native App that runs container workloads in Snowflake. Container apps can run any containerized service supported by Snowpark Container Services.

Apps with containers leverage all of the features of the Snowflake Native App Framework, including provider IP protection, security and governance, data sharing, monetization, and integration with compute resources.

Like any Snowflake Native App, an app with containers is comprised of an application package and application object. However, there are some differences as shown in the following image:

../../_images/na-spcs-overview.png
Application package:
To manage containers, the application package must have access to a services specification file on a stage. Within this file, there are references to the container images required by the app. These images must be stored in an image repository in the provider account.

Application object:
When a consumer installs an app with containers, the application object that is created contains a compute pool that stores the containers required by the app.

Compute pool:
A compute pool is a collection of one or more virtual machine (VM) nodes on which Snowflake runs your Snowpark Container Services jobs and services. When a consumer installs an app with containers, they can grant the CREATE COMPUTE POOL privilege to the app or they can create the compute pools manually.

Protect provider intellectual property in an app with containers
When an app with containers is installed in the consumer account, the query history of the services is available in the consumer account. To protect a provider’s confidential information, the Snowflake Native App Framework redacts the following information:

The query text is hidden from the QUERY_HISTORY view.

All information in the ACCESS_HISTORY view is hidden.

The Query Profile graph for the service’s query is collapsed into a single empty node instead of displaying the full query profile tree.

Multi-factor requirements for users in a provider account
Depending on the type of user, Snowflake requires different types of authentication for users in the provider account.

Non-service users
Snowflake recommends that users in a provider account enroll in multi-factor authentication (MFA) if they do not have the TYPE property set to SERVICE. In a future update, multi-factor authentication will be mandatory for these types of users. Non-service users who use federated authentication and single sign-on (SSO) must have MFA enabled as part of their authentication process.

Service users
Users who have the TYPE parameter set to SERVICE must use key-pair authentication or OAuth.

Snowflake Native App Framework workflow
Feature — Generally Available

The Snowflake Native App Framework is generally available on supported cloud platforms. For additional information, see Support for private connectivity, VPS, and government regions.

This topic describes the workflows for developing, publishing, and installing an application created using the Native Apps Framework.

Development workflow
The following workflow outlines the general tasks for developing and testing an application using the Native Apps Framework:

Note

Developing an application is an iterative process. You might perform many of these tasks multiple times or in a different order depending on the requirements of your application and environment.

Create the setup script for your application.

The setup script contains the SQL statements that define the components created when a consumer installs your application.

Create the manifest file for your application.

The manifest file defines the configuration and setup properties required by the application, including the location of the setup script and versions.

Upload the application files to a named stage.

The setup script, the manifest file, and other resources that your application requires must be uploaded to a named stage so that these files are available as you develop your application.

Create an application package.

An application package is a container that encapsulates the data content, application logic, metadata, and setup script required by an application.

Add versions and patch levels to your application.

Adding versions and patches to your application allows you to add features to your application or fix problems.

Add shared data content to your application.

The Native Apps Framework allows you to securely share your data content with consumers.

Add application logic.

You can include business logic as part of your application. An application can contain:

User-defined functions (UDFs) and stored procedures.

Snowpark functions and procedures written in Python, Java, and Scala.

External functions.

Set up logging and event handling to troubleshoot your application.

To troubleshoot an application, the Native Apps Framework provides logging and event handling. Consumers can set up logging and event handling in their account and share them with providers.

Set the release directive for your application.

A release directive determines which version and patch level are available to consumers.

Test your application.

You can test an application in your account before publishing it to consumers. The Native Apps Framework provides development mode and debug mode to test different aspects of your application.

Run the automated security scan.

Before you can share an application with consumers outside your organization, the application must pass an automated security scan to ensure that it is secure and stable.

Publishing workflow
After developing and testing the application, providers can publish the application to share it with consumers. See Sharing an Application with Consumers for details.

Become a provider.

Becoming a provider allows you to create and manage listings to share your application with consumers.

Create a listing.

You can create a private listing or a Snowflake Marketplace listing to share your application with consumers.

Submit your listing for approval.

Before you can publish a listing to the Snowflake Marketplace, you must submit the listing to Snowflake for approval.

Publish your listing.

After your listing is approved, you can publish the listing to make it available to consumers.

Consumer workflow
Consumers can discover the application and install it from a listing. After installing the application, consumers can configure, use, and monitor the application. See Working with Applications as a Consumer.

Become a Snowflake consumer.

Becoming a Snowflake consumer allows you to access listings shared privately or on the Snowflake Marketplace. You can also access data shared as part of direct shares or data exchanges, which offer more limited data sharing capabilities.

Install the application.

Consumers can install an application from a listing.

Grant the privileges required by the application.

Some applications might ask the consumer to grant global and object-level privileges to the application.

Enable logging and event sharing to troubleshoot the application.

A provider can set up an application to emit logging and event data. A consumer can set up an events table to share this data with providers. Logs and event data are useful when troubleshooting an application.

Manage the application.

After installing and configuring the application, a consumer can perform additional tasks to use and monitor the application.

author: Allan Mitchell
id: data_mapping_in_native_apps
summary: This guide will provide step-by-step details for building a data mapping requirement in Snowflake Native Apps and Streamlit
categories: Getting-Started, featured, data-engineering, Native-App, Streamlit
environments: web
status: draft
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Data Engineering, Native App, Streamlit, Python

# Data Mapping in Snowflake Native Apps using Streamlit
<!-- ------------------------ -->
## Overview
Duration: 5

The Snowflake Native App Framework is a fantastic way for Snowflake application providers to distribute proprietary functionality to their customers, partners and to the wider Snowflake Marketplace. As a provider you can be assured that your code and data (if included) is secure and that the consumers of your application can take advantage of the functionality but not see the details of the implementation. As a consumer of an application you can be assured that the provider via the application is not able to see or operate on any data in your account unless you explicitly allow them access.

> aside negative
> 
> **Note** - As of 23/10/2023, the [Snowflake Native App Framework](https://docs.snowflake.com/en/developer-guide/native-apps/native-apps-about) is in public preview in all non-government AWS regions.

### Prerequisites

* A basic understanding of Snowflake Native Applications
* An introductory level of coding in Python
* A basic knowledge of Snowflake
* Snowflake CLI installed and configured

### What You'll Learn

* The basic building blocks of a Snowflake Native Application
* Assigning Permissions to your Snowflake Native Application
* Allowing configuration of  your Snowflake native Application through a Streamlit UI

### What You'll need

* A Snowflake account in AWS
* A Snowflake user created with **ACCOUNTADMIN** permissions - this is more than is strictly necessary and you can read more about the permissions required [here](https://docs.snowflake.com/en/sql-reference/sql/create-application-package#access-control-requirements). You MUST execute the entire tutorial using the **accountadmin** role.
* You must have setup your preferred connection using the latest **Snowflake CLI** version available, which can be downloaded **[here](https://docs.snowflake.com/en/developer-guide/snowflake-cli-v2/installation/installation)**.

### Snowflake CLI

Snowflake CLI is a command-line tool that allow the developers to execute powerful and simplified SQL operations. New features are added continuously and it is a preview feature itself, but it is available for all accounts. It is important to keep the CLI updated to ensure the newest features and bug fixes.

### The Scenario
The scenario is as follows. You are a Snowflake Native Application provider. Your application requires the consumer of the application to pass in a column in a table that contains an IP address and you will write out enhanced data for that particular IP address to another column in the same consumer defined table.

The scenario presents some challenges to me as the provider

* You need Read and Write access to a table in the consumer account
* You have no idea what the name of the IP address attribute will be
* You have no idea where the consumer will want me to write out the data

Requesting read and write access to a table in the consumer account is easy because my application can simply tell the consumer I require Read/Write access to a table and the consumer can grant access. The next two points are slightly more tricky. We have the ability within the Snowflake Native App Framework to gain access to a table which the application consumer will specify. Every consumer of the application will most likely have differently named attributes as well. In testing an application's functionality locally you know the names of the columns and life is good. Let’s see two ways in which you could solve this problem with Snowflake Native Apps.  There are others but here we want to just call out two for now.

#### Solution 1:  Make the consumer do the work

In the readme file for the application you could distribute instructions for the consumer to make sure they have a table called T that contains columns labeled C_INPUT and C_OUTPUT.  The application consumer could enable this by providing a view over the top of an existing table to the application.  Whilst this will work, we don’t necessarily want new objects to be created in Snowflake databases simply to serve the purpose of our application.

#### Solution 2: Provide an intuitive UI in the application

The application provides a user interface which allows the consumer of the application to map columns in an existing table/view to the requirements of the application. This is much more user friendly and doesn’t require new objects to be created in a Snowflake database.

The first solution is not really what we want to be doing because the consumer will potentially have to create objects on their Snowflake instance just to satisfy the application's requirements, so this Quickstart will deliver the second solution.

> aside positive
> 
> **Note** - The following steps explain how to create the app using the **Snowflake CLI**, as this option presents as a faster, more straightforward way to build Native Apps. You can also accomplish it by manually creating the folder structure and executing the SQL commands in Snowsight, but this alternative is out of the scope for this Quickstart. Remember to have the latest CLI version installed.

<!-- ------------------------ -->
## Project Structure
Duration: 7

The project we are about to create is composed of several files in the following tree structure:

```
-- Datamapping App project

    |-- app
    |   |-- ui
    |   |   |-- enricher_dash.py
    |   |-- manifest.yml
    |   |-- setup_script.sql
    |-- scripts
    |   |-- setup-package-script.sql
    |-- .gitignore
    |-- prepare_data.sh
    |-- README.md
    |-- snowflake.yml
```

To start creating this folder structure, go to your console and inside the folder you want the project to reside. Execute the following command: 
**`snow app init datamapping_app_streamlit`**.

Now, inside the **app** folder, create another one, called **ui**, and add the following file

- enricher_dash.py

The next step is to create an empty file called **prepare_data.sh** at the project root.


From the project's root, create a new folder and name it **scripts**, inside, create a file named **setup_package_script.sql**.

Finally, replace the content of **snowflake.yml** file with the following code:

```sh
definition_version: 1 
native_app:
name: IP2LOCATION_STREAMLIT
source_stage: app_src.stage
artifacts:
    - src: app/*
      dest: ./
package:
    scripts:
    - scripts/setup_package_script.sql
```


Finally, the tree structure inside your project structure should look like this:

<img src="assets/folder_structure.png" width="288" />






<!-- ------------------------ -->
## Building the Application
Duration: 7

The application itself has been broken down into three parts:

* The building of the **application package** on the provider and the sharing of the lookup database with the application. 
* The building of the application **setup script** which contains the functionality to accept an IP address, look it up in the database we just shared with the application and write back enhanced data from the application. 
* Arguably (certainly for this Quickstart) the most important part which is the user interface written using Streamlit. This is where we will do the mappings.

To do the enhancement of the IP addresses we will use a dataset called DB11 from [IP2LOCATION](https://www.ip2location.com/database/ip2location). There is a free version of this database available [here](https://lite.ip2location.com/database/db11-ip-country-region-city-latitude-longitude-zipcode-timezone), which is the one we will use in this quickstart. There are several versions of this IP information; we are going to use the IPv4 verison for this tutorial. If you do not have an account with them already you will need to create one. Download the dataset as a CSV file so it is ready to import  into the provider account.

### Preparing the data

The first thing you need to do is create a new database which will serve as the lookup database for the application, following that, it is necessary to create a table, a file format, and a stage. That way we can upload our files to the **stage**, using the **file format** and after that loading that staged data into the **table**.

> aside positive
> 
> **Note** - This setup SQL commands are performed by the **prepare_data.sh** file created previously, you can complete it with the code below:

```sh
# Create a database and a schema to hold the data to lookup.
snow sql -q "
CREATE DATABASE IF NOT EXISTS IP2LOCATION;
CREATE SCHEMA IF NOT EXISTS IP2LOCATION;
"

# Create the table to host the data.
# Create a file format for the file
# Create a stage so we can upload the file

snow sql -q "
CREATE TABLE IF NOT EXISTS LITEDB11 (
ip_from INT,
ip_to INT,
country_code char(2),
country_name varchar(64),
region_name varchar(128),
city_name varchar(128),
latitude DOUBLE,
longitude DOUBLE,
zip_code varchar(30),
time_zone varchar(8)
);

CREATE OR REPLACE FILE FORMAT LOCATION_CSV
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '\"'
COMPRESSION = AUTO;

CREATE STAGE IF NOT EXISTS IP2LOCATION.IP2LOCATION.LOCATION_DATA_STAGE
file_format = LOCATION_CSV;" --database ip2location --schema ip2location 

# Copy the csv files from your local machine to the stage we created previously
snow stage copy /USER_PATH_HERE/IP2LOCATION-LITE-DB11.CSV @location_data_stage --database ip2location --schema ip2location 

# Copy the csv file from the stage to load the table
snow sql -q "copy into litedb11 from @location_data_stage
files = ('IP2LOCATION-LITE-DB11.CSV')
;" --database ip2location --schema ip2location

# Simple query test to ensure the table is correctly filled.
snow sql -q "
SELECT COUNT(*) FROM LITEDB11;
SELECT * FROM LITEDB11 LIMIT 10;" --database ip2location --schema ip2location

# Create test database and schema.
snow sql -q "
DATABASE IF NOT EXISTS TEST_IPLOCATION;
CREATE SCHEMA IF NOT EXISTS TEST_IPLOCATION;"

# Create test table to insert some values
snow sql -q "
CREATE OR REPLACE TABLE TEST_IPLOCATION.TEST_IPLOCATION.TEST_DATA (
	IP VARCHAR(16),
	IP_DATA VARIANT
);"

# Insert testing values to use later on
snow sql -q "
INSERT INTO TEST_IPLOCATION.TEST_IPLOCATION.TEST_DATA(IP) VALUES('73.153.199.206'),('8.8.8.8');"
```

You can run the file by executing:
 ```SNOWFLAKE_DEFAULT_CONNECTION_NAME=your_connection ./prepare_data.sh```  
 in the folder root.

We now have the referenced database setup in the provider account so we are ready to start building the application itself.

<!-- ------------------------ -->
## Provider Setup
Duration: 5

> aside positive
> 
> **Note** - You will need to replace the content in the **setup_package_script.sql** file with the following code. The **{{ package_name }}** directive, allows the application to use whatever name the app package has, according to the user's system username, as a code variable.

```sql
--Create a schema in the applcation package
CREATE SCHEMA IF NOT EXISTS {{ package_name }}.IP2LOCATION;

--Grant the application permissions on the schema we just created
GRANT USAGE ON SCHEMA {{ package_name }}.IP2LOCATION TO SHARE IN APPLICATION PACKAGE {{ package_name }};

-- Grant the applications permissions to reference the database where the data is located
GRANT REFERENCE_USAGE ON DATABASE IP2LOCATION TO SHARE IN APPLICATION PACKAGE {{ package_name }};

--We should not reference directly to the table, instead we need to create a proxy artifact here referencing the data we want to use
CREATE VIEW IF NOT EXISTS {{ package_name }}.IP2LOCATION.LITEDB11
AS
SELECT * FROM IP2LOCATION.IP2LOCATION.LITEDB11;
--Grant permissions to the application on the view.
GRANT SELECT ON VIEW {{ package_name }}.IP2LOCATION.LITEDB11 TO SHARE IN APPLICATION PACKAGE {{ package_name }};
```

Fantastic,  we now have an application package with permissions onto the lookup database.  That's the first part of the application completed but we will be adding the necessary files to deploy the actual application.

<!-- ------------------------ -->
## The Manifest File
Duration: 3

Every Snowflake Native App is required to have a manifest file.  The manifest file defines any properties of the application as well as the location of the application's setup script.  The manifest file for this application will not use all the possible fetures of the manifest file so you can read more about it [here](https://docs.snowflake.com/en/developer-guide/native-apps/creating-manifest).  The manifest file has three requirements:

* The name of the manifest file must be manifest.yml.
* The manifest file must be uploaded to a named stage so that it is accessible when creating an application package or Snowflake Native App.
* The manifest file must exist at the root of the directory structure on the named stage.

The named stage in this example is going to be created when we execute the **snow app run** command.

> aside positive
>
> **Note** - The **manifest.yml** file you created should be replaced with this code:

```yaml
manifest_version: 1
artifacts:
  readme: README.md
  setup_script: setup_script.sql
  default_streamlit: ui."Dashboard"

references:
  - tabletouse:
      label: "Table that contains data to be keyed"
      description: "Table that has IP address column and a column to write into"
      privileges:
        - SELECT
        - INSERT
        - UPDATE
        - REFERENCES
      object_type: TABLE
      multi_valued: false
      register_callback: config_code.register_single_callback
```

The **artifacts** section details what files will be included in the application and their location relative to the manifest file.  The **references** section is where we define the permissions we require within the consumer account.  This is what we will ask the consumer to grant.  The way it does that is by calling the **register_callback** procedure which we will shortly define in our setup script.

<!-- ------------------------ -->
## The Setup Script
Duration: 10

In a Snowflake Native App, the setup script is used to define what objects will be created when the application is installed on the consumer account.  The location of the file as we have seen is defined in the manifest file.  The setup script is run on initial installation of the application and any subsequent upgrades/patches.

Most setup scripts are called either **setup.sql** or **setup_script.sql** but that is not a hard and fast requirement.  In the setup script you will see that for some objects, the application role is given permissions and some not.  
If the application role is permissioned onto an object then the object will be visible in Snowsight after the application is installed (permissions allowing).
If the application role is not granted permissions onto an object then you will not see the object in Snowsight.  The application itself can still use the objects regardless.

> aside positive
>
> **Note** - Go ahead and replace your **setup_script.sql** file with the following code:

```sql
--create an application role which the consumer can inherit
CREATE APPLICATION ROLE APP_PUBLIC;

--create a schema
CREATE OR ALTER VERSIONED SCHEMA ENRICHIP;
--grant permissions onto the schema to the application role
GRANT USAGE ON SCHEMA ENRICHIP TO APPLICATION ROLE APP_PUBLIC;

--this is an application version of the object shared with the application package
CREATE VIEW ENRICHIP.LITEDB11 AS SELECT * FROM IP2LOCATION.litedb11;
-- If the user prefers, access can be granted directly to the IPLOCATION.litebd11 view, created in the setup_package_script file.

--accepts an IP address and returns a modified version of the IP address 
--the modified version will be used in the lookup
CREATE OR REPLACE SECURE FUNCTION ENRICHIP.ip2long(ip_address varchar(16))
RETURNS string
LANGUAGE JAVASCRIPT
AS
$$
var result = "";
var parts = [];
if (IP_ADDRESS.match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)) {
parts = IP_ADDRESS.split('.');
result = (parts[0] * 16777216 +
(parts[1] * 65536) +
(parts[2] * 256) +
(parts[3] * 1));
}
return result;
$$
;

--this function accepts an ip address and 
--converts it using the ip2long function above
--looks up the returned value in the view
--returns the enhanced information as an object
CREATE OR REPLACE SECURE FUNCTION ENRICHIP.ip2data(ip_address varchar(16))
returns object
as
$$
select object_construct('country_code', MAX(COUNTRY_CODE), 'country_name', MAX(COUNTRY_NAME),
'region_name', MAX(REGION_NAME), 'city_name', MAX(CITY_NAME),
'latitude', MAX(LATITUDE), 'longitude', MAX(LONGITUDE),
'zip_code', MAX(ZIP_CODE), 'time_zome', MAX(TIME_ZONE))
from ENRICHIP.LITEDB11 where ip_from <= ENRICHIP.ip2long(ip_address)::int AND ip_to >= ENRICHIP.ip2long(ip_address)::int
$$
;

--create a schema for our callback procedure mentioned in the manifest file
create or alter versioned schema config_code;
--grant the application role permissions onto the schema
grant usage on schema config_code to application role app_public;

--this is the permissions callback we saw in the manifest.yml file
create or replace procedure config_code.register_single_callback(ref_name string, operation string, ref_or_alias string)
    returns string
    language sql
    as $$
        begin
            case (operation)
                when 'ADD' then
                    select system$set_reference(:ref_name, :ref_or_alias);
                when 'REMOVE' then
                    select system$remove_reference(:ref_name);
                when 'CLEAR' then
                    select system$remove_reference(:ref_name);
                else
                    return 'Unknown operation: ' || operation;
            end case;
            system$log('debug', 'register_single_callback: ' || operation || ' succeeded');
            return 'Operation ' || operation || ' succeeded';
        end;
    $$;

--grant the application role permissions to the procedure
grant usage on procedure config_code.register_single_callback(string, string, string) to application role app_public;

--create a schema for the UI (streamlit)
create or alter versioned schema ui;
--grant the application role permissions onto the schema
grant usage on schema ui to application role app_public;

--this is our streamlit.  The application will be looking for 
--file = enricher_dash.py in a folder called ui

--this is the reference to the streamlit (not the streamlit itself)
--this was referenced in the manifest file
create or replace streamlit ui."Dashboard" from 'ui' main_file='enricher_dash.py';

--grant the application role permissions onto the streamlit
grant usage on streamlit ui."Dashboard" TO APPLICATION ROLE APP_PUBLIC;

--this is where the consumer data is read and the enhanced information is written
CREATE OR REPLACE PROCEDURE ENRICHIP.enrich_ip_data(inp_field varchar, out_field varchar)
RETURNS number
AS
$$
    DECLARE 
        q VARCHAR DEFAULT 'UPDATE REFERENCE(''tabletouse'') SET ' || out_field || ' = ENRICHIP.ip2data(' || inp_field || ')';
        result INTEGER DEFAULT 0;
    BEGIN
        EXECUTE IMMEDIATE q;
        RETURN RESULT;
    END;
$$; 
```

> aside positive
> 
> **Note** - In the setup script we defined a stored procedure labeled **ENRICHIP.enrich_ip_data**.  In the body we make calls to **REFERENCE(tabletouse)**.  This reference was defined in the manifest file and it is the table to which the consumer has granted us permissions.  Because, as the application producer, we have no way of knowing that ahead of time, the Snowflake Native App framework adds this facility and will resolve the references once permissions have been granted.

<!-- ------------------------ -->
## Creating the Streamlit
Duration: 5

We now come to arguably the most important part of the application for us which is the user interface.  We have defined all the objects we need to create and also the permissions we will require from the consumer of the application.

A little recap on what this UI needs to achieve:

* Map a field in a table to an ip column
* Map a field in a the same table to receive the enhanced output

Once we have the streamlit UI built we can then finish off the build of the application package.

### Building the User Interface

The code for the streamlit looks like this.  There will be other ways of doing this, but this is one way. 

> aside positive
>
> **Note** - Add this code to your **enricher_dash.py** file.

```python
import streamlit as st
import pandas as pd
from snowflake.snowpark.context import get_active_session

# get the active session
session = get_active_session()
# define the things that need mapping
lstMappingItems =  ["IP ADDRESS COLUMN", "RESULT COLUMN"]
# from our consumer table return a list of all the columns
option_source = session.sql("SELECT * FROM REFERENCE('tabletouse') WHERE 1=0").to_pandas().columns.values.tolist()
# create a dictionary to hold the mappings
to_be_mapped= dict()
#create a form to do the mapping visualisation
with st.form("mapping_form"):
    header = st.columns([1])
    #give it a title
    header[0].subheader('Define Mappings')
    # for each mapping requirement add a selectbox
    # populate the choices with the column list from the consumer table
    for i in range(len(lstMappingItems)):
        row = st.columns([1])
        selected_col = row[0].selectbox(label = f'Choose Mapping for {lstMappingItems[i]}',options = option_source)
        # add the mappings to the dictionary
        to_be_mapped[lstMappingItems[i]] = selected_col
        
    row = st.columns(2)
    # submit the mappings
    submit = row[1].form_submit_button('Update Mappings')

# not necessary but useful to see what the mappings look like
st.json(to_be_mapped)

#function call the stored procedure in the application that does the reading and writing
def update_table():
    # build the statement
    statement = ' CALL ENRICHIP.enrich_ip_data(\'' + to_be_mapped["IP ADDRESS COLUMN"] + '\',\'' +  to_be_mapped["RESULT COLUMN"] + '\')'
    #execute the statement
    session.sql(statement).collect()
    #again not necessary but useful for debugging (would the statement work in a worksheet)
    st.write(statement)
#update the consumer table
st.button('UPDATE!', on_click=update_table)
```

### Finishing the Application

All the pieces are in place for our application, we just created (manifest.yml, setup_script.sql and enricher_dash.py) and now we are going to actually deploy it in the next step.

<!-- ------------------------ -->
## Creating and Deploying the Application
Duration: 2

There are a few ways we could deploy our application:

* Same account / Different account
* Same Org / Different Org
* Debug Mode / non-debug mode


In a manual environment you would have to upload the files to the stage APPLICATION_STAGE and then run other commands from a SQL worksheet, but instead, we are taking the Snowflake CLI approach and run:

```sh
    snow app run --database ip2location
```

At the root of the project, and the CLI is going to create the application for you, using the files explained in the previous steps, as well as the other configuration files present in the project folder.

### Viewing the Application

Because we have installed the application locally we needed to create a table to test with. That step we did it in the **prepare_data.sh** file.

Click on the link that appeared in your console output.

 The application if you remember needs permissions onto a table in the consumer account (the one we just created).  We have now switched roles to being the consumer.  We are finished with being the application provider.  Over on the right hand side hit the shield icon to go to **Security**.

<img src="assets/security_tab.png" width="288" />

 This will take you through to a page which will allow you to specify the table that you want the application to work with.  This dialog is a result of the **REFERENCE** section in the manifest file.

<img src="assets/assign_perms.png" width="901" />

Click **Add** and navigate to the table we just created and select it:

> aside positive
> 
> **Note** - You may at this point be asked to specify a warehouse, because assigning permissions requires a warehouse.

<img src="assets/table_chosen.png" width="719" />

Once we click **Done** and **Save** then the application has been assigned the needed permissions.  Now go back to the **Dashboard** section and click it. It should open to a screen like the following:

<img src="assets/app_entry.png" width="975" />

You should recognise the layout from building the streamlit earlier.  If you drop down either of the two boxes you will see that they are populated with the columns from the table the application has been assigned permissions to.  If we populate the mappings correctly, hit **Update Mappings** then you will see the piece of JSON underneath change to tell us the currently set mappings.  The ones we want for this application are:

<img src="assets/correct_mappings.png" width="703" />

Hit the **Update Mappings** button and then the **UPDATE!** button.  At the top of the screen you will see the SQL that you just executed on your data.

<img src="assets/statement.png" width="336" />

Now go back to your console to confirm that enhanced data has been written to your database table.

```sh
snow sql -q " USE DATABASE TEST_IPLOCATION;
USE SCHEMA TEST_IPLOCATION;
SELECT * FROM TEST_DATA;"
```
<img src="assets/complete.png" width="1243" />

<!-- ------------------------ -->
## Teardown
Duration: 1

Once you have finished with the application and want to clean up your environment you can execute the following script

```sh
snow sql -q "DROP DATABASE TEST_IPLOCATION;"
snow app teardown
```

<!-- ------------------------ -->
## Conclusion
Duration: 1

We have covered a lot of ground in this Quickstart.  We have covered the building blocks of almost every Snowflake Native App you will ever build.  Sure some will be more complicated but the way you structure them will be very similar to what you have covered here.

> aside positive
> 
> **Note** - In [this repository](https://github.com/snowflakedb/native-apps-examples/tree/main/data-mapping) you can find all this code with the instructions to execute it.

### What we learned

* Creating an Application Package
* Defining and understand the role of the manifest file
* Creating the Setup script
* Understanding how References work within an application
* How to deploy an application locally
* How to assign permissions to the application
* creating a user interface for an application using Streamlit

### Further Reading

* [Snowflake Native App Developer Toolkit](https://www.snowflake.com/snowflake-native-app-developer-toolkit/?utm_cta=na-us-en-eb-native-app-quickstart)
* [Tutorial: Developing an Application with the Native Apps Framework](https://docs.snowflake.com/en/developer-guide/native-apps/tutorials/getting-started-tutorial)
* [Getting Started with Snowflake Native Apps](https://quickstarts.snowflake.com/guide/getting_started_with_native_apps/#0)
* [Build a Snowflake Native App to Analyze Chairlift Sensor Data](https://quickstarts.snowflake.com/guide/native-app-chairlift/#0)
* [About the Snowflake Native App Framework](https://docs.snowflake.com/en/developer-guide/native-apps/native-apps-about)

author: Praveen Padige
id: airflow-spcs
summary: Running Apache Airflow on SPCS
categories: data-engineering,app-development
environments: web
status: Published 
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Data Science, Data Engineering, Apache Airflow 

# Running Apache Airflow on SPCS
<!-- ------------------------ -->
## Overview

Duration: 5

In this guide, we will be walking you through how to deploy Apache Airflow application with Celery Executor in Snowpark Container Services.

This application is made up of the following containers:
- **Airflow Webserver**: Provides a user interface for managing and monitoring workflows. It allows users to trigger tasks, view logs, and visualize DAGs (Directed Acyclic Graphs).
- **Airflow Scheduler**: Monitors the DAGs and schedules the tasks to run. It determines the order of task execution based on the dependencies defined in the DAGs.
- **Airflow Workers**: Executes tasks distributed by the Airflow scheduler using Celery for parallel processing. 
- **Postgres**: Serves as the metadata database, storing the state of the DAGs, task instances, users, roles, and other operational data necessary for Airflow to function.
- **Redis**:Acts as a message broker, facilitating communication between the scheduler and the Celery workers. It queues the tasks that the scheduler hands off to the workers for execution.

Together, these components enable efficient scheduling, execution, and monitoring of complex workflows in Airflow.

##
![Architecture](assets/architecture.png)
##

Here is a summary of what you will be doing in each step by following this quickstart:

- **Setup Environment**: Setup deidicated Airflow SPCS database,schema, role, compute pools, Image repository etc.
- **SnowGIT Integration**: Sync your Airflow environment with your Github repo to scan for DAG files.
- **Build Docker Images**: Build Airflow, Postgres, Redis & Git Docker images and push them to Snowflake image repository
- **Create Service Specifications**: Create Service specification files for Airflow Service, Redis Service, Postgres Service and upload these files to Snowflake Internal stage.
- **Create Services**: Create Airflow, Redis, Postgres services
- **Run DAG**: Run a sample DAG 
- **Clean up**: If you don’t plan to explore other tutorials, you should remove billable resources you created.

##
### What is Apache Airflow?

Apache Airflow is an open-source platform to programmatically author, schedule, and monitor workflows. Using Directed Acyclic Graphs (DAGs), Airflow allows users to define workflows as code, ensuring flexibility, scalability, and maintainability. It's widely used in various scenarios, from ETL processes and data pipeline automation to machine learning model training and deployment.

Learn more about [Apache Airflow](https://airflow.apache.org/docs/).

##
### What is Snowpark Container Services?
Snowpark Container Services (SPCS) is a feature provided by Snowflake that allows users to run containerized workloads within the Snowflake environment. It is designed to enable the execution of custom code and applications in a scalable and efficient manner, leveraging the Snowflake data platform's infrastructure

Learn more about [Snowpark Container Services](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview/).
##

### What You Will Build
 - Apache Airflow application with Celery Executor, using a PostgreSQL database as the metadata store backed by block storage, and persisting task logs in a Snowflake internal stage. 

### What You Will Learn
- The working mechanics of Snowpark Container Services
- How to build and push a containerized Docker image to SPCS along with code and other files
- How to create SnowGIT integration with your Github repository
- How to create External Access Integration
- How to deploy Apache Airflow with Celery Executor in SPCS


### Prerequisites
- A Snowflake account with access to SnowPark Container Services.
- [Docker](https://www.docker.com/products/docker-desktop/) installed locally for building images.
- Basic knowledge of Apache Airflow and containerized deployments.


<!-- ------------------------ -->
## Setup Environment

Duration: 10

### Create Snowflake Objects

Log into [Snowsight](https://docs.snowflake.com/en/user-guide/ui-snowsight.html#) using your credentials to create Snowflake objects.

1) In a new SQL worksheet, run the following SQL commands to complete [Common Setup for SPCS](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/tutorials/common-setup#introduction).

```sql

USE ROLE ACCOUNTADMIN;
CREATE ROLE airflow_admin_rl;

CREATE DATABASE IF NOT EXISTS airflow_db;
GRANT OWNERSHIP ON DATABASE airflow_db TO ROLE airflow_admin_rl COPY CURRENT GRANTS;

CREATE OR REPLACE WAREHOUSE airflow_wh WITH
  WAREHOUSE_SIZE='X-SMALL';
GRANT USAGE ON WAREHOUSE airflow_wh TO ROLE airflow_admin_rl;

GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE airflow_admin_rl;

GRANT ROLE airflow_admin_rl TO USER <user_name>;

```

2) In the same SQL worksheet, run the following SQL commands to create [compute pool](https://docs.snowflake.com/en/sql-reference/sql/create-compute-pool) for each of the Airflow services (Webserver, Scheduler, Celery Worker, Redis and Postgres).

```sql
USE ROLE ACCOUNTADMIN;
/* Compute pool for host Postgres and Redis services */
CREATE COMPUTE POOL postgres_redis
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = CPU_X64_S;

/* Compute pool for Airflow Webserver and Scheduler services */
CREATE COMPUTE POOL airflow_server
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = CPU_X64_S;

/* Compute pool for Airflow Workers, set max_nodes to 2 for auto scaling */
CREATE COMPUTE POOL airflow_workers
  MIN_NODES = 1
  MAX_NODES = 2
  INSTANCE_FAMILY = CPU_X64_S;

/* Grant access on these compute pools to role airflow_admin_rl */
GRANT USAGE, MONITOR ON COMPUTE POOL postgres_redis to ROLE airflow_admin_rl;
GRANT USAGE, MONITOR ON COMPUTE POOL airflow_server to ROLE airflow_admin_rl;
GRANT USAGE, MONITOR ON COMPUTE POOL airflow_workers to ROLE airflow_admin_rl;
```
##
![Compute Pools](assets/compute_pools.png)
##

3) Run the following SQL commands in SQL worksheet to create [image repository](https://docs.snowflake.com/en/sql-reference/sql/create-image-repository) to upload docker images for these services, also create [internal stage](https://docs.snowflake.com/en/sql-reference/sql/create-stage) to upload service specification files.

```sql
USE ROLE airflow_admin_rl;
USE DATABASE airflow_db;
USE WAREHOUSE airflow_wh;

CREATE SCHEMA IF NOT EXISTS airflow_schema;
USE SCHEMA airflow_db.airflow_schema;
CREATE IMAGE REPOSITORY IF NOT EXISTS airflow_repository;
CREATE STAGE IF NOT EXISTS service_spec DIRECTORY = ( ENABLE = true );
```

4) Create Snowflake secret objects to store passwords for Postgres, Redis and [Airflow Fernet Key](https://airflow.apache.org/docs/apache-airflow/stable/security/secrets/fernet.html#fernet). Refer to this [document](https://airflow.apache.org/docs/apache-airflow/stable/security/secrets/fernet.html#generating-fernet-key) to generate Fernet Key.

```sql
USE ROLE airflow_admin_rl;
USE SCHEMA airflow_db.airflow_schema;

CREATE SECRET airflow_fernet_key
    TYPE = password
    username = 'airflow_fernet_key'
    password = '########'
    ;

CREATE SECRET airflow_postgres_pwd
    TYPE = password
    username = 'postgres'
    password = '########'
    ;

CREATE SECRET airflow_redis_pwd
    TYPE = password
    username = 'airflow'
    password = '########'
    ;
```

<!-- ------------------------ -->
## SnowGIT and External Access Integration

Duration: 5

1) Create a [SnowGIT integration](https://docs.snowflake.com/en/developer-guide/git/git-setting-up). You will use this integration in the Airflow service to scan for DAG files from the repository. As soon as a DAG file is added or updated in the GitHub repo, it will be made available to the Airflow UI.

```sql
USE ROLE airflow_admin_rl;
USE SCHEMA airflow_db.airflow_schema;

/* create a secret object to store Github personal access token */
CREATE OR REPLACE SECRET git_airflow_secret
  TYPE = password
  USERNAME = '<username>'
  PASSWORD = 'patghp_token'
  ;

GRANT USAGE ON SECRET git_airflow_secret  TO ROLE accountadmin;

USE ROLE accountadmin;
CREATE OR REPLACE API INTEGRATION airflow_git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/my-account')
  ALLOWED_AUTHENTICATION_SECRETS = (airflow_db.airflow_schema.git_airflow_secret)
  ENABLED = TRUE;

GRANT USAGE ON INTEGRATION airflow_git_api_integration TO ROLE airflow_admin_rl;

USE ROLE airflow_admin_rl;
USE SCHEMA airflow_db.airflow_schema;

CREATE OR REPLACE GIT REPOSITORY airflow_dags_repo
  API_INTEGRATION = airflow_git_api_integration
  GIT_CREDENTIALS = airflow_db.airflow_schema.git_airflow_secret
  ORIGIN = 'https://github.com/my-account/repo.git';

SHOW GIT BRANCHES IN airflow_dags_repo;

/* we will mount this stage as a volume to the Airflow service. git-sync container copies the DAGs to this stage. */
CREATE STAGE IF NOT EXISTS airflow_dags ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

/* we will mount this stage as a volume to the Airflow service where it will store task logs. */
CREATE STAGE IF NOT EXISTS airflow_logs ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');
```
##
![SnowGIT](assets/snowgit.png)
##
2) In SPCS by default outbound traffic is disabled. To enable it you will have to create a [Netwrok Rule](https://docs.snowflake.com/en/sql-reference/sql/create-network-rule) and [External Access Integration](https://docs.snowflake.com/en/sql-reference/sql/create-external-access-integration). This integration will be  passed as an input to Airflow Service. 

```sql
USE ROLE airflow_admin_rl;
USE SCHEMA airflow_db.airflow_schema;

CREATE OR REPLACE NETWORK RULE airflow_spcs_egress_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = (
  'my-account.snowflakecomputing.com',
  'api.slack.com',
  'hooks.slack.com',
  'events.pagerduty.com');

GRANT USAGE ON NETWORK RULE airflow_spcs_egress_rule TO ROLE accountadmin;

USE ROLE accountadmin;
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION airflow_spcs_egress_access_integration
  ALLOWED_NETWORK_RULES = (airflow_db.airflow_schema.airflow_spcs_egress_rule)
  ENABLED = true;

GRANT USAGE ON  INTEGRATION airflow_spcs_egress_access_integration to role airflow_admin_rl;

```

<!-- ------------------------ -->
## Build Docker Images

Duration: 15

In this section you will be build the docker images and push them to Snowflake Image Repository.

1) Make sure you have the URL of the repository where you want to upload the images. To get this URL, you can execute the SHOW IMAGE REPOSITORIES command, using SnowSQL CLI or the Snowsight web interface. The command returns the repository URL, including the organization name and the account name.

2) Open a terminal window, and change to the directory of your choice.

3) Clone the GitHub repository.

```
git clone https://github.com/Snowflake-Labs/spcs-templates.git
```
4) Go to `airflow-spcs` directory. This directory has Dockerfiles for Airflow, Postgres, Redis and Git.

5) To enable Docker to upload images on your behalf to your image repository, you must use the docker login command to authenticate to the Snowflake registry:

```
docker login <registry_hostname> -u <username>
```
*Note: The <registry_hostname> is the hostname part of the repository URL. For example, myorg-myacct.registry.snowflakecomputing.com. <username> is your Snowflake username. Docker will prompt you for your password.*

6) Build Airflow Image. The base image used in Dockerfile is `apache/airflow:slim-2.7.3-python3.10`. If you want to use an another version of Airflow you can update the Dockerfile for the same.

```
docker build  --rm --platform linux/amd64 -t <registry_hostname>/airflow_db/airflow_schema/airflow_repository/airflow:2.7.3 -f ./airflow/airflow/Dockerfile .
```

7) Build Postgres Image. The base image used in Dockerfile is `postgres:14.10`.

```
docker build  --rm --platform linux/amd64 -t <registry_hostname>/airflow_db/airflow_schema/airflow_repository/postgres:14.10 -f ./airflow/postgres/Dockerfile .
```

8) Build Redis Image. The base image used in Dockerfile is `redis:7.0`.

```
docker build  --rm --platform linux/amd64 -t <registry_hostname>/airflow_db/airflow_schema/airflow_repository/redis:7.0 -f ./airflow/redis/Dockerfile .
```

9) Build git-sync Image.

```
docker build  --rm --platform linux/amd64 -t <registry_hostname>/airflow_db/airflow_schema/airflow_repository/gitsync:latest -f ./airflow/git-sync/Dockerfile .
```
10) Push images to Snowflake Image Repository

```
docker push <registry_hostname>/airflow_db/airflow_schema/airflow_repository/airflow:2.7.3
docker push <registry_hostname>/airflow_db/airflow_schema/airflow_repository/postgres:14.10
docker push <registry_hostname>/airflow_db/airflow_schema/airflow_repository/redis:7.0
docker push <registry_hostname>/airflow_db/airflow_schema/airflow_repository/gitsync:latest
```

11) Run this command to list the images in Snowflake Image Repository.

```sql
USE ROLE airflow_admin_rl;
USE SCHEMA airflow_db.airflow_schema;
SHOW IMAGES IN IMAGE REPOSITORY airflow_repository;
```
##
![Image Repository](assets/images.png)
##
<!-- ------------------------ -->
## Create Service Specification files

Duration: 5

In each of the service directory of the cloned repository you will see `.template` files. We rendere these `.template` files by running `render_template.py` script. It uses values from `values.yaml` file. You can modify values in `values.yaml` file to customize the application as per your needs.

1) Open a terminal window, and change directory to `airflow-spcs/airflow/template`

2) Run below script, it will generate `airflow/airflow_server.yaml`, `airflow/airflow_worker.yaml`, `postgres/postgres.yaml`, `redis/redis.yaml` and  `git-sync/gitsync.yaml` files.

```python
python render_template.py
```

3) Upload these specification files to `@airflow_db.airflow_schema.service_spec`. You can upload directly from Snowsight or you can use [SnowSQL CLI](https://docs.snowflake.com/en/user-guide/snowsql) to upload from terminal.

```sql
USE  ROLE airflow_admin_rl;
put file://~/airflow_spcs/redis/redis.yaml @airflow_db.airflow_schema.service_spec AUTO_COMPRESS=FALSE OVERWRITE=TRUE; 
put file://~/airflow_spcs/postgres/postgres.yaml @airflow_db.airflow_schema.service_spec AUTO_COMPRESS=FALSE OVERWRITE=TRUE; 
put file://~/airflow_spcs/airflow/airflow_server.yaml @airflow_db.airflow_schema.service_spec AUTO_COMPRESS=FALSE OVERWRITE=TRUE; 
put file://~/airflow_spcs/airflow/airflow_worker.yaml @airflow_db.airflow_schema.service_spec AUTO_COMPRESS=FALSE OVERWRITE=TRUE; 
```

<!-- ------------------------ -->
## Create Services

Duration: 8

Run below commands in Snowsight to create Redis, Postgres, Airflow services.

```sql
USE  ROLE airflow_admin_rl;
USE SCHEMA airflow_db.airflow_schema;

/* creates Postgres service */
CREATE SERVICE postgres_service
  IN COMPUTE POOL postgres_redis
  FROM @service_spec
  SPECIFICATION_FILE='postgres.yaml'
  MIN_INSTANCES=1
  MAX_INSTANCES=1;

/* check status of the service */
SELECT SYSTEM$GET_SERVICE_STATUS('postgres_service');
/* check container logs of the service */
CALL SYSTEM$GET_SERVICE_LOGS('postgres_service', '0','postgres');
```
##
![Postgres Log](assets/postgres_log.png)
##

```sql
/* creates Redis service */
CREATE SERVICE redis_service
  IN COMPUTE POOL postgres_redis
  FROM @service_spec
  SPECIFICATION_FILE='redis.yaml'
  MIN_INSTANCES=1
  MAX_INSTANCES=1;

/* check status of the service */
SELECT SYSTEM$GET_SERVICE_STATUS('redis_service');
/* check container logs of the service */
CALL SYSTEM$GET_SERVICE_LOGS('redis_service', '0','redis');
```

##
![Redis Log](assets/redis_log.png)
##

```sql
/* creates Airflow webserver, Scheduler and Git-Sync services */
CREATE SERVICE airflow_service
  IN COMPUTE POOL airflow_server
  FROM @service_spec
  SPECIFICATION_FILE='airflow_server.yaml'
  MIN_INSTANCES=1
  MAX_INSTANCES=1
  EXTERNAL_ACCESS_INTEGRATIONS = (airflow_spcs_egress_access_integration);

/* check status of the service */
SELECT SYSTEM$GET_SERVICE_STATUS('airflow_service');
/* check container logs of the service */
CALL SYSTEM$GET_SERVICE_LOGS('airflow_service', '0','webserver');
```
##
![Webserver Log](assets/weblog.png)
##
```sql
CALL SYSTEM$GET_SERVICE_LOGS('airflow_service', '0','scheduler');
```
##
![Scheduler Log](assets/scheduler_log.png)
##
```sql
CALL SYSTEM$GET_SERVICE_LOGS('airflow_service', '0','git-sync');
/* creates Airflow Workers service */
CREATE SERVICE airflow_worker
  IN COMPUTE POOL airflow_workers
  FROM @service_spec
  SPECIFICATION_FILE='airflow_worker.yaml'
  MIN_INSTANCES=1
  MAX_INSTANCES=2
  EXTERNAL_ACCESS_INTEGRATIONS = (airflow_spcs_egress_access_integration);

/* check status of the service */
SELECT SYSTEM$GET_SERVICE_STATUS('airflow_worker');
/* check container logs of the service */
CALL SYSTEM$GET_SERVICE_LOGS('airflow_worker', '0','worker');
CALL SYSTEM$GET_SERVICE_LOGS('airflow_worker', '1','worker');
```
##
![Worker Log](assets/worker_log.png)
##

If you have changed Docker image or changed service specification files, run below command to restart the service with latest changes.

```sql
USE  ROLE airflow_admin_rl;
USE SCHEMA airflow_db.airflow_schema;
ALTER SERVICE airflow_worker FROM @service_spec SPECIFICATION_FILE='airflow_worker.yaml';
```

You can share this app with other Snowflake roles within the same account. Run the below grant command for the same.

```sql
USE  ROLE airflow_admin_rl;
USE SCHEMA airflow_db.airflow_schema;
GRANT SERVICE ROLE airflow_service!ALL_ENDPOINTS_USAGE TO ROLE <role-name>;
```

<!-- ------------------------ -->
## Run a DAG

Duration: 5

Once all the services have created successfully and the containers are in running state, run the below command in Snowsight to get the endpoint for Airflow UI.

```sql
USE  ROLE airflow_admin_rl;
USE SCHEMA airflow_db.airflow_schema;
SHOW ENDPOINTS IN SERVICE airflow_service;
```
##
![End Points](assets/show_endpoints.png)
##

Copy `webserver` container `ingress_url` to the browser, after successful authentication you will be redirected to Airflow Login page. 

##
![Airflow Login](assets/airflow_login.png)
##

Pass the credentials as `airflow/airflow`. You will be redirected to Airflow DAGs home page.

In the home page, you will be seeing below two DAGs which are extracted from Snowflake stage `@airflow_db.airflow_schema.airflow_dags` mounted as a volume to Airflow containers.

##
![Airflow DAGs](assets/stage.png)
##


Enable `sample_python_dag`, this should run once.

##
![Sample DAG](assets/sample_dag.png)
##

Task Logs are persisted in Snowflake's internal stage `@airflow_db.airflow_schema.airflow_logs`

##
![Task Logs](assets/snow_task_logs.png)
##

<!-- ------------------------ -->
## Clean up

Duration: 2

Snowflake charges for the Compute Pool nodes that are active for your account. (See [Working With Compute Pools](https://docs.snowflake.com/developer-guide/snowpark-container-services/working-with-compute-pool)). To prevent unwanted charges, first stop all services that are currently running on a compute pool. Then, either suspend the compute pool (if you intend to use it again later) or drop it.

1. Stop all the services on the compute pool
```sql
USE ROLE airflow_admin_rl;
ALTER COMPUTE POOL postgres_redis STOP ALL;
ALTER COMPUTE POOL airflow_server STOP ALL;
ALTER COMPUTE POOL airflow_workers STOP ALL;
```

2. Drop the compute pool
```sql
DROP COMPUTE POOL postgres_redis;
DROP COMPUTE POOL airflow_server;
DROP COMPUTE POOL airflow_workers;
```

3. Clean up the image registry (remove all images), drop SnowGIT repository and the internal stage objects(remove specifications)
```sql
DROP IMAGE REPOSITORY airflow_repository;
DROP GIT REPOSITORY airflow_dags_repo;
DROP STAGE service_spec;
DROP STAGE airflow_logs;
DROP STAGE airflow_dags;
```

<!-- ------------------------ -->
## Additional Consideration

Duration: 5

Steps to Integrate Airflow with Okta for RBAC.

1. In Airflow Dockerfile (`/airflow/airflow/Dockerfile`) uncomment below line and save the file. Build the docker image and push it to Snowflake image repository
```
#ADD --chown=airflow:root ./airflow/airflow/webserver_config.py /opt/airflow/webserver_config.py
```

2. Create Snowflake secret object to store Okta app `Client_Id` and `Client_Secret`
3. In `/template/values.yaml` file uncomment below secret objects also set `AIRFLOW__WEBSERVER__AUTHENTICATE` and  `AIRFLOW__WEBSERVER__RBAC` variables to True.

```
      # - snowflakeSecret: airflow_db.airflow_schema.airflow_user
      #   secretKeyRef: password
      #   envVarName: SNOWFLAKE_CONNECTIONS_SNOWHOUSE_PASSWORD
      # - snowflakeSecret: airflow_db.airflow_schema.airflow_spcs_okta
      #   secretKeyRef: username
      #   envVarName: AIRFLOW_WEB_CLIENT_ID
      # - snowflakeSecret: airflow_db.airflow_schema.airflow_spcs_okta
      #   secretKeyRef: password
      #   envVarName: AIRFLOW_WEB_CLIENT_SECRET
      AIRFLOW__WEBSERVER__AUTHENTICATE: False # Change its value to True if you are planning to put the UI behind Okta
      AIRFLOW__WEBSERVER__RBAC: False # Change its value to True if you are planning to put the UI behind Okta
```
4. Run `rendere_templates.py` script and upload `airflow_server.yaml` file to `@service_spec` stage. Once done, restart `airflow_server` service.


<!-- ------------------------ -->
## Conclusion and Resources

### Conclusion

Congratulations! You've successfully hosted Apache Airflow with Celery Executor on Snowpark Container Services.
Running Airflow on Snowpark Container Services simplifies the process of setting up a robust, production-ready orchestration environment. By leveraging Snowflake's integrated ecosystem and scalable infrastructure, you can focus on building and managing your data workflows without the overhead of traditional deployment complexities. Start leveraging the power of Airflow on SPCS today and experience the benefits of a seamless, efficient deployment process.

### What You Learned

- The working mechanics of Snowpark Container Services
- How to build and push a containerized Docker image to SPCS along with code and data files
- How to create SnowGIT integration with your Github repository
- How to create External Access Integration
- How to deploy Apache Airflow with Celery Executor in SPCS


### Resources

- [Apache Airflow](https://airflow.apache.org/docs/)
- [Celery Executor](https://airflow.apache.org/docs/apache-airflow-providers-celery/stable/celery_executor.html)
- [Snowpark Container Services](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview/)
- [SnowGIT](https://docs.snowflake.com/en/developer-guide/git/git-setting-up)
- [Snowflake Secret Objects](https://docs.snowflake.com/en/sql-reference/sql/create-secret)

author: Gilberto Hernandez, Kamesh Sampath
id: getting-started-snowflake-python-api
summary: Learn how to get started with Snowflake's Python API to manage Snowflake objects and tasks.
categories: Getting-Started
environments: web
status: Published
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Data Science, Data Engineering, Twitter

# Getting Started with the Snowflake Python API

<!-- ------------------------ -->

## Overview

Duration: 1

The Snowflake Python API allows you to manage Snowflake using Python. Using the API, you're able to create, delete, and modify tables, schemas, warehouses, tasks, and much more, in many cases without needing to write SQL or use the Snowflake Connector for Python. In this Quickstart, you'll learn how to get started with the Snowflake Python API for object and task management with Snowflake.

### Prerequisites

- Familiarity with Python
- Familiarity with Jupyter Notebooks

### What You’ll Learn

- How to install the Snowflake Python API library
- How to create a Root object to use the API
- How to create tables, schemas, and warehouses using the API
- How to create and manage tasks using the API
- How to use Snowpark Container Services with the Snowflake Python API

### What You’ll Need

- A Snowflake account ([trial](https://signup.snowflake.com/?utm_cta=quickstarts_), or otherwise)
- A code editor that supports Jupyter notebooks, or ability to run notebooks in your browser using `jupyter notebook`

### What You’ll Build

- Multiple objects within Snowflake

<!-- ------------------------ -->

## Install the Snowflake Python API

Duration: 8

> aside negative
>
> **Important**
> The Snowflake Python API is currently supported in Python versions 3.8, 3.9., and 3.10.

Before installing the Snowflake Python API, we'll start by activating a Python environment.

**Conda**

If you're using conda, you can create and activate a conda environment using the following commands:

```bash
conda create -n <env_name> python==3.10
```

```bash
conda activate <env_name>
```

**venv**

If you're using venv, you can create and activate a virtual environment using the following commands:

```bash
python3 -m venv '.venv'
```

```bash
source '.venv/bin/activate'
```

The Snowflake Python API is available via PyPi. Install it by running the following command:

```bash
pip install snowflake -U
```

## Configure Snowflake

Let us create `$HOME/.snowflake/config.toml` with the following content and update it with your actual credentials. The connection details `default` under table `connections` i.e.`connections.default` will be used to establish a connection with Snowflake.

```toml
[connections]
[connections.default]
account = "YOUR ACCOUNT NAME"
user = "YOUR ACCOUNT USER"
password = "YOUR ACCOUNT USER PASSWORD"
# optional
# warehouse = "COMPUTE_WH"
# optional
# database = "COMPUTE_WH"
# optional
# schema = "PUBLIC"
```

Next create a `connections_params` dictionary as show below and set the connection to use for the session,

```py
  connection_params = {
   "connection_name": "default",
  }
```

<!-- ------------------------ -->

## Overview of the Snowflake Python API

Duration: 5

Let's quickly take a look at how the Snowflake Python API is organized:

| **Module**                        | **Description**                                                                                                   |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `snowflake.core`                  | Defines an Iterator to represent a certain resource instances fetched from the Snowflake database                 |
| `snowflake.core.paging`           |                                                                                                                   |
| `snowflake.core.exceptions`       |                                                                                                                   |
| `snowflake.core.database`         | Manages Snowflake databases                                                                                       |
| `snowflake.core.schema`           | Manages Snowflake schemas                                                                                         |
| `snowflake.core.task`             | Manages Snowflake Tasks                                                                                           |
| `snowflake.core.task.context`     | Manage the context in a Snowflake Task                                                                            |
| `snowflake.core.task.dagv1`       | A set of higher-level APIs than the lower-level Task APIs in snowflake.core.task to more conveniently manage DAGs |
| `snowflake.core.compute_pool`     | Manages Snowpark Container Compute Pools                                                                          |
| `snowflake.core.image_repository` | Manages Snowpark Container Image Repositories                                                                     |
| `snowflake.core.service`          | Manages Snowpark Container Services                                                                               |

`snowflake.core` represents the entry point to the core Snowflake Python APIs that manage Snowflake objects. To use the Snowflake Python API, you'll follow a common pattern:

1. Establish a session using Snowpark or a Python connector connection, representing your connection to Snowflake.

2. Import and instantiate the `Root` class from `snowflake.core`, and pass in the Snowpark session object as an argument. You'll use the resulting `Root` object to use the rest of the methods and types in the Snowflake Python API.

Here's an example of what this pattern typically looks like:

```py
from snowflake.snowpark import Session
from snowflake.core import Root

session = Session.builder.configs(connection_params).create()
root = Root(session)
```

For more information on various connection options/attributes, see [Connecting to Snowflake with the Snowflake Python API](https://docs.snowflake.com/en/LIMITEDACCESS/snowflake-python-api/snowflake-python-connecting-snowflake).

> aside negative
>
> **NOTE**
> The Snowflake Python API can establish a connection to Snowflake via a Snowpark session or a Python connector connection. In the example above, we opt for a Snowpark session.

Let's get started!

<!-- ------------------------ -->

## Set up your development environment

Duration: 10

In this Quickstart, we'll walk through a Jupyter notebook to incrementally showcase the capabilities of the Snowflake Python API. Let's start by setting up your development environment so that you can run the notebook.

1. First, download the [
   Quickstart: Getting Started with the Snowflake Python API notebook](https://github.com/Snowflake-Labs/sfguide-getting-started-snowflake-python-api/blob/main/getting_started_snowflake_python_api.ipynb) from the accompanying repo for this Quickstart.

2. Next, open the notebook in a code editor that supports Jupyter notebooks (i.e., Visual Studio Code).
   Alternatively, open the notebook in your browser by starting a notebook server with `jupyter notebook` and navigating to the notebook in your browser. To do this, you'll need to ensure your environment can run a notebook (be sure to run `conda install notebook` in your terminal, then start the notebook server).

Now run the first cell within the notebook, the one containing the import statements.

```py
from datetime import timedelta
from typing import List

from snowflake.snowpark import Session
from snowflake.snowpark.functions import col
from snowflake.core import Root,CreateMode
from snowflake.core.database import Database
from snowflake.core.schema import Schema
from snowflake.core.table import Table, TableColumn, PrimaryKey
from snowflake.core.warehouse import Warehouse
from snowflake.core._common import CreateMode
from snowflake.core.task import StoredProcedureCall, Task
from snowflake.core.task.dagv1 import DAGOperation, DAG, DAGTask
```

> aside negative
>
> **Note**
> Upon running this cell, you may be prompted to set your Python kernel. We activated a conda environment earlier, so we'll select conda as our Python kernel (i.e., something like `~/miniconda3/envs/<your conda env>/bin/python`).

In this cell, we import Snowpark and the core Snowflake Python APIs that manage Snowflake objects.

Next, configure the `connection_params` dictionary with your account credentials and run the cell.

```py
connection_params = {
    "connection_name": "default"
}
```

Create a Snowpark session and pass in your connection parameters to establish a connection to Snowflake.

```py
session = Session.builder.configs(connection_params).create()
```

Finally, create a `Root` object by passing in your `session` object to the `Root` constructor. Run the cell.

```py
root = Root(session)
```

And that's it! By running these four cells, we're now ready to use the Snowflake Python API.

<!-- ------------------------ -->

## Create a database, schema, and table

Duration: 5

Let's use our `root` object to create a database, schema, and table in your Snowflake account.

Create a database by running the following cell in the notebook:

```py
database = root.databases.create(
  Database(
    name="PYTHON_API_DB"),
    mode=CreateMode.or_replace
  )
```

This line of code creates a database in your account called `PYTHON_API_DB`, and is functionally equivalent to the SQL command `CREATE OR REPLACE DATABASE PYTHON_API_DB;`. This line of code follows a common pattern for managing objects in Snowflake. Let's examine this line of code in a bit more detail:

- `root.databases.create()` is used to create a database in Snowflake. It accepts two arguments, a `Database` object and a mode.

- We pass in a `Database` object with `Database(name="PYTHON_API_DB")`, and set the name of the database using the `name` argument. Recall that we imported `Database` on line 3 of the notebook.

- We specify the creation mode by passing in the `mode` argument. In this case, we set it to `CreateMode.or_replace`, but other valid values are `CreateMode.if_not_exists` (functionally equivalent to `CREATE IF NOT EXISTS` in SQL). If a mode is not specified, the default value will be `CreateMode.error_if_exists`, which means an exception will be raised if the object already exists in Snowflake.

- We'll manage the database programmatically by storing a reference to the database in an object we created called `database`.

Navigate back to the databases section of your Snowflake account. If successful, you should see the `PYTHON_API_DB` database.

![database](./assets/python_api_db.png)

> aside negative
>
> **TIP**:
> If you use VSCode, then install [Snowflake plugin](https://marketplace.visualstudio.com/items?itemName=snowflake.snowflake-vsc) to explore all Snowflake objects from within your editor

Next, create a schema and table in that schema by running the following cells:

```py
schema = database.schemas.create(
  Schema(
    name="PYTHON_API_SCHEMA"),
    mode=CreateMode.or_replace,
  )
```

```py
table = schema.tables.create(
  Table(
    name="PYTHON_API_TABLE",
    columns=[
      TableColumn(
        name="TEMPERATURE",
        datatype="int",
        nullable=False,
      ),
      TableColumn(
        name="LOCATION",
        datatype="string",
      ),
    ],
  ),
mode=CreateMode.or_replace
)
```

The code in both of these cells should look and feel familiar. They follow the pattern you saw in the cell that created the `PYTHON_API_DB` database. The first cell creates a schema in the database created earlier (note `.schemas.create()` is called on the `database` object from earlier). The next cell creates a table in that schema, with two columns and their data types specified - `TEMPERATURE` as `int` and `LOCATION` as `string`.

After running these two cells, navigate back to your Snowflake account and confirm that the objects were created.

![schema and table](./assets/db_schema_table.png)

<!-- ------------------------ -->

## Retrieve object data

Duration: 5

Let's cover a couple of ways to retrieve metadata about an object in Snowflake. Run the following cell:

```py
table_details = table.fetch()
```

`fetch()` returns a `TableModel` object. We can then call `.to_dict()` on the resulting object to view information about the object. Run the next cell:

```py
table_details.to_dict()
```

In the notebook, you should see a dictionary printed that contains metadata about the `PYTHON_API_TABLE` table.

```py
{
    "name": "PYTHON_API_TABLE",
    "kind": "TABLE",
    "enable_schema_evolution": False,
    "change_tracking": False,
    "data_retention_time_in_days": 1,
    "max_data_extension_time_in_days": 14,
    "default_ddl_collation": "",
    "columns": [
        {"name": "TEMPERATURE", "datatype": "fixed", "nullable": False},
        {"name": "LOCATION", "datatype": "text", "nullable": True},
    ],
    "created_on": datetime.datetime(
        2024, 5, 9, 8, 59, 15, 832000, tzinfo=datetime.timezone.utc
    ),
    "database_name": "PYTHON_API_DB",
    "schema_name": "PYTHON_API_SCHEMA",
    "rows": 0,
    "bytes": 0,
    "owner": "ACCOUNTADMIN",
    "automatic_clustering": False,
    "search_optimization": False,
    "owner_role_type": "ROLE",
}
```

As you can see, the dictionary above contains information about the `PYTHON_API_TABLE` table that you created earlier, with detailed information on `columns`, `owner`, `database`, `schema` etc.,

Object metadata is useful when building business logic in your application. For example, you could imagine building logic that executes depending on certain information about an object. `fetch()` would be helpful in retrieving object metadata in such scenarios.

<!-- ------------------------ -->

## Programmatically update a table

Duration: 5

Let's take a look at how you might programmatically add a column to a table. The `PYTHON_API_TABLE` table currently has two columns, `TEMPERATURE` and `LOCATION`, let us add a new column named `ELEVATION` of type `int` and set it as the table's `Primary Key`.

Run the following cell:

```py
table_details.columns.append(
    TableColumn(
      name="elevation",
      datatype="int",
      nullable=False,
      constraints=[PrimaryKey()],
    )
)
```

Note, however, that this line of code does not create the column (you can confirm this by navigating to Snowflake and inspecting the table after running the cell). Instead, this column definition is appended to the array that represents the table's columns in the TableModel. To view this array, take a look at the value of `columns` in the previous step.

To modify the table and add the column, run the next cell:

```py
table.create_or_update(table_details)
```

In this line, we call `create_or_update()` on the object representing `PYTHON_API_TABLE` and pass in the updated value of `table_details`. This line adds the `ELEVATION` column to `PYTHON_API_TABLE`. To quickly confirm, run the following cell:

```py
table.fetch().to_dict()
```

This should be the output:

```py
{
    "name": "PYTHON_API_TABLE",
    "kind": "TABLE",
    "enable_schema_evolution": False,
    "change_tracking": False,
    "data_retention_time_in_days": 1,
    "max_data_extension_time_in_days": 14,
    "default_ddl_collation": "",
    "columns": [
        {"name": "TEMPERATURE", "datatype": "fixed", "nullable": False},
        {"name": "LOCATION", "datatype": "text", "nullable": True},
    ],
    "created_on": datetime.datetime(
        2024, 5, 9, 8, 59, 15, 832000, tzinfo=datetime.timezone.utc
    ),
    "database_name": "PYTHON_API_DB",
    "schema_name": "PYTHON_API_SCHEMA",
    "rows": 0,
    "bytes": 0,
    "owner": "ACCOUNTADMIN",
    "automatic_clustering": False,
    "search_optimization": False,
    "owner_role_type": "ROLE",
}
```

Take a look at the value of `columns`, as well as the value of `constraints`, which now includes the `ELEVATION` column.

Finally, visually confirm by navigating to your Snowflake account and inspecting the table.

![add_column](./assets/add_column.png)

<!-- ------------------------ -->

## Create, suspend, and delete a warehouse

Duration: 5

You can also manage warehouses with the Snowflake Python API. Let's use the API to create, suspend, and delete a warehouse.

Run the following cell:

```py
warehouses = root.warehouses
```

Calling the `.warehouses` property on our `root` returns the collection of warehouses associated with our session. We'll manage warehouses in our session using the resulting `warehouses` object.

Run the next cell:

```py
python_api_wh = Warehouse(
    name="PYTHON_API_WH",
    warehouse_size="SMALL",
    auto_suspend=500,
)

warehouse = warehouses.create(python_api_wh,mode=CreateMode.or_replace)
```

In this cell, we define a new warehouse by instantiating `Warehouse` and specifying the warehouse's name, size, and auto suspend policy. The auto suspend timeout is in units of seconds. In this case, the warehouse will suspend after 8.33 minutes of inactivity.

We then create the warehouse by calling `create()` on our warehouse collection. We store the reference in the resulting `warehouse_ref` object. Navigate to your Snowflake account and confirm that the warehouse was created.

![create warehouse](./assets/create_wh.png)

To retrieve information about the warehouse, run the next cell:

```py
warehouse_details = warehouse.fetch()
warehouse_details.to_dict()
```

The code in this cell should look familiar, as it follows the same patterns we used to fetch table data in a previous step. The output should be:

```py
{'name': 'PYTHON_API_WH',
 'auto_suspend': 500,
 'auto_resume': 'true',
 'resource_monitor': 'null',
 'comment': '',
 'max_concurrency_level': 8,
 'statement_queued_timeout_in_seconds': 0,
 'statement_timeout_in_seconds': 172800,
 'tags': {},
 'type': 'STANDARD',
 'size': 'Small'
}
```

If we had several warehouses in our session, we could use the API to iterate through them or to search for a specific warehouse. Run the next cell:

```py
warehouse_list = warehouses.iter(like="PYTHON_API_WH")
result = next(warehouse_list)
result.to_dict()
```

In this cell, we call `iter()` on the warehouse collection and pass in the `like` argument, which is used to return any warehouses that has a name matching the string we pass in. In this case, we passed in the name of the warehouse we defined earlier, but this argument is generally a case-insensitive string that functions as a filter, with support for SQL wildcard characters like `%` and `_`. You should see the following output after running the cell, which shows that we successfully returned a matching warehouse:

```py
{'name': 'PYTHON_API_WH',
 'auto_suspend': 500,
 'auto_resume': 'true',
 'resource_monitor': 'null',
 'comment': '',
 'max_concurrency_level': 8,
 'statement_queued_timeout_in_seconds': 0,
 'statement_timeout_in_seconds': 172800,
 'tags': {},
 'type': 'STANDARD',
 'size': 'Small'
}
```

To programmatically modify the warehouse we need to do `create` with `CREATE OR REPLACE` mode with modified properties:

```py
warehouse = root.warehouses.create(Warehouse(
    name="PYTHON_API_WH",
    warehouse_size="LARGE",
    auto_suspend=500,
),mode=CreateMode.or_replace)
```

Confirm that the warehouse size was indeed updated to `LARGE` by running the next cell:

```py
warehouse.fetch().size
```

Navigate to your Snowflake account and confirm the change in warehouse size.

![large warw](./assets/large_wh.png)

**OPTIONAL** Delete the warehouse and close your Snowflake session by running the final cell. This is optional so that you can continue to use the warehouse in the subsequent steps. If you run the cell, be sure to create a new warehouse so that you can complete the subsequent steps.

```py
warehouse.delete()
```

Navigate once again to your Snowflake account and confirm the deletion of the warehouse.

![delete wh close session](./assets/delete_wh_close_session.png)

<!-- ------------------------ -->

## Managing tasks

Duration: 10

You can also manage tasks using the Snowflake Python API. Let's use the API to manage a couple of basic stored procedures using tasks.

First, create a stage within the **PYTHON_API_SCHEMA** called **TASKS_STAGE**. This stage will hold the stored procedures and any dependencies those procedures will need.

```py
tasks_stage_name = f"{database.name}.{schema.name}.TASKS_STAGE"
create_query = f"CREATE OR REPLACE STAGE {tasks_stage_name}"
session.connection.execute_string(create_query)
```

> aside: negative
>
> **NOTE**:
> Since we don't yet have the API for manipulating stages, let us create the `TASKS_STAGE` stage using SQL.

Create a couple of basic functions that will be run as stored procedures. `trunc()` creates a truncated version of an input table and `filter_by_shipmode()` creates a 10 row table created by filtering the **SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.LINEITEM** by ship mode. The functions are intentionally basic in nature and are intended to be used for demonstration purposes.

```python
def trunc(session: Session, from_table: str, to_table: str, count: int) -> str:
  (
    session
    .table(from_table)
    .limit(count)
    .write.save_as_table(to_table)
  )
  return "Truncated table successfully created!"

def filter_by_shipmode(session: Session, mode: str) -> str:
    (
      session
      .table("snowflake_sample_data.tpch_sf100.lineitem")
      .filter(col("L_SHIPMODE") == mode)
      .limit(10)
      .write.save_as_table("filter_table")
    )
    return "Filter table successfully created!"
```

Define two tasks, `task1` and `task2`, whose definitions are stored procedures that each refer to the functions created. We specify the stage that will hold the contents of the stored procedure, and also specify packages that are dependencies. Task 1 is the root task, so we specify a warehouse and a schedule (run every minute).

```py
task1 = Task(
    "task_python_api_trunc",
    definition=StoredProcedureCall(
      trunc,
      stage_location=f"@{tasks_stage_name}",
      packages=["snowflake-snowpark-python"],
    ),
    warehouse="COMPUTE_WH",
    schedule=timedelta(minutes=1)
)

task2 = Task(
    "task_python_api_filter",
    definition=StoredProcedureCall(
      filter_by_shipmode,
      stage_location=f"@{tasks_stage_name}",
      packages=["snowflake-snowpark-python"],
    ),
    warehouse="COMPUTE_WH"
)
```

You can check more details on Snowflake documentation on [Writing stored procedures in Python](https://docs.snowflake.com/en/developer-guide/stored-procedure/stored-procedures-python).

Now create the two tasks by first retrieving a TaskCollection object (`tasks`) and adding the two tasks to that object. We will also set `task1` as a predecessor to t`ask2`, which links the tasks, creating a DAG (albeit, a small one).

```python
# create the task into the Snowflake database
tasks = schema.tasks

trunc_task = tasks.create(task1, mode=CreateMode.or_replace)
# should be fully qualified name
task2.predecessors = [f"{trunc_task.database.name}.{trunc_task.schema.name}.{trunc_task.name}"]
filter_task = tasks.create(task2, mode=CreateMode.or_replace)
```

Navigate back to your Snowflake account and confirm that the two tasks now exist.

![tasks](./assets/tasks.png)

![minidag](./assets/minidag.png)

When created, tasks are suspended by default. To start them, call `.resume()` on the task. Run the following cell in the notebook:

```python
trunc_task.resume()
```

Navigate to your Snowflake account and observe that the `trunc_task` task was started. You can check the status of the task by running the next cell:

```python
taskiter = tasks.iter()
for t in taskiter:
    print("Name: ", t.name, "| State: ", t.state)
```

You should see an output similar to the following:

```console
Name:  TASK_PYTHON_API_FILTER | State:  suspended
Name:  TASK_PYTHON_API_TRUNC | State:  started
```

Let's wrap things up by suspending the task, and then deleting both tasks. Run the following cell:

```python
trunc_task.suspend()
```

Navigate to your Snowflake account to confirm that the task is indeed suspended.

(Optional) Finally, delete both tasks by running the following cell:

```python
trunc_task.delete()
filter_task.delete()
```

<!-- ------------------------ -->

## Managing Directd Acyclic Graphs(DAG)

Duration: 8

When the number of tasks that must be managed becomes very large, individually managing each task can be a challenge. The Snowflake Python API provides functionality to orchestrate tasks with a higher level DAG API. Let's take a look at how it can be used.

As part of the next cell we will do,

- Create a DAG object by calling the `DAG` constructor, and specifying a DAG name and schedule.

- Define DAG-specific tasks using the `DAGTask` constructor. Note that the constructor accepts the same arguments that were specified in an earlier cell (in the previous step) when using the `StoredProcedureCall` class.

- Specifie `dag_task1` as the root task and predecessor to `dag_task2`, with more convenient syntax.

- Deploys the DAG to the `PYTHON_API_SCHEMA` schema.

```python
dag_name = "python_api_dag"
dag = DAG(dag_name, schedule=timedelta(days=1))
with dag:
    dag_task1 = DAGTask(
        "task_python_api_trunc",
        StoredProcedureCall(
            trunc,
            stage_location=f"@{tasks_stage_name}",
            packages=["snowflake-snowpark-python"]),
        warehouse="COMPUTE_WH",
    )
    dag_task2 = DAGTask(
        "task_python_api_filter",
        StoredProcedureCall(
            filter_by_shipmode,
            stage_location=f"@{tasks_stage_name}",
            packages=["snowflake-snowpark-python"]),
        warehouse="COMPUTE_WH",
    )
    dag_task1 >> dag_task2
dag_op = DAGOperation(schema)
dag_op.deploy(dag, mode=CreateMode.or_replace)
```

Navigate to your Snowflake account and confirm the creation of the DAG.

![dag](./assets/dag.png)

![daggraph](./assets/daggraph.png)

Start the DAG by starting the root task by running the following cell:

```python
dag_op.run(dag)
```

Optionally, navigate to your Snowflake account and confirm that `PYTHON_API_DAG$TASK_PYTHON_API_TRUNC` task was started. The call to the function will not succeed as we are not calling it with any of its required arguments. The purpose of this cell is simply to demonstrate how to programatically start the DAG.

Finally, delete the DAG by running the following cell:

```python
dag_op.delete(dag)
```

Clean up all the objects that was created with this quickstart and close the session.

```python
database.delete()
session.close()
```

<!-- ------------------------ -->

## Managing Snowpark Container Services

Duration: 10

> aside negative
>
> **Important**
> At the time of writing, Snowpark Container Services is in Public Preview in select AWS regions. To use Snowpark Container Services, your Snowflake account must be in one of the select AWS regions. For more information, refer to [Snowpark Container Services – Available Regions](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview#available-regions).

Snowpark Container Services is a fully managed container offering designed to facilitate the deployment, management, and scaling of containerized applications within the Snowflake ecosystem. The service enables users to run containerized workloads directly within Snowflake. Let's take a look at how you can manage Snowpark Container Services with the Snowflake Python API.

For this section, we'll switch to a new notebook. The notebook contains **sample code** that runs an NGINX web server using Snowpark Container Services, all running in Snowflake. The notebook is provided for convenience and demonstrative purposes.

Download and open the following notebook in your preferred code editor, or with `jupyter notebook`: [Snowpark Container Services – Python API](https://github.com/Snowflake-Labs/sfguide-getting-started-snowflake-python-api/blob/main/snowpark_container_services_python_api.ipynb).

In the first cell, we import the required libraries, create our connection to Snowflake, and instantiate our `Root` object. We also create objects to represent references to existing Snowflake objects in a Snowflake account. Our Snowpark Container Services will reside in the **PUBLIC** schema.

```python
from pprint import pprint
from snowflake.core import Root
from snowflake.core.service import ServiceSpecInlineText
from snowflake.snowpark import Session

session = Session.builder.config("connection_name", "python_api").create()
api_root = Root(session)
database = api_root.databases["spcs_python_api_db"]
schema = database.schemas["public"]
```

When orchestrating Snowpark Container Services, there are a couple of patterns you'll typically follow:

- **Define a compute pool** – A compute pool represents a set of compute resources (virtual machine nodes). You can think of these compute resources as analogous (but not equivalent) to Snowflake virtual warehouses. The service (in this case, our NGINX service) will run in the compute pool. Compute-intensive services will require high-powered compute pools (i.e., many cores, many GPUs), while less intensive services can run in smaller compute pools (fewer cores). For more information, see [Snowpark Container Services: Working with compute pools](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-compute-pool).

- **Define the service** – A service is how you run an application container. The services require, at minimum, a specification and a compute pool. A specification contains the information needed to run the application container, like the path to a container image, endpoints that the services will expose, and more. The specification is written in YML. The compute pool is what the service will run in. For more information, see [Snowpark Container Services: Working with services](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-services).

Let's cover these patterns in the notebook. Take a look at the following cell:

```python
new_compute_pool_def = ComputePool(
    name="MyComputePool",
    instance_family="CPU_X64_XS",
    min_nodes=1,
    max_nodes=2,
)

new_compute_pool = api_root.compute_pools.create(new_compute_pool_def)
```

In this cell, we define a compute pool using the `ComputePool` constructor, and provide a name, instance family, and the min and max number of nodes. We then create the compute pool and pass in the compute pool definition.

Here are some details behind the arguments passed into the constructor:

- `instance_family` – An instance family refers to the type of machine you want to provision for the nodes in the compute pool. Different machines have different amounts of compute resources in their compute pools. In this cell, we use `CPU_X64_XS`, which is the smallest available machine type. See [CREATE COMPUTE POOL: Required parameters](https://docs.snowflake.com/en/sql-reference/sql/create-compute-pool#required-parameters) for more detail.

- `min_nodes`, `max_nodes` – The lower and upper bounds for nodes in the compute pool. After creating a compute pool, Snowflake launches the minimum number of nodes. New nodes are created – up to the maximum specified – when the running nodes cannot take any additional workload. This is called **autoscaling**. For more information, see [Snowpark Container Services: Working with compute pools](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-compute-pool).

It's time to build our service. Take a look at the next cell:

```python
image_repository = schema.image_repositories["MyImageRepository"]
```

In this cell, we retrieve the repository containing our container image. This repository is in the Snowflake account, listed as a stage in the **PUBLIC** schema. We'll need this reference to fetch container image information, which you can see referenced in the next cell:

```python
from textwrap import dedent
from io import BytesIO
from snowflake.core.service import Service
session.use_role("my_role")  # Perhaps this role has permission to create and run a service
specification = dedent(f"""\
            spec:
              containers:
              - name: web-server
                image: {image_repository.fetch().repository_url}/nginx:latest
              endpoints:
              - name: ui
                port: 80
                public: true
             """)

service_def = Service(
    name="MyService",
    compute_pool="MyComputePool",
    spec=ServiceSpecInlineText(specification),
    min_instances=1,
    max_instances=1,
)

nginx_service = schema.services.create(service_def)
```

This cell defines the service specification, the service, and creates the service for our NGINX web server. You should note a few things:

- `specification` – We define the specification using a Python f-string. The string is formatted as YML. It contains the name of the container, a path to the container image, and endpoints that the service will expose to be able to access the service publicly. Although the specification is defined inline, it could also been a reference to a **.yml** file in a stage.

- `service_def` – We define a service with the `Service` constructor, passing in a name for the service, the compute pool it should run in, a path to the specification, and the total number of instances for the service. Note that `ServiceSpecInlineText` is used when setting `spec` in this cell. This is because the specification was defined inline as an f-string. Multiple instances of the service could be run, but in this example we want only one instance of the service to run, which is set via `min_instances` and `max_instances`.

With the service created, the next cell will output the status of the service.

```python
pprint(nginx_service.get_service_status(timeout=5))
```

Sample output of the cell:

```console
{'auto_resume': True,
 'auto_suspend_secs': 3600,
 'instance_family': 'CPU_X64_XS',
 'max_nodes': 1,
 'min_nodes': 1,
 'name': 'MyService'}
```

It'll take a few minutes for the endpoints that are needed to access the service to be provisioned. The next cell isn't specific to Snowpark Container Services or the Snowflake Python API – it simply provides a handy way to inspect whether the endpoints are ready. Note that we fetch the endpoints by calling `.fetch().public_endpoints` on our service object.

```python
import json, time
while True:
    public_endpoints = nginx_service.fetch().public_endpoints
    try:
        endpoints = json.loads(public_endpoints)
    except json.JSONDecodeError:
        print(public_endpoints)
        time.sleep(15)
    else:
        break
```

Sample output of the cell:

```console
Endpoints provisioning in progress... check back in a few minutes
Endpoints provisioning in progress... check back in a few minutes
Endpoints provisioning in progress... check back in a few minutes
```

Once the endpoints are provisioned, the next cell will open the public endpoints in your browser.

```python
print(f"Visiting {endpoints['ui']} in your browser. You may need to log in there.")
import webbrowser
webbrowser.open(f"https://{endpoints['ui']}")
```

Sample output of the cell:

```console
Visiting fekqoap7-orgname-sslpr.snowflakecomputing.app in your browser. You may need to log in there.
```

If successful, you'll see the NGINX success page in your browser when visiting the endpoint:

![minidag](./assets/nginx-success.png)

With just a few lines of Python, we were able to run an NGINX web server in Snowflake using Snowpark Container Services.

The next cells will suspend and delete the compute pool and the service:

```python
new_compute_pool_def.suspend()
nginx_service.suspend()
```

```python
new_compute_pool_def.delete()
nginx_service.delete()
```

<!-- ------------------------ -->

## Conclusion

Duration: 1

Congratulations! In this Quickstart, you learned the fundamentals for managing Snowflake objects, tasks, DAGs, and Snowpark Container Services using the Snowflake Python API.

### What we've covered

- Installing the Snowflake Python API
- Creating databases, schemas, and tables
- Retrieving object information
- Programmatically updating an object
- Creating, suspending, and deleting warehouses
- How to manage tasks and DAGs
- How to manage Snowpark Container Services

### Additional resources

- [Snowflake Documentation: Snowflake Python API](https://docs.snowflake.com/en/LIMITEDACCESS/snowflake-python-api/snowflake-python-overview)

- [Snowflake Python API Reference Documentation](https://docs.snowflake.com/en/LIMITEDACCESS/snowflake-python-api/reference/0.1.0/index.html)

author: Tomasz Urbaszek, Gilberto Hernandez, Bhumika Goel, David Wang
summary: Getting Started with Snowflake CLI
id:getting-started-with-snowflake-cli
categories: getting-started
environments: web
status: Published 
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, SQL, Data Engineering, SnowSQL

# Getting Started with Snowflake CLI
<!-- ------------------------ -->
## Overview 
Duration: 2


Snowflake CLI is a command-line interface designed for developers building apps on Snowflake. Using Snowflake CLI, you can manage a Snowflake Native App, Snowpark functions, stored procedures, Snowpark Container Services, and much more. This guide will show you how to configure and efficiently use Snowflake CLI.



### Prerequisites
- [Video: Introduction to Snowflake](https://www.youtube.com/watch?v=gGPKYGN0VQM)
- [Video: Snowflake Data Loading Basics](https://youtu.be/htLsbrJDUqk?si=vfTjL6JaCdEFdiSG)
- Basic knowledge of Snowflake concepts
- You'll need a Snowflake account. You can sign up for a free 30-day trial account here: [https://signup.snowflake.com/](https://signup.snowflake.com/?utm_cta=quickstarts_).

### What You’ll Learn
- How to install Snowflake CLI
- How to configure Snowflake CLI
- How to switch between different Snowflake connections
- How to download and upload files using Snowflake CLI
- How to execute SQL using Snowflake CLI
- How to manage Snowflake objects
- How to build and deploy Snowpark and Streamlit applications
- How to build and deploy a Snowflake Native App
- How to create and deploy Snowpark Container Services projects

<!-- ------------------------ -->
## Install Snowflake CLI
Duration: 6
First, you’ll install the Snowflake CLI, and later you'll configure it to connect to your Snowflake account.

### Create a Snowflake Account

You'll need a Snowflake account. You can sign up for a free 30-day trial account here: [https://signup.snowflake.com/](https://signup.snowflake.com/?utm_cta=quickstarts_).

### Access Snowflake’s Web Interface

Navigate to [https://app.snowflake.com/](https://app.snowflake.com/) and log into your Snowflake account.


### Install the Snowflake CLI 

Snowflake CLI can be installed on Linux, Windows, or Mac. To install it we recommend using
package manager dedicated for your operating system. Follow the detailed instruction from the [official documentation](https://docs.snowflake.com/developer-guide/snowflake-cli/installation/installation#install-sf-cli-using-package-managers)
to install the CLI.

Once the CLI has been successfully installed, run the following command to verify that it was successfully installed:

```bash
snow --help
```

If Snowflake CLI was installed successfully, you should see output similar to the following:

```bash
Usage: snow [OPTIONS] COMMAND [ARGS]...                                                        
                                                                                                
 Snowflake CLI tool for developers.                                                             
                                                                                                
╭─ Options ────────────────────────────────────────────────────────────────────────────────────╮
│ --version                    Shows version of the Snowflake CLI                              │
│ --info                       Shows information about the Snowflake CLI                       │
│ --config-file          FILE  Specifies Snowflake CLI configuration file that should be used  │
│                              [default: None]                                                 │
│ --help         -h            Show this message and exit.                                     │
╰──────────────────────────────────────────────────────────────────────────────────────────────╯
╭─ Commands ───────────────────────────────────────────────────────────────────────────────────╮
│ app         Manages a Snowflake Native App                                                   │
│ connection  Manages connections to Snowflake.                                                │
│ object      Manages Snowflake objects like warehouses and stages                             │
│ snowpark    Manages procedures and functions.                                                │
│ spcs        Manages Snowpark Container Services compute pools, services, image registries,   │
│             and image repositories.                                                          │
│ sql         Executes Snowflake query.                                                        │
│ streamlit   Manages Streamlit in Snowflake.                                                  │
╰──────────────────────────────────────────────────────────────────────────────────────────────╯
```

### Troubleshooting

You may encounter an error like the following when attempting to use Snowflake CLI for the first time:

```console
╭─ Error ──────────────────────────────────────────────────────────────────────────────────────╮
│ Configuration file /Users/yourusername/.snowflake/config.toml has too wide permissions, run    │
│ `chmod 0600 "/Users/yourusername/.snowflake/config.toml"`                                      │
╰──────────────────────────────────────────────────────────────────────────────────────────────╯
```

In this case, run `chmod 0600 "/Users/yourusername/.snowflake/config.toml"` in the terminal to update the permissions on the file. After running this command, run `snow --help` again. You should see the output shown earlier in this section.

### Configure connection to Snowflake

Snowflake CLI uses a [configuration file named **config.toml** for storing your Snowflake connections](https://docs.snowflake.com/en/developer-guide/snowflake-cli-v2/connecting/specify-credentials#how-to-add-snowflake-credentials-using-a-configuration-file) . This file is created automatically when
you run Snowflake CLI for the first time. The file is typically created at **~/.snowflake/config.toml**, but to confirm the default config file path, run the following command:

```console
snow --info
```

The output will be an array of dictionaries. One of the dictionaries will contain the default config file path, similar to the following:


```console
...

{
  "key": "default_config_file_path",
  "value": "/Users/yourusername/.snowflake/config.toml
},

...
```

You can add your connection details within **config.toml** either manually or by using Snowflake CLI. Let's add a connection using Snowflake CLI.

To add a new connection, run the following:

```bash
snow connection add
```

The command will guide you through defining a connection. You can omit all fields denoted by `[optional]` by pressing "Enter" or "return" on your keyboard.

Here's an example:

```console
Name for this connection: my_connection
Snowflake account name: my_account
Snowflake username: jdoe
Snowflake password [optional]: 
Role for the connection [optional]: 
Warehouse for the connection [optional]: 
Database for the connection [optional]: 
Schema for the connection [optional]: 
Connection host [optional]: 
Connection port [optional]: 
Snowflake region [optional]: 
Authentication method [optional]: 
Path to private key file [optional]: 
```
For more detailed information about configuring connections see DOCS LINK.

### Test connection to Snowflake

To test a connection to Snowflake, run the following command

```bash
snow connection test --connection my_connection
```

In the example above, we use `my_connection` as the connection name, as it corresponds to the prior example connection. To test your connection, replace `my_connection` with the name of the connection you defined during the connection definition process.

<!-- ------------------------ -->
## Working with connections
Duration: 5

An understanding of connections is critical for efficiently working with Snowflake CLI. In the next step, you'll learn how to work with connections.

### Default connection

You can define a default Snowflake connection by adding the following at the top of **config.toml**:

```toml
default_connection_name = "my_connection"
```

This is the connection that will be used by default if you do not specify a connection name when using the `-c` or `--connection` flag with Snowflake CLI.

You can also set a default connection directly from the terminal:

```bash
snow connection set-default <connection-name>
```

Running `set-default` will update your `config.toml` file to use the specified connection as the default connection. This command is incredibly convenient if you work across multiple Snowflake accounts.

### Using multiple connections

By default, Snowflake CLI commands operate within context of a specified connection. The only required fields in a named connection in **config.toml** are `user` and `account`, however, many Snowflake CLI commands require `database`, `schema`, or `warehouse` to be set in order for a command to be successful. For this reason, it's convenient to proactively set these fields in your named connections:

```toml
[connections.my_connection]
user = "jdoe"
account = "my_account"
database = "jdoe_db"
warehouse = "xs"
```

This is especially recommended if you usually work with a particular context (i.e., a single database, dedicated warehouse, or role, etc.).

If you switch your Snowflake context often (for example, when using different roles), it's good practice to define several connections that each correspond to a specific context, like so:

```toml
[connections.admin_connection]
user = "jdoe"
account = "my_account"
role = "accountadmin"

[connections.eng_connection]
user = "jdoe"
account = "my_account"
role = "eng_ops_rl"
```

In such cases, switching between multiple connections can be easily done by using the `snow connection set-default` command shown previously.

### Overriding connection details

There may be instances where you might want to override connection details without directly editing **config.toml**. You can do this in one of the following ways:

1. Using connection flags in CLI commands
2. Using environment variables

#### Using CLI flags

All commands that require an established connection to Snowflake support the following flags:

```console
╭─ Connection configuration ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ --connection,--environment  -c      TEXT  Name of the connection, as defined in your `config.toml`. Default: `default`.                                                                                 │
│ --account,--accountname             TEXT  Name assigned to your Snowflake account. Overrides the value specified for the connection.                                                                    │
│ --user,--username                   TEXT  Username to connect to Snowflake. Overrides the value specified for the connection.                                                                           │
│ --password                          TEXT  Snowflake password. Overrides the value specified for the connection.                                                                                         │
│ --authenticator                     TEXT  Snowflake authenticator. Overrides the value specified for the connection.                                                                                    │
│ --private-key-path                  TEXT  Snowflake private key path. Overrides the value specified for the connection.                                                                                 │
│ --database,--dbname                 TEXT  Database to use. Overrides the value specified for the connection.                                                                                            │
│ --schema,--schemaname               TEXT  Database schema to use. Overrides the value specified for the connection.                                                                                     │
│ --role,--rolename                   TEXT  Role to use. Overrides the value specified for the connection.                                                                                                │
│ --warehouse                         TEXT  Warehouse to use. Overrides the value specified for the connection.                                                                                           │
│ --temporary-connection      -x            Uses connection defined with command line parameters, instead of one defined in config                                                                        │
│ --mfa-passcode                      TEXT  Token to use for multi-factor authentication (MFA)                                                                                                            │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

You can access this list by running any Snowflake CLI command with `--help`.

You can override any of the connection settings above directly from the CLI. Overriding a connection detail using a CLI flag will always take precedence over other overwriting methods (as in the next section).

#### Using environment variables

Another option for overriding connection details is to use environment variables. This option is recommended for passwords or any other sensitive information, especially if you use Snowflake CLI with external systems (e.g., CI/CD pipelines, etc.)

For every connection field, there are two flags:

1. A generic flag in form of `SNOWFLAKE_[KEY]`

2. A connection-specific flag in form of `SNOWFLAKE_CONNECTIONS_[CONNECTION_NAME]_[KEY]`

Connection specific flags take precedence over generic flags. 

Let's take a look at an example, where we test a connection with a role that doesn't exist in that Snowflake environment:

```bash
SNOWFLAKE_ROLE=funny_role snow connection test
```

If the role does not exist, you should see error similar the one below:

```console
╭─ Error ───────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Invalid connection configuration. 250001 (08001): None: Failed to connect to DB: myacc.snowflakecomputing.com:443.    │
│ Role 'FUNNY_ROLE' specified in the connect string does not exist or not authorized. Contact your local system         │
│ administrator, or attempt to login with another role, e.g. PUBLIC.                                                    │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### Using temporary connection

In situations where you are unable to add a new connection to **config.toml**, you may specify a temporary connection directly from the command line using the `-x` or `--temporary-connection` flags. These flags allow you to specify connection details inline, like so:


```bash
snow sql -q "SELECT r_value FROM my_table LIMIT 10" -x --account=<account_name> --user=<user_name> --password=<your_password>
```

In the example above, we establish a temporary connection to Snowflake and execute the `SELECT r_value FROM my_table LIMIT 10` SQL statement.

> aside negative
> 
> **Note:** If your account does not allow password authentication, use proper authentication using `--authenticator`.


## Using Snowflake CLI to execute SQL commands
Duration: 6

Snowflake CLI enables basic execution of SQL. In this step you will learn how to execute ad-hoc queries or entire SQL files.

### The `sql` command

To execute SQL queries using Snowflake CLI, you can use the `snow sql` command. 

The `snow sql` command can be run as follows:

```console
snow sql --help                
                                                                                                                         
 Usage: snow sql [OPTIONS]                                                                                               
                                                                                                                         
 Executes Snowflake query.                                                                                               
 Query to execute can be specified using query option, filename option (all queries from file will be executed) or via   
 stdin by piping output from other command. For example `cat my.sql | snow sql -i`.                                      
                                                                                                                         
╭─ Options ─────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ --query     -q      TEXT  Query to execute. [default: None]                                                           │
│ --filename  -f      FILE  File to execute. [default: None]                                                            │
│ --stdin     -i            Read the query from standard input. Use it when piping input to this command.               │
│ --help      -h            Show this message and exit.                                                                 │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

Whenever you're working with a new Snowflake CLI command, consider running it initially with the `--help` flag  to learn more about how to use it.usages.

### Executing ad-hoc query

To execute an ad-hoc query run the following command:
```bash
snow sql --query "select 1 as a, 2 as b, 3 as c"
```

This command will output the following:

```
+-----------+
| A | B | C |
|---+---+---|
| 1 | 2 | 3 |
+-----------+

```

You can execute multiple queries using `--query` parameter. For example:
```bash
snow sql --query "select 42 as a; select 2 as b"
```

This will return result for each query separately:
```
select 42 as a;
+----+
| A  |
|----|
| 42 |
+----+

select 2 as b
+---+
| B |
|---|
| 2 |
+---+
```

#### Process the output programmatically

You may encounter situations where you might want to process the output of a SQL query programmatically. To do this, you'll need to change the output format of the command output. 

Currently Snowflake CLI supports only JSON output. To format the output of your SQL queries to JSON, you'll need to add `--format=JSON` to your query commands.

Let's re-run the above examples using JSON format. To do so run the following command:
```bash
snow sql --query "select 1 as a, 2 as b, 3 as c" --format=JSON
```
This will return data as single array (because there's only single query) with rows:
```json
[
  {
    "A": 1,
    "B": 2,
    "C": 3
  }
]
```

Next run the other example with JSON format:

```bash
snow sql --query "select 42 as a; select 2 as b" --format=JSON
```
In this case data will be returned as array of arrays due to executing multiple queries:
```json
[
  [
    {
      "A"  :   42
    }
  ],
  [
    {
      "B"  :   2
    }
  ]
]

```

### Executing query from file

Snowflake CLI also allows you to execute SQL files. Let's start by preparing a SQL file with a very simple script.

First, write `select 1` to a file called **test.sql**. This will create the file in your working directory.

```bash
echo "select 1 as a;" >> test.sql
```

Next, execute the contents of the file by running the following:

```bash
snow sql --filename test.sql
```

As a result you should see the following output:
```console
+---+
| a |
|---|
| 1 |
+---+
```

### Templating SQL queries

In many case you may want to change your queries depending on some context, for example type of environment (production vs. testing).
This is possible thanks to client-side templating in Snowflake CLI. We call it client-side to distinguish if from [server-side rendering
supported by EXECUTE IMMEDIATE FROM](https://docs.snowflake.com/en/sql-reference/sql/execute-immediate-from#jinja2-templating).

Snowflake CLI is using `<% VARIABLE_NAME %>` pattern for specifying variables in SQL. You can use templates in both ad-hoc queries
and files.

Variables can be defined using `-D/--variable` flag in `snow sql` command. The input for this flag has to be in form of
`key=value` string.

To test out the templating functionality run the following command:
```bash
snow sql -q "select <% my_var %> + 2" -D "my_var=40"
```
in the result you should see the following:
```console
select 40 + 2
+--------+
| 40 + 2 |
|--------|
| 42     |
+--------+
```

## Managing Snowflake objects
Duration: 5

Snowflake CLI offers commands for generic object operations like `SHOW`, `DROP` and `DESCRIBE`. Those commands are available under `snow object` command.

### Prerequisites

Let's create a new database using `snow sql`:

```bash
snow sql -q "create database snowflake_cli_db"
```

### Listing objects

Snowflake CLI allows you to list existing objects of given type. In this example we will use `database`` as the type.

To list available databases to you run:

```bash
snow object list database
```

You can filter results by specifying `--like` flag. For example running the following command should return only one database:

```bash
snow object list database --like=snowflake_cli_db
```

To learn more about supported objects, run `snow object list --help`.

### Describing objects

Snowflake CLI allows you to describe objects of a given type. In this example, we will use `database`` as the type.

By running the following command you will get details of the database we created in previous steps:

```bash
snow object describe database snowflake_cli_db
```

To check for list of supported objects run `snow object describe --help`.


### Dropping objects

Snowflake CLI allows you to drop existing objects of a given type. In this example we will use `database`` as the type.

By running the following command you will drop the database we created in previous steps:

```bash
snow object drop database snowflake_cli_db
```

To check for list of supported objects run `snow object drop --help`.

## Using Snowflake CLI to work with stages
Duration: 10

You can use Snowflake CLI to work with stages. In this step you will learn how to use the `snow stage` commands.

### Prerequisites

Commands in this section require a `database` and `schema` to be specified in your connection details. If you skipped creating `snowflake_cli_db` database in previous steps, you should create it now by running the following command:

```bash
snow sql -q "create database snowflake_cli_db"
```

After running the command you should see output similar to this one:
```console
+---------------------------------------------------+
| status                                            |
|---------------------------------------------------|
| Database SNOWFLAKE_CLI_DB successfully created.   |
+---------------------------------------------------+
```

### Creating a stage

You can create a new stage using by running the following command:

```bash
snow stage create snowflake_cli_db.public.my_stage
```

If the command succeeds, you should see the following output:

```console
+----------------------------------------------------+
| key    | value                                     |
|--------+-------------------------------------------|
| status | Stage area MY_STAGE successfully created. |
+----------------------------------------------------+
```

### Uploading files to a stage

Now that the stage is created, you can upload files from your local file system to the stage. First, you'll need to create these files before uploading them.

Let's create an empty CSV file:

```bash
touch data.csv
```

Next, upload this file to the stage by running the following command:

```bash
snow stage copy data.csv @snowflake_cli_db.public.my_stage
```

Running this command should return the following output:

```console
+----------------------------------------------------------------------------------------------------------------+
| source   | target   | source_size | target_size | source_compression | target_compression | status   | message |
|----------+----------+-------------+-------------+--------------------+--------------------+----------+---------|
| data.csv | data.csv | 0           | 16          | NONE               | NONE               | UPLOADED |         |
+----------------------------------------------------------------------------------------------------------------+
```

### Listing stage contents

At this point you should have a stage with a single file in it. To list the contents of the stage, you can run:

```bash
snow stage list @snowflake_cli_db.public.my_stage 
```

After running this command you should see output similar to the folowing:

```console
+--------------------------------------------------------------------------------------------+
| name              | size | md5                              | last_modified                |
|-------------------+------+----------------------------------+------------------------------|
| my_stage/data.csv | 16   | beb79a90840ec142a6586b03c2893c77 | Fri, 1 Mar 2024 20:56:24 GMT |
+--------------------------------------------------------------------------------------------+
```

### Downloading a file from stage

You can also download files from a stage. Let's download the CSV file we just uploaded.

You can download files from a stage using the same `snow stage copy`` command, only this time you will replace the order of the arguments.

To download the file from the stage to your current working directory run the following command:

```bash
snow stage copy @snowflake_cli_db.public.my_stage/data.csv .
```

This command should return output similar to the following:

```console
+----------------------------------------+
| file     | size | status     | message |
|----------+------+------------+---------|
| data.csv | 0    | DOWNLOADED |         |
+----------------------------------------+
```

### Removing stage

Lastly, you can use Snowflake CLI to remove a stage. You can do this with the `snow object drop` command.

To remove the stage you created for this tutorial, run:
```bash
snow object drop stage snowflake_cli_db.public.my_stage
```

In the output, you should see a message like this one:

```console
+--------------------------------+
| status                         |
|--------------------------------|
| MY_STAGE successfully dropped. |
+--------------------------------+
```

## Building applications using Snowflake CLI
Duration: 1

In the next steps, you'll learn how to use Snowflake CLI to bootstrap and develop Snowpark, Snowflake Native App and Streamlit apps. 

## Working with Snowpark applications
Duration: 10

Let's take a look at how Snowflake CLI can support development of Snowpark applications with multiple functions and procedures.

### Initializing Snowpark project

You can use Snowflake CLI to initialize a Snowpark project. To do so, run the following command

```bash
snow init my_project --template example_snowpark      
```

Running this command will create a new `my_project` directory. Now move to this new directory by running:

```bash
cd my_project
```

This new directory include:
- **snowflake.yml** – a project definition file that includes definitions of procedures and functions

- **requirements.txt** – a requirements file for this Python project.

- **app/** - directory with Python code for your app

In its initial state, the project defines:

- A function called `hello_function(name string)`

- Two procedures: `hello_procedure(name string)` and `test_procedure()`

### Building Snowpark project

Working with a Snowpark project requires two main steps: building and deploying. In this step you will build the project.

Building a Snowpark project results in the creation of a ZIP file. The name of the ZIP file is the same as the value of the `snowpark.src` key from `snowflake.yml`. The archive contains code for your application, as well as downloaded dependencies that were defined in **requirements.txt** (not present in Snowflake's Anaconda channel).

You can build the project by running:

```bash
snow snowpark build
```

### Deploying the Snowpark project

The next step is to deploy the Snowpark project. This step uploads your 
code and required dependencies to a stage in Snowflake. At this point, functions and procedures will be created in your Snowflake account.

Before deploying the project, you will need to create a database to store the the functions and procedures. This is also where the stage will be created.

To create a database, use the `snow sql` command:

```bash
snow sql -q "create database snowpark_example"
```

Now, you can deploy the project to the newly created database:

```bash
snow snowpark deploy --database=snowpark_example
```

This will result in the creation of the functions and procedures. After the process is completed you should see message similar to this one:

```console
+----------------------------------------------------------------------------+
| object                                               | type      | status  |
|------------------------------------------------------+-----------+---------|
| SNOWPARK_EXAMPLE.PUBLIC.HELLO_PROCEDURE(name string) | procedure | created |
| SNOWPARK_EXAMPLE.PUBLIC.TEST_PROCEDURE()             | procedure | created |
| SNOWPARK_EXAMPLE.PUBLIC.HELLO_FUNCTION(name string)  | function  | created |
+----------------------------------------------------------------------------+
```

### Executing functions and procedures

You have successfully deployed Snowpark functions and procedures. Now you can execute them to confirm that they function as intended.

To execute the `HELLO_FUNCTION` function run the following
```bash
snow snowpark execute function "SNOWPARK_EXAMPLE.PUBLIC.HELLO_FUNCTION('jdoe')"
```

Running this command should return output similar to this:

```console
+--------------------------------------------------------------+
| key                                            | value       |
|------------------------------------------------+-------------|
| SNOWPARK_EXAMPLE.PUBLIC.HELLO_FUNCTION('JDOE') | Hello jdoe! |
+--------------------------------------------------------------+
```

To execute the `HELLO_PROCEDURE` procedure run the following command:

```bash
snow snowpark execute procedure "SNOWPARK_EXAMPLE.PUBLIC.HELLO_PROCEDURE('jdoe')"
```

Running this command should return an output similar to this one:
```console
+-------------------------------+
| key             | value       |
|-----------------+-------------|
| HELLO_PROCEDURE | Hello jdoe! |
+-------------------------------+
```

## Working with a Snowflake Native App
Duration: 10

Let's take a look at how Snowflake CLI can support development of a Snowflake Native App.

### Initializing a Snowflake Native App project

You can use Snowflake CLI to initialize a Snowflake Native App project. To do so, run the following command

```bash
snow app init na_streamlit_project --template streamlit-python
```

Running this command will create a new `na_streamlit_project` directory from a predetermined template provided by Snowflake called `streamlit-python`. For a full list of templates, check out the official [Snowflake Native App templates repo](https://github.com/snowflakedb/native-apps-templates/tree/main). 

Once the directory is created, navigate to it by running:

```bash
cd na_streamlit_project
```

This new directory includes:
- **snowflake.yml** – a project definition file that includes information about the Snowflake Native App that you will create.

- **src/** – a directory that contains all the source code for stored procedures, UDFs and streamlit application.

- **app/** - a directory that contains the files required by Snowflake Native App such as manifest.yml and a setup script.

- **scripts/** - a directory that contains scripts that will be run as part of the Snowflake Native App creation.

This template will be used to build a simple calculator as a Snowflake Native App.

### Building a Snowflake Native App

Working with this Snowflake Native App project involves two main steps: deploying an application package and creating an application object from this application package.

The following step will create an application package for you, upload the files specified in **snowflake.yml** to a stage, run any scripts in **scripts/** if they are specified in **snowflake.yml**, and create an application object from this application package using named files on the stage. 

You can achieve all of the above from your project by running a single commnad:

```bash
snow app run
```

As a note, this template assumes that the role and warehouse you specified in your **config.toml** file has the required privileges to create an application package and an application object. If you did not specify either in **config.toml** file, then the default role and/or warehouse assigned to your user will be used. 

After the process is completed you should see message similar to this one:

```console
Your application object na_streamlit_project_$USER is now available:
https://app.snowflake.com/.../apps/application/na_streamlit_project_$USER
```

where `$USER` is populated from the environment variable from your machine. This will navigate you directly to the application object created in your account.

### Executing functions and procedures in your application object

You have successfully created an application object in your account. Now you can use either the Streamlit UI or SQL to interact with it. 

To execute the `core.add` function in the application object using SQL, run the following
```bash
snow sql -q "select na_streamlit_project_$USER.core.add(1, 2)"
```
replacing `na_streamlit_project_$USER` with the actual name of your application object. This will output the result of the function call also on the console.

### Opening a Snowflake Native App from the command line

Snowflake CLI also allows you to retrieve the URL for a Snowflake Native App, as well as open the app directly from the command line. To open the application created in previous step while still in the project directory,
run:

```bash
snow app open
```

This will open the Snowflake Native App in your browser.

### Dropping a Snowflake Native App from the command line

Snowflake CLI allows you to drop both the application object and the application package you created as part of the previous `snow app run` in one go. To do that, run:

```bash
snow app teardown
```

This will drop both the objects for you. As a note, it will not drop any other roles, databases, warehouses etc associated with the Snowflake Native App project.

## Working with Streamlit applications
Duration: 10

Snowflake CLI also provides commands to work with Streamlit applications. In this step you will learn how to deploy a Streamlit application using Snowflake CLI.

### Initializing Streamlit project

Start by initializing a Streamlit project. To do so, run:

```bash
snow init streamlit_app --template example_streamlit
```

By running this command a new `streamlit_app` directory will be created. Similar to a Snowpark project, this directory also includes also a **snowflake.yml** file which defines the Streamlit app.

Navigate to this new project directory by running:

```bash
cd streamlit_app/
```

### Deploying a Streamlit project

The next step is to deploy the Streamlit application. Before deploying you will need to create database where the Streamlit and related sources will live. To do so run:

```bash
snow sql -q "create database streamlit_example"
```

You'll also need a warehouse to deploy the Streamlit application. If you already have a warehouse that you can use, then you should update the Streamlit definition in the **snowflake.yml** file to use the specified warehouse:
```yml
definition_version: 1
streamlit:
  # ...
  query_warehouse: <warehouse_name>
```

Once you specify an existing warehouse, you can deploy the Streamlit application by running:

```bash
snow streamlit deploy --database=streamlit_example
```

Successfully deploying the Streamlit should result in message similar to this one:
```console
Streamlit successfully deployed and available under https://app.snowflake.com/.../streamlit-apps/STREAMLIT_EXAMPLE.PUBLIC.STREAMLIT_APP
```

### Opening Streamlit app from the command line

Snowflake CLI also allows you to retrieve the URL for a Streamlit app, as well as open the app directly from the command line. To open the application created in previous step
run:
```bash
snow streamlit get-url streamlit_app --database=streamlit_example --open
```
<!-- ------------------------ -->
## Working with Snowpark Container Services 
Duration: 15

> aside negative
> 
> **Note:** Snowpark Container Services is currently in Public Preview in select AWS [regions](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview?_fsi=g3LX4YOG&_fsi=g3LX4YOG#available-regions). In addition, trial accounts do not support Snowpark Container Services. Reach out to your Snowflake account team to enable your account for Snowpark Container Services.

You can also manage Snowpark Container Services with Snowflake CLI. In this step, you'll learn how to create and use Snowpark Container Services with Snowflake CLI. To proceed, you'll need the following prerequisites:

* A Snowflake account with Snowpark Container Services enabled
* A user in your Snowflake account with ACCOUNTADMIN privileges
* [Docker Desktop](https://docs.docker.com/get-docker/) installed on your computer

### Download the source code

Download the source code for this section: [snowflake_cli_snowpark_container_services](https://github.com/Snowflake-Labs/sf-samples/tree/main/samples/snowflake_cli_snowpark_container_services)


### Set up your connection

1. Navigate to the downloaded folder (i.e., `cd snowflake_cli_snowpark_container_services`, or wherever you saved the source code).

2. Setup the connection for your admin user by running `snow connection add` and filling in the admin user login along with the following settings:

```console
Name for this connection: admin
Snowflake account name: <account_name>
Snowflake username: <admin_user>
Snowflake password [optional]: <password> (note that your password input will be hidden)
Role for the connection [optional]: accountadmin
```

### Create a test role

3. Edit the **setup/admin_setup.sql** file and fill in `<user_name>` with the name of the test user.

4. Run `snow sql -f setup/admin_setup.sql -c admin`. This does the following:

* Creates a role (`test_role`) and other Snowflake objects. To create the role and objects, you must use the ACCOUNTADMIN role. (This restriction helps to control costs and manage business information risks.) The script also grants the `test_role` role the privileges needed to manage the newly created objects.

* Grants the role to the specified test user, who then uses the role to explore the tutorial.

### Set up a connection for your test role

5. Setup the connection for your test user by running `snow connection add` and filling in the user login as well as the following settings: 

```console
Name for this connection: default
Snowflake account name: <account_name>
Snowflake username: <test_user>
Snowflake password [optional]: <password> (note that your password input will be hidden)
Role for the connection [optional]: tutorial_role
Warehouse for the connection [optional]: tutorial_warehouse
Database for the connection [optional]: tutorial_db
Schema for the connection [optional]: data_schema
```

### Create an image repository for your service code

6. Run `snow sql -f setup/user_setup.sql`. This does the following:

* Creates a schema for your image repository and service.

* Creates an image repository to store your service code (container images).

### Verify proper set up

7. Verify that you have the correct objects from the setup with the following commands

```console
# should describe your newly created compute pool
snow object describe compute-pool tutorial_compute_pool

# should describe your newly created warehouse
snow object describe warehouse tutorial_warehouse

# confirms that tutorial repository exists and also returns the url
snow spcs image-repository url tutorial_repository
```

### Build an image and upload it to an image repository

1. Get the repository URL by running:
 
```console
snow spcs image-repository url tutorial_repository
```

You could also run the following handy command to retrieve the repository URL and store it:

```console
repo_url=$(snow spcs image-repository url tutorial_repository)
image_name="my_echo_service_image:latest"

```

2. Open another terminal window, and change to the `snowflake_cli_snowpark_container_services/tutorial` directory.

3. To build a Docker image, execute the following docker build command using the Docker CLI. Note the command specifies the current working directory (`.`) as the PATH for files to use for building the image. You may need to update it according to your preferred directory structure.

```console
docker build --rm --platform linux/amd64 -t <repository_url>/<image_name> .
```

For `image_name`, use `my_echo_service_image:latest`. 

4. To login to Docker, use `snow spcs image-registry login`.

5. Push your image to Docker with the following command:

```console
docker push <repository_url>/<image_name>
```

### Create the service

1. Create the service with the following command

```console
snow spcs service create echo_service --compute-pool tutorial_compute_pool --min-instances 1 --spec-path spec.yaml
```

2. Inspect your service with the following commands:

```
# check that your service is listed
snow object list service

# get the current status of the service
snow spcs service status echo_service

# get the logs of the service
snow spcs service logs echo_service --container-name echo --instance-id 0

# get detailed info on your service
snow object describe service echo_service
```

### Use the service

1. Test the service endpoints using the UI. Start by retrieving the public endpoint of your service with:

```
snow spcs service list-endpoints echo_service
```

2. In your web browser, navigate to `<endpoint_url>/ui`.

3. Type in some input and press `return` or `Enter` on your keyboard


4. You should see output like the following, which is what was specified in **echo_service.py**:

![ui for the service](./assets/echo_service_ui.png)


### Clean up

Finally, clean up billable resources by suspending or dropping `tutorial_compute_pool` and `tutorial_warehouse`. Run the following commands:

```
# suspend (currently no native SnowCLI support for suspending warehouses)
snow spcs compute-pool suspend tutorial_compute_pool
snow sql -q "alter warehouse tutorial_warehouse suspend" 

# drop
snow object drop compute-pool tutorial_compute_pool
snow object drop warehouse tutorial_warehouse
```

<!-- ------------------------ -->
## Conclusion
Duration: 1

Congratulations! In just a few short steps, you were able to get up and running with Snowflake CLI for connection and object management, working with stages, and building and deploying Snowpark projects, Snowflake Native App and Streamlit applications.

### What we've covered
- Snowflake CLI setup
- Connection management in Snowflake CLI
- Uploading data using Snowflake CLI
- Executing SQL using Snowflake CLI
- Managing Snowflake objects using the CLI

### Additional resources

- [Snowflake CLI Guide](https://docs.snowflake.com/LIMITEDACCESS/snowcli-v2/snowcli-guide)

id: getting_started_with_snowpark_for_python_streamlit
summary: This guide provides the instructions for writing a Streamlit application using Snowpark for Python and Cybersyn data from Snowflake Marketplace.
categories: featured,getting-started,data-engineering,app-development
environments: web
status: Published
feedback link: <https://github.com/Snowflake-Labs/sfguides/issues>
tags: Getting Started, Snowpark Python, Streamlit
authors: Dash Desai, Victoria Warner (Cybersyn)

# Getting Started With Snowpark for Python and Streamlit
<!-- ------------------------ -->
## Overview

Duration: 5

This guide provides the instructions for building a Streamlit application using Snowpark for Python and [Cybersyn data](https://app.snowflake.com/marketplace/listings/Cybersyn%2C%20Inc) from the Snowflake Marketplace.

### What You Will Build

A Streamlit application that loads and visualizes daily **stock performance** and **foreign exchange (FX) rate** data loaded from [Cybersyn](https://app.snowflake.com/marketplace/listings/Cybersyn%2C%20Inc) on the Snowflake Marketplace using Snowpark for Python.

![App](assets/sis.gif)

### What is Snowpark?

The set of libraries and runtimes in Snowflake that securely deploy and process non-SQL code, including Python, Java and Scala.

**Familiar Client Side Libraries** - Snowpark brings deeply integrated, DataFrame-style programming and OSS compatible APIs to the languages data practitioners like to use. It also includes the Snowpark ML API for more efficient ML modeling (public preview) and ML operations (private preview).

**Flexible Runtime Constructs** - Snowpark provides flexible runtime constructs that allow users to bring in and run custom logic. Developers can seamlessly build data pipelines, ML models, and data applications with User-Defined Functions and Stored Procedures.

Learn more about [Snowpark](https://www.snowflake.com/snowpark/).

![App](assets/snowpark.png)

### What is Streamlit?

Streamlit enables data scientists and Python developers to combine Streamlit's component-rich, open-source Python library with the scale, performance, and security of the Snowflake platform.

Learn more about [Streamlit](https://www.snowflake.com/en/data-cloud/overview/streamlit-in-snowflake/).

### What is Cybersyn?

Cybersyn is a data-as-a-service company creating a real-time view of the world's economy with analytics-ready economic data on Snowflake Marketplace. Cybersyn builds derived data products from datasets that are difficult to procure, clean, or join. With Cybersyn, you can access external data directly in your Snowflake instance — no ETL required.

Check out Cybersyn's [Consumer Spending product](https://app.snowflake.com/marketplace/listing/GZTSZ290BUX62/) and [explore all 60+ public sources](https://app.cybersyn.com/data_catalog/?utm_source=Snowflake+Quickstart&utm_medium=organic&utm_campaign=Snowflake+Quickstart) Cybersyn offers on the [Snowflake Marketplace](https://app.snowflake.com/marketplace/listings/Cybersyn%2C%20Inc).

### What You Will Learn

- How to access current Session object in Streamlit
- How to load data from Cybersyn on the Snowflake Marketplace
- How to create Snowpark DataFrames and perform transformations
- How to create and display interactive charts in Streamlit
- How to run Streamlit in Snowflake

### Prerequisites

- A [Snowflake](https://www.snowflake.com/) account in **AWS US Oregon**
- Access to the **Financial & Economic Essentials** dataset provided by **Cybersyn**.
  - In the [Snowflake Marketplace](https://app.snowflake.com/marketplace/listing/GZTSZAS2KF7/), click on **Get Data** and follow the instructions to gain access. In particular, we will use data in schema **CYBERSYN** from tables **STOCK_PRICE_TIMESERIES** and **FX_RATES_TIMESERIES**.

<!-- ------------------------ -->
## Get Started

Duration: 5

Follow these steps to start building Streamlit application in Snowsight.

**Step 1.** Click on **Streamlit** on the left navigation menu

**Step 2.** Click on **+ Streamlit App** on the top right

**Step 3.** Enter **App name**

**Step 4.** Select **Warehouse** (X-Small) and **App location** (Database and Schema) where you'd like to create the Streamlit applicaton

**Step 5.** Click on **Create**

- At this point, you will be provided code for an example Streamlit application

**Step 6.** Replace sample application code displayed in the code editor on the left by following instructions in the subsequent steps

<!-- ------------------------ -->
## Application Setup

Duration: 2

Delete existing sample application code in the code editor on the left and add the following code snippet at the very top.

```python
# Import libraries
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import sum, col, when, max, lag
from snowflake.snowpark import Window
from datetime import timedelta
import altair as alt
import streamlit as st
import pandas as pd

# Set page config
st.set_page_config(layout="wide")

# Get current session
session = get_active_session()
```

In the above code snippet, we're importing the required libraries, setting the application's page config to use full width of the browser window, and gaining access to the current session.

<!-- ------------------------ -->
## Load and Transform Data

Duration: 5

Now add the following Python function that loads and caches data from the `FINANCIAL__ECONOMIC_ESSENTIALS.CYBERSYN.STOCK_PRICE_TIMESERIES` and `FINANCIAL__ECONOMIC_ESSENTIALS.CYBERSYN.FX_RATES_TIMESERIES` tables.

```python
@st.cache_data()
def load_data():
    # Load and transform daily stock price data.
    snow_df_stocks = (
        session.table("FINANCIAL__ECONOMIC_ESSENTIALS.CYBERSYN.STOCK_PRICE_TIMESERIES")
        .filter(
            (col('TICKER').isin('AAPL', 'MSFT', 'AMZN', 'GOOGL', 'META', 'TSLA', 'NVDA')) & 
            (col('VARIABLE_NAME').isin('Nasdaq Volume', 'Post-Market Close')))
        .groupBy("TICKER", "DATE")
        .agg(
            max(when(col("VARIABLE_NAME") == "Nasdaq Volume", col("VALUE"))).alias("NASDAQ_VOLUME"),
            max(when(col("VARIABLE_NAME") == "Post-Market Close", col("VALUE"))).alias("POSTMARKET_CLOSE")
        )
    )
    
    # Adding the Day over Day Post-market Close Change calculation
    window_spec = Window.partitionBy("TICKER").orderBy("DATE")
    snow_df_stocks_transformed = snow_df_stocks.withColumn("DAY_OVER_DAY_CHANGE", 
        (col("POSTMARKET_CLOSE") - lag(col("POSTMARKET_CLOSE"), 1).over(window_spec)) /
        lag(col("POSTMARKET_CLOSE"), 1).over(window_spec)
    )

    # Load foreign exchange (FX) rates data.
    snow_df_fx = session.table("FINANCIAL__ECONOMIC_ESSENTIALS.CYBERSYN.FX_RATES_TIMESERIES").filter(
        (col('BASE_CURRENCY_ID') == 'EUR') & (col('DATE') >= '2019-01-01')).with_column_renamed('VARIABLE_NAME','EXCHANGE_RATE')
    
    return snow_df_stocks_transformed.to_pandas(), snow_df_fx.to_pandas()

# Load and cache data
df_stocks, df_fx = load_data()
```

In the above code snippet, we’re leveraging several Snowpark DataFrame functions to load and transform data. For example, `filter()`, `group_by()`, `agg()`, `sum()`, `alias()` and `isin()`.

<!-- ------------------------ -->
## Daily Stock Performance on the Nasdaq by Company

Duration: 5

Now add the following Python function that displays daily stock performance. Create selection dropdowns for date, stock ticker, and metric to be visualized.

```python
def stock_prices():
    st.subheader('Stock Performance on the Nasdaq for the Magnificent 7')
    
    df_stocks['DATE'] = pd.to_datetime(df_stocks['DATE'])
    max_date = df_stocks['DATE'].max()  # Most recent date
    min_date = df_stocks['DATE'].min()  # Earliest date
    
    # Default start date as 30 days before the most recent date
    default_start_date = max_date - timedelta(days=30)

    # Use the adjusted default start date in the 'date_input' widget
    start_date, end_date = st.date_input("Date range:", [default_start_date, max_date], min_value=min_date, max_value=max_date, key='date_range')
    start_date_ts = pd.to_datetime(start_date)
    end_date_ts = pd.to_datetime(end_date)

    # Filter DataFrame based on the selected date range
    df_filtered = df_stocks[(df_stocks['DATE'] >= start_date_ts) & (df_stocks['DATE'] <= end_date_ts)]
    
    # Ticker filter with multi-selection and default values
    unique_tickers = df_filtered['TICKER'].unique().tolist()
    default_tickers = [ticker for ticker in ['AAPL', 'MSFT', 'AMZN', 'GOOGL', 'META', 'TSLA', 'NVDA'] if ticker in unique_tickers]
    selected_tickers = st.multiselect('Ticker(s):', unique_tickers, default=default_tickers)
    df_filtered = df_filtered[df_filtered['TICKER'].isin(selected_tickers)]
    
    # Metric selection
    metric = st.selectbox('Metric:',('DAY_OVER_DAY_CHANGE','POSTMARKET_CLOSE','NASDAQ_VOLUME'), index=0) # Default to DAY_OVER_DAY_CHANGE
    
    # Generate and display line chart for selected ticker(s) and metric
    line_chart = alt.Chart(df_filtered).mark_line().encode(
        x='DATE',
        y=alt.Y(metric, title=metric),
        color='TICKER',
        tooltip=['TICKER','DATE',metric]
    ).interactive()
    st.altair_chart(line_chart, use_container_width=True)
```

In the above code snippet, a line chart is constructed which takes a dataframe as one of the parameters. In our case, that is a subset of the `df_stocks` dataframe filtered by ticker, date, and metric using Streamlit's built in components. This enhances the customizability of the visualization.

<!-- ------------------------ -->

## EUR Exchange (FX) Rates by Quote Currency

Duration: 5

Next, add the following Python function that displays a currency selection dropdown and a chart to visualize euro exchange rates over time for the selected quote currencies.

```python
def fx_rates():
    st.subheader('EUR Exchange (FX) Rates by Currency Over Time')

    # GBP, CAD, USD, JPY, PLN, TRY, CHF
    currencies = ['British Pound Sterling','Canadian Dollar','United States Dollar','Japanese Yen','Polish Zloty','Turkish Lira','Swiss Franc']
    selected_currencies = st.multiselect('', currencies, default = ['British Pound Sterling','Canadian Dollar','United States Dollar','Swiss Franc','Polish Zloty'])
    st.markdown("___")

    # Display an interactive chart to visualize exchange rates over time by the selected currencies
    with st.container():
        currencies_list = currencies if len(selected_currencies) == 0 else selected_currencies
        df_fx_filtered = df_fx[df_fx['QUOTE_CURRENCY_NAME'].isin(currencies_list)]
        line_chart = alt.Chart(df_fx_filtered).mark_line(
            color="lightblue",
            line=True,
        ).encode(
            x='DATE',
            y='VALUE',
            color='QUOTE_CURRENCY_NAME',
            tooltip=['QUOTE_CURRENCY_NAME','DATE','VALUE']
        )
        st.altair_chart(line_chart, use_container_width=True)
```

In the above code snippet, a line chart is constructed which takes a dataframe as one of the parameters. In our case, that is a subset of the `df_fx` dataframe filtered by the currencies selected via Streamlit's `multiselect()` user input component.

<!-- ------------------------ -->

## Application Components

Duration: 5

Add the following code snippet to display application header, create a sidebar, and map `stock_prices()` and `fx_rates()` functions to **Daily Stock Performance Data** and **Exchange (FX) Rates** options respectively in the sidebar.

```python
# Display header
st.header("Cybersyn: Financial & Economic Essentials")

# Create sidebar and load the first page
page_names_to_funcs = {
    "Daily Stock Performance Data": stock_prices,
    "Exchange (FX) Rates": fx_rates
}
selected_page = st.sidebar.selectbox("Select", page_names_to_funcs.keys())
page_names_to_funcs[selected_page]()
```

<!-- ------------------------ -->
## Run Application

Duration: 5

The fun part! Assuming your code is free of syntax and other errors, you’re ready to run the Streamlit application.

### Code

Here's what the entire application code should look like.

```python
# Import libraries
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import sum, col, when, max, lag
from snowflake.snowpark import Window
from datetime import timedelta
import altair as alt
import streamlit as st
import pandas as pd

# Set page config
st.set_page_config(layout="wide")

# Get current session
session = get_active_session()

@st.cache_data()
def load_data():
    # Load and transform daily stock price data.
    snow_df_stocks = (
        session.table("FINANCIAL__ECONOMIC_ESSENTIALS.CYBERSYN.STOCK_PRICE_TIMESERIES")
        .filter(
            (col('TICKER').isin('AAPL', 'MSFT', 'AMZN', 'GOOGL', 'META', 'TSLA', 'NVDA')) & 
            (col('VARIABLE_NAME').isin('Nasdaq Volume', 'Post-Market Close')))
        .groupBy("TICKER", "DATE")
        .agg(
            max(when(col("VARIABLE_NAME") == "Nasdaq Volume", col("VALUE"))).alias("NASDAQ_VOLUME"),
            max(when(col("VARIABLE_NAME") == "Post-Market Close", col("VALUE"))).alias("POSTMARKET_CLOSE")
        )
    )
    
    # Adding the Day over Day Post-market Close Change calculation
    window_spec = Window.partitionBy("TICKER").orderBy("DATE")
    snow_df_stocks_transformed = snow_df_stocks.withColumn("DAY_OVER_DAY_CHANGE", 
        (col("POSTMARKET_CLOSE") - lag(col("POSTMARKET_CLOSE"), 1).over(window_spec)) /
        lag(col("POSTMARKET_CLOSE"), 1).over(window_spec)
    )

    # Load foreign exchange (FX) rates data.
    snow_df_fx = session.table("FINANCIAL__ECONOMIC_ESSENTIALS.CYBERSYN.FX_RATES_TIMESERIES").filter(
        (col('BASE_CURRENCY_ID') == 'EUR') & (col('DATE') >= '2019-01-01')).with_column_renamed('VARIABLE_NAME','EXCHANGE_RATE')
    
    return snow_df_stocks_transformed.to_pandas(), snow_df_fx.to_pandas()

# Load and cache data
df_stocks, df_fx = load_data()

def stock_prices():
    st.subheader('Stock Performance on the Nasdaq for the Magnificent 7')
    
    df_stocks['DATE'] = pd.to_datetime(df_stocks['DATE'])
    max_date = df_stocks['DATE'].max()  # Most recent date
    min_date = df_stocks['DATE'].min()  # Earliest date
    
    # Default start date as 30 days before the most recent date
    default_start_date = max_date - timedelta(days=30)

    # Use the adjusted default start date in the 'date_input' widget
    start_date, end_date = st.date_input("Date range:", [default_start_date, max_date], min_value=min_date, max_value=max_date, key='date_range')
    start_date_ts = pd.to_datetime(start_date)
    end_date_ts = pd.to_datetime(end_date)

    # Filter DataFrame based on the selected date range
    df_filtered = df_stocks[(df_stocks['DATE'] >= start_date_ts) & (df_stocks['DATE'] <= end_date_ts)]
    
    # Ticker filter with multi-selection and default values
    unique_tickers = df_filtered['TICKER'].unique().tolist()
    default_tickers = [ticker for ticker in ['AAPL', 'MSFT', 'AMZN', 'GOOGL', 'META', 'TSLA', 'NVDA'] if ticker in unique_tickers]
    selected_tickers = st.multiselect('Ticker(s):', unique_tickers, default=default_tickers)
    df_filtered = df_filtered[df_filtered['TICKER'].isin(selected_tickers)]
    
    # Metric selection
    metric = st.selectbox('Metric:',('DAY_OVER_DAY_CHANGE','POSTMARKET_CLOSE','NASDAQ_VOLUME'), index=0) # Default to DAY_OVER_DAY_CHANGE
    
    # Generate and display line chart for selected ticker(s) and metric
    line_chart = alt.Chart(df_filtered).mark_line().encode(
        x='DATE',
        y=alt.Y(metric, title=metric),
        color='TICKER',
        tooltip=['TICKER','DATE',metric]
    ).interactive()
    st.altair_chart(line_chart, use_container_width=True)

def fx_rates():
    st.subheader('EUR Exchange (FX) Rates by Currency Over Time')

    # GBP, CAD, USD, JPY, PLN, TRY, CHF
    currencies = ['British Pound Sterling','Canadian Dollar','United States Dollar','Japanese Yen','Polish Zloty','Turkish Lira','Swiss Franc']
    selected_currencies = st.multiselect('', currencies, default = ['British Pound Sterling','Canadian Dollar','United States Dollar','Swiss Franc','Polish Zloty'])
    st.markdown("___")

    # Display an interactive chart to visualize exchange rates over time by the selected currencies
    with st.container():
        currencies_list = currencies if len(selected_currencies) == 0 else selected_currencies
        df_fx_filtered = df_fx[df_fx['QUOTE_CURRENCY_NAME'].isin(currencies_list)]
        line_chart = alt.Chart(df_fx_filtered).mark_line(
            color="lightblue",
            line=True,
        ).encode(
            x='DATE',
            y='VALUE',
            color='QUOTE_CURRENCY_NAME',
            tooltip=['QUOTE_CURRENCY_NAME','DATE','VALUE']
        )
        st.altair_chart(line_chart, use_container_width=True)

# Display header
st.header("Cybersyn: Financial & Economic Essentials")

# Create sidebar and load the first page
page_names_to_funcs = {
    "Daily Stock Performance Data": stock_prices,
    "Exchange (FX) Rates": fx_rates
}
selected_page = st.sidebar.selectbox("Select", page_names_to_funcs.keys())
page_names_to_funcs[selected_page]()
```

### Run

To run the application, click on **Run** button located at the top right corner. If all goes well, you should see the application running as shown below.

![App](assets/sis.gif)

In the application:

1. Select **Daily Stock Performance Data** or **Exchange (FX) Rates** option from the sidebar.
2. Select or unselect currencies to visualize euro exchange rates over time for select currencies.
3. Select a different stock price metric and date range to visualize additional metrics for stock performance evaluation.

<!-- ------------------------ -->
## Conclusion And Resources

Duration: 1

Congratulations! You've successfully completed the Getting Started with Snowpark for Python and Streamlit with Cybersyn data quickstart guide.

### What You Learned

- How to access current Session object in Streamlit
- How to load data from [Cybersyn](https://app.snowflake.com/marketplace/listings/Cybersyn%2C%20Inc) on the Snowflake Marketplace
- How to create Snowpark DataFrames and perform transformations
- How to create and display interactive charts in Streamlit
- How to run Streamlit in Snowflake

### Related Resources

- [Snowpark for Python Developer Guide](https://docs.snowflake.com/en/developer-guide/snowpark/python/index.html)
- [Snowpark for Python API Reference](https://docs.snowflake.com/en/developer-guide/snowpark/reference/python/index.html)
- [Cybersyn data on the Snowflake Marketplace](https://app.snowflake.com/marketplace/listings/Cybersyn%2C%20Inc)
- [Cybersyn Data Catalog](https://app.cybersyn.com/data_catalog/?utm_source=Snowflake+Quickstart&utm_medium=organic&utm_campaign=Snowflake+Quickstart)

author: ashleynagaki, vskarine
id: getting_started_with_streamlit_in_snowflake
summary: How to run custom Streamlit app in Snowflake 
categories: Streamlit
environments: web
status: Published 
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Data Science, Data Engineering, Twitter 

# Quickstart Guide: Cybersyn Streamlit in Snowflake - Financial Demo
<!-- ------------------------ -->
## Overview 
Duration: 2

![logo-image](assets/FinancialDataSnowflakeNativeApp.png)

In this guide, we will review how to build a Streamlit App within Snowflake that allows you to easily demo Cybersyn’s Financial Data Package data tables with charts built in Vega-Lite.

### What is Streamlit?
Streamlit is a pure Python [open source](https://github.com/streamlit/streamlit) application framework that enables developers to quickly and easily write, share, and deploy data applications. Learn more about [Streamlit](https://streamlit.io/).

### What is Vega-Lite? 
Vega-Lite is an [open-source](https://vega.github.io/vega-lite/) high-level grammar of interactive graphics. It provides a concise, declarative JSON syntax to create an expressive range of visualizations for data analysis and presentation.

### What You’ll Build?
An application on Streamlit within Snowflake that connects directly to a data listing acquired (for free) through the Snowflake Marketplace. This application allows users to quickly demonstrate usage examples from data in the [Cybersyn Financial Data Package](https://app.snowflake.com/marketplace/listing/GZTSZAS2KF7/cybersyn-inc-financial-data-package?search=financial%20data%20package). This data specifically focuses on the US banking system and respective financials and performance.

### What You’ll Learn? 
- How to access data from Snowflake Marketplace
- How to create and run Streamlit in Snowflake
- How to create VegaLite charts in Streamlit

### Prerequisites
A [Snowflake account](https://signup.snowflake.com/?utm_cta=quickstarts_)
- To ensure you can mount data from the Marketplace, login to your Snowflake account with the admin credentials that were created with the account in one browser tab (a role with ORGADMIN privileges is required for this step). Keep this tab open during the session.
  - Click on the Billing on the left side panel
  - Click on Terms and Billing
  - Read and accept terms to continue


<!-- ------------------------ -->
## Setting up the Streamlit Application
Duration: 4

### Step 1: Accessing Data in Snowflake Marketplace
<button>[Cybersyn Financial Data Package](https://app.snowflake.com/marketplace/listing/GZTSZAS2KF7)</button>

After logging into your Snowflake account, access [Cybersyn’s Financial Data Package](https://app.snowflake.com/marketplace/listing/GZTSZAS2KF7/cybersyn-inc-financial-data-package?search=financial%20data%20package) in the Marketplace. 
- Click the Get button on the top right box on the listing
- Read and accept terms by clicking Get again 
  - Note: This data listing is available for free, at no additional charge. 
- The data is now available in your Snowflake instance, as the `FINANCIAL_DATA_PACKAGE` database under Data on the left hand side panel.

![package-image](assets/MarketplaceDataListing.png)

### Step 2: Create a Database & Schema
- On the left side panel, click Data. 
- Click the blue + Database button in the top right corner. 
- Create a new database with a name of your choosing (eg. `FINANCIAL_STREAMLIT`) for the Streamlit to live in.
- Create a new Schema in the new database (eg. `FINANCIAL_STREAMLIT`) with a name of your choosing (eg. `STREAMLIT`).

### Step 3: Create a Streamlit
- On the left side panel, click Streamlit. 
- Click the blue button, blue + Streamlit App button in the top right corner.
  - Name your App (eg. Financial Streamlit)
  - Select a Warehouse. 
  - Select the database and schema for your app. If you followed Step 2, select this database (eg. `FINANCIAL_STREAMLIT` and `STREAMLIT`).
  - Click the blue Create button
  - Delete all of the existing code.

### Step 4: Copy the Python code from GitHub
<button>[streamlit_app.py](https://github.com/cybersyn-data/streamlit-in-snowflake-example/blob/main/streamlit_app.py)</button>

- Click the button above which will direct you to our Financial Streamlit Python Setup file that is hosted on GitHub. 
- Within GitHub navigate to the right side and click the ‘Copy raw contents’ button on the top right of the code block. This will copy all of the required Python into your clipboard. 
- Paste the Python code to the Streamlit code block in your newly created Streamlit in Snowflake.

### Step 5: Create a Database & Schema
- Click the blue Run button  on the top right corner. 
- Wait for app to load. 
  - Note: If there is an error then try to refresh the page. If you continue to receive an error, please ensure that under Data you see the `FINANCIAL_DATA_PACKAGE` listing in your databases. 

#### You’ve successfully built the Cybersyn Financial Streamlit in Snowflake!


<!-- ------------------------ -->
## Walk-through of the App Functionality
Duration: 3

To see the Streamlit in the full window, click < Streamlit Apps on the top left and reopen the application you created (eg. Financial Streamlit).

All charts are setup to show a chart summary of the data, the raw data, and the SQL query to recreate the analysis.
 
### Chart 1: Deposits by Size of Bank
![screenshot1](assets/DepositsbySizeofBank.png)
- This chart allows the user to see the US bank deposits broken down by Top 25 Banks and All Others since January 1999. 
- Data is sourced from [FRED](https://fred.stlouisfed.org/tags/series). 

### Chart 2: Share of Total Commercial Bank Deposits, Small Banks (Non-Top 25)
![screenshot2](assets/ShareofTotalCommercialBankDeposits.png)
- This chart shows the share of deposits help by the banks that are not in the top 25 US banks by total deposits. 
- Data is sourced from [FRED](https://fred.stlouisfed.org/tags/series). 

### Chart 3: Deposit Flows by Size of Bank, WoW
![screenshot3](assets/DepositFlowsbySizeofBank.png)
- This chart shows the WoW deposit inflows and (outflows) for banks. 
- The chart can be filtered by date and the user can add in ‘Top 25 Banks’ and ‘All Other Banks’ to see the two breakdowns.
- Data is sourced from [FRED](https://fred.stlouisfed.org/tags/series).

### Chart 4: Monthly Change in Bank Branches Since COVID-19
![screenshot4](assets/MonthlyChangeinBankBranchesSinceCOVID-19.png)
- This chart shows the monthly and cumulative change of bank branch openings and closures since January 2018. 
- Data is sourced from [FFIEC](https://www.ffiec.gov/npw/FinancialReport/DataDownload).

### Chart 5: As of Dec '23: Banks w/ $10B Assets with Lowest FDIC Insured Deposits
![screenshot5](assets/Dec_23-banks_w_10B_Assets.png)
- This chart shows the banks with lowest FDIC insured deposits as of December 2022. 
- Data is sourced from [FDIC](https://banks.data.fdic.gov/docs/).

### Chart 6: Bank Failures by Quarter
![screenshot6](assets/Bank_Failures_by_Quarter.png)
- This chart shows the number of bank failures by quarter. 
- Data is sourced from [FFIEC](https://www.ffiec.gov/npw/FinancialReport/DataDownload).

### Chart 7: Banking Industry Net Interest Income vs. Fed Funds Rate
![screenshot7](assets/Banking_Industry_Net_Interest_Income_v_Fed_Funds.png)
- This chart shows net interest income by the bar charts against the left axis and the Fed Funds Rate in the line graph against the right axis since March 1985. 
- Data is sourced from [FRED](https://fred.stlouisfed.org/tags/series).

### Chart 8: Interest Expense / Interest Income Ratio vs Fed Funds Rate
![screenshot8](assets/InterestExpenseInterestIncomeRatiovFedFunds.png)
- This chart shows the ratio of Interest Expense to Interest Income and compares it to the Fed Funds Rate since March 1985.
- Data is sourced from [FRED](https://fred.stlouisfed.org/tags/series).

author: ilesh Garish
id: intro_to_snowpark_container_services_with_python_api
summary: Through this quickstart guide, you will explore Snowpark Container Services using Python API
categories: Getting-Started
environments: web
status: Published 
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Containers, Snowpark, Python API

# Intro to Snowpark Container Services with Snowflake Python APIs
<!-- ------------------------ ----------------------------------->
## Overview 
Duration: 3

Through this quickstart guide, you will explore [Snowpark Container Services](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview), which are now in Public Preview on AWS. You will explore Snowpark Container Services using [Python API](https://docs.snowflake.com/en/developer-guide/snowflake-python-api/snowflake-python-overview), which is now in Public Preview. You will learn the basic mechanics of working with Snowpark Container Services using Python API and build several introductory services. **Please note: this quickstart assumes some existing knowledge and familiarity with containerization (e.g. Docker) , basic familiarity with container orchestration. and basic familiartity with Python**

### What is Snowpark Container Services?

![Snowpark Container Service](./assets/containers.png)

[Snowpark Container Services](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview) is a fully managed container offering that allows you to easily deploy, manage, and scale containerized services, jobs, and functions, all within the security and governance boundaries of Snowflake, and requiring zero data movement. As a fully managed service, SPCS comes with Snowflake’s native security, RBAC support, and built-in configuration and operational best-practices.

Snowpark Container Services are fully integrated with both Snowflake features and third-party tools, such as Snowflake Virtual Warehouses and Docker, allowing teams to focus on building data applications, and not building or managing infrastructure. Just like all things Snowflake, this managed service allows you to run and scale your container workloads across regions and clouds without the additional complexity of managing a control plane, worker nodes, and also while having quick and easy access to your Snowflake data.

The introduction of Snowpark Container Services on Snowflake includes the incorporation of new object types and constructs to the Snowflake platform, namely: images, image registry, image repositories, compute pools, specification files, services, and jobs.

![Development to Deployment](./assets/spcs_dev_to_deploy.png)

For more information on these objects, check out [this article](https://medium.com/snowflake/snowpark-container-services-a-tech-primer-99ff2ca8e741) along with the Snowpark Container Services [documentation](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview).

How are customers and partners using Snowpark Container Services today? Containerized services on Snowflake open up the opportunity to host and run long-running services, like front-end web applications, all natively within your Snowflake environment. Customers are now running GPU-enabled machine learning and AI workloads, such as GPU-accelerated model training and open-source Large Language Models (LLMs) as jobs and as service functions, including fine-tuning of these LLMs on your own Snowflake data, without having to move the data to external compute infrastructure. Snowpark Container Services are an excellent path for deploying applications and services that are tightly coupled to the Data Cloud.

Note that in this quickstart, we will predominantly use the Python API to interact with Snowpark Container Services and their associated objects. Please refer to the [Python API support](https://docs.snowflake.com/developer-guide/snowflake-python-api/snowflake-python-overview) in Public Preview. Refer to the [documentation](https://docs.snowflake.com/developer-guide/snowflake-python-api/snowflake-python-overview) for more info.

### What you will learn 
- The basic mechanics of how Snowpark Container Services works
- How to deploy a long-running service with a UI and use volume mounts to persist changes in the file system
- How to interact with Snowflake warehouses to run SQL queries from inside of a service
- How to deploy a Service Function to perform basic calculations

### Prerequisites
##### **Download the git repo here: https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services.git**. 
You can simply download the repo as a .zip if you don't have Git installed locally.

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
- [Python 3.10](https://www.python.org/downloads/) installed
    - Note that you will be creating a Python environment with 3.10 in the **Setup the Local Environment** step
- (Optional) [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) installed
    >**Download the git repo here: https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services.git**. You can simply download the repo as a .zip if you don't have Git installed locally.
- (Optional) [VSCode](https://code.visualstudio.com/) (recommended) with the [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker), [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python), and [Snowflake](https://marketplace.visualstudio.com/items?itemName=snowflake.snowflake-vsc) extensions installed.
- A non-trial Snowflake account in a supported [AWS region](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview#available-regions).
- A Snowflake account login with a role that has the `ACCOUNTADMIN` role. If not, you will need to work with your `ACCOUNTADMIN` to perform the initial account setup (e.g. creating the `CONTAINER_USER_ROLE` and granting required privileges, as well as creating the OAuth Security Integration).
- Install Python API [Python API Installtion](https://docs.snowflake.com/developer-guide/snowflake-python-api/snowflake-python-installing)

### What You’ll Build 
- A hosted Jupyter Notebook service running inside of Snowpark Container Services with a basic notebook
- A Python REST API to perform basic temperature conversions
- A Snowflake Service Function that leverages the REST API

<!-- ![e2e_ml_workflow](assets/snowpark-ml-e2e.png) -->

<!-- ------------------------ -->
## Set up the Snowflake environment
Duration: 5

Run the following Python API code in [`00_setup.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/00_setup.py) using the Snowpark Python Connector and Python API to create the role, database, warehouse, and stage that we need to get started:
```Python API
# create a SnowflakeConnection instance
connection_acct_admin = connect(**CONNECTION_PARAMETERS_ACCOUNT_ADMIN)

try:
    # create a root as the entry point for all object
    root = Root(connection_acct_admin)

    # CREATE ROLE CONTAINER_USER_ROLE
    root.roles.create(Role(
        name='CONTAINER_USER_ROLE',
        comment='My role to use container',
    ))

    # GRANT CREATE DATABASE ON ACCOUNT TO ROLE CONTAINER_USER_ROLE
    # GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE CONTAINER_USER_ROLE;
    # GRANT CREATE COMPUTE POOL ON ACCOUNT TO ROLE CONTAINER_USER_ROLE;
    # GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE CONTAINER_USER_ROLE;
    # GRANT MONITOR USAGE ON ACCOUNT TO  ROLE  CONTAINER_USER_ROLE;
    # GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE CONTAINER_USER_ROLE;
    root.grants.grant(Grant(
        grantee=Grantees.role('CONTAINER_USER_ROLE'),
        securable=Securables.current_account,
        privileges=[Privileges.create_database,
                    Privileges.create_warehouse,
                    Privileges.create_compute_pool,
                    Privileges.create_integration,
                    Privileges.monitor_usage,
                    Privileges.bind_service_endpoint
                    ],
    ))

    # GRANT IMPORTED PRIVILEGES ON DATABASE snowflake TO ROLE CONTAINER_USER_ROLE;
    root.grants.grant(Grant(
        grantee=Grantees.role('CONTAINER_USER_ROLE'),
        securable=Securables.database('snowflake'),
        privileges=[Privileges.imported_privileges
                    ],
    ))

    # grant role CONTAINER_USER_ROLE to role ACCOUNTADMIN;
    root.grants.grant(Grant(
        grantee=Grantees.role('ACCOUNTADMIN'),
        securable=Securables.role('CONTAINER_USER_ROLE'),
    ))

    # USE ROLE CONTAINER_USE_ROLE
    root.session.use_role("CONTAINER_USE_ROLE")

    # CREATE OR REPLACE DATABASE CONTAINER_HOL_DB;
    root.databases.create(Database(
        name="CONTAINER_HOL_DB",
        comment="This is a Container Quick Start Guide database"
    ), mode=CreateMode.or_replace)

    # CREATE OR REPLACE WAREHOUSE CONTAINER_HOL_WH
    #   WAREHOUSE_SIZE = XSMALL
    #   AUTO_SUSPEND = 120
    #   AUTO_RESUME = TRUE;
    root.warehouses.create(Warehouse(
        name="CONTAINER_HOL_WH",
        warehouse_size="XSMALL",
        auto_suspend=120,
        auto_resume="true",
        comment="This is a Container Quick Start Guide warehouse"
    ), mode=CreateMode.or_replace)

    # CREATE STAGE IF NOT EXISTS specs
    # ENCRYPTION = (TYPE='SNOWFLAKE_SSE');
    root.schemas[CONNECTION_PARAMETERS_ACCOUNT_ADMIN.get("schema")].stages.create(
        Stage(
            name="specs",
            encryption=StageEncryption(type="SNOWFLAKE_SSE")
    ))

    # CREATE STAGE IF NOT EXISTS volumes
    # ENCRYPTION = (TYPE='SNOWFLAKE_SSE')
    # DIRECTORY = (ENABLE = TRUE);
    root.schemas[CONNECTION_PARAMETERS_ACCOUNT_ADMIN.get("schema")].stages.create(
        Stage(
            name="volumes",
            encryption=StageEncryption(type="SNOWFLAKE_SSE"),
            directory_table=StageDirectoryTable(enable="true")
    ))
    # create collection objects as the entry
finally:
    connection_acct_admin.close()

```

Run the following Python API code in [`01_snowpark_container_services_setup.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/01_snowpark_container_services_setup.py) using the Snowpark Python Connector and Python API to create the [External Access Integration](https://docs.snowflake.com/developer-guide/snowpark-container-services/additional-considerations-services-jobs#network-egress) 
```Python API

# create a SnowflakeConnection instance
connection_acct_admin = connect(**CONNECTION_PARAMETERS_ACCOUNT_ADMIN)

try:
    # create a root as the entry point for all object
    root = Root(connection_acct_admin)

    connection_acct_admin.cursor().execute("""CREATE OR REPLACE NETWORK RULE ALLOW_ALL_RULE
        TYPE = 'HOST_PORT'
        MODE = 'EGRESS'
        VALUE_LIST= ('0.0.0.0:443', '0.0.0.0:80');""")

    connection_acct_admin.cursor().execute("""CREATE EXTERNAL ACCESS INTEGRATION ALLOW_ALL_EAI
        ALLOWED_NETWORK_RULES = (ALLOW_ALL_RULE)
        ENABLED = true;""")

    # GRANT USAGE ON INTEGRATION ALLOW_ALL_EAI TO ROLE CONTAINER_USER_ROLE;
    root.grants.grant(Grant(
        grantee=Grantees.role('CONTAINER_USER_ROLE'),
        securable=Securables.integration("ALLOW_ALL_EAI"),
        privileges=[Privileges.Usage]
    ))

finally:
        connection_acct_admin.close()
```

Run the following Python API code in [`01_snowpark_container_services_setup.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/01_snowpark_container_services_setup.py) using the Snowpark Python Connector and Python API to create
our first [compute pool](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-compute-pool), and our [image repository](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-registry-repository)
```Python API
    # USE ROLE CONTAINER_USE_ROLE
    root.session.use_role("CONTAINER_USE_ROLE")

    # CREATE COMPUTE POOL IF NOT EXISTS CONTAINER_HOL_POOL
    # MIN_NODES = 1
    # MAX_NODES = 1
    # INSTANCE_FAMILY = standard_1;
    root.compute_pools.create(ComputePool(
      name="CONTAINER_HOL_POOL",
      min_nodes=1,
      max_nodes=1,
      instance_family="CPU_X64_XS",
    ))

    # CREATE IMAGE REPOSITORY CONTAINER_HOL_DB.PUBLIC.IMAGE_REPO;
    root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].image_repositories.create(ImageRepository(
      name="IMAGE_REPO",
    ))

    # SHOW IMAGE REPOSITORIES IN SCHEMA CONTAINER_HOL_DB.PUBLIC;
    itr_data = root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].image_repositories.iter()
    for image_repo in itr_data:
        print(image_repo)
```
- The [OAuth security integration](https://docs.snowflake.com/en/user-guide/oauth-custom#create-a-snowflake-oauth-integration) will allow us to login to our UI-based services using our web browser and Snowflake credentials
- The [External Access Integration](https://docs.snowflake.com/developer-guide/snowpark-container-services/additional-considerations-services-jobs#network-egress) will allow our services to reach outside of Snowflake to the public internet
- The [compute pool](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-compute-pool) is the set of compute resources on which our services will run
- The [image repository](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-registry-repository) is the location in Snowflake where we will push our Docker images so that our services can use them

<!-- ------------------------ -->
## Set up your local environment
Duration: 10

### Python Virtual Environment and SnowCLI

- Download and install the miniconda installer from [https://conda.io/miniconda.html](https://conda.io/miniconda.html). (OR, you may use any other Python environment with Python 3.10, for example, [virtualenv](https://virtualenv.pypa.io/en/latest/)).

- Open a new terminal window, navigate to your Git repo, and execute the following commands in the same terminal window:

  1. Create the conda environment.
  ```
  conda env create -f conda_env.yml
  ```

  2. Activate the conda environment.
  ```
  conda activate snowpark-container-services-hol
  ```

  3. Configure your Snowflake CLI connection. The Snowflake CLI is designed to make managing UDFs, stored procedures, and other developer centric configuration files easier and more intuitive to manage. Let's create a new connection using:
  ```bash
  snow connection add
  ```
  ```yaml
  # follow the wizard prompts to set the following values:
  name : CONTAINER_hol
  account name: <ORG>-<ACCOUNT-NAME> # e.g. MYORGANIZATION-MYACCOUNT
  username : <user_name>
  password : <password>  
  role: CONTAINER_USER_ROLE  
  warehouse : CONTAINER_HOL_WH
  Database : CONTAINER_HOL_DB  
  Schema : public  
  connection :   
  port : 
  Region :  
  ```
  ```bash
  # test the connection:
  snow connection test --connection "CONTAINER_hol"
  ```

  6. Start docker via opening Docker Desktop.
  
  7. Test that we can successfully login to the image repository we created above, `CONTAINER_HOL_DB.PUBLIC.IMAGE_REPO`. Run the following using Python API code [`06_docker_jupyter_service.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/06_docker_jupyter_service.py) :
  ```Python API
  # Connect as CONTAINER_USE_ROLE
    connection_container_user_role = connect(**CONNECTION_PARAMETERS_CONTAINER_USER_ROLE)

    try:

        root = Root(connection_container_user_role)

        # Get the image repository URL
        #   use role CONTAINER_user_role;
        #   show image repositories in schema CONTAINER_HOL_DB.PUBLIC;
        #   // COPY the repository_url field, e.g. org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo
        #   ```
        #   ```bash
        #   # e.g. if repository_url = org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo, snowflake_registry_hostname = org-account.registry.snowflakecomputing.com
        repos = root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].image_repositories
        repo = repos["IMAGE_REPO"].fetch()

        # Extract the registry hostname from the repository URL
        pattern = r'^[^/]+'

        repository_url = repo.repository_url
        match = re.match(pattern, repository_url)
        registry_hostname = match.group(0)

        # Docker client
        client = docker.from_env()

        #   docker login <snowflake_registry_hostname> -u <user_name>
        #   > prompt for password
        # Login to the remote registry. Give user name and password for docker login
        client.login(username = "<username>",
                            password = "<password>",
                            registry = registry_hostname,
                            reauth = True)
    finally:
        connection_container_user_role.close()
  ```
  **Note the difference between `REPOSITORY_URL` (`org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo`) and `SNOWFLAKE_REGISTRY_HOSTNAME` (`org-account.registry.snowflakecomputing.com`)**

<!-- ------------------------ -->
## Build, Push, and Run the Jupyter Service
Duration: 45

### Build and Test the Image Locally

The first service we are going to create is a hosted Jupyter notebook service. First, we will build and test the image locally. In the code repo, there is a [`./src/jupyter-snowpark/dockerfile`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/src/jupyter-snowpark/dockerfile) with the following contents:
```python
FROM python:3.9
LABEL author=""

#Install packages & python base
RUN apt-get update && \
    apt-get install -y python3-pip

RUN pip3 install JPype1 jupyter pandas numpy seaborn scipy matplotlib seaborn pyNetLogo SALib "snowflake-snowpark-python[pandas]" snowflake-connector-python

#Create a new user for the notebook server , NB RUN instrcution are only ever executed during the buid
RUN useradd -ms /bin/bash jupyter   

#set the user and working directory 
USER jupyter
WORKDIR /home/jupyter 

#other system settings
EXPOSE 8888   

#launch jupyter notebook server. NOTE!  ENTRYPOINT ( or CMD )intrscutions run each time a container is launched!
ENTRYPOINT ["jupyter", "notebook","--allow-root","--ip=0.0.0.0","--port=8888","--no-browser" , "--NotebookApp.token=''", "--NotebookApp.password=''"] 
```
This is just a normal Dockerfile, where we install some packages, change our working directory, expose a port, and then launch our notebook service. There's nothing unique to Snowpark Container Services here! 

Let's build and test the image locally from the terminal. **Note it is a best practice to tag your local images with a `local_repository` prefix.** Often, users will set this to a combination of first initial and last name, e.g. `jsmith/my-image:latest`. Navigate to your local clone of `.../sfguide-intro-to-snowpark-container-services/src/jupyter-snowpark` and run a Docker build command using Python code:
```bash

# Build the Docker Image in the Example
# cd .../sfguide-intro-to-snowpark-container-services/src/jupyter-snowpark
# docker build --platform=linux/amd64 -t <local_repository>/python-jupyter-snowpark:latest .
client.images.build(path='sfguide-intro-to-snowpark-container-services/src/jupyter-snowpark', platform='linux/aarch64', tag='<local_repository>/python-jupyter-snowpark:latest')

```
Verify the image built successfully:
```bash
# Check to see if the image is there
# Verify the image built successfully:
# docker image list
client.images.list()
```
Now that our local image has built, let's validate that it runs successfully. From a terminal run:
```bash
# Test running the image
# docker run -d -p 8888:8888 <local_repository>/python-jupyter-snowpark:latest
container = client.containers.run(image='<local_repository>/python-jupyter-snowpark:latest', detach=True, ports={8888: 8888})

# Use CURL to test the service
# Open up a browser and navigate to [localhost:8888/lab](http://localhost:8888/lab) to verify 
# your notebook service is working locally. Once you've verified that the service is working,
# you can stop the container:
os.system("""curl -X GET  http://localhost:8888/lab""")

# docker stop python-jupyter-snowpark
container.stop()
```

### Tag and Push the Image
Now that we have a local version of our container working, we need to push it to Snowflake so that a Service can access the image. To do this we will create a new tag of the image that points at our image repository in our Snowflake account, and then push said tagged image. From a terminal, run the following:
```bash
    # Tag it
    #  # e.g. if repository_url = org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo, 
    #  snowflake_registry_hostname = org-account.registry.snowflakecomputing.com
    #   docker login <snowflake_registry_hostname> -u <user_name>
    #   > prompt for password
    #   docker tag <local_repository>/python-jupyter-snowpark:latest <repository_url>/python-jupyter-snowpark:dev
        # Grab the image
    image = next(i for i in client.images.list() if "<local_repository>/python-jupyter-snowpark:latest" in i.tags)
    image.tag(repository_url, 'dev')
```
  **Note the difference** between `REPOSITORY_URL` (`org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo`) and `SNOWFLAKE_REGISTRY_HOSTNAME` (`org-account.registry.snowflakecomputing.com`)

Verify that the new tagged image exists by running:
```bash
    # Check to see if the image is there
    # Verify the image built successfully:
    # docker image list
    client.images.list()
```
Now, we need to push our image to Snowflake. From the terminal:
```bash
    # Push the image to the remote registry
    # docker push <repository_url>/python-jupyter-snowpark:dev
    client.api.push(repository_url + '/python-jupyter-snowpark:dev')
```
This may take some time, so you can move on to the next step **Configure and Push the Spec YAML** while the image is being pushed. Once the `docker push` command completes, you can verify that the image exists in your Snowflake Image Repository by running the following Python API code:
```Python API
    # USE ROLE CONTAINER_USER_ROLE;
    # CALL SYSTEM$REGISTRY_LIST_IMAGES('/CONTAINER_HOL_DB/PUBLIC/IMAGE_REPO');
    images = root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].image_repositories["IMAGE_REPO"].list_images_in_repository()
    for image in images:
        print(image)
```
You should see your `python-jupyter-snowpark` image listed.

### Configure and Push the Spec YAML
Services in Snowpark Container Services are defined using YAML files. These YAML files configure all of the various parameters, etc. needed to run the containers within your Snowflake account. These YAMLs support a [large number of configurable parameter](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/specification-reference), although we will not reference all of them here. Navigate to your local clone of `.../sfguide-intro-to-snowpark-container-services/src/jupyter-snowpark/jupyter-snowpark.yaml`, which should look like this:

```yaml
spec:
  containers:
    - name: jupyter-snowpark
      image: <repository_hostname>/container_hol_db/public/image_repo/python-jupyter-snowpark:dev
      volumeMounts:
        - name: jupyter-home
          mountPath: /home/jupyter
  endpoints:
    - name: jupyter-snowpark
      port: 8888
      public: true
  volumes:
    - name: jupyter-home
      source: "@volumes/jupyter-snowpark"
      uid: 1000
      gid: 1000

```

**NOTE**: Update **<repository_hostname>** for your image and save the file.

Now that the spec file is updated, we need to push it to our Snowflake Stage so that we can reference it next in our `create service` statement. We will use Python API to push the yaml file. Run the following using Python API code [`08_stage_files.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/08_stage_files.py) :

```Python API
    # cd .../sfguide-intro-to-snowpark-container-services/src/jupyter-snowpark
    # snow stage copy ./jupyter-snowpark.yaml @specs --overwrite --connection CONTAINER_hol
    s = root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].stages["SPECS"]
    s.upload_file("./jupyter-snowpark.yaml", "/", auto_compress=False, overwrite=True)
```
You can verify that your yaml was pushed successfully by running the following Python API code and verifying that the file is listed:
```Python API
connection_container_user_role = connect(**CONNECTION_PARAMETERS_CONTAINER_USER_ROLE)

try:

    root = Root(connection_container_user_role)

    #USE ROLE CONTAINER_USER_ROLE;
    #LS @CONTAINER_HOL_DB.PUBLIC.SPECS;
    stageFiles = root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].stages["SPECS"].list_files()
    for stageFile in stageFiles:
        print(stageFile)

finally:
    connection_container_user_role.close()

```

### Create and Test the Service
Once we have successfully pushed our image and our spec YAML, we have all of the components uploaded to Snowflake that we need in order to create our service. There are three components required to create the service: a service name, a compute pool the service will run on, and the spec file that defines the service. Run the following Python script to create our Jupyter service:
```Python API

# Connect as CONTAINER_USE_ROLE
connection_container_user_role = connect(**CONNECTION_PARAMETERS_CONTAINER_USER_ROLE)

try:
    # create a root as the entry point for all object
    root = Root(connection_container_user_role)

    # create service CONTAINER_HOL_DB.PUBLIC.JUPYTER_SNOWPARK_SERVICE
    # in compute pool CONTAINER_HOL_POOL
    # from @specs
    # specification_file='jupyter-snowpark.yaml'
    # external_access_integrations = (ALLOW_ALL_EAI);
    s = root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].services.create(Service(
        name="JUPYTER_SNOWPARK_SERVICE",
        compute_pool="CONTAINER_HOL_POOL",
        spec=ServiceSpecStageFile(stage="specs", spec_file="jupyter-snowpark.yaml"),
        external_access_integrations=["ALLOW_ALL_EAI"],
    ))

    # CALL SYSTEM$GET_SERVICE_STATUS('CONTAINER_HOL_DB.PUBLIC.jupyter_snowpark_service');
    status = s.get_service_status()
    print(status)

    # CALL SYSTEM$GET_SERVICE_LOGS('CONTAINER_HOL_DB.PUBLIC.JUPYTER_SNOWPARK_SERVICE', '0', 'jupyter-snowpark',10);
    logs = s.get_service_logs("0", "jupyter-snowpark", 10)
    print(logs)

    # SHOW ENDPOINTS IN SERVICE JUPYTER_SNOWPARK_SERVICE;
    endpoints = s.get_endpoints()
    for endpoint in endpoints:
        print(endpoint)

    # --- After we make a change to our Jupyter notebook,
    # --- we will suspend and resume the service
    # --- and you can see that the changes we made in our Notebook are still there!
    # ALTER SERVICE CONTAINER_HOL_DB.PUBLIC.JUPYTER_SNOWPARK_SERVICE SUSPEND;
    s.suspend()

    # ALTER SERVICE CONTAINER_HOL_DB.PUBLIC.JUPYTER_SNOWPARK_SERVICE RESUME;
    s.resume()

finally:
    connection_container_user_role.close()

```
These script is the file [`02_jupyter_service.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/02_jupyter_service.py).

Since we specified that the `jupyter-snowpark` endpoint running on port `8888` would be `public: true` in our spec YAML, Snowflake is going to generate a URL for our service that can be used to access the service via our Web Browser. To get the URL, once the service is successfully in a `RUNNING` state, execute the following:
```Python API
    # SHOW ENDPOINTS IN SERVICE JUPYTER_SNOWPARK_SERVICE;
    endpoints = s.get_endpoints()
    for endpoint in endpoints:
        print(endpoint)
```
Copy the `jupyter-snowpark` endpoint URL, and paste it in your browser. You will be asked to login to Snowflake via your username and password, after which you should successfully see your Jupyter instance running, all inside of Snowflake! **Note, to access the service** the user logging in must have the `CONTAINER_USER_ROLE` AND their default role cannot be `ACCOUNTADMIN`, `SECURITYADMIN`, or `ORGADMIN`.

### Upload and Modify a Jupyter Notebook
Notice that in our spec YAML file we mounted the `@volumes/jupyter-snowpark` internal stage location to our `/home/jupyter` directory inside of our running container. What this means is that we will use our internal stage `@volumes` to persist and store artifacts from our container. If you go check out the `@volumes` stage in Snowsight, you'll see that when we created our `jupyter_snowpark_service`, a folder was created in our stage: `@volumes/jupyter-snowpark`

![Stage Volume Mount](./assets/stage_volume_mount.png)

Now, any file that is uploaded to `@volumes/jupyter-snowpark` will be available inside of our container in the `/home/jupyter` directory, and vice versa. Read more about volume mounts in the [documentation](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/specification-reference#spec-volumes-field-optional). To test this out, let's upload the sample Jupyter notebook that is in our source code repo at `.../sfguide-intro-to-snowpark-container-services/src/jupyter-snowpark/sample_notebook.ipynb`. To do this you can either
- Click on the `jupyter-snowpark` directory in Snowsight, click the blue `+ Files` button and drag/browse to `sample_notebook.ipynb`. Click Upload. Navigate to your Jupyter service UI in your browser, click the refresh arrow and you should now see your notebook available!

OR
- Upload `sample_notebook.ipynb` to `@volumes/jupyter-snowpark` using SnowCLI

OR
- Upload `sample_notebook.ipynb` directly in your Jupyter service  on the home screen by clicking the `Upload` button. If you now navigate back to `@volumes/jupyter-snowpark` in Snowsight, our run an `ls @volumes/jupyter-snowpark` SQL command, you should see  your `sample_notebook.ipynb` file listed. Note you may need to hit the Refresh icon in Snowsight for the file to appear.

What we've done is now created a Jupyter notebook which we can modify in our service, and the changes will be persisted in the file because it is using a stage-backed volume. Let's take a look at the contents of our `sample_notebook.ipynb`. Open up the notebook in your Jupyter service:

![Jupyter Notebook](./assets/jupyter.png)

We want to pay special attention to the contents of the `get_login_token()` function:
```python
def get_login_token():
    with open('/snowflake/session/token', 'r') as f:
        return f.read()
```
When you start a service or a job, Snowflake provides credentials to the running containers in the form of an oauth token located at `/snowflake/session/token`, enabling your container code to use Snowflake connectors for [connecting to Snowflake](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/additional-considerations-services-jobs#connecting-to-snowflake-from-inside-a-container) and executing SQL (similar to any other code on your computer connecting to Snowflake). The provided credentials authenticate as the service role. Snowflake provides some of the information as environment variables in your containers.

Every object in Snowflake has an owner role. In the case of a service or job, Snowflake has a concept called a service role (this term applies to both services and jobs). The service role determines what capabilities your service is allowed to perform when interacting with Snowflake. This includes executing SQL, accessing stages, and service-to-service networking.

We configure the Snowpark Python Client to connect to our Snowflake account and execute SQL using this oauth token:
```python
connection_parameters = {
    "account": os.getenv('SNOWFLAKE_ACCOUNT'),
    "host": os.getenv('SNOWFLAKE_HOST'),
    "token": get_login_token(),
    "authenticator": "oauth",
    "database": "CONTAINER_HOL_DB",
    "schema": "PUBLIC",
    "warehouse": "CONTAINER_HOL_WH"
}
```

Now we can run a sample query using our Snowpark session!

We've successfully built and deployed our Jupyter Notebook service. Now let's move on to a REST API which we will interact with using a Service Function.
<!-- ------------------------ -->
## Build, Push, and Run the Temperature Conversion REST API Service
Duration: 30

### Build and Test the Image Locally

The next service we are going to create is a simple REST API that takes in Celsius temperatures and converts them to Fahrenheit- a trivial example. First, we will build and test the image locally. In the code repo, there is a [`./src/convert-api/dockerfile`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/src/convert-api/dockerfile) with the following contents:
```python
FROM python:3.11

# Copy the packages file into the build
WORKDIR /app
COPY ./ /app/

# run the install using the packages manifest file
RUN pip install --no-cache-dir -r requirements.txt

# Open port 9090
EXPOSE 9090

# When the container launches run the flask app
ENV FLASK_APP="convert-app.py"
CMD ["flask", "run", "--host=0.0.0.0", "--port=9090"]
```
This is just a normal Dockerfile, where we install some packages, change our working directory, expose a port, and then launch our REST API. Our REST API is defined in [`./src/convert-api/convert-app.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/src/convert-api/convert-app.py):
```python
from flask import Flask, request, jsonify

app = Flask(__name__)

# The function to convert Celsius to Fahrenheit
def celsius_to_fahrenheit(celsius):
    return celsius * 9./5 + 32

@app.route('/convert', methods=['POST'])
def convert():
    # Get JSON data from request
    data = request.get_json()

    # Check if the 'data' key exists in the received JSON
    if 'data' not in data:
        return jsonify({'error': 'Missing data key in request'}), 400

    # Extract the 'data' list from the received JSON
    data_list = data['data']

    # Initialize a list to store converted values
    converted_data = []

    # Iterate over each item in 'data_list'
    for item in data_list:
        # Check if the item is a list with at least two elements
        if not isinstance(item, list) or len(item) < 2:
            return jsonify({'error': 'Invalid data format'}), 400
        
        # Extract the Celsius value
        celsius = item[1]
        
        # Convert to Fahrenheit and append to 'converted_data'
        converted_data.append([item[0], celsius_to_fahrenheit(celsius)])

    # Return the converted data as JSON
    return jsonify({'data': converted_data})

if __name__ == '__main__':
    app.run(debug=True)
```

The only thing unique to Snowflake about this container, is that the REST API code expects to receive requests in the format that [Snowflake External Function](https://docs.snowflake.com/en/sql-reference/external-functions-data-format#body-format) calls are packaged, and must also package the response in the expected format so that we can use it as a Service Function. **Note this is only required if you intend to interact with the API via a SQL function**.

Let's build and test the image locally from the terminal. **Note it is a best practice to tag your local images with a `local_repository` prefix. Often, users will set this to a combination of first initial and last name, e.g. `jsmith/my-image:latest`. Navigate to your local clone of `.../sfguide-intro-to-snowpark-container-services/src/convert-api` and run a Docker build command using Python. Run the following using Python API code [`07_docker_rest_service.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/07_docker_rest_service.py) :
```bash
    # Build the Docker Image in the Example
    # cd .../sfguide-intro-to-snowpark-container-services/src/convert-api
    # docker build --platform=linux/amd64 -t <local_repository>/convert-api:latest .
    client.images.build(path='sfguide-intro-to-snowpark-container-services/src/convert-api', platform='linux/aarch64', tag='<local_repository>/convert-api:latest')
```
Verify the image built successfully:
```bash
    # Check to see if the image is there
    # Verify the image built successfully:
    # docker image list
    client.images.list()
```
Now that our local image has built, let's validate that it runs successfully. From a terminal run:
```bash
    # Test running the image
    # docker run -d -p 9090:9090 <local_repository>/convert-api:latest
    container = client.containers.run(image='<local_repository>/convert-api:latest', detach=True, ports={9090: 9090})
```
Test our local container endpoint by running the following from a different terminal window:
```bash
    # Use CURL to test the service
    # curl -X POST -H "Content-Type: application/json" -d '{"data": [[0, 12],[1,19],[2,18],[3,23]]}' http://localhost:9090/convert
    
    os.system("""curl -X POST 
                -H "Content-Type: application/json" 
                -d '{"data": [[0, 12],[1,19],[2,18],[3,23]]}' 
                http://localhost:9090/convert """)

```
You should recieve back a JSON object, this will contain the batch id and then the converted value in Fahrenheit:
```bash
{"data":[[0,53.6],[1,66.2],[2,64.4],[3,73.4]]}
```
Once you've verified that the service is working, you can stop the container: `container.stop()`.

### Tag and Push the Image
Now that we have a local version of our container working, we need to push it to Snowflake so that a Service can access the image. To do this we will create a new tag of the image that points at our image repository in our Snowflake account, and then push said tagged image. From a terminal, run the following:
```bash
  # e.g. if repository_url = org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo, snowflake_registry_hostname = org-account.registry.snowflakecomputing.com
      #   docker login <snowflake_registry_hostname> -u <user_name>
    #   > prompt for password
    # Login to the remote registry. Give user name and password for docker login
    client.login(username = "<username>",
                        password = "<password>",
                        registry = registry_hostname,
                        reauth = True)

     # Grab the image
    image = next(i for i in client.images.list() if "<local_repository>/convert-api:latest" in i.tags)

    # Tag it
    #  # e.g. if repository_url = org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo,
    #  snowflake_registry_hostname = org-account.registry.snowflakecomputing.com
    #   docker login <snowflake_registry_hostname> -u <user_name>
    #   > prompt for password
    #  docker tag <local_repository>/convert-api:latest <repository_url>/convert-api:dev
    image.tag(repository_url, 'dev')
 
```
**Note the difference between `REPOSITORY_URL` (`org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo`) and `SNOWFLAKE_REGISTRY_HOSTNAME` (`org-account.registry.snowflakecomputing.com`)**

Verify that the new tagged image exists by running:
```bash
    # Check to see if the image is there
    # Verify the image built successfully:
    # docker image list
    client.images.list()
```
Now, we need to push our image to Snowflake. From the terminal:
```bash
    # Push the image to the remote registry
    # docker push <repository_url>/convert-api:dev
    client.api.push(repository_url + '/convert-api:dev')
```
This may take some time, so you can move on to the next step **Configure and Push the Spec YAML** while the image is being pushed. Once the `docker push` command completes, you can verify that the image exists in your Snowflake Image Repository by running the following Python API code:
```Python API
    # USE ROLE CONTAINER_USER_ROLE;
    # CALL SYSTEM$REGISTRY_LIST_IMAGES('/CONTAINER_HOL_DB/PUBLIC/IMAGE_REPO');
    images = root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].image_repositories["IMAGE_REPO"].list_images_in_repository()
    for image in images:
        print(image)
```
You should see your `convert-api` image listed.

### Configure and Push the Spec YAML
Services in Snowpark Container Services are defined using YAML files. These YAML files configure all of the various parameters, etc. needed to run the containers within your Snowflake account. These YAMLs support a [large number of configurable parameter](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/specification-reference), although we will not reference all of them here. Navigate to your local clone of `.../sfguide-intro-to-snowpark-container-services/src/convert-api/convert-api.yaml`, which should look like this:

```yaml
spec:
  containers:
    - name: convert-api
      image: <repository_hostname>/container_hol_db/public/image_repo/convert-api:dev
  endpoints:
    - name: convert-api
      port: 9090
      public: true
```

**NOTE**: Update **<repository_hostname>** for your image and save the file.

Now that the spec file is updated, we need to push it to our Snowflake Stage so that we can reference it next in our `create service` statement. We will use Python API to push the yaml file. Run the following using Python API code [`08_stage_files.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/08_stage_files.py)
```Python API
    # cd .../sfguide-intro-to-snowpark-container-services/src/convert-api
    # snow stage copy ./convert-api.yaml @specs --overwrite --connection CONTAINER_hol
    s = root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].stages["SPECS"]
    s.upload_file("./convert-api.yaml", "/", auto_compress=False, overwrite=True)
```
You can verify that your yaml was pushed successfully by running the Python code and verifying that the file is listed. Run the following using Python API code [`08_stage_files.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/08_stage_files.py) :
```Python API
# Connect as CONTAINER_USE_ROLE
connection_container_user_role = connect(**CONNECTION_PARAMETERS_CONTAINER_USER_ROLE)

try:

    root = Root(connection_container_user_role)

    #USE ROLE CONTAINER_USER_ROLE;
    #LS @CONTAINER_HOL_DB.PUBLIC.SPECS;
    stageFiles = root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].stages["SPECS"].listFiles()
    for stageFile in stageFiles:
        print(stageFile)
        
finally:
    connection_container_user_role.close()

```

### Create and Test the Service
Once we have successfully pushed our image and our spec YAML, we have all of the components uploaded to Snowflake that we need in order to create our service. There are three components required to create the service: a service name, a compute pool the service will run on, and the spec file that defines the service. Run the following Python API script to create our Jupyter service:
```Python API
# Connect as CONTAINER_USE_ROLE
connection_container_user_role = connect(**CONNECTION_PARAMETERS_CONTAINER_USER_ROLE)

try:
    # create a root as the entry point for all object
    root = Root(connection_container_user_role)

    # create service CONTAINER_HOL_DB.PUBLIC.convert_api
    #     in compute pool CONTAINER_HOL_POOL
    #     from @specs
    #     specification_file='convert-api.yaml'
    #     external_access_integrations = (ALLOW_ALL_EAI);
    s = root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].services.create(Service(
        name="convert_api",
        compute_pool="CONTAINER_HOL_POOL",
        spec=ServiceSpecStageFile(stage="specs", spec_file="convert-api.yaml"),
        external_access_integrations=["ALLOW_ALL_EAI"],
    ))

    # CALL SYSTEM$GET_SERVICE_STATUS('CONTAINER_HOL_DB.PUBLIC.CONVERT-API');
    status = s.get_service_status()
    print(status)

    # CALL SYSTEM$GET_SERVICE_LOGS('CONTAINER_HOL_DB.PUBLIC.CONVERT_API', '0', 'convert-api',10);
    logs = s.get_service_logs("0", "convert-api", 10)
    print(logs)

finally:
    connection_container_user_role.close()

```
These commands are also listed in [`03_rest_service.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/03_rest_service.py)

### Create and Test the Service Function
Once the service is up and running, we will create a Service Function that allows us to call our REST API's function via Python Connector. First, let's create a table and then create a Service function:
```Python API
# Connect as CONTAINER_USE_ROLE
connection_container_user_role = connect(**CONNECTION_PARAMETERS_CONTAINER_USER_ROLE)

try:
    # create a root as the entry point for all object
    root = Root(connection_container_user_role)

    # CREATE OR REPLACE TABLE WEATHER (
    #     DATE DATE,
    #     LOCATION VARCHAR,
    #     TEMP_C NUMBER,
    #     TEMP_F NUMBER
    # );
    root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].tables.create(
        Table(
            name="WEATHER",
            columns=[
                    TableColumn(name="DATE", datatype="DATE"),
                    TableColumn(name="LOCATION", datatype="VARCHAR"),
                    TableColumn(name="TEMP_C", datatype="NUMBER"),
                    TableColumn(name="TEMP_F", datatype="NUMBER"),
                ],
        ),
        mode=CreateMode.or_replace
    )

finally:
    connection_container_user_role.close()

```

Now, let's insert some sample weather data in the table using Python Connector:
These commands are also listed in [`03_rest_service.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/03_rest_service.py)
``` Python Connector
    
    # Connect as CONTAINER_USE_ROLE
    connection_container_user_role = connect(**CONNECTION_PARAMETERS_CONTAINER_USER_ROLE)

    connection_container_user_role.cursor().execute("""INSERT INTO weather (DATE, LOCATION, TEMP_C, TEMP_F)
                        VALUES 
                            ('2023-03-21', 'London', 15, NULL),
                            ('2023-07-13', 'Manchester', 20, NULL),
                            ('2023-05-09', 'Liverpool', 17, NULL),
                            ('2023-09-17', 'Cambridge', 19, NULL),
                            ('2023-11-02', 'Oxford', 13, NULL),
                            ('2023-01-25', 'Birmingham', 11, NULL),
                            ('2023-08-30', 'Newcastle', 21, NULL),
                            ('2023-06-15', 'Bristol', 16, NULL),
                            ('2023-04-07', 'Leeds', 18, NULL),
                            ('2023-10-23', 'Southampton', 12, NULL);""")

finally:
    connection_container_user_role.close()

```
Now, let's create a function that specifies our `convert-api` service's `convert-api` endpoint:
```Python API
# Connect as CONTAINER_USE_ROLE
connection_container_user_role = connect(**CONNECTION_PARAMETERS_CONTAINER_USER_ROLE)

try:
    # create a root as the entry point for all object
    root = Root(connection_container_user_role)

    # CREATE OR REPLACE FUNCTION convert_udf (input float)
    # RETURNS float
    # SERVICE=CONVERT_API      //Snowflake container service
    # ENDPOINT='convert-api'   //The endpoint within the container
    # MAX_BATCH_ROWS=5         //limit the size of the batch
    # AS '/convert';           //The API endpoint
    root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].functions.create(
        ServiceFunction(
        name="convert_udf",
        arguments=[
            FunctionArgument(name="input", datatype="REAL")
        ],
        returns="REAL",
        service="CONVERT_API",
        endpoint="'convert-api'",
        path="/convert",
        max_batch_rows=5,
        ),
        mode = CreateMode.or_replace)

finally:
    connection_container_user_role.close()

```
We can now test our function:
```Python Connector

    f = root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].functions["convert_udf(REAL)"].execute_function([12])
    print(f)

```
And even update our table to populate the `TEMP_F` field using our Service Function:
```Python Connector
    
    connection_container_user_role.cursor().execute("""UPDATE WEATHER
                    SET TEMP_F = convert_udf(TEMP_C);""")

    for (col1, col2, col3, col4) in connection_container_user_role.cursor().execute("SELECT * FROM WEATHER;"):
        print('{0} {1} {2} {3}'.format(col1, col2, col3, col4))

```

### (Optional) Call the Convert Temperature Service Function from our Jupyter Notebook Service
Open up our previously created Jupyter Notebook service and open up our `sample_notebook.ipynb`. Copy and paste the following code into a new cell at the bottom of the notebook:
```python
df = session.table('weather')
df = df.with_column("TEMP_F_SNOWPARK", F.call_udf('convert_udf', df['TEMP_C']))
df.show()
```

Run the cell, and you should see the following output dataframe, with our new column `TEMP_F_SNOWPARK` included:
```python
----------------------------------------------------------------------
|"DATE"      |"LOCATION"   |"TEMP_C"  |"TEMP_F"  |"TEMP_F_SNOWPARK"  |
----------------------------------------------------------------------
|2023-03-21  |London       |15        |59        |59.0               |
|2023-07-13  |Manchester   |20        |68        |68.0               |
|2023-05-09  |Liverpool    |17        |63        |62.6               |
|2023-09-17  |Cambridge    |19        |66        |66.2               |
|2023-11-02  |Oxford       |13        |55        |55.4               |
|2023-01-25  |Birmingham   |11        |52        |51.8               |
|2023-08-30  |Newcastle    |21        |70        |69.8               |
|2023-06-15  |Bristol      |16        |61        |60.8               |
|2023-04-07  |Leeds        |18        |64        |64.4               |
|2023-10-23  |Southampton  |12        |54        |53.6               |
----------------------------------------------------------------------
```

Now, save the Jupyter notebook- when you come back to this service in the future, your new code will be saved because of our stage-backed volume mount!
<!-- ------------------------ -->
## Managing Services with Python API
Duration: 5

There are a number of useful Python API we should explore with respect to controlling the service itself.  More information on Python API can be found at [Snowpark Container Services Python API](https://docs.snowflake.com/developer-guide/snowflake-python-api/snowflake-python-overview) 

1. Get the status of your container using ServiceResource.get_service_status():

    ```Python API
    s = root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].services["JUPYTER_SNOWPARK_SERVICE"]
    s.get_service_status()
    ```

2. Check the status of the logs with :

    ```Python API
    s.get_service_logs("0","jupyter-snowpark",10)
    ```

3. Suspend your container using the Python API

    ```Python API
    s.suspend()
    ```

4. Resume your container using the Python API

  ```Python API
  s.resume()
  ```

<!-- ------------------------ -->
## Stop the Services and Suspend the Compute Pool
Duration: 2

If you no longer need the services and compute pool up and running, we can stop the services and suspend the compute pool so that we don't incur any cost (Snowpark Container Services bill credits/second based on the compute pool's uptime, similar to Virtual Warehouse billing) run the following from [`05_stop_snowpark_container_services_and_suspend_compute_pool.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/05_stop_snowpark_container_services_and_suspend_compute_pool.py):
```Python API
# Connect as CONTAINER_USE_ROLE
connection_container_user_role = connect(**CONNECTION_PARAMETERS_CONTAINER_USER_ROLE)

try:
    # create a root as the entry point for all object
    root = Root(connection_container_user_role)

    # ALTER COMPUTE POOL CONTAINER_HOL_POOL STOP ALL;
    root.compute_pools["CONTAINER_HOL_POOL"].stop_all_services()

    # ALTER COMPUTE POOL CONTAINER_HOL_POOL SUSPEND;
    root.compute_pools["CONTAINER_HOL_POOL"].suspend()

finally:
    connection_container_user_role.close()

```

If you want to clean up and remove ALL of the objects you created during this quickstart, run the following from [`04_cleanup.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/04_teardown.py):
```Python API
# Connect as CONTAINER_USE_ROLE
connection_container_user_role = connect(**CONNECTION_PARAMETERS_CONTAINER_USER_ROLE)

try:
    # create a root as the entry point for all object
    root = Root(connection_container_user_role)

    # ALTER COMPUTE POOL CONTAINER_HOL_POOL STOP ALL;
    root.compute_pools["CONTAINER_HOL_POOL"].stop_all_services()

    # ALTER COMPUTE POOL CONTAINER_HOL_POOL SUSPEND;
    root.compute_pools["CONTAINER_HOL_POOL"].suspend()

    # DROP SERVICE CONTAINER_HOL_DB.PUBLIC.JUPYTER_SNOWPARK_SERVICE;
    root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].services["JUPYTER_SNOWPARK_SERVICE"].delete()

    # DROP SERVICE CONTAINER_HOL_DB.PUBLIC.CONVERT_API;
    root.databases["CONTAINER_HOL_DB"].schemas["PUBLIC"].services["CONVERT_API"].delete()

    # DROP COMPUTE POOL CONTAINER_HOL_POOL;
    root.compute_pools["CONTAINER_HOL_POOL"].delete()

    # DROP DATABASE CONTAINER_HOL_DB;
    root.databases["CONTAINER_HOL_DB"].delete()

    # DROP WAREHOUSE CONTAINER_HOL_WH;
    root.warehouses["CONTAINER_HOL_WH"].delete()

    # create a SnowflakeConnection instance
    connection_acct_admin = connect(**CONNECTION_PARAMETERS_ACCOUNT_ADMIN)

    # create a root as the entry point for all object
    root = Root(connection_acct_admin)

    try:
        # DROP ROLE CONTAINER_USER_ROLE;
        root.roles["CONTAINER_USER_ROLE"].delete()
    finally:
        connection_acct_admin.close()

finally:
    connection_container_user_role.close()
```

<!-- ------------------------ -->
## Conclusion
Congratulations, you have successfully completed this quickstart! Through this quickstart, we were able to create and manage long-running services using Snowflake's managed Snowpark Container Services. These services run entirely within your Snowflake account boundary using a managed container orchestration service- keeping your data secure, and making development to deployment incredibly easy.

For more information, check out the resources below:

### Related Resources
- [Snowpark Container Services Documentation](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview)
- [Snowpark Container Services SQL Commands](https://docs.snowflake.com/en/sql-reference/commands-snowpark-container-services)
- [Snowpark Container Services - A Tech Primer](https://medium.com/snowflake/snowpark-container-services-a-tech-primer-99ff2ca8e741)
- [Building Advanced ML with Snowpark Container Services - Summit 2023](https://www.youtube.com/watch?v=DelaJBm0UgI)
- [Snowpark Container Services with NVIDIA](https://www.youtube.com/watch?v=u98YTgCelYg)
- [Quickstart GitHub](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services)
- [Snowflake Announces Snowpark Container Services](https://www.snowflake.com/blog/snowpark-container-services-deploy-genai-full-stack-apps/)

<!-- ------------------------ -->

author: Caleb Baechtold
id: intro_to_snowpark_container_services
summary: Through this quickstart guide, you will explore Snowpark Container Services
categories: Getting-Started
environments: web
status: Published 
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Containers, Snowpark

# Intro to Snowpark Container Services
<!-- ------------------------ -->
## Overview 
Duration: 3

Through this quickstart guide, you will explore [Snowpark Container Services](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview). You will learn the basic mechanics of working with Snowpark Container Services and build several introductory services. **Please note: this quickstart assumes some existing knowledge and familiarity with containerization (e.g. Docker) and basic familiarity with container orchestration.**

### What is Snowpark Container Services?

![Snowpark Container Service](./assets/containers.png)

[Snowpark Container Services](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview) is a fully managed container offering that allows you to easily deploy, manage, and scale containerized services, jobs, and functions, all within the security and governance boundaries of Snowflake, and requiring zero data movement. As a fully managed service, SPCS comes with Snowflake’s native security, RBAC support, and built-in configuration and operational best-practices.

Snowpark Container Services are fully integrated with both Snowflake features and third-party tools, such as Snowflake Virtual Warehouses and Docker, allowing teams to focus on building data applications, and not building or managing infrastructure. Just like all things Snowflake, this managed service allows you to run and scale your container workloads across regions and clouds without the additional complexity of managing a control plane, worker nodes, and also while having quick and easy access to your Snowflake data.

The introduction of Snowpark Container Services on Snowflake includes the incorporation of new object types and constructs to the Snowflake platform, namely: images, image registry, image repositories, compute pools, specification files, services, and jobs.

![Development to Deployment](./assets/spcs_dev_to_deploy.png)

For more information on these objects, check out [this article](https://medium.com/snowflake/snowpark-container-services-a-tech-primer-99ff2ca8e741) along with the Snowpark Container Services [documentation](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview).

How are customers and partners using Snowpark Container Services today? Containerized services on Snowflake open up the opportunity to host and run long-running services, like front-end web applications, all natively within your Snowflake environment. Customers are now running GPU-enabled machine learning and AI workloads, such as GPU-accelerated model training and open-source Large Language Models (LLMs) as jobs and as service functions, including fine-tuning of these LLMs on your own Snowflake data, without having to move the data to external compute infrastructure. Snowpark Container Services are an excellent path for deploying applications and services that are tightly coupled to the Data Cloud.

Note that while in this quickstart, we will predominantly use the direct SQL commands to interact with Snowpark Container Services and their associated objects, there is also [Python API support](https://docs.snowflake.com/developer-guide/snowflake-python-api/snowflake-python-overview) in Public Preview that you can also use. Refer to the [documentation](https://docs.snowflake.com/developer-guide/snowflake-python-api/snowflake-python-overview) for more info.

### What you will learn 
- The basic mechanics of how Snowpark Container Services works
- How to deploy a long-running service with a UI and use volume mounts to persist changes in the file system
- How to interact with Snowflake warehouses to run SQL queries from inside of a service
- How to deploy a Service Function to perform basic calculations

### Prerequisites
##### **Download the git repo here: https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services.git**. 
You can simply download the repo as a .zip if you don't have Git installed locally.

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
- [Python 3.10](https://www.python.org/downloads/) installed
    - Note that you will be creating a Python environment with 3.10 in the **Setup the Local Environment** step
- (Optional) [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) installed
    >**Download the git repo here: https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services.git**. You can simply download the repo as a .zip if you don't have Git installed locally.
- (Optional) [VSCode](https://code.visualstudio.com/) (recommended) with the [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker), [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python), and [Snowflake](https://marketplace.visualstudio.com/items?itemName=snowflake.snowflake-vsc) extensions installed.
- A non-trial Snowflake account in a supported [AWS region](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview#available-regions).
- A Snowflake account login with a role that has the `ACCOUNTADMIN` role. If not, you will need to work with your `ACCOUNTADMIN` to perform the initial account setup (e.g. creating the `CONTAINER_USER_ROLE` and granting required privileges, as well as creating the OAuth Security Integration).

### What You’ll Build 
- A hosted Jupyter Notebook service running inside of Snowpark Container Services with a basic notebook
- A Python REST API to perform basic temperature conversions
- A Snowflake Service Function that leverages the REST API

<!-- ![e2e_ml_workflow](assets/snowpark-ml-e2e.png) -->

<!-- ------------------------ -->
## Set up the Snowflake environment
Duration: 5

Run the following SQL commands in [`00_setup.sql`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/00_setup.sql) using the Snowflake VSCode Extension OR in a SQL worksheet to create the role, database, warehouse, and stage that we need to get started:
```SQL
// Create an CONTAINER_USER_ROLE with required privileges
USE ROLE ACCOUNTADMIN;
CREATE ROLE CONTAINER_USER_ROLE;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE CONTAINER_USER_ROLE;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE CONTAINER_USER_ROLE;
GRANT CREATE COMPUTE POOL ON ACCOUNT TO ROLE CONTAINER_USER_ROLE;
GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE CONTAINER_USER_ROLE;
GRANT MONITOR USAGE ON ACCOUNT TO  ROLE  CONTAINER_USER_ROLE;
GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE CONTAINER_USER_ROLE;
GRANT IMPORTED PRIVILEGES ON DATABASE snowflake TO ROLE CONTAINER_USER_ROLE;

// Grant CONTAINER_USER_ROLE to ACCOUNTADMIN
grant role CONTAINER_USER_ROLE to role ACCOUNTADMIN;

// Create Database, Warehouse, and Image spec stage
USE ROLE CONTAINER_USER_ROLE;
CREATE OR REPLACE DATABASE CONTAINER_HOL_DB;

CREATE OR REPLACE WAREHOUSE CONTAINER_HOL_WH
  WAREHOUSE_SIZE = XSMALL
  AUTO_SUSPEND = 120
  AUTO_RESUME = TRUE;
  
CREATE STAGE IF NOT EXISTS specs
ENCRYPTION = (TYPE='SNOWFLAKE_SSE');

CREATE STAGE IF NOT EXISTS volumes
ENCRYPTION = (TYPE='SNOWFLAKE_SSE')
DIRECTORY = (ENABLE = TRUE);
```

Run the following SQL commands in [`01_snowpark_container_services_setup.sql`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/01_snowpark_container_services_setup.sql) using the Snowflake VSCode Extension OR in a SQL worksheet to create the [External Access Integration](https://docs.snowflake.com/developer-guide/snowpark-container-services/additional-considerations-services-jobs#network-egress) our first [compute pool](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-compute-pool), and our [image repository](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-registry-repository)
```SQL
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE NETWORK RULE ALLOW_ALL_RULE
  TYPE = 'HOST_PORT'
  MODE = 'EGRESS'
  VALUE_LIST= ('0.0.0.0:443', '0.0.0.0:80');

CREATE EXTERNAL ACCESS INTEGRATION ALLOW_ALL_EAI
  ALLOWED_NETWORK_RULES = (ALLOW_ALL_RULE)
  ENABLED = true;

GRANT USAGE ON INTEGRATION ALLOW_ALL_EAI TO ROLE CONTAINER_USER_ROLE;

USE ROLE CONTAINER_USER_ROLE;
CREATE COMPUTE POOL IF NOT EXISTS CONTAINER_HOL_POOL
MIN_NODES = 1
MAX_NODES = 1
INSTANCE_FAMILY = CPU_X64_XS;

CREATE IMAGE REPOSITORY CONTAINER_HOL_DB.PUBLIC.IMAGE_REPO;

SHOW IMAGE REPOSITORIES IN SCHEMA CONTAINER_HOL_DB.PUBLIC;
```
- The [External Access Integration](https://docs.snowflake.com/developer-guide/snowpark-container-services/additional-considerations-services-jobs#network-egress) will allow our services to reach outside of Snowflake to the public internet
- The [compute pool](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-compute-pool) is the set of compute resources on which our services will run
- The [image repository](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-registry-repository) is the location in Snowflake where we will push our Docker images so that our services can use them

<!-- ------------------------ -->
## Set up your local environment
Duration: 10

### Python Virtual Environment and SnowCLI

- Download and install the miniconda installer from [https://conda.io/miniconda.html](https://conda.io/miniconda.html). (OR, you may use any other Python environment with Python 3.10, for example, [virtualenv](https://virtualenv.pypa.io/en/latest/)).

- Open a new terminal window, navigate to your Git repo, and execute the following commands in the same terminal window:

  1. Create the conda environment.
  ```
  conda env create -f conda_env.yml
  ```

  2. Activate the conda environment.
  ```
  conda activate snowpark-container-services-hol
  ```

  3. Configure your Snowflake CLI connection. The Snowflake CLI is designed to make managing UDFs, stored procedures, and other developer centric configuration files easier and more intuitive to manage. Let's create a new connection using:
  ```bash
  snow connection add
  ```
  ```yaml
  # follow the wizard prompts to set the following values:
  name : CONTAINER_hol
  account name: <ORG>-<ACCOUNT-NAME> # e.g. MYORGANIZATION-MYACCOUNT
  username : <user_name>
  password : <password>  
  role: CONTAINER_USER_ROLE  
  warehouse : CONTAINER_HOL_WH
  Database : CONTAINER_HOL_DB  
  Schema : public  
  connection :   
  port : 
  Region :  
  ```
  ```bash
  # test the connection:
  snow connection test --connection "CONTAINER_hol"
  ```

  6. Start docker via opening Docker Desktop.
  
  7. Test that we can successfully login to the image repository we created above, `CONTAINER_HOL_DB.PUBLIC.IMAGE_REPO`. Run the following using Snowflake VSCode Extension or in a SQL worksheet and copy the `repository_url` field, then execute a `docker login` with your registry host and user name from the terminal:
  ```sql
  // Get the image repository URL
  use role CONTAINER_user_role;
  show image repositories in schema CONTAINER_HOL_DB.PUBLIC;
  // COPY the repository_url field, e.g. org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo
  ```
  ```bash
  # e.g. if repository_url = org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo, snowflake_registry_hostname = org-account.registry.snowflakecomputing.com
  docker login <snowflake_registry_hostname> -u <user_name>
  > prompt for password
  ```
  **Note the difference between `REPOSITORY_URL` (`org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo`) and `SNOWFLAKE_REGISTRY_HOSTNAME` (`org-account.registry.snowflakecomputing.com`)**

<!-- ------------------------ -->
## Build, Push, and Run the Jupyter Service
Duration: 45

### Build and Test the Image Locally

The first service we are going to create is a hosted Jupyter notebook service. First, we will build and test the image locally. In the code repo, there is a [`./src/jupyter-snowpark/dockerfile`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/src/jupyter-snowpark/dockerfile) with the following contents:
```python
FROM python:3.9
LABEL author=""

#Install packages & python base
RUN apt-get update && \
    apt-get install -y python3-pip

RUN pip3 install JPype1 jupyter pandas numpy seaborn scipy matplotlib seaborn pyNetLogo SALib "snowflake-snowpark-python[pandas]" snowflake-connector-python

#Create a new user for the notebook server , NB RUN instrcution are only ever executed during the buid
RUN useradd -ms /bin/bash jupyter   

#set the user and working directory 
USER jupyter
WORKDIR /home/jupyter 

#other system settings
EXPOSE 8888   

#launch jupyter notebook server. NOTE!  ENTRYPOINT ( or CMD )intrscutions run each time a container is launched!
ENTRYPOINT ["jupyter", "notebook","--allow-root","--ip=0.0.0.0","--port=8888","--no-browser" , "--NotebookApp.token=''", "--NotebookApp.password=''"] 
```
This is just a normal Dockerfile, where we install some packages, change our working directory, expose a port, and then launch our notebook service. There's nothing unique to Snowpark Container Services here! 

Let's build and test the image locally from the terminal. **Note it is a best practice to tag your local images with a `local_repository` prefix.** Often, users will set this to a combination of first initial and last name, e.g. `jsmith/my-image:latest`. Navigate to your local clone of `.../sfguide-intro-to-snowpark-container-services/src/jupyter-snowpark` and run a Docker build command:
```bash
cd .../sfguide-intro-to-snowpark-container-services/src/jupyter-snowpark
docker build --platform=linux/amd64 -t <local_repository>/python-jupyter-snowpark:latest .
```
Verify the image built successfully:
```bash
docker image list
```
Now that our local image has built, let's validate that it runs successfully. From a terminal run:
```bash
docker run -d -p 8888:8888 <local_repository>/python-jupyter-snowpark:latest
```
Open up a browser and navigate to [localhost:8888/lab](http://localhost:8888/lab) to verify your notebook service is working locally. Once you've verified that the service is working, you can stop the container: `docker stop python-jupyter-snowpark`.

### Tag and Push the Image
Now that we have a local version of our container working, we need to push it to Snowflake so that a Service can access the image. To do this we will create a new tag of the image that points at our image repository in our Snowflake account, and then push said tagged image. From a terminal, run the following:
```bash
  # e.g. if repository_url = org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo, snowflake_registry_hostname = org-account.registry.snowflakecomputing.com
  docker login <snowflake_registry_hostname> -u <user_name>
  > prompt for password
  docker tag <local_repository>/python-jupyter-snowpark:latest <repository_url>/python-jupyter-snowpark:dev
```
  **Note the difference** between `REPOSITORY_URL` (`org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo`) and `SNOWFLAKE_REGISTRY_HOSTNAME` (`org-account.registry.snowflakecomputing.com`)

Verify that the new tagged image exists by running:
```bash
docker image list
```
Now, we need to push our image to Snowflake. From the terminal:
```bash
docker push <repository_url>/python-jupyter-snowpark:dev
```
This may take some time, so you can move on to the next step **Configure and Push the Spec YAML** while the image is being pushed. Once the `docker push` command completes, you can verify that the image exists in your Snowflake Image Repository by running the following SQL using the Snowflake VSCode Extension or SQL worksheet:
```sql
USE ROLE CONTAINER_USER_ROLE;
CALL SYSTEM$REGISTRY_LIST_IMAGES('/CONTAINER_HOL_DB/PUBLIC/IMAGE_REPO');
```
You should see your `python-jupyter-snowpark` image listed.

### Configure and Push the Spec YAML
Services in Snowpark Container Services are defined using YAML files. These YAML files configure all of the various parameters, etc. needed to run the containers within your Snowflake account. These YAMLs support a [large number of configurable parameter](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/specification-reference), although we will not reference all of them here. Navigate to your local clone of `.../sfguide-intro-to-snowpark-container-services/src/jupyter-snowpark/jupyter-snowpark.yaml`, which should look like this:

```yaml
spec:
  containers:
    - name: jupyter-snowpark
      image: <repository_hostname>/container_hol_db/public/image_repo/python-jupyter-snowpark:dev
      volumeMounts:
        - name: jupyter-home
          mountPath: /home/jupyter
  endpoints:
    - name: jupyter-snowpark
      port: 8888
      public: true
  volumes:
    - name: jupyter-home
      source: "@volumes/jupyter-snowpark"
      uid: 1000
      gid: 1000

```

**NOTE**: Update **<repository_hostname>** for your image and save the file. 

Now that the spec file is updated, we need to push it to our Snowflake Stage so that we can reference it next in our `create service` statement. We will use snowcli to push the yaml file. 

From the terminal:
```bash
cd .../sfguide-intro-to-snowpark-container-services/src/jupyter-snowpark
snow stage copy ./jupyter-snowpark.yaml @specs --overwrite --connection CONTAINER_hol
```
You can verify that your yaml was pushed successfully by running the following SQL using the Snowflake VSCode Extension or a SQL worksheet and verifying that the file is listed:
```sql
USE ROLE CONTAINER_USER_ROLE;
LS @CONTAINER_HOL_DB.PUBLIC.SPECS;
```

### Create and Test the Service
Once we have successfully pushed our image and our spec YAML, we have all of the components uploaded to Snowflake that we need in order to create our service. There are three components required to create the service: a service name, a compute pool the service will run on, and the spec file that defines the service. Run the following SQL to create our Jupyter service:
```sql
use role CONTAINER_user_role;
create service CONTAINER_HOL_DB.PUBLIC.jupyter_snowpark_service
    in compute pool CONTAINER_HOL_POOL
    from @specs
    specification_file='jupyter-snowpark.yaml'
    external_access_integrations = (ALLOW_ALL_EAI);
```
Run `CALL SYSTEM$GET_SERVICE_STATUS('CONTAINER_HOL_DB.PUBLIC.JUPYTER_SNOWPARK_SERVICE');` to verify that the service is successfully running. These commands are also spelled out in [`02_jupyter_service.sql`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/02_jupyter_service.sql).

Since we specified that the `jupyter-snowpark` endpoint running on port `8888` would be `public: true` in our spec YAML, Snowflake is going to generate a URL for our service that can be used to access the service via our Web Browser. To get the URL, once the service is successfully in a `RUNNING` state, execute the following:
```sql
SHOW ENDPOINTS IN SERVICE JUPYTER_SNOWPARK_SERVICE;
```
Copy the `jupyter-snowpark` endpoint URL, and paste it in your browser. You will be asked to login to Snowflake via your username and password, after which you should successfully see your Jupyter instance running, all inside of Snowflake! **Note, to access the service** the user logging in must have the `CONTAINER_USER_ROLE` AND their default role cannot be `ACCOUNTADMIN`, `SECURITYADMIN`, or `ORGADMIN`.

### Upload and Modify a Jupyter Notebook
Notice that in our spec YAML file we mounted the `@volumes/jupyter-snowpark` internal stage location to our `/home/jupyter` directory inside of our running container. What this means is that we will use our internal stage `@volumes` to persist and store artifacts from our container. If you go check out the `@volumes` stage in Snowsight, you'll see that when we created our `jupyter_snowpark_service`, a folder was created in our stage: `@volumes/jupyter-snowpark`

![Stage Volume Mount](./assets/stage_volume_mount.png)

Now, any file that is uploaded to `@volumes/jupyter-snowpark` will be available inside of our container in the `/home/jupyter` directory, and vice versa. Read more about volume mounts in the [documentation](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/specification-reference#spec-volumes-field-optional). To test this out, let's upload the sample Jupyter notebook that is in our source code repo at `.../sfguide-intro-to-snowpark-container-services/src/jupyter-snowpark/sample_notebook.ipynb`. To do this you can either
- Click on the `jupyter-snowpark` directory in Snowsight, click the blue `+ Files` button and drag/browse to `sample_notebook.ipynb`. Click Upload. Navigate to your Jupyter service UI in your browser, click the refresh arrow and you should now see your notebook available!

OR
- Upload `sample_notebook.ipynb` to `@volumes/jupyter-snowpark` using SnowCLI

OR
- Upload `sample_notebook.ipynb` directly in your Jupyter service  on the home screen by clicking the `Upload` button. If you now navigate back to `@volumes/jupyter-snowpark` in Snowsight, our run an `ls @volumes/jupyter-snowpark` SQL command, you should see  your `sample_notebook.ipynb` file listed. Note you may need to hit the Refresh icon in Snowsight for the file to appear.

What we've done is now created a Jupyter notebook which we can modify in our service, and the changes will be persisted in the file because it is using a stage-backed volume. Let's take a look at the contents of our `sample_notebook.ipynb`. Open up the notebook in your Jupyter service:

![Jupyter Notebook](./assets/jupyter.png)

We want to pay special attention to the contents of the `get_login_token()` function:
```python
def get_login_token():
    with open('/snowflake/session/token', 'r') as f:
        return f.read()
```
When you start a service or a job, Snowflake provides credentials to the running containers in the form of an oauth token located at `/snowflake/session/token`, enabling your container code to use Snowflake connectors for [connecting to Snowflake](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/additional-considerations-services-jobs#connecting-to-snowflake-from-inside-a-container) and executing SQL (similar to any other code on your computer connecting to Snowflake). The provided credentials authenticate as the service role. Snowflake provides some of the information as environment variables in your containers.

Every object in Snowflake has an owner role. In the case of a service or job, Snowflake has a concept called a service role (this term applies to both services and jobs). The service role determines what capabilities your service is allowed to perform when interacting with Snowflake. This includes executing SQL, accessing stages, and service-to-service networking.

We configure the Snowpark Python Client to connect to our Snowflake account and execute SQL using this oauth token:
```python
connection_parameters = {
    "account": os.getenv('SNOWFLAKE_ACCOUNT'),
    "host": os.getenv('SNOWFLAKE_HOST'),
    "token": get_login_token(),
    "authenticator": "oauth",
    "database": "CONTAINER_HOL_DB",
    "schema": "PUBLIC",
    "warehouse": "CONTAINER_HOL_WH"
}
```

Now we can run a sample query using our Snowpark session!

We've successfully built and deployed our Jupyter Notebook service. Now let's move on to a REST API which we will interact with using a Service Function.
<!-- ------------------------ -->
## Build, Push, and Run the Temperature Conversion REST API Service
Duration: 30

### Build and Test the Image Locally

The next service we are going to create is a simple REST API that takes in Celsius temperatures and converts them to Fahrenheit- a trivial example. First, we will build and test the image locally. In the code repo, there is a [`./src/convert-api/dockerfile`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/src/convert-api/dockerfile) with the following contents:
```python
FROM python:3.11

# Copy the packages file into the build
WORKDIR /app
COPY ./ /app/

# run the install using the packages manifest file
RUN pip install --no-cache-dir -r requirements.txt

# Open port 9090
EXPOSE 9090

# When the container launches run the flask app
ENV FLASK_APP="convert-app.py"
CMD ["flask", "run", "--host=0.0.0.0", "--port=9090"]
```
This is just a normal Dockerfile, where we install some packages, change our working directory, expose a port, and then launch our REST API. Our REST API is defined in [`./src/convert-api/convert-app.py`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/src/convert-api/convert-app.py):
```python
from flask import Flask, request, jsonify

app = Flask(__name__)

# The function to convert Celsius to Fahrenheit
def celsius_to_fahrenheit(celsius):
    return celsius * 9./5 + 32

@app.route('/convert', methods=['POST'])
def convert():
    # Get JSON data from request
    data = request.get_json()

    # Check if the 'data' key exists in the received JSON
    if 'data' not in data:
        return jsonify({'error': 'Missing data key in request'}), 400

    # Extract the 'data' list from the received JSON
    data_list = data['data']

    # Initialize a list to store converted values
    converted_data = []

    # Iterate over each item in 'data_list'
    for item in data_list:
        # Check if the item is a list with at least two elements
        if not isinstance(item, list) or len(item) < 2:
            return jsonify({'error': 'Invalid data format'}), 400
        
        # Extract the Celsius value
        celsius = item[1]
        
        # Convert to Fahrenheit and append to 'converted_data'
        converted_data.append([item[0], celsius_to_fahrenheit(celsius)])

    # Return the converted data as JSON
    return jsonify({'data': converted_data})

if __name__ == '__main__':
    app.run(debug=True)
```

The only thing unique to Snowflake about this container, is that the REST API code expects to receive requests in the format that [Snowflake External Function](https://docs.snowflake.com/en/sql-reference/external-functions-data-format#body-format) calls are packaged, and must also package the response in the expected format so that we can use it as a Service Function. **Note this is only required if you intend to interact with the API via a SQL function**.

Let's build and test the image locally from the terminal. **Note it is a best practice to tag your local images with a `local_repository` prefix. Often, users will set this to a combination of first initial and last name, e.g. `jsmith/my-image:latest`. Navigate to your local clone of `.../sfguide-intro-to-snowpark-container-services/src/convert-api` and run a Docker build command:
```bash
cd .../sfguide-intro-to-snowpark-container-services/src/convert-api
docker build --platform=linux/amd64 -t <local_repository>/convert-api:latest .
```
Verify the image built successfully:
```bash
docker image list
```
Now that our local image has built, let's validate that it runs successfully. From a terminal run:
```bash
docker run -d -p 9090:9090 <local_repository>/convert-api:latest
```
Test our local container endpoint by running the following from a different terminal window:
```bash
curl -X POST -H "Content-Type: application/json" -d '{"data": [[0, 12],[1,19],[2,18],[3,23]]}' http://localhost:9090/convert
```
You should recieve back a JSON object, this will conatin the batch id and then the converted value in Fahrenheit:
```bash
{"data":[[0,53.6],[1,66.2],[2,64.4],[3,73.4]]}
```
Once you've verified that the service is working, you can stop the container: `docker stop convert-api`.

### Tag and Push the Image
Now that we have a local version of our container working, we need to push it to Snowflake so that a Service can access the image. To do this we will create a new tag of the image that points at our image repository in our Snowflake account, and then push said tagged image. From a terminal, run the following:
```bash
  # e.g. if repository_url = org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo, snowflake_registry_hostname = org-account.registry.snowflakecomputing.com
  docker login <snowflake_registry_hostname> -u <user_name>
  > prompt for password
  docker tag <local_repository>/convert-api:latest <repository_url>/convert-api:dev
```
**Note the difference between `REPOSITORY_URL` (`org-account.registry.snowflakecomputing.com/container_hol_db/public/image_repo`) and `SNOWFLAKE_REGISTRY_HOSTNAME` (`org-account.registry.snowflakecomputing.com`)**

Verify that the new tagged image exists by running:
```bash
docker image list
```
Now, we need to push our image to Snowflake. From the terminal:
```bash
docker push <repository_url>/convert-api:dev
```
This may take some time, so you can move on to the next step **Configure and Push the Spec YAML** while the image is being pushed. Once the `docker push` command completes, you can verify that the image exists in your Snowflake Image Repository by running the following SQL using the Snowflake VSCode Extension or SQL worksheet:
```sql
USE ROLE CONTAINER_USER_ROLE;
CALL SYSTEM$REGISTRY_LIST_IMAGES('/CONTAINER_HOL_DB/PUBLIC/IMAGE_REPO');
```
You should see your `convert-api` image listed.

### Configure and Push the Spec YAML
Services in Snowpark Container Services are defined using YAML files. These YAML files configure all of the various parameters, etc. needed to run the containers within your Snowflake account. These YAMLs support a [large number of configurable parameter](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/specification-reference), although we will not reference all of them here. Navigate to your local clone of `.../sfguide-intro-to-snowpark-container-services/src/convert-api/convert-api.yaml`, which should look like this:

```yaml
spec:
  containers:
    - name: convert-api
      image: <repository_hostname>/container_hol_db/public/image_repo/convert-api:dev
  endpoints:
    - name: convert-api
      port: 9090
      public: true
```

**NOTE**: Update **<repository_hostname>** for your image and save the file. 

Now that the spec file is updated, we need to push it to our Snowflake Stage so that we can reference it next in our `create service` statement. We will use snowcli to push the yaml file. From the terminal:

```bash
cd .../sfguide-intro-to-snowpark-container-services/src/convert-api
snow stage copy ./convert-api.yaml @specs --overwrite --connection CONTAINER_hol
```
You can verify that your yaml was pushed successfully by running the following SQL using the Snowflake VSCode Extension or a SQL worksheet and verifying that the file is listed:
```sql
USE ROLE CONTAINER_USER_ROLE;
LS @CONTAINER_HOL_DB.PUBLIC.SPECS;
```

### Create and Test the Service
Once we have successfully pushed our image and our spec YAML, we have all of the components uploaded to Snowflake that we need in order to create our service. There are three components required to create the service: a service name, a compute pool the service will run on, and the spec file that defines the service. Run the following SQL to create our Jupyter service:
```sql
use role CONTAINER_user_role;
create service CONTAINER_HOL_DB.PUBLIC.convert_api
    in compute pool CONTAINER_HOL_POOL
    from @specs
    specification_file='convert-api.yaml'
    external_access_integrations = (ALLOW_ALL_EAI);
```
Run `CALL SYSTEM$GET_SERVICE_STATUS('CONTAINER_HOL_DB.PUBLIC.CONVERT-API');` to verify that the service is successfully running. These commands are also listed in [`03_rest_service.sql`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/03_rest_service.sql)

### Create and Test the Service Function
Once the service is up and running, we will create a Service Function that allows us to call our REST API's function via SQL. First, let's create a table with some sample weather data in it:
```sql
USE ROLE CONTAINER_USER_ROLE;
USE DATABASE CONTAINER_HOL_DB;
USE SCHEMA PUBLIC;
USE WAREHOUSE CONTAINER_HOL_WH;

CREATE OR REPLACE TABLE WEATHER (
    DATE DATE,
    LOCATION VARCHAR,
    TEMP_C NUMBER,
    TEMP_F NUMBER
);

INSERT INTO weather (DATE, LOCATION, TEMP_C, TEMP_F) 
    VALUES 
        ('2023-03-21', 'London', 15, NULL),
        ('2023-07-13', 'Manchester', 20, NULL),
        ('2023-05-09', 'Liverpool', 17, NULL),
        ('2023-09-17', 'Cambridge', 19, NULL),
        ('2023-11-02', 'Oxford', 13, NULL),
        ('2023-01-25', 'Birmingham', 11, NULL),
        ('2023-08-30', 'Newcastle', 21, NULL),
        ('2023-06-15', 'Bristol', 16, NULL),
        ('2023-04-07', 'Leeds', 18, NULL),
        ('2023-10-23', 'Southampton', 12, NULL);
```
Now, let's create a function that specifies our `convert-api` service's `convert-api` endpoint:
```sql
CREATE OR REPLACE FUNCTION convert_udf (input float)
RETURNS float
SERVICE=CONVERT_API      //Snowpark Container Service name
ENDPOINT='convert-api'   //The endpoint within the container
MAX_BATCH_ROWS=5         //limit the size of the batch
AS '/convert';           //The API endpoint
```
We can now test our function:
```sql
SELECT convert_udf(12) as conversion_result;
```
And even update our table to populate the `TEMP_F` field using our Service Function:
```sql
UPDATE WEATHER
SET TEMP_F = convert_udf(TEMP_C);

SELECT * FROM WEATHER;
```

### (Optional) Call the Convert Temperature Service Function from our Jupyter Notebook Service
Open up our previously created Jupyter Notebook service and open up our `sample_notebook.ipynb`. Copy and paste the following code into a new cell at the bottom of the notebook:
```python
df = session.table('weather')
df = df.with_column("TEMP_F_SNOWPARK", F.call_udf('convert_udf', df['TEMP_C']))
df.show()
```

Run the cell, and you should see the following output dataframe, with our new column `TEMP_F_SNOWPARK` included:
```python
----------------------------------------------------------------------
|"DATE"      |"LOCATION"   |"TEMP_C"  |"TEMP_F"  |"TEMP_F_SNOWPARK"  |
----------------------------------------------------------------------
|2023-03-21  |London       |15        |59        |59.0               |
|2023-07-13  |Manchester   |20        |68        |68.0               |
|2023-05-09  |Liverpool    |17        |63        |62.6               |
|2023-09-17  |Cambridge    |19        |66        |66.2               |
|2023-11-02  |Oxford       |13        |55        |55.4               |
|2023-01-25  |Birmingham   |11        |52        |51.8               |
|2023-08-30  |Newcastle    |21        |70        |69.8               |
|2023-06-15  |Bristol      |16        |61        |60.8               |
|2023-04-07  |Leeds        |18        |64        |64.4               |
|2023-10-23  |Southampton  |12        |54        |53.6               |
----------------------------------------------------------------------
```

Now, save the Jupyter notebook- when you come back to this service in the future, your new code will be saved because of our stage-backed volume mount!
<!-- ------------------------ -->
## Managing Services with SQL
Duration: 5

There are a number of useful functions we should explore with respect to controlling the service itself from SQL. More information on SQL commands can be found at [Snowpark Container Services SQL Commands](https://docs.snowflake.com/en/sql-reference/commands-snowpark-container-services#service) and [Snowpark Container Services System Functions](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview#what-s-next)

1. Get the status of your container using CALL $SYSTEM:

    From a SQl console:

    ```sql
    CALL SYSTEM$GET_SERVICE_STATUS('CONTAINER_HOL_DB.PUBLIC.JUPYTER_SNOWPARK_SERVICE');
    ```

2. Check the status of the logs with :

    From a SQl console:

    ```sql
    CALL SYSTEM$GET_SERVICE_LOGS('CONTAINER_HOL_DB.PUBLIC.JUPYTER_SNOWPARK_SERVICE', '0', 'jupyter-snowpark',10);
    ```

3. Suspend your container using the ALTER SERVICE command

    From a SQL console:

    ```sql
    ALTER SERVICE CONTAINER_HOL_DB.PUBLIC.JUPYTER_SNOWPARK_SERVICE SUSPEND ;
    ```

4. Resume your container using the ALTER SERVICE command

  From a SQL console:

  ```sql
  ALTER SERVICE CONTAINER_HOL_DB.PUBLIC.JUPYTER_SNOWPARK_SERVICE RESUME ;
  ```

<!-- ------------------------ -->
## Stop the Services and Suspend the Compute Pool
Duration: 2

If you no longer need the services and compute pool up and running, we can stop the services and suspend the compute pool so that we don't incur any cost (Snowpark Container Services bill credits/second based on the compute pool's uptime, similar to Virtual Warehouse billing):
```sql
USE ROLE CONTAINER_USER_ROLE;
ALTER COMPUTE POOL CONTAINER_HOL_POOL STOP ALL;
ALTER COMPUTE POOL CONTAINER_HOL_POOL SUSPEND;
```

If you want to clean up and remove ALL of the objects you created during this quickstart, run the following from [`04_cleanup.sql`](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services/blob/main/04_teardown.sql):
```sql
USE ROLE CONTAINER_USER_ROLE;
ALTER COMPUTE POOL CONTAINER_HOL_POOL STOP ALL;
ALTER COMPUTE POOL CONTAINER_HOL_POOL SUSPEND;

DROP SERVICE CONTAINER_HOL_DB.PUBLIC.JUPYTER_SNOWPARK_SERVICE;
DROP SERVICE CONTAINER_HOL_DB.PUBLIC.CONVERT_API;
DROP COMPUTE POOL CONTAINER_HOL_POOL;

DROP DATABASE CONTAINER_HOL_DB;
DROP WAREHOUSE CONTAINER_HOL_WH;

USE ROLE ACCOUNTADMIN;
DROP ROLE CONTAINER_USER_ROLE;
```

<!-- ------------------------ -->
## Conclusion
Congratulations, you have successfully completed this quickstart! Through this quickstart, we were able to create and manage long-running services using Snowflake's managed Snowpark Container Services. These services run entirely within your Snowflake account boundary using a managed container orchestration service- keeping your data secure, and making development to deployment incredibly easy.

For more information, check out the resources below:

### Related Resources
- [Snowpark Container Services Documentation](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/overview)
- [Snowpark Container Services SQL Commands](https://docs.snowflake.com/en/sql-reference/commands-snowpark-container-services)
- [Snowpark Container Services - A Tech Primer](https://medium.com/snowflake/snowpark-container-services-a-tech-primer-99ff2ca8e741)
- [Building Advanced ML with Snowpark Container Services - Summit 2023](https://www.youtube.com/watch?v=DelaJBm0UgI)
- [Snowpark Container Services with NVIDIA](https://www.youtube.com/watch?v=u98YTgCelYg)
- [Quickstart GitHub](https://github.com/Snowflake-Labs/sfguide-intro-to-snowpark-container-services)
- [Snowflake Announces Snowpark Container Services](https://www.snowflake.com/blog/snowpark-container-services-deploy-genai-full-stack-apps/)

<!-- ------------------------ -->

author: Gilberto Hernandez
id: native-app-chairlift
summary: This Snowflake Native App demonstrates how a chairlift manufacturer can build a native app to provide chairlift customers with analytics on purchased chairlifts by using sensor data collected from the chairlifts owned by the customer.
categories: Getting-Started
environments: web
status: Published 
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Data Science, Data Engineering, Apps 

# Build a Snowflake Native App to Analyze Chairlift Sensor Data
<!-- ------------------------ -->
## Introduction
Duration: 2

In this Quickstart, you'll build a Snowflake Native Application that can analyze sensor data from chairlifts at different locations at a ski resort. Let's explore the scenario from the perspective of the application provider and an application consumer.

– **Provider** – The provider of the app is a chairlift manufacturer. The app, once installed by a consumer, can run against chairlift sensor data housed in the consumer's account, and provide the consumer with important analytics and insights on the condition of each chairlift. 

– **Consumer** – The consumer of the app is a customer of the chairlift manufacturer. They have purchased and installed chairlifts in various locations across a ski resort they own, and they collect raw sensor data from the chairlifts using a connector that ingests this data directly into their account. The provider's app runs against this data and helps the customer identify chairlifts in need of maintenance.

Within the app, you'll create the following:

- **Dashboard** – A dashboard with a list of sensor warnings from all chairlifts at the ski resort. You'll be able to filter by chairlift and by sensor type.

- **Configuration** – A tab that allows an application admin to toggle sensor warnings about chairlifts.

- **Sensor data** – Visualizations of raw sensor data across all chairlifts at the ski resorts.  You'll be able to filter by chairlift and by sensor type.

Note that this Quickstart is limited to a single-account installation. Listing to the Snowflake Marketplace and versions / release directives are outside of the scope of this guide.

Let's get started!

![Sensor data](assets/sensor-data.png)


### What You’ll Learn 

- How to create an application package
- How to create grants in the application package to control access to different parts of the app, depending on Snowflake role 
- How to create a new version of the app
- How to install and run the app in a single Snowflake account using multiple roles

### What You’ll Need

> aside negative
> 
> **Important**
> Native Apps are currently only  available on AWS.  Ensure your Snowflake deployment or trial account uses AWS as the cloud provider. Native Apps will be available on other major cloud providers soon.

- A Snowflake account ([trial](https://signup.snowflake.com/developers), or otherwise). See note above on AWS as cloud provider for the deployment.

### What You’ll Build 

- A Snowflake Native App

<!-- ------------------------ -->
## Clone GitHub repository
Duration: 2

Start by cloning the following GitHub repository, which contains the code we'll need to build the app:

```bash
git clone https://github.com/Snowflake-Labs/sfguide-native-apps-chairlift.git
```

Take a look at the directory structure:

```console
sfguide-native-apps-chairlift/
├─ LEGAL.md
├─ LICENSE
├─ README.md
├─ app/
│  ├─ README.md
│  ├─ manifest.yml
│  ├─ setup_script.sql
│  ├─ sql_lib/
│  │  ├─ ... (.sql files)
│  ├─ src/
│     ├─ ui/
│        ├─ ... (.py files)
├─ consumer/
│  ├─ install-app.sql
├─ prepare/
│  ├─ consumer-data.sql
│  ├─ consumer-roles.sql
│  ├─ provider-data.sql
│  ├─ provider-role.sql
├─ provider/
│  ├─ create-package.sql
├─ tests/
│  ├─ ... (.py files)
├─ ...
```

The app's entry point (**manifest.yml**) and the app's source code reside in the **app/** directory. There are also three other directories in this repository: **prepare/**, **consumer/**, and **provider/**. These three directories are specific to this Quickstart, and the files in these folders will be used to properly set up account roles and objects within the Snowflake account for this native app. In practice, you may have your own directory structure outside of the **app/** folder, or other methods for achieving what the files in these other directories do.

Here's an overview of the directories:

**app/**

- The **app/** directory includes two required (and very important) files: The manifest file **manifest.yml** and the setup script **setup_script.sql**. The setup script can also reference other files. In our case, it references files in the **sql_lib/** directory, which include all stored procedures and user-defined functions (UDFs). The **app/src/** directory contains the source code for the app, like the front-end Streamlit files present in **app/src/ui/** directory. We'll take a deeper look at the **app/** directory in the next step.

**prepare/** 

- This directory is specific to this Quickstart. It contains files to prepare your Snowflake account by creating certain roles, granting privileges, and loading data. We'll execute the scripts in this folder before building the native app.

**consumer/** 

- This directory is specific to this Quickstart. It contains a SQL script to install the native app in the account and grant appropriate privileges. This will allow you to run the native app from the perspective of the consumer (i.e., a customer of the chairlift manufacturer).

**provider/** 

- This directory is specific to this Quickstart. It contains a SQL script to create the application package and grant privileges on provider data.

**tests/**

- This directory contains unit tests for the Front-ends of the app which are built with Streamlit.

<!-- ------------------------ -->
## The **app/** directory
Duration: 4

Let's take a deeper look at the **app/** directory for this app.

```console
app/
├─ README.md
├─ manifest.yml
├─ setup_script.sql
├─ sql_lib/
│  ├─ config_code-register_single_callback.sql
│  ├─ config_data-configuration.sql
│  ├─ shared_content-sensor_ranges.sql
│  ├─ shared_content-sensor_service_schedules.sql
│  ├─ shared_content-sensor_types_view.sql
│  ├─ ui-v_configuration.sql
│  ├─ ui-v_dashboard.sql
│  ├─ ui-v_sensor_data.sql
│  ├─ warnings_code-check_warnings.sql
│  ├─ warnings_code-create_warning_check_task.sql
│  ├─ warnings_code-update_warning_check_task_status.sql
│  ├─ warnings_data-warnings.sql
│  ├─ warnings_data-warnings_reading_cursor.sql
├─ src/
   ├─ ui/
      ├─ chairlift_data.py
      ├─ environment.yml
      ├─ first_time_setup.py
      ├─ references.py
      ├─ ui_common.py
      ├─ util.py
      ├─ v_configuration.py
      ├─ v_dashboard.py
      ├─ v_sensor_data.py
```

This directory contains the source code for the native app. This Quickstart uses **app/** as the name of the folder, but in practice, this folder may take on any name you'd like. 

Here's an overview of what this folder contains:

**manifest.yml** 

- A manifest file is a requirement when creating a native app. This file defines the runtime configuration for the application. It contains metadata about the app (version, etc.), artifacts required by the app, and log configuration settings. It also defines the privileges that the consumer must grant to the application when the application is installed in their account. Finally, it also contains references defined by the provider. Typically these references refer to tables and the corresponding privileges needed by the app to run against consumer data. For more information, see [Creating the Manifest File](https://docs.snowflake.com/en/developer-guide/native-apps/creating-manifest).

**setup_script.sql** 

- A setup script is a requirement when creating a native app. This script contains statements that are run when the consumer installs or upgrades an application, or when a provider installs or upgrades an application for testing. The location of this script should be specified in the manifest file. For more information, see [Creating the Setup Script](https://docs.snowflake.com/en/developer-guide/native-apps/creating-setup-script).

**sql_lib/**

- A directory that contains smaller SQL files that are included in the setup script. This helps keep the setup script short and well organized.

**README.md** 

- This file should provide a description of what the app does. This file is shown when viewing the app within Snowflake.

**src/ui/** 

- This directory is specific to this Quickstart, and contains all of the files and code used to create the front-end of the app. Front-ends for Snowflake Native Apps are built with Streamlit. You should peruse all of the files in this folder to get familiar with how the front-end is built, and pay special attention to the files that define the main views within the app, namely **v_dashboard.py**, **v_sensor_data.py**, and **v_configuration.py**. For more information, see [Adding Frontend Experience to Your Application with Streamlit](https://docs.snowflake.com/en/developer-guide/native-apps/adding-streamlit).


<!-- ------------------------ -->
## Test the App
Duration: 3

Let's take a deeper look at the files and directories related to testing this native app.

```console
local_test_env.yml
pytest.ini
tests/
├─ test_utils.py
├─ test_v_configuration.py
├─ test_v_dashboard.py
├─ test_v_sensor_data.py
```

Here's an overview of the above files and directories:

**local_test_env.yml**

This file is a conda environment file that contains the dependencies allowing you to run the tests. To activate the testing environment:
```
conda env update -f local_test_env.yml
conda activate chairlift-test
```
To deactivate it:
```
conda deactivate

```
**pytest.ini**

This file contains the different settings for pytest tests. For example, it contains the location of source code on which the unit tests run.

**tests/**

This directory contains Streamlit unit tests. **tests/test_utils.py** contains common util functions and Pytest fixtures used for the unit tests. The other files in this directory contain the actual tests. The included tests leverage the [Streamlit App Testing](https://docs.streamlit.io/develop/api-reference/app-testing) framework which allows automated testing of Streamlit elements.

### Running Unit tests

To run unit tests, make sure that `chairlift-test` conda environment is active, and then run the following command:
```
pytest -vv
```

You should observe all the tests passing.

<!-- ------------------------ -->
## Set up account roles
Duration: 4

Let's start building the app. You'll first need to configure certain roles and permissions within your Snowflake account. This will allow you to view the app as an app admin (for configuring the application after installation and/or dismissing sensor warnings), or as an app viewer (perhaps someone in charge of equipment maintenance at the resort keeps an eye on the condition of chairlifts).

To create these roles and permissions, run the scripts below. You'll only need to execute these scripts once.

**Execute prepare/provider-role.sql**

Open a SQL worksheet in Snowsight and execute the following script:

```sql
-- create provider role
create role if not exists chairlift_provider;
grant role chairlift_provider to role accountadmin;
grant create application package on account to role chairlift_provider;
grant create database on account to role chairlift_provider;

-- ensure a warehouse is usable by provider
create warehouse if not exists chairlift_wh;
grant usage on warehouse chairlift_wh to role chairlift_provider;
```

**Execute prepare/consumer-roles.sql**

Open a SQL worksheet in Snowsight and execute the following script:

```sql
-- create consumer role
create role if not exists chairlift_admin;
create role if not exists chairlift_viewer;
grant role chairlift_admin to role accountadmin;
grant role chairlift_viewer to role accountadmin;
grant create database on account to role chairlift_admin;
grant create application on account to role chairlift_admin;
grant execute task, execute managed task on account to role chairlift_admin with grant option;
grant role chairlift_viewer to role chairlift_admin;

-- ensure a warehouse is usable by consumer
grant usage on warehouse chairlift_wh to role chairlift_admin;
grant usage on warehouse chairlift_wh to role chairlift_viewer;
```


<!-- ------------------------ -->
## Prepare objects in account
Duration: 5

Next, you'll run some scripts to set up some databases, schemas, and tables needed by the app.

The scripts will do a couple of things:

* The provider scripts define roles, warehouses, and data types for the data emitted by the sensors (i.e., brake temperature, motor RPMs, etc.). This data is combined with the consumer data inside of the app, and is necessary so that the app can function as intended in the consumer's account. From this perspective, the provider is the chairlift manufacturer, and the app will run against raw sensor data in (and owned by) a consumer's account. Running the app against this data will provide the consumer with analytics and insights on the chairlifts they own, granted that the consumer installs the app and grants the proper privileges to the app.

* The consumer scripts mock fictional, raw sensor data about the chairlifts. In practice, this data could be ingested directly into the consumer's account with a connector that collects raw sensor data from the chairlifts. For the purposes of this Quickstart, we mock this data so that the provider's native app can run against this data that lives in the consumer's account.

To set up the environment, run the scripts below. You'll only need to execute these scripts once.

**Execute prepare/provider-data.sql**

Open a SQL worksheet in Snowsight and execute the following script:

```sql
use role chairlift_provider;
use warehouse chairlift_wh;

create database if not exists chairlift_provider_data;
use database chairlift_provider_data;
create schema if not exists core;
use schema core;

-- Sensor types with reading min range, max ranges, service intervals and lifetime of the sensor.
create or replace table chairlift_provider_data.core.sensor_types (
    id int,
    name varchar,
    min_range int,
    max_range int,
    service_interval_count int,
    service_interval_unit varchar,
    lifetime_count int,
    lifetime_unit varchar,
    primary key (id)
);

insert into chairlift_provider_data.core.sensor_types values
    (1, 'Brake Temperature', -40, 40, 6, 'month', 5, 'year'),
    (2, 'Current Load', 20000, 50000, 3, 'month', 5, 'year'),
    (3, 'Bull-wheel RPM', 4000, 5000, 1, 'month', 1, 'year'),
    (4, 'Motor RPM', 2000, 2500, 1, 'month', 1, 'year'),
    (5, 'Motor Voltage', 110, 130, 2, 'month', 5, 'year'),
    (6, 'Current Temperature', -40, 40, 4, 'month', 5, 'year'),
    (7, 'Rope Tension', 70, 100, 3, 'month', 5, 'year'),
    (8, 'Chairlift Load', 50, 250, 3, 'month', 2, 'year'),
    (9, 'Chairlift Vibration', 30, 100, 3, 'month', 3, 'year');
```

**Execute prepare/consumer-data.sql**

Open a SQL worksheet in Snowsight and execute the following script:

```sql
use role chairlift_admin;
use warehouse chairlift_wh;

-- consumer data: streaming readings from sensors on their ski lift machines.
create database if not exists chairlift_consumer_data;
use database chairlift_consumer_data;
create schema if not exists data;
use schema data;

-- what machines (chairlifts and stations) exist in the consumer\'s ski resort?
create or replace table machines (
    uuid varchar,
    name varchar,
    latitude double,
    longitude double,
    primary key (uuid)
);

-- what sensors are configured and streaming data from those machines?
create or replace table sensors (
    uuid varchar,
    name varchar,
    sensor_type_id int,
    machine_uuid varchar,
    last_reading int,
    installation_date date,
    last_service_date date,
    primary key (uuid),
    foreign key (machine_uuid) references machines(uuid)
);

-- what readings have we received from the configured sensors?
create table if not exists sensor_readings (
    sensor_uuid varchar,
    reading_time timestamp,
    reading int,
    primary key (sensor_uuid, reading_time),
    foreign key (sensor_uuid) references sensors(uuid)
);

-- Sensor types with reading min range, max ranges, service intervals and lifetime of the sensor.
-- Note that both the consumer and provider have a version of this table; you can think
-- of this version as coming from an imaginary "second app" which is a connector that
-- streams data into the consumer\'s account from the sensors. Consumer owns their own data!
create or replace table sensor_types (
    id int,
    name varchar,
    min_range int,
    max_range int,
    service_interval_count int,
    service_interval_unit varchar,
    lifetime_count int,
    lifetime_unit varchar,
    primary key (id)
);

insert into sensor_types values
    (1, 'Brake Temperature', -40, 40, 6, 'month', 5, 'year'),
    (2, 'Current Load', 20000, 50000, 3, 'month', 5, 'year'),
    (3, 'Bull-wheel RPM', 4000, 5000, 1, 'month', 1, 'year'),
    (4, 'Motor RPM', 2000, 2500, 1, 'month', 1, 'year'),
    (5, 'Motor Voltage', 110, 130, 2, 'month', 5, 'year'),
    (6, 'Current Temperature', -40, 40, 4, 'month', 5, 'year'),
    (7, 'Rope Tension', 70, 100, 3, 'month', 5, 'year'),
    (8, 'Chairlift Load', 50, 250, 3, 'month', 2, 'year'),
    (9, 'Chairlift Vibration', 30, 100, 3, 'month', 3, 'year');

-- what is the most-recent reading we have from a given sensor?
create view if not exists last_readings as
    select uuid, name, last_reading from sensors;

-- mock data in machines
insert into machines(uuid, name) select uuid_string(), 'Base Station';
insert into machines(uuid, name) select uuid_string(), 'Hilltop Station';
insert into machines(uuid, name) select uuid_string(), 'Chairlift #1';
insert into machines(uuid, name) select uuid_string(), 'Chairlift #2';
insert into machines(uuid, name) select uuid_string(), 'Chairlift #3';

-- mock data in sensors
execute immediate $$
declare
    c1 cursor for
        select uuid from machines where name = 'Base Station' or name = 'Hilltop Station';
    c2 cursor for
        select uuid from machines where name in ('Chairlift #1', 'Chairlift #2', 'Chairlift #3');
begin
    --for base and hilltop stations/machines
    for machine in c1 do
        let machine_uuid varchar default machine.uuid;
        insert into sensors(uuid, name, sensor_type_id, machine_uuid, installation_date, last_service_date)
            select uuid_string(), name, id, :machine_uuid, dateadd(day, -365, getdate()), dateadd(day, -1 * abs(hash(uuid_string()) % 365), getdate())
                from sensor_types where id < 8;
    end for;
    --for chairlifts machines
    for machine in c2 do
        let machine_uuid varchar default machine.uuid;
        insert into sensors(uuid, name, sensor_type_id, machine_uuid, installation_date,last_service_date)
            select uuid_string(), name, id, :machine_uuid, dateadd(day, -365, getdate()), dateadd(day, -1 * abs(hash(uuid_string()) % 365), getdate())
                from sensor_types where id > 7;
    end for;
end;
$$
;

-- mock data in sensor_readings table
create or replace procedure populate_reading()
  returns varchar
  language sql
  as
  $$
    declare
      starting_ts       timestamp;
      rows_to_produce   integer;
      sensors_cursor cursor for
        select id, uuid, min_range, max_range
          from sensors s join sensor_types sr
                 on s.sensor_type_id = sr.id;
    begin
      --
      -- starting_ts is the time of the last sensor reading we wrong or, if no
      -- readings are available, 10 minutes in the past.
      --
      select coalesce(max(reading_time), dateadd(second, -30*20, current_timestamp()))
               into :starting_ts
        from sensor_readings;

      --
      -- produce one row for every thirty seconds from our starting time to now
      --
      rows_to_produce := datediff(second, starting_ts, current_timestamp()) / 30;

      for sensor in sensors_cursor do
        let sensor_uuid varchar default sensor.uuid;
        let min_range integer default sensor.min_range;
        let max_range integer default sensor.max_range;
  
        insert into sensor_readings(sensor_uuid, reading_time, reading)
          select
              :sensor_uuid,
              dateadd(second, row_id * 30, :starting_ts),
              case
                when rand_value < 10 then
                  :min_range - abs(hash(uuid)) % 10
                when rand_value > 90 then
                  :max_range + abs(hash(uuid)) % 10
                else
                  :min_range + abs(hash(uuid)) % (:max_range - :min_range)
              end case
          from ( 
              select seq4() + 1            as row_id,
                     uuid_string()         as uuid,
                     abs(hash(uuid)) % 100 as rand_value
                from table(generator(rowcount => :rows_to_produce)));
      end for;

      update sensors
         set last_reading = r.reading
        from sensors as s2, sensor_readings as r
       where s2.uuid = sensors.uuid
         and r.sensor_uuid = s2.uuid
         and r.reading_time = 
              (select max(reading_time)  
                 from sensor_readings r2
                where r2.sensor_uuid = s2.uuid);
    end;
  $$
;

-- Task to call the stored procedure to update the readings table every minute
create or replace task populate_reading_every_minute
    warehouse = chairlift_wh
    schedule = '1 minute'
as
    call populate_reading();

-- If you would like the data to be populated on a schedule, you can run:
-- alter task chairlift_consumer_data.data.populate_reading_every_minute resume;

-- To stop:
-- alter task chairlift_consumer_data.data.populate_reading_every_minute suspend;

-- Get some initial data in the readings table
call populate_reading();
```

<!-- ------------------------ -->
## Create application package and install application using Snowflake CLI
Duration: 3

With the environment created, we can now create the application package for the app. You'll run a command that creates this package and does a few key things:

* Creates the application package for the native app

* Marks that the native app makes use of an external database in the provider's account

* Creates views and grants the setup script access to the views

For more details, see the comments in the **snowflake.yml** file.

**Deploy the application package**

Open a new terminal in the root of the repository and execute the following command:

```bash
snow app run
```

This command will upload source files, create the application package, and install the application object automatically. When you run it again, it will perform the minimum steps necessary to ensure the application is up-to-date with your local copy. 

Snowflake CLI project is configured using `snowflake.yml` file.

<!-- ------------------------ -->
## Create the first version of the app
Duration: 2

Let's review what we've covered so far:

* Created necessary account roles and objects, and granted proper privileges

* Created the application package and uploaded the app's source code to the application package

Next, you'll create the first version of the app. Run the following command in your terminal:

```bash
snow app version create develop
```

This command will create the first (new) version of the native app using the source code files that you uploaded earlier.

> aside positive
> 
>  **PATCH VERSIONS** Do not run the command below. It is included here to demonstrate how you can add a patch version of a native app.

In the scenario where you update the source code for the app to roll out a fix (i.e., fixing a bug), you could add the updated source as a patch to the native app using the following command:

```bash
snow app version create develop --patch 1
```

This SQL command returns the new patch number, which will be used when installing the application as the consumer.

<!-- ------------------------ -->
## Allow restricted application access to a secondary role
Duration: 3

Now that the source code has been uploaded into the application package and the application was installed, we can grant appropriate privileges to a secondary consumer role named **chairlift_viewer**. Note that the version and/or patch values may need to be updated to install the application using a different version or patch.

```sql
use role chairlift_admin;
use warehouse chairlift_wh;

-- allow our secondary viewer role restricted access to the app
grant application role chairlift_app.app_viewer
    to role chairlift_viewer;
```

<!-- ------------------------ -->
## Set up the application
Duration: 4

With the application installed, you can now run the app in your Snowflake account!

1. Set your role to **CHAIRLIFT_ADMIN**.

2. Navigate to **Apps** within Snowsight (left hand side).

3. Next, click **Apps** at the top of Snowsight.

4. You should see the app installed under "Installed Apps". Click **CHAIRLIFT_APP**. This will start the app. You'll be prompted to do some first-time setup by granting the app access to certain tables. After completing this setup, you'll have access to the main dashboard within the app. If you're encountering an error, ensure your role is set to **CHAIRLIFT_ADMIN** during first-time setup.

![First time setup](assets/first-time-setup.png)

When running the app for the first time, you'll be prompted to create bindings. The bindings link references defined in the manifest file to corresponding objects in the Snowflake account. These bindings ensure that the application can run as intended. You'll also be prompted to grant the application privileges to execute a task based on a toggle within the app's user interface. For more information, see the **first_time_setup.py** and **references.py** files in the **ui/** folder within the repo.

> aside negative
> 
>  **NOTE** Before being able to run the app, you may be prompted to accept the Anaconda terms and conditions. Exit the app, set your role to **ORGADMIN**, then navigate to "**Admin** -> **Billing & Terms**". Click **Enable** and then acknowledge and continue in the ensuing modal. If, when navigating back to the app as **CHAIRLIFT_ADMIN**, you are again prompted to accept the terms, refresh your browser.

![Anaconda](assets/anaconda.png)

<!-- ------------------------ -->
## Run the application
Duration: 6

You can run the app as an app admin or or app viewer. See the sections below for the differences between the two roles.

**APP VIEWER**

 To run the app as an app viewer, switch your role to **CHAIRLIFT_VIEWER**, and navigate back to the app. You should have access to two views:

– **Dashboard** – A list of warnings emitted by all chairlift sensors. You can filter by specific chairlift, or by a sensor type. You can also acknowledge warnings and dismiss them as needed.

– **Sensor data** – Graphs of sensor data for each sensor type, over a given time interval, and segmented by chairlift. You can filter by specific chairlift, by a sensor type, or by date. You can also view raw sensor readings data.

![Sensor data](assets/sensor-data.png)

**APP ADMIN**

To run the app as an app admin, switch your role to **CHAIRLIFT_ADMIN**, and navigate back to the app. You should have access to the two views above, as well as one additional view:

– **Configuration** – The app admin is granted the following capabilities within this tab:

  - **Enable a warning generation task** – A maintenance warning is generated for any sensor reading that falls outside of the manufacturer's specified range for that sensor type. Toggling this checkbox (i.e., clicking it) will call the warning generation task. Every 60 seconds, the task will scan all sensor readings and conditionally generate a warning based on the sensor's reading.  You can view these generated warnings in the **Dashboard** view. Because this task runs every 60 seconds, this task can consume a lot of credits in your Snowflake account.  To avoid prolonged credit consumption, be sure to disable (i.e., uncheck) the checkbox, or consider the button below the checkbox. Its functionality is described below.

  - **Generate new warnings (takes a while)** button – Clicking this button will also call the warning generation task, but it will only run on-demand (i.e., only when the button is clicked, not every 60 seconds). As a result, it consumes fewer credits when compared to the continuously run task, but it may take a little longer to generate warnings. You can view these generated warnings in the **Dashboard** view. In addition, clicking the button will temporarily disable the checkbox above it.


In this Quickstart, the **Configuration** tab is included to demonstrate how different roles in an account may be granted different privileges within the app. In practice, the app admin (or other roles) may have access to other areas or functionality of the app.

> aside negative
> 
>  **AVOID PROLONGED CREDIT CONSUMPTION** Enabling warning generation via the checkbox will call a warning generation task every 60 seconds. **To avoid prolonged credit consumption, be sure to disable the warning generation task by unchecking the checkbox.**
<!-- ------------------------ -->
## Clean up
Duration: 1

Let's clean up your Snowflake account. In the same terminal you opened before, execute the following command:

```bash
snow app teardown
```

Then, run the following SQL commands in a worksheet:

```sql
USE ROLE chairlift_admin;
DROP DATABASE chairlift_consumer_data;

USE ROLE ACCOUNTADMIN;
DROP WAREHOUSE chairlift_wh;
DROP ROLE chairlift_provider;
DROP ROLE chairlift_viewer;
DROP ROLE chairlift_admin;
```

<!-- ------------------------ -->
## Conclusion
Duration: 1

Congratulations! In just a few minutes, you built a Snowflake Native App that allows a consumer to generate maintenance-related insights based on raw sensor data from chairlifts they own at a ski resort. The app also grants select access to parts of the app depending on the Snowflake role selected.

### What we've covered

- How to create a application package
- How to add source code to an application package
- How to create a new version (or patch) of the app
- How to install and run the native app in a consumer account

### Related Resources

- [Snowflake Native App Developer Toolkit](https://www.snowflake.com/snowflake-native-app-developer-toolkit/?utm_cta=na-us-en-eb-native-app-quickstart)
- [Official Native App documentation](https://docs.snowflake.com/en/developer-guide/native-apps/native-apps-about)
- [Tutorial: Developing an Application with the Native Apps Framework](https://docs.snowflake.com/en/developer-guide/native-apps/tutorials/getting-started-tutorial)
- [Snowflake Demos](https://developers.snowflake.com/demos)
- [Getting Started with Native Apps](https://quickstarts.snowflake.com/guide/getting_started_with_native_apps/)

author: Daniel Chen, Sara Altman
id: analyze_data_with_r_using_posit_workbench_and_snowflake
summary: Analyze Data with R using Posit Workbench and Snowflake
categories: Getting-Started
environments: web
status: Published
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Data Science, R, Posit Workbench, Native Applications

#  Analyze Data with R using Posit Workbench and Snowflake

## Overview
Duration: 1

This guide will walk you through using R to analyze data in Snowflake using the Posit
Workbench Native App. You'll learn how to launch the Posit Workbench Native App and use the available RStudio Pro IDE. You'll also learn how to use the `{dbplyr}` package to translate R code into SQL, allowing you to run data operations directly in Snowflake's high-performance computing environment.

We'll focus on a healthcare example by analyzing heart failure data. We'll then guide you through launching an R session, accessing the data, and performing data cleaning, transformation, and visualization. Finally, you'll see how to generate an HTML report, build an interactive Shiny app, and write data back to Snowflake—-completing an end-to-end R analysis _entirely within Snowflake_.

![](assets/overview/architecture.png)

### What You'll Need

- Familiarity with R
- The ability to launch Posit Workbench from [Snowflake Native Applications](https://docs.posit.co/ide/server-pro/integration/snowflake/native-app/). This can be provided by an administrator with the `accountadmin` role.

### What You’ll Learn

- How to create an R session within the RStudio Pro IDE that comes with the Posit Workbench Native App.
- How to connect to your Snowflake data from R to create tables, visualizations, and more.

### What You’ll Build

- An RStudio Pro IDE environment to use within Snowflake.
- A Quarto document that contains plots and tables built with R, using data stored in Snowflake.
- An interactive Shiny application built with R, using data stored in Snowflake.

Along the way, you will use R to analyze which variables are associated with survival among patients with heart failure.
You can follow along with this quickstart guide,
or look at the materials provided in the accompanying repository:
<https://github.com/posit-dev/snowflake-posit-quickstart-r>.

## Setup
Duration: 3

Before we begin there are a few components we need to prepare. We need to:

- Add the heart failure data to Snowflake
- Launch the Posit Workbench Native App
- Create an RStudio Pro IDE session
- Install R Packages

### Add the heart failure data to Snowflake

For this analysis, we'll use the [Heart Failure Clinical Records](https://archive.ics.uci.edu/dataset/519/heart+failure+clinical+records) dataset. The data is available for download as a CSV from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/519/heart+failure+clinical+records). 

We'll walk through how to download the data from UCI and then upload it to Snowflake from a CSV.

> **_INTERACTIVITY NOTE:_** If you have the necessary permissions in Snowflake, you can also import the data from this S3 bucket: s3://heart-failure-records/heart_failure.csv.

#### Step 1: Download the data as a CSV

Download the data from UCI [here](https://archive.ics.uci.edu/dataset/519/heart+failure+clinical+records), and then unzip the downloaded file. 

#### Step 2: Add data in Snowsight

Log into [Snowsight](https://docs.snowflake.com/en/user-guide/ui-snowsight), then click `Create` > `Add Data`. You can find the `Create` button in the upper-left corner. 

![](assets/snowflake/02-add_data.png)

#### Step 3: Load data

Choose the `Load Data into a Table` option, then select your downloaded heart failure CSV. Specify an existing database or create a new one for the heart failure data (we called ours `HEART_FAILURE`). Then, select `+ Create a new table` and name it `HEART_FAILURE`.

Once your find the database, you can load it into your Snowflake account by clicking the Get button on the right-hand side.

![](assets/snowflake/03-load_data_into_table.png)

#### Step 4: Confirm data

You should now be able to see the heart failure data in Snowsight. Navigate to `Data` > `Databases`, then select the database to which you added the data (e.g., `HEART_FAILURE`). Expand the database, schema, and tables until you see the `HEART_FAILURE` table. 

![](assets/snowflake/04-confirm_data.png)

### Launch Posit Workbench

We can now start exploring the data using Posit Workbench.
You can find Posit Workbench as a Snowflake Native Application
and use it to connect to your database.

#### Step 1: Navigate to Apps

In your Snowflake account, Go to `Data Products` > `Apps` to open the Native Apps collection. If Posit Workbench is not already installed, click `Get`. Please note that the Native App must be [installed and configured ](https://docs.posit.co/ide/server-pro/integration/snowflake/native-app/install.html)by an administrator. 

![](assets/snowflake/05-get_posit_workbench.png)

#### Step 2: Open the Posit Workbench Native App

Once Posit Workbench is installed, click on the app under `Installed Apps` to launch the app. If you do not see the Posit Workbench app listed, ask your Snowflake account administrator for access to the app.

![](assets/snowflake/06-open_app.png)

After clicking on the app, you will see a page with configuration instructions and a blue `Launch app` button.

![](assets/snowflake/09-launch-app.png)

Click on `Launch app`. This should take you to the webpage generated for the Workbench application. You may be prompted to first login to Snowflake using your regular credentials or authentication method.

### Create an RStudio Pro Session 

Posit Workbench provides several IDEs, such as RStudio Pro, JupyterLab, and VS Code. For this analysis we will use an RStudio Pro IDE.

#### Step 1: New Session

Within Posit Workbench, click `New Session` to launch a new session to spin up your coding environment.

![](assets/posit_workbench/01-start_new_session.png)

#### Step 2: Select an IDE

When prompted, select the RStudio Pro IDE.

![](assets/posit_workbench/02-create_new_session_snowflake.png)

#### Step 3: Log into your Snowflake account

Next, connect to your Snowflake account from within Posit Workbench.
Under `Credentials`, click the button with the Snowflake icon to sign in to Snowflake.
Follow the sign in prompts.

![](assets/posit_workbench/03-snowflake_login.png)

When you're successfully signed into Snowflake, the Snowflake button will turn blue
and there will be a checkmark in the upper-left corner.

![](assets/posit_workbench/04-snowflake_login_success.png)

#### Step 4: Launch the RStudio Pro IDE

Click `Start Session` to launch the RStudio Pro IDE.

Once everything is ready,
you will be able to work with your Snowflake data
in the familiar RStudio Pro IDE. Since the IDE is provided by the Posit Workbench Native App, 
your entire analysis will occur securely within Snowflake.

![](assets/rstudio/01-rstudio.png)

#### Step 5: Access the Quickstart Materials

This Quickstart will step you through the analysis contained in <https://github.com/posit-dev/snowflake-posit-quickstart-r/blob/main/quarto.qmd>.
To follow along, open the file in your RStudio Pro IDE. There are two ways to do this:

1. **Simple copy-and-paste** Go to File > New File > Quarto Document and then copy the contents of [quarto.qmd](https://github.com/posit-dev/snowflake-posit-quickstart-r/blob/main/quarto.qmd) into your new file.
2. **Starting a new project linked to the GitHub repo.** To do this:

    1.  Go to File > New Project in the RStudio IDE menu bar.

    ![](assets/rstudio/03-new-project.png)

    2.  Select Version Control in the New Project Wizard

    ![](assets/rstudio/04-project-wizard.png)

    3.  Select Git

    ![](assets/rstudio/05-git.png)

    4.  Paste the [URL](https://github.com/posit-dev/snowflake-posit-quickstart-r/) of the GitHub repo and click Create Project

    ![](assets/rstudio/06-create-project.png)

    RStudio will clone a local copy of the materials on GitHub. You can use the Files pane in the bottom right-hand corner of the IDE to navigate to `quarto.qmd`. Click on the file to open it.


Note: SSH authentication is not available in Snowpark Container Services, so when creating projects from Git, you may need to authenticate Git operations over HTTPS, using a username and password or a personal access token.


### Install R Packages

Now that we're in a familiar R environment,
we need to prepare the packages we will use. For this analysis, we will use the [Tidyverse](https://www.tidyverse.org/) suite of packages, as well as a few others.

```r
install.packages(c("tidyverse", "DBI", "dbplyr", "gt", "gtExtras", "odbc"))
```

After we install the packages, we load them.

```r
library(tidyverse)
library(DBI)
library(dbplyr)
library(gt)
library(gtExtras)
library(odbc)
```

## Access Snowflake data from R
Duration: 5

We will run our code in the R environment created by the RStudio Pro IDE, but the code will use data stored in our database on Snowflake.

To access this data, we will use the `{DBI}` and `{odbc}` R packages to connect to the database. We will then use `{dplyr}` and `{dbplyr}` to query the data with R,
without having to write raw SQL. Let's take a look at how this works.

### Connect with `{DBI}`

`{DBI}` is an R package that allows us to connect to databases with `DBI::dbConnect()`.

To connect to our Snowflake database, we will use a driver provided by the `{odbc}` package. We will need to provide a `warehouse` for compute, and a `database` to connect to.
We can also provide a `schema` here to make connecting to specific tables and views easier.

```r
# Connect to the database
conn <-
  DBI::dbConnect(
    odbc::snowflake(),
    warehouse = "DEFAULT_WH",
    database = "HEART_FAILURE",
    schema = "PUBLIC"
  )
```

We will save our connection as an object, named `conn`, which will make it easy to use.

Once we build a connection, we can see the databases, schemas, and tables available to us in the RStudio IDE Connections pane. Click on the database icon to the right of a database to see its schemas. Click on the schema icon to the right of a schema to see its tables. Click on the table icon to the right of a table to see a preview of the table.

![](assets/rstudio/02-connections.png)

### Create `tbl`s that correspond to tables in the database

Once we build a connection, we can use `dplyr::tbl()` to create `tbl`s. A tbl is an R object that represents a table or view accessed through a connection.


```r
heart_failure <- tbl(conn, "HEART_FAILURE")
```

> If we did not provide the `schema` argument into `DBI::dbConnect()` earlier, we would need to specify the view with `tbl(conn, in_schema("PUBLIC", "HEART_FAILURE"))`.

### Rely on `{dbplyr}` to translate R to SQL

We can now use `heart_failure` as if it was a tibble in R. For example, we can filter rows and select columns from our data.

```r
heart_failure_young <-
  heart_failure |> 
  filter(age < 50) |>
  select(age, sex, smoking, death_event)
```

When we use `tbl`s, `{dbplyr}` translates our R code into SQL queries. Think of any object made downstream from a tbl like a view: it contains SQL that represents a table built from the tbl. If we want to see the SQL code that `{dbplyr}` generates, we can run `dbplyr::show_query()`.

```r
heart_failure_young |>
  show_query()
```
```
SELECT
  "AGE" AS "age",
  "SEX" AS "sex",
  "SMOKING" AS "smoking",
  "DEATH_EVENT" AS "death_event"
FROM "HEART_FAILURE"
WHERE ("AGE" < 50.0)
```

To save compute, R waits to execute a query until we request the data that it represents.

To save memory, R stores the data as a temporary file in the database (instead of in R's global environment). When we inspect the data, R only returns the first few rows of this file to display.

```r
heart_failure_young
```
```
# Source:   SQL [?? x 4]
# Database: Snowflake 8.39.2[@Snowflake/HEART_FAILURE]
     age   sex smoking death_event
   <dbl> <dbl>   <dbl>       <dbl>
 1    45     1       0           1
 2    49     0       0           0
 3    45     1       0           1
 4    48     0       0           1
 5    49     1       1           1
 6    45     1       0           1
 7    45     1       0           1
 8    45     0       0           0
 9    42     0       0           1
10    41     1       1           0
# ℹ more rows
# ℹ Use `print(n = ...)` to see more rows
```

### `collect()`

We can trigger R to execute a query and to return the _entire_ result as a tibble with `dbplyr::collect()`. Keep in mind, that if your result is large, you may not want to collect it into R.

```r
heart_failure_young_df <-
  heart_failure_young |> 
  collect()
  
heart_failure_young_df
```
```
# A tibble: 47 × 4
     age   sex smoking death_event
   <dbl> <dbl>   <dbl>       <dbl>
 1    45     1       0           1
 2    49     0       0           0
 3    45     1       0           1
 4    48     0       0           1
 5    49     1       1           1
 6    45     1       0           1
 7    45     1       0           1
 8    45     0       0           0
 9    42     0       0           1
10    41     1       1           0
# ℹ 37 more rows
# ℹ Use `print(n = ...)` to see more rows
```

### In summary

This system:

1. Keeps our data in the database, saving memory in the R session
2. Pushes computations to the database, saving compute in the R session
3. Evaluates queries lazily, saving compute in the database

We don't need to manage the process, it happens automatically behind the scenes.

> `{dbplyr}` can translate the most common tidyverse and base R functions to SQL. However, you may sometimes use a function that `{dbplyr}` does not recognize or for which there is no SQL analogue. On these occasions, you will need to `collect()` your data into R, where you can process it as a real tibble.

Learn more about `{dbplyr}` at [dbplyr.tidyverse.org](https://dbplyr.tidyverse.org/)

## Write to a Snowflake database
Duration: 1

You can also use `{DBI}` to create a new table in a database or append to an existing table.

To add a new table, use `DBI::dbWriteTable()`. Note that `value` needs to be a data.frame or tibble, which
is why we passed `heart_failure_young_df`, the result of calling `collect()` on `heart_failure_young`.

```r
dbWriteTable(conn, name = "HEART_FAILURE_YOUNG", value = heart_failure_young_df)
```

To append to an existing table, specify `append = TRUE`. If appending, the `name` 
argument should refer to an existing table.

Now that we understand how R will interact with the database, we can use R to perform our analysis.

## Prepare data with `{dplyr}`
Duration: 5

We want to understand which variables in `HEART_FAILURE` are associated with survival
of patients with heart failure.

First we convert the column names to lowercase, so we won't need to worry about capitalization.

```r
# Standardize column names
heart_failure <- 
  heart_failure |> 
  rename_with(str_to_lower)
```

> When we are running these commands on a database connection, `{dbplyr}` is translating the code into SQL for us under the hood.
> We don't need to write raw SQL commands, and the compute is happening directly on the database.
> You can pipe `|>` the code into `show_query()` if you want to see the generated SQL query.


### Filter ages

For now, we'll focus on just patients younger than 50. We also reduce the data to just the columns we're interested in.

```r
heart_failure <-
  heart_failure |> 
  filter(age < 50) |> 
  select(age, diabetes, serum_sodium, serum_creatinine, sex, death_event)
```

Our table now looks like this.

```
# Source:   SQL [?? x 6]
# Database: Snowflake 8.39.2[@Snowflake/HEART_FAILURE]
     age diabetes serum_sodium serum_creatinine   sex death_event
   <dbl>    <dbl>        <dbl>            <dbl> <dbl>       <dbl>
 1    45        0          137             1.1      1           1
 2    49        0          138             1        0           0
 3    45        0          127             0.8      1           1
 4    48        1          121             1.9      0           1
 5    49        0          136             1.1      1           1
 6    45        1          139             1        1           1
 7    45        0          145             1        1           1
 8    45        0          137             1.18     0           0
 9    42        1          136             1.3      0           1
10    41        0          140             0.8      1           0
# ℹ more rows
# ℹ Use `print(n = ...)` to see more rows
```

## Visualize Data with `{ggplot2}`
Duration: 5

The heart failure data provides important insights that can help us:

- Identify factors associated with increased risk of mortality after heart failure
- Predict future survival outcomes based on historical clinical data
- Benchmark patient outcomes based on clinical indicators like serum sodium levels

Visualizing clinical variables across different patient groups can help identify patterns.

### Visualize serum sodium levels

We can use `{ggplot2}` to visually compare sodium levels across different patient groups. In this plot, we see the distribution of serum sodium based on whether the patients have diabetes and whether they survived (`0`) or died (`1`) during the follow-up period.

```r
heart_failure |> 
  mutate(
    death_event = as.character(death_event), 
    diabetes = as.character(diabetes)
  ) |> 
  ggplot(aes(x = death_event, y = serum_sodium, fill = diabetes)) +
  geom_boxplot() +
  labs(
    title = "Serum Sodium Levels by Diabetes Status and Survival Outcome",
    x = "Survival Outcome (0 = Survived, 1 = Died)",
    y = "Serum Sodium (mEq/L)",
    fill = "Diabetes"
  ) +
  theme(legend.position = "bottom")
```

![](assets/analysis/plot-sodium.png)

> **_INTERACTIVITY NOTE:_**  The code above allows for easy visualization of other variables. You can adjust the `aes()` function or filter the data to explore different clinical indicators and patient characteristics.

## Make publication-ready tables with `{gt}`
Duration: 5

We can continue exploring the heart failure dataset with visualizations or create a table that concisely displays multiple pieces of information at once. For example, we can use `{dplyr}` verbs to calculate the median values for various clinical metrics across different patient groups.

```r
heart_failure |> 
  summarize(
    across(
      c("age", "serum_creatinine", "serum_sodium"), 
      \(x) median(x, na.rm = TRUE), 
      .names = "median_{.col}"
    )
  )
```

```
# Source:   SQL [1 x 3]
# Database: Snowflake 8.39.2[@Snowflake/HEART_FAILURE]
  median_age median_serum_creatinine median_serum_sodium
       <dbl>                   <dbl>               <dbl>
1         45                       1                 137
```

With `{dplyr}`'s `group_by()` command, we can compute separate metrics for each
combination of `death_event` and `diabetes`.

```r
comparison <- 
  heart_failure |> 
  group_by(death_event, diabetes) |> 
  summarize(
    across(
      c("age", "serum_creatinine", "serum_sodium"), 
      \(x) median(x, na.rm = TRUE), 
      .names = "median_{.col}"
    ),
    .groups = "drop"
  )
  
comparison
```

```
# Source:   SQL [4 x 5]
# Database: Snowflake 8.39.2[@Snowflake/HEART_FAILURE]
  death_event diabetes median_age median_serum_creatinine median_serum_sodium
        <dbl>    <dbl>      <dbl>                   <dbl>               <dbl>
1           0        0       42                      1                    139
2           1        1       45.5                    1.45                 133
3           1        0       45                      1.1                  136
4           0        1       45                      0.9                  137
```

This is a useful way to examine the information for ourselves. However, if we wish to share the information with others, we might prefer to present the table in a more polished format. We can do this with commands from R's [`{gt}` package](https://gt.rstudio.com/).

The following code creates a table displaying the information in `comparison`.

```r
comparison |> 
  mutate(
    death_event = case_when(
      death_event == 1 ~ "Died",
      death_event == 0 ~ "Survived"
    ),
    diabetes = case_when(
      diabetes == 1 ~ "Yes",
      diabetes == 0 ~ "No"
    )
  ) |> 
  arrange(desc(death_event), desc(diabetes)) |> 
  gt(rowname_col = "death_event") |> 
  cols_label(
    diabetes = "Diabetes Status",
    median_age = "Median Age",
    median_serum_creatinine = "Median Serum Creatinine (mg/dL)",
    median_serum_sodium = "Median Serum Sodium (mEq/L)"
  ) |> 
  tab_header(
    title = "Clinical Metrics by Survival Outcome and Diabetes Status"
  ) |> 
  data_color(
    columns = c(median_serum_creatinine, median_serum_sodium),
    palette = "Blues"
  ) 
```

![](assets/gt/gt-table.png)

Now that we've accumulated some insights, let's think about how we might present the results of our analysis to our colleagues.

## Build Reports and Dashboards with Quarto
Duration: 2

We've conveniently written our analysis in a Quarto (`.qmd`) document, [quarto.qmd](https://github.com/posit-dev/snowflake-posit-quickstart-r/blob/main/quarto.qmd). [Quarto](https://quarto.org/)
is an open-source publishing system that makes it easy to create
[data products](https://quarto.org/docs/guide/) such as
[documents](https://quarto.org/docs/output-formats/html-basics.html),
[presentations](https://quarto.org/docs/presentations/),
[dashboards](https://quarto.org/docs/dashboards/),
[websites](https://quarto.org/docs/websites/),
and
[books](https://quarto.org/docs/books/).

By placing our work in a Quarto document, we have interwoven all of our code, results, output, and prose text into a single literate programming document.
This way everything can travel together in a reproducible data product.

A Quarto document can be thought of as a regular markdown document,
but with the ability to run code chunks.

You can run any of the code chunks by clicking the play button above the chunk in the RStudio Pro IDE.

![](assets/quarto/run-chunk.png)

You can render the entire document into a polished report to share, with the `Render` button.

![](assets/quarto/rstudio-render.png)

This will run all the code in the document from top to bottom in a new R session,
and generate an HTML file, by default, for you to view and share.

### Learn More about Quarto

You can learn more about Quarto here: <https://quarto.org/>,
and the documentation for all the various Quarto outputs here: <https://quarto.org/docs/guide/>.
Quarto works with R, Python, and Javascript Observable code out-of-the box,
and is a great tool to communicate your data science analyses.


## Shiny Application
Duration: 2

One way to share our work and allow others to explore the heart failure dataset is to create an
interactive [Shiny](https://shiny.posit.co/) app. 

We've prepared an example Shiny app in the directory:
<https://github.com/posit-dev/snowflake-posit-quickstart-r>. Our app allows the user
to explore different clinical metrics in one place.

![](assets/shiny/shiny.png)

To run the app, open `app.R` and then click the Run App button at the top of the script in the RStudio Pro IDE.

![](assets/shiny/run.png)

Change the metric in the sidebar to control which metric is plotted.

### Learn More About Shiny

You can learn more about Shiny at: <https://shiny.posit.co/>.
This example uses Shiny for R, but
[Shiny for Python](https://shiny.posit.co/py/)
is also available!

If you're new to Shiny, you can try it online with
[shinylive](https://shinylive.io/r/).
It too, comes in a [Python](https://shinylive.io/py) version.

## Conclusion and Resources
Duration: 2

R is beloved by data scientists for its intuitive, concise syntax. You can now combine this syntax with the power and peace of mind of Snowflake. The Posit Workbench Native Application provides an IDE for R _within Snowflake_. You can then use R's existing database packages---`{DBI}`, `{odbc}`, `{dbplyr}`---to access your Snowflake databases.

### What You Learned

- How to create an R session within the RStudio Pro IDE that comes with the Posit Workbench Native App.
- How to connect to your Snowflake data from R to create tables, visualizations, and more.
- Build an RStudio Pro IDE environment to use within Snowflake.
- Build a Quarto document that contains plots and tables built with R, using data stored in Snowflake.
- Build an interactive Shiny Application built with R, using data stored in Snowflake.


### Resources

- [Source Code on GitHub](https://github.com/posit-dev/snowflake-posit-quickstart-r)
- [More about Posit Workbench](https://posit.co/products/enterprise/workbench/)
- [{tidyverse} package for data science in R](https://dbplyr.tidyverse.org/)
- [{dbplyr} package for database connections](https://dbplyr.tidyverse.org/)
- [{gt} package for tables](https://gt.rstudio.com/)
- [Quarto for reproducible documents, reports, and data products](https://quarto.org/)
- [Shiny for interactive dashboards and applications](https://shiny.posit.co/)
- [Shinylive for serverless Shiny applications](https://shinylive.io/)

Snowpark Developer Guide for Python
The Snowpark library provides an intuitive API for querying and processing data in a data pipeline. Using the Snowpark library, you can build applications that process data in Snowflake without moving data to the system where your application code runs. You can also automate data transformation and processing by writing stored procedures and scheduling those procedures as tasks in Snowflake.

Get Started
You can write Snowpark Python code in a local development environment or in a Python worksheet in Snowsight.

If you need to write a client application, set up a local development environment by doing the following:

Set up your preferred development environment to build Snowpark apps. See Setting Up Your Development Environment for Snowpark Python.

Establish a session to interact with the Snowflake database. See Creating a Session for Snowpark Python.

If you want to write a stored procedure to automate tasks in Snowflake, use Python worksheets in Snowsight. See Writing Snowpark Code in Python Worksheets.

Write Snowpark Python Code
You can query, process, and transform data in a variety of ways using Snowpark Python.

Query and process data with a DataFrame object. See Working with DataFrames in Snowpark Python.

Run your pandas code directly on your data in Snowflake. See pandas on Snowflake.

Convert custom lambdas and functions to user-defined functions (UDFs) that you can call to process data. See Creating User-Defined Functions (UDFs) for DataFrames in Python.

Write a user-defined tabular function (UDTF) that processes data and returns data in a set of rows with one or more columns. See Creating User-Defined Table Functions (UDTFs) for DataFrames in Python.

Write a stored procedure that you can call to process data, or automate with a task to build a data pipeline. See Creating Stored Procedures for DataFrames in Python.

Perform Machine Learning Tasks
You can use Snowpark Python to perform machine learning tasks like training models:

Train machine learning models by writing stored procedures. See Training Machine Learning Models with Snowpark Python.

Train, score, and tune machine learning models using Snowpark Python stored procedures and deploy the trained models with user-defined functions. See Machine Learning with Snowpark Python - Credit Card Approval Prediction (Snowflake Quickstarts).

Troubleshoot Snowpark Python Code
Troubleshoot your code with logging statements and by viewing the underlying SQL. See Troubleshooting with Snowpark Python.

Record and Analyze Data About Code Execution
You can record log messages and trace events in an event table for later analysis. For more information, see Logging, tracing, and metrics.

