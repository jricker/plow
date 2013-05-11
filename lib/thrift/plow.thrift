/**
* Plow Thrift RPC Interface Definition
**/
include "common.thrift"

namespace java com.breakersoft.plow.thrift
namespace py rpc
namespace cpp Plow

typedef map<string,string> Attrs

/**
* Job State Enum
**/
enum JobState {
    // Job is in the process of launching.
    INITIALIZE,
    // Job is now accepting procs.
    RUNNING,
    // The job has been stopped.
    FINISHED
}

/**
* Task State Enum
**/
enum TaskState {
    INITIALIZE,
    WAITING,
    RUNNING,
    DEAD,
    EATEN,
    DEPEND,
    SUCCEEDED
}

/**
* Node state enumeration
**/
enum NodeState {
    UP,
    DOWN,
    REPAIR
}

enum DependType {
    JOB_ON_JOB,
    LAYER_ON_LAYER,
    LAYER_ON_TASK,
    TASK_ON_LAYER,
    TASK_ON_TASK,
    TASK_BY_TASK
}

exception PlowException {
    1: i32 what,
    2: string why
}

struct DependT {
    1:required common.Guid id,
    2:required DependType type,
    3:required bool active,
    4:required common.Timestamp createdTime,
    5:required common.Timestamp satisfiedTime,
    6:required string dependentJobId,
    7:required string dependOnJobId,
    8:optional string dependentLayerId,
    9:optional string dependOnLayerId,
    10:optional string dependentTaskId,
    11:optional string dependOnTaskId,
    12:required string dependentJobName,
    13:required string dependOnJobName,
    14:optional string dependentLayerName,
    15:optional string dependOnLayerName,
    16:optional string dependentTaskName,
    17:optional string dependOnTaskName,
}

struct TaskTotalsT {
    1:i32 totalTaskCount = 0,
    2:i32 succeededTaskCount = 0,
    3:i32 runningTaskCount = 0,
    4:i32 deadTaskCount = 0,
    5:i32 eatenTaskCount = 0,
    6:i32 waitingTaskCount = 0,
    7:i32 dependTaskCount = 0,
}

struct ProjectT {
    1:common.Guid id,
    2:string code,
    3:string title,
    4:bool isActive
}

struct ClusterCountsT {
    1:required i32 nodes,
    2:required i32 upNodes, 
    3:required i32 downNodes,
    4:required i32 repairNodes,
    5:required i32 lockedNodes,
    6:required i32 unlockedNodes,
    7:required i32 cores,
    8:required i32 upCores, 
    9:required i32 downCores,
    10:required i32 repairCores,
    11:required i32 lockedCores,
    12:required i32 unlockedCores,
    13:required i32 runCores,
    14:required i32 idleCores
}

struct ClusterT {
    1:required common.Guid id,
    2:string name,
    3:set<string> tags,
    4:bool isLocked,
    5:bool isDefault,
    6:ClusterCountsT total
}

struct QuotaT {
    1:common.Guid id,
    2:common.Guid clusterId,
    3:common.Guid projectId,
    4:string name,
    5:bool isLocked,
    6:i32 size,
    7:i32 burst,
    8:i32 runCores
}

struct NodeSystemT {
    1:i32 physicalCores,
    2:i32 logicalCores,
    3:i32 totalRamMb,               
    4:i32 freeRamMb,
    5:i32 totalSwapMb,
    6:i32 freeSwapMb,
    7:string cpuModel,
    8:string platform,
    9:list<i32> load
}

struct NodeT {
    1:common.Guid id,
    2:common.Guid clusterId,
    3:string name,
    4:string clusterName,
    5:string ipaddr,
    6:set<string> tags,
    7:NodeState state,
    8:bool locked,
    9:common.Timestamp createdTime,
    10:common.Timestamp updatedTime,
    11:common.Timestamp bootTime,
    12:i32 totalCores,
    13:i32 idleCores,
    14:i32 totalRamMb,
    15:i32 freeRamMb,
    16:NodeSystemT system
}

struct ProcT {
    1:common.Guid id,
    2:common.Guid hostId,
    3:string jobName,
    4:string taskName,
    5:i32 cores,
    6:i32 ramMb,
    7:i32 usedRamMb,
    8:i32 highRamMb,
    9:bool unbooked
}

struct JobStatsT {
    1:required i32 highRam,
    2:required double highCores,
    3:required i32 highCoreTime,
    4:required i64 totalCoreTime,
    5:required i64 totalGoodCoreTime,
    6:required i64 totalBadCoreTime
}

struct JobT {
    1:required common.Guid id,
    2:required common.Guid folderId,
    3:required string name,
    4:required string username,
    5:required i32 uid,
    6:required JobState state,
    7:required bool paused
    8:required i32 minCores,
    9:required i32 maxCores,
    10:required i32 runCores,
    11:required common.Timestamp startTime,
    12:required common.Timestamp stopTime,
    13:required TaskTotalsT totals,
    14:required JobStatsT stats,
    15:required Attrs attrs
}

struct LayerStatsT {
    1:required i32 highRam,
    2:required i32 avgRam,
    3:required double stdDevRam,
    4:required double highCores,
    5:required double avgCores,
    6:required double stdDevCores,
    7:required i32 highCoreTime,
    8:required i32 avgCoreTime,
    9:required i32 lowCoreTime,
    10:required double stdDevCoreTime,
    11:required i64 totalCoreTime,
    12:required i64 totalGoodCoreTime,
    13:required i64 totalBadCoreTime
}

struct LayerT {
    1:required common.Guid id,
    2:required string name,
    3:required string range,
    4:required i32 chunk,
    5:required set<string> tags,
    6:required bool threadable,
    7:required i32 minCores,
    8:required i32 maxCores,
    9:required i32 minRam,
    10:required i32 maxRam,
    11:required i32 runCores,
    12:required TaskTotalsT totals,
    13:required LayerStatsT stats
}

struct TaskStatsT {
    1:required i32 cores,
    2:required double usedCores,
    3:required double highCores,
    4:required i32 ram,
    5:required i32 usedRam,
    6:required i32 highRam,
    7:required common.Timestamp startTime,
    8:required common.Timestamp stopTime,
    9:required i32 retryNum,
    10:required i32 progress,
    11:required string lastLogLine,
    12:bool active = false,
    13:i32 exitStatus,
    14:i32 exitSignal
}

struct TaskT {
    1:required common.Guid id,
    2:required string name,
    3:required i32 number,
    4:required TaskState state,
    7:required i32 order,
    8:required i32 retries,
    9:required i32 minCores,
    10:required i32 minRam,
    11:string lastResource,
    12:TaskStatsT stats
}

struct FolderT {
    1:common.Guid id,
    2:string name,
    3:i32 minCores,
    4:i32 maxCores,
    5:i32 runCores,
    6:i32 order,
    7:TaskTotalsT totals,
    8:optional list<JobT> jobs
}

enum MatcherType {
    CONTAINS,
    NOT_CONTAINS,
    IS,
    IS_NOT,
    BEGINS_WITH,
    ENDS_WITH
}

enum MatcherField {
    JOB_NAME,
    USER,
    ATTR
}

struct MatcherT {
    1:common.Guid id,
    2:MatcherType type,
    3:MatcherField field,
    4:string value,
    5:optional string attr
}

enum ActionType {
    SET_FOLDER,
    SET_MIN_CORES,
    SET_MAX_CORES,
    PAUSE,
    STOP_PROCESSING
}

struct ActionT {
    1:common.Guid id,
    2:ActionType type,
    3:optional string value
}

struct FilterT {
    1:common.Guid id,
    2:string name,
    3:i32 order,
    4:bool enabled,
    5:optional list<MatcherT> matchers,
    6:optional list<ActionT> actions
}

/**
* DependSpecT describes a dependency launched with a JobSpec.
**/
struct DependSpecT {
    1:DependType type,
    2:string dependentJob,
    3:string dependOnJob,
    4:string dependentLayer,
    5:string dependOnLayer,
    6:string dependentTask,
    7:string dependOnTask
}

struct TaskSpecT {
    1:string name,
    2:list<DependSpecT> depends
}

struct LayerSpecT {
    1:string name,
    2:list<string> command,
    3:set<string> tags,
    4:optional string range,
    5:i32 chunk = 1,
    6:i32 minCores = 1,
    7:i32 maxCores = 1,
    8:i32 minRamMb = 1024,
    9:bool threadable = false,
    10:list<DependSpecT> depends,
    11:list<TaskSpecT> tasks,
    12:Attrs env
}

struct JobSpecT {
    1:string name,
    2:string project,
    3:bool paused,
    4:string username,
    5:i32 uid,
    6:string logPath
    7:list<LayerSpecT> layers,
    8:list<DependSpecT> depends,
    9:Attrs attrs,
    10:Attrs env
}

struct JobFilterT {
    1:bool matchingOnly = false,
    2:list<string> project,
    3:list<string> user,
    4:string regex,
    5:list<JobState> states,
    6:list<common.Guid> jobIds,
    7:list<string> name
}

struct TaskFilterT {
    1:common.Guid jobId,
    2:list<common.Guid> layerIds,
    3:list<TaskState> states,
    4:i32 limit = 0,
    5:i32 offset = 0,
    6:i64 lastUpdateTime = 0,
    7:list<common.Guid> taskIds
}

struct NodeFilterT {
    1:list<common.Guid> hostIds,
    2:list<common.Guid> clusterIds,
    3:string regex,
    4:list<string> hostnames,
    5:list<NodeState> states,
    6:optional bool locked
}

struct QuotaFilterT {
    1:optional list<common.Guid> project,
    2:optional list<common.Guid> cluster
}

struct OutputT {
    1:string path,
    2:common.Attrs attrs
}

service RpcService {
    
    i64 getPlowTime() throws (1:PlowException e),

    ProjectT getProject(1:common.Guid id) throws (1:PlowException e),
    ProjectT getProjectByCode(1:string code) throws (1:PlowException e),
    list<ProjectT> getProjects() throws (1:PlowException e),
    list<ProjectT> getActiveProjects() throws (1:PlowException e),
    ProjectT createProject(1:string title, 2:string code) throws (1:PlowException e),
    void setProjectActive(1:common.Guid id, 2:bool active) throws (1:PlowException e),

    JobT launch(1:JobSpecT spec) throws (1:PlowException e),
    JobT getActiveJob(1:string name) throws (1:PlowException e),
    JobT getJob(1:common.Guid jobId) throws (1:PlowException e),
    bool killJob(1:common.Guid jobId, 2:string reason) throws (1:PlowException e),
    void pauseJob(1:common.Guid jobId, 2:bool paused) throws (1:PlowException e),
    list<JobT> getJobs(1:JobFilterT filter) throws (1:PlowException e),
    list<OutputT> getJobOutputs(1:common.Guid jobId) throws (1:PlowException e),
    void setJobMinCores(1:common.Guid jobId, 2:i32 value) throws (1:PlowException e),
    void setJobMaxCores(1:common.Guid jobId, 2:i32 value) throws (1:PlowException e),
    void setJobAttrs(1:common.Guid jobId, 2:Attrs attrs) throws (1:PlowException e),
    list<DependT> getDependsOnJob(1:common.Guid jobId) throws (1:PlowException e),
    list<DependT> getJobDependsOn(1:common.Guid jobId) throws (1:PlowException e),
    JobSpecT getJobSpec(1:common.Guid jobId) throws (1:PlowException e),

    FolderT createFolder(1:string projectId, 2:string name) throws (1:PlowException e),
    FolderT getFolder(1:string id) throws (1:PlowException e),
    list<FolderT> getJobBoard(1:common.Guid project) throws (1:PlowException e),
    list<FolderT> getFolders(1:common.Guid project) throws (1:PlowException e),
    void setFolderMinCores(1:common.Guid folderId, 2:i32 value) throws (1:PlowException e),
    void setFolderMaxCores(1:common.Guid folderId, 2:i32 value) throws (1:PlowException e),
    void setFolderName(1:common.Guid folderId, 2:string name) throws (1:PlowException e),
    void deleteFolder(1:common.Guid folderId) throws (1:PlowException e),

    LayerT getLayerById(1:common.Guid layerId) throws (1:PlowException e),
    LayerT getLayer(1:common.Guid jobId, 2:string name) throws (1:PlowException e),
    list<LayerT> getLayers(1:common.Guid jobId) throws (1:PlowException e),
    void addOutput(1:common.Guid layerId, 2:string path, 3:common.Attrs attrs) throws (1:PlowException e)
    list<OutputT> getLayerOutputs(1:common.Guid layerId) throws (1:PlowException e),
    void setLayerTags(1:common.Guid guid, 2:set<string> tags) throws (1:PlowException e),
    void setLayerMinCoresPerTask(1:common.Guid guid, 2:i32 minCores) throws (1:PlowException e),
    void setLayerMaxCoresPerTask(1:common.Guid guid, 2:i32 minCores) throws (1:PlowException e),
    void setLayerMinRamPerTask(1:common.Guid guid, 2:i32 minCores) throws (1:PlowException e),
    void setLayerThreadable(1:common.Guid guid, 2:bool threadable) throws (1:PlowException e),
    list<DependT> getDependsOnLayer(1:common.Guid layerId) throws (1:PlowException e),
    list<DependT> getLayerDependsOn(1:common.Guid layerId) throws (1:PlowException e),

    TaskT getTask(1:common.Guid taskId) throws (1:PlowException e),
    list<TaskT> getTasks(1:TaskFilterT filter) throws (1:PlowException e),
    string getTaskLogPath(1:common.Guid taskId) throws (1:PlowException e),
    void retryTasks(1:TaskFilterT filter) throws (1:PlowException e),
    void eatTasks(1:TaskFilterT filter) throws (1:PlowException e),
    void killTasks(1:TaskFilterT filter) throws (1:PlowException e),
    list<DependT> getDependsOnTask(1:common.Guid taskId) throws (1:PlowException e),
    list<DependT> getTaskDependsOn(1:common.Guid taskId) throws (1:PlowException e),
    list<TaskStatsT> getTaskStats(1:common.Guid taskId) throws (1:PlowException e),

    bool dropDepend(1:common.Guid dependId) throws (1:PlowException e),
    bool reactivateDepend(1:common.Guid dependId) throws (1:PlowException e),

    NodeT getNode(1:string name) throws (1:PlowException e),
    list<NodeT> getNodes(1:NodeFilterT filter) throws (1:PlowException e),
    void setNodeLocked(1:common.Guid id, 2:bool locked) throws (1:PlowException e),
    void setNodeCluster(1:common.Guid id, 2:common.Guid clusterId) throws (1:PlowException e),
    void setNodeTags(1:common.Guid id, 2:set<string> tags) throws (1:PlowException e),

    ClusterT getCluster(1:string name) throws (1:PlowException e),
    list<ClusterT> getClustersByTag(1:string tag) throws (1:PlowException e),
    list<ClusterT> getClusters() throws (1:PlowException e),
    ClusterT createCluster(1:string name, 2:set<string> tags) throws (1:PlowException e),
    bool deleteCluster(1:common.Guid id) throws (1:PlowException e),
    bool lockCluster(1:common.Guid id, 2:bool locked) throws (1:PlowException e),
    void setClusterTags(1:common.Guid id, 2:set<string> tags) throws (1:PlowException e),
    void setClusterName(1:common.Guid id, 2: string name) throws (1:PlowException e),
    void setDefaultCluster(1:common.Guid id) throws (1:PlowException e),

    QuotaT getQuota(1:common.Guid id) throws (1:PlowException e),
    list<QuotaT> getQuotas(1:QuotaFilterT filter) throws (1:PlowException e),
    QuotaT createQuota(1:common.Guid projectId, 2:common.Guid clusterId, 3:i32 size, 4:i32 burst) throws (1:PlowException e),
    void setQuotaSize(1:common.Guid id, 2:i32 size) throws (1:PlowException e),
    void setQuotaBurst(1:common.Guid id, 2:i32 burst) throws (1:PlowException e),
    void setQuotaLocked(1:common.Guid id, 2:bool locked) throws (1:PlowException e)

    FilterT createFilter(1:common.Guid projectId, 2:string name) throws (1:PlowException e),
    list<FilterT> getFilters(1:common.Guid projectId) throws (1:PlowException e),
    FilterT getFilter(1:common.Guid filterId) throws (1:PlowException e),
    void deleteFilter(1:common.Guid id) throws (1:PlowException e),
    void setFilterName(1:common.Guid id, 2:string name) throws (1:PlowException e),
    void setFilterOrder(1:common.Guid id, 2:i32 order) throws (1:PlowException e),
    void increaseFilterOrder(1:common.Guid id) throws (1:PlowException e),
    void decreaseFilterOrder(1:common.Guid id) throws (1:PlowException e),
    MatcherT createFieldMatcher(1:common.Guid filterId, 2:MatcherField field, 3:MatcherType type, 4:string value) throws (1:PlowException e),
    MatcherT createAttrMatcher(1:common.Guid filterId, 2:MatcherType type, 3:string attr, 4:string value) throws (1:PlowException e),
    MatcherT getMatcher(1:common.Guid matcherId) throws (1:PlowException e),
    list<MatcherT> getMatchers(1:common.Guid filterId) throws (1:PlowException e),
    void deleteMatcher(1:common.Guid id) throws (1:PlowException e),
    ActionT createAction(1:common.Guid filterId, 2:ActionType type, 3:string value) throws (1:PlowException e),
    void deleteAction(1:common.Guid id) throws (1:PlowException e),
    list<ActionT> getActions(1:common.Guid filterId) throws (1:PlowException e),
    ActionT getAction(1:common.Guid actionId) throws (1:PlowException e)
}
