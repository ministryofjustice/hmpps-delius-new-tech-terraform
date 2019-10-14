{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 27,
            "width": 24,
            "height": 3,
            "properties": {
                "view": "singleValue",
                "metrics": [
                    [ "ECS/ContainerInsights", "CpuReserved", "ClusterName", "${name_prefix}-ecscluster-private-ecs" ],
                    [ ".", "CpuUtilized", ".", "." ],
                    [ ".", "MemoryReserved", ".", "." ],
                    [ ".", "MemoryUtilized", ".", "." ],
                    [ ".", "ServiceCount", ".", "." ],
                    [ ".", "ContainerInstanceCount", ".", "." ]
                ],
                "region": "eu-west-2",
                "title": "New Tech ECS Summary"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "RunningTaskCount", "ServiceName", "${name_prefix}-casenotes-pri-ecs", "ClusterName", "${name_prefix}-ecscluster-private-ecs" ],
                    [ "...", "${name_prefix}-cnotesdb-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-newtechweb-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-offapi-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-offpoll-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-pdfgen-pri-ecs", ".", "." ],
                    [ "AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "${name_prefix}-ecscluster-private-asg", { "label": "ECS Nodes" } ]
                ],
                "view": "singleValue",
                "region": "eu-west-2",
                "title": "New Tech Running Task Count",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 3,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "PendingTaskCount", "ServiceName", "${name_prefix}-casenotes-pri-ecs", "ClusterName", "${name_prefix}-ecscluster-private-ecs", { "period": 60, "stat": "Maximum", "color": "#d62728" } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "period": 60, "stat": "Maximum", "color": "#2ca02c" } ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "eu-west-2",
                "period": 300,
                "title": "casenotes"
            }
        },
        {
            "type": "metric",
            "x": 15,
            "y": 3,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "PendingTaskCount", "ServiceName", "${name_prefix}-pdfgen-pri-ecs", "ClusterName", "${name_prefix}-ecscluster-private-ecs", { "color": "#d62728" } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "color": "#2ca02c" } ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "eu-west-2",
                "period": 300,
                "title": "pdfgen"
            }
        },
        {
            "type": "metric",
            "x": 3,
            "y": 3,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "PendingTaskCount", "ServiceName", "${name_prefix}-cnotesdb-pri-ecs", "ClusterName", "${name_prefix}-ecscluster-private-ecs", { "stat": "Maximum", "period": 60, "color": "#d62728" } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "stat": "Maximum", "period": 60, "color": "#2ca02c" } ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "eu-west-2",
                "period": 300,
                "title": "cnotesdb"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 3,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "PendingTaskCount", "ServiceName", "${name_prefix}-newtechweb-pri-ecs", "ClusterName", "${name_prefix}-ecscluster-private-ecs", { "period": 60, "stat": "Maximum", "color": "#d62728" } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "period": 60, "stat": "Maximum", "color": "#2ca02c" } ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "eu-west-2",
                "period": 300,
                "title": "web"
            }
        },
        {
            "type": "metric",
            "x": 9,
            "y": 3,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "PendingTaskCount", "ServiceName", "${name_prefix}-offapi-pri-ecs", "ClusterName", "${name_prefix}-ecscluster-private-ecs", { "color": "#d62728" } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "color": "#2ca02c" } ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "eu-west-2",
                "period": 300,
                "title": "offapi"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 3,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "PendingTaskCount", "ServiceName", "${name_prefix}-offpoll-pri-ecs", "ClusterName", "${name_prefix}-ecscluster-private-ecs", { "color": "#d62728" } ],
                    [ ".", "RunningTaskCount", ".", ".", ".", ".", { "color": "#2ca02c" } ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "eu-west-2",
                "period": 300,
                "title": "offpoll"
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 3,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/AutoScaling", "GroupPendingInstances", "AutoScalingGroupName", "${name_prefix}-ecscluster-private-asg", { "color": "#d62728" } ],
                    [ ".", "GroupTotalInstances", ".", ".", { "color": "#2ca02c" } ]
                ],
                "view": "timeSeries",
                "region": "eu-west-2",
                "stacked": true,
                "title": "ECS Nodes",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 9,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "ECS/ContainerInsights", "CpuUtilized", "ServiceName", "${name_prefix}-newtechweb-pri-ecs", "ClusterName", "${name_prefix}-ecscluster-private-ecs", { "period": 300 } ],
                    [ "...", "${name_prefix}-cnotesdb-pri-ecs", ".", ".", { "period": 300 } ],
                    [ "...", "${name_prefix}-offpoll-pri-ecs", ".", ".", { "period": 300 } ],
                    [ "...", "${name_prefix}-casenotes-pri-ecs", ".", ".", { "period": 300 } ],
                    [ "...", "${name_prefix}-pdfgen-pri-ecs", ".", ".", { "period": 300 } ],
                    [ "...", "${name_prefix}-offapi-pri-ecs", ".", ".", { "period": 300 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-2",
                "title": "CPU Util"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 9,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "ECS/ContainerInsights", "MemoryUtilized", "ServiceName", "${name_prefix}-offapi-pri-ecs", "ClusterName", "${name_prefix}-ecscluster-private-ecs" ],
                    [ "...", "${name_prefix}-cnotesdb-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-offpoll-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-pdfgen-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-newtechweb-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-casenotes-pri-ecs", ".", "." ]
                ],
                "region": "eu-west-2",
                "title": "Mem Util"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 30,
            "width": 12,
            "height": 3,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "ECS/ContainerInsights", "CpuUtilized", "ClusterName", "${name_prefix}-ecscluster-private-ecs" ]
                ],
                "region": "eu-west-2",
                "title": "ECS CPU"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 30,
            "width": 12,
            "height": 3,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "ECS/ContainerInsights", "MemoryUtilized", "ClusterName", "${name_prefix}-ecscluster-private-ecs" ]
                ],
                "region": "eu-west-2",
                "title": "ECS Mem"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 15,
            "width": 24,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/Logs", "IncomingLogEvents", "LogGroupName", "${name_prefix}-casenotes-pri-cwl" ],
                    [ "...", "${name_prefix}-cnotesdb-pri-cwl" ],
                    [ "...", "${name_prefix}-newtechweb-pri-cwl" ],
                    [ "...", "${name_prefix}-offendapi-pri-cwl" ],
                    [ "...", "${name_prefix}-offpoll-pri-cwl" ],
                    [ "...", "${name_prefix}-pdfgen-pri-cwl" ]
                ],
                "region": "eu-west-2"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 21,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "ECS/ContainerInsights", "StorageReadBytes", "TaskDefinitionFamily", "${name_prefix}-cnotesdb-pri-ecs", "ClusterName", "${name_prefix}-ecscluster-private-ecs" ],
                    [ "...", "${name_prefix}-offapi-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-pdfgen-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-offpoll-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-newtechweb-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-casenotes-pri-ecs", ".", "." ]
                ],
                "region": "eu-west-2",
                "title": "Storage Read Bytes"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 21,
            "width": 12,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "ECS/ContainerInsights", "StorageWriteBytes", "TaskDefinitionFamily", "${name_prefix}-newtechweb-pri-ecs", "ClusterName", "${name_prefix}-ecscluster-private-ecs" ],
                    [ "...", "${name_prefix}-casenotes-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-pdfgen-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-cnotesdb-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-offpoll-pri-ecs", ".", "." ],
                    [ "...", "${name_prefix}-offapi-pri-ecs", ".", "." ]
                ],
                "region": "eu-west-2",
                "title": "Storage Wrote Bytes"
            }
        }
    ]
}