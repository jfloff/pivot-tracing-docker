# pivot-tracing-docker

`pivot-tracing-docker` is a docker container for [Pivot Tracing](http://pivottracing.io/).

> Pivot Tracing is a monitoring framework for distributed systems that can seamlessly correlate statistics across applications, components, and machines at runtime, without needing to change or redeploy system code. Users can define and install monitoring queries on-the-fly, to collect arbitrary statistics from one point in the system while being able to select, filter, and group by events meaningful at other points in the system.

For more information regarding Pivot Tracing, read its research paper: [Pivot Tracing: Dynamic Causal Monitoring for Distributed Systems @ SOSP 2015 (Best Paper Award)](http://pivottracing.io/mace15pivot.pdf)

At this moment this container is focused on bootstrapping the example detailed on [Pivot Tracing's tutorials section](http://brownsys.github.io/tracing-framework/docs/tutorials/gettingstarted.html). It runs a pre-instrumented version of HDFS that has all of the instrumentation libraries added to it.

**Don't forget to acknowledge Pivot Tracing (i.e. cite the [paper](http://pivottracing.io/mace15pivot.pdf)) if you publish results produced with this software.**

## Installation

_For any problems during the installation, please double check if its really a container problem, or a Pivot Tracing installation problem._

First clone the `tracing-framework` repository to the `tracing` folder in the current directory.

```shell
git clone https://github.com/brownsys/tracing-framework.git tracing
```

Then clone the pre-instrumented fork of Hadoop 2.7.2 into `tracing/hadoop`. _If you change the destination folder names, don't forget to also change the Dockerfile accordingly._

```shell
git clone -b brownsys-pivottracing-2.7.2 --single-branch https://github.com/brownsys/hadoop.git tracing/hadoop
```

**Note:** I'm checking out *only* the pre-instrumented Hadoop branch. If you found any problems, please follow the tutorial's advice:

> If you encounter any problems while building, try building the non-instrumented branch branch-2.7.2. This will determine whether it is a Hadoop build issue, or a problem with our extra instrumentation.

After cloning both repos, we can build the container with all [Pivot Tracing prerequisites](http://brownsys.github.io/tracing-framework/docs/tutorials/prerequisites.html):
```shell
docker build --rm=true -t jfloff/pivot-tracing .
```

After building the container, we can run it. The first run will take a while because it will build and install the tracing-framework and Hadoop ([see tutorial](http://brownsys.github.io/tracing-framework/docs/tutorials/gettingstarted.html)).

```shell
docker run -ti -v "$(pwd)/tracing":/home/pt -w /home/pt -p 5000:22 --name pivot-tracing jfloff/pivot-tracing
```

After the `docker run` finishes, the container will stop (you can check with `docker ps -a`) and you will have a container ready to run Pivot Tracing example queries. **Note:** Don't forget to remove the container when you are done with it:

```shell
docker stop pivot-tracing
docker rm pivot-tracing
```

## Usage

First start the Pivot Tracing container:

```shell
docker start pivot-tracing
```

Then following the tutorial, we need to start [HDFS `DataNode` and `NameNode`](http://brownsys.github.io/tracing-framework/docs/tutorials/gettingstarted.html):
```shell
docker exec pivot-tracing sh /home/start-hdfs.sh
```

After that [start a pub sub server](http://brownsys.github.io/tracing-framework/docs/tutorials/gettingstarted.html):
```shell
docker exec pivot-tracing /home/pt/tracingplane/pubsub/target/appassembler/bin/server
```

In a new terminal, we will open the `print-agent-status` that [prints all Pivot Tracing agents status](http://brownsys.github.io/tracing-framework/docs/tutorials/pivottracing.html).
```shell
docker exec pivot-tracing /home/pt/pivottracing/client/target/appassembler/bin/print-agent-status
```

And in (yet) another terminal, we leave run the `print-query-results` utility that will print the query outputs:
```shell
docker exec pivot-tracing /home/pt/pivottracing/client/target/appassembler/bin/print-query-results
```

Finally we can first install the query:
```shell
docker exec pivot-tracing /home/pt/pivottracing/client/target/appassembler/bin/example-hdfs-query
```

And then run some data through HDFS so we can see our query working:
```shell
docker exec pivot-tracing sh -c 'echo "Hello World" >> example.txt'
docker exec pivot-tracing /home/pt/hadoop/hadoop-dist/target/hadoop-2.7.2/bin/hdfs dfs -copyFromLocal example.txt /example.txt
docker exec pivot-tracing /home/pt/hadoop/hadoop-dist/target/hadoop-2.7.2/bin/hdfs dfs -copyToLocal /example.txt example2.txt
```

_**Don't forget to look at the official [Pivot Tracing tutorial](http://brownsys.github.io/tracing-framework/docs/tutorials/pivottracing.html) to see the expected output of each command.**_

## Future Work

* Create a Dockerfile for standard tracing framework, not specific to example
* Work on a simple baggage example

## License

See [Pivot Tracing original LICENSE](https://github.com/brownsys/tracing-framework/blob/master/LICENSE)
