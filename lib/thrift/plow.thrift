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
    FINISHED,
    // Post
    POST
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

/**
* Node slot mode.
**/
enum SlotMode {

    /**
    * Fully dynamic slots driven by job requirements. 
    **/
    DYNAMIC,

    /**
    * Node is treated as a single large resource, all cores and all memory.
    **/
    SINGLE,
    
    /**
    * Custom min cores/min ram defined on a per node basis.
    **/
    SLOTS
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
    8:SlotMode mode,
    9:bool locked,
    10:common.Timestamp createdTime,
    11:common.Timestamp updatedTime,
    12:common.Timestamp bootTime,
    13:i32 totalCores,
    14:i32 idleCores,
    15:i32 slotCores,
    16:i32 totalRamMb,
    17:i32 freeRamMb,
    18:i32 slotRam,
    19:NodeSystemT system
}

struct ProcT {
    1:common.Guid id,
    2:common.Guid nodeId,
    3:string jobName,
    4:string layerName,
    5:string taskName,
    6:i32 cores,
    7:double usedCores,
    8:double highCores,
    9:i32 ram,
    10:i32 usedRam,
    11:i32 highRam,
    12:list<i64> ioStats,
    13:common.Timestamp createdTime,
    14:common.Timestamp updatedTime,
    15:common.Timestamp startedTime
}

struct ProcFilterT {
    1:list<common.Guid> projectIds,
    2:list<common.Guid> folderIds,
    3:list<common.Guid> jobIds,
    4:list<common.Guid> layerIds,
    5:list<common.Guid> taskIds,
    6:list<common.Guid> clusterIds,
    7:list<common.Guid> quotaIds,
    8:list<common.Guid> nodeIds,
    20:i64 lastUpdateTime = 0,
    21:i32 limit = 0,
    22:i32 offset = 0
}

struct JobStatsT {
    1:i32 highRam,
    2:double highCores,
    3:i64 highCoreTime,
    4:i64 totalCoreTime,
    5:i64 totalSuccessCoreTime,
    6:i64 totalFailCoreTime,
    7:i64 highClockTime
}

struct JobT {
    1:required common.Guid id,
    2:required common.Guid folderId,
    3:string name,
    4:string username,
    5:i32 uid,
    6:JobState state,
    7:bool paused
    8:i32 minCores,
    9:i32 maxCores,
    10:i32 runCores,
    11:i32 runProcs,
    12:common.Timestamp startTime,
    13:common.Timestamp stopTime,
    14:TaskTotalsT totals,
    15:JobStatsT stats,
    16:Attrs attrs
}

struct LayerStatsT {
    1:i32 highRam,
    2:i32 avgRam,
    3:double stdDevRam,
    4:double highCores,
    5:double avgCores,
    6:double stdDevCores,
    7:i64 highCoreTime,
    8:i64 avgCoreTime,
    9:i64 lowCoreTime,
    10:double stdDevCoreTime,
    11:i64 totalCoreTime,
    12:i64 totalSuccessCoreTime,
    13:i64 totalFailCoreTime,
    14:i64 highClockTime,
    15:i64 avgClockTime,
    16:i64 lowClockTime,
    17:double stdDevClockTime,
    18:i64 totalClockTime,
    19:i64 totalSuccessClockTime,
    20:i64 totalFailClockTime
}

struct ServiceT {
    1:common.Guid id,
    2:required string name,
    3:list<string> tags,
    4:i32 minCores,
    5:i32 maxCores,
    6:i32 minRam,
    7:i32 maxRam,
    8:i32 maxRetries,
    9:bool threadable
}

struct LayerT {
    1:required common.Guid id,
    2:common.Guid jobId,
    3:string name,
    4:string range,
    5:string serv,
    6:i32 chunk,
    7:list<string> tags,
    8:bool threadable,
    9:i32 minCores,
    10:i32 maxCores,
    11:i32 minRam,
    12:i32 maxRam,
    13:i32 runCores,
    14:i32 maxRetries,
    15:i32 runProcs,
    16:TaskTotalsT totals,
    17:LayerStatsT stats
}

struct TaskStatsT {
    1:i32 cores,
    2:double usedCores,
    3:double highCores,
    4:i32 ram,
    5:i32 usedRam,
    6:i32 highRam,
    7:common.Timestamp startTime,
    8:common.Timestamp stopTime,
    9:i32 retryNum,
    10:i32 progress,
    11:string lastLogLine,
    12:bool active = false,
    13:i32 exitStatus,
    14:i32 exitSignal,
    15:string lastNode
}

struct TaskT {
    1:required common.Guid id,
    2:common.Guid layerId,
    3:common.Guid jobId,
    4:string name,
    5:i32 number,
    6:TaskState state,
    7:i32 order,
    8:i32 retries,
    9:i32 minCores,
    10:i32 minRam,
    11:TaskStatsT stats
}

struct FolderT {
    1:common.Guid id,
    2:string name,
    3:i32 minCores,
    4:i32 maxCores,
    5:i32 runCores,
    6:i32 runProcs,
    7:i32 order,
    8:TaskTotalsT totals,
    9:optional list<JobT> jobs
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
    1:required string name,
    2:required list<string> command,
    3:optional string range,
    4:optional list<string> tags,
    5:optional string serv,
    6:optional i32 minCores,
    7:optional i32 maxCores,
    8:optional i32 minRam,
    9:optional i32 maxRam,
    10:optional bool threadable,
    11:optional i32 maxRetries,
    12:i32 chunk = 1,
    13:list<DependSpecT> depends,
    14:list<TaskSpecT> tasks,
    15:Attrs env,
    16:bool isPost
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
    7:list<common.Guid> taskIds,
    8:list<common.Guid> nodeIds
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
    1:common.Guid outputId,
    2:string path,
    3:common.Attrs attrs
}

service RpcService {
    
    i64 getPlowTime() throws (1:PlowException e),

    list<ServiceT> getServices() throws (1:PlowException e),
    ServiceT createService(1:ServiceT svc) throws (1:PlowException e),
    void deleteService(1:common.Guid id) throws (1:PlowException e),
    void updateService(1:ServiceT svc) throws (1:PlowException e),

    ProjectT getProject(1:common.Guid id) throws (1:PlowException e),
    ProjectT getProjectByCode(1:string code) throws (1:PlowException e),
    list<ProjectT> getProjects() throws (1:PlowException e),
    list<ProjectT> getActiveProjects() throws (1:PlowException e),
    ProjectT createProject(1:string title, 2:string code) throws (1:PlowException e),
    void setProjectActive(1:common.Guid id, 2:bool active) throws (1:PlowException e),

    JobT launch(1:JobSpecT spec) throws (1:PlowException e),
    JobT getActiveJob(1:string name) throws (1:PlowException e),
    JobT getJob(1:common.Guid jobId) throws (1:PlowException e),
    void killJob(1:common.Guid jobId, 2:string reason) throws (1:PlowException e),
    void pauseJob(1:common.Guid jobId, 2:bool paused) throws (1:PlowException e),
    list<JobT> getJobs(1:JobFilterT filter) throws (1:PlowException e),
    list<OutputT> getJobOutputs(1:common.Guid jobId) throws (1:PlowException e),
    void setJobMinCores(1:common.Guid jobId, 2:i32 value) throws (1:PlowException e),
    void setJobMaxCores(1:common.Guid jobId, 2:i32 value) throws (1:PlowException e),
    void setJobAttrs(1:common.Guid jobId, 2:Attrs attrs) throws (1:PlowException e),
    list<DependT> getDependsOnJob(1:common.Guid jobId) throws (1:PlowException e),
    list<DependT> getJobDependsOn(1:common.Guid jobId) throws (1:PlowException e),
    JobSpecT getJobSpec(1:common.Guid jobId) throws (1:PlowException e),
    void createJobOnJobDepend(1:common.Guid jobId, 2:common.Guid onJobId) throws (1:PlowException e),

    void updateOutputAttrs(1:common.Guid outputId, 2:common.Attrs attrs) throws (1:PlowException e),
    void setOutputAttrs(1:common.Guid outputId, 2:common.Attrs attrs) throws (1:PlowException e),
    common.Attrs getOutputAttrs(1:common.Guid outputId) throws (1:PlowException e),

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
    OutputT addOutput(1:common.Guid layerId, 2:string path, 3:common.Attrs attrs) throws (1:PlowException e)
    list<OutputT> getLayerOutputs(1:common.Guid layerId) throws (1:PlowException e),
    void setLayerTags(1:common.Guid guid, 2:list<string> tags) throws (1:PlowException e),
    void setLayerMinCoresPerTask(1:common.Guid guid, 2:i32 minCores) throws (1:PlowException e),
    void setLayerMaxCoresPerTask(1:common.Guid guid, 2:i32 minCores) throws (1:PlowException e),
    void setLayerMinRamPerTask(1:common.Guid guid, 2:i32 minCores) throws (1:PlowException e),
    void setLayerThreadable(1:common.Guid guid, 2:bool threadable) throws (1:PlowException e),
    list<DependT> getDependsOnLayer(1:common.Guid layerId) throws (1:PlowException e),
    list<DependT> getLayerDependsOn(1:common.Guid layerId) throws (1:PlowException e),
    void createLayerOnLayerDepend(1:common.Guid layerId, 2:common.Guid onLayerId) throws (1:PlowException e),
    void createLayerOnTaskDepend(1:common.Guid layerId, 2:common.Guid onTaskId) throws (1:PlowException e),
    void createTaskByTaskDepend(1:common.Guid layerId, 2:common.Guid onLayerId) throws (1:PlowException e),

    TaskT getTask(1:common.Guid taskId) throws (1:PlowException e),
    list<TaskT> getTasks(1:TaskFilterT filter) throws (1:PlowException e),
    string getTaskLogPath(1:common.Guid taskId) throws (1:PlowException e),
    void retryTasks(1:TaskFilterT filter) throws (1:PlowException e),
    void eatTasks(1:TaskFilterT filter) throws (1:PlowException e),
    void killTasks(1:TaskFilterT filter) throws (1:PlowException e),
    list<DependT> getDependsOnTask(1:common.Guid taskId) throws (1:PlowException e),
    list<DependT> getTaskDependsOn(1:common.Guid taskId) throws (1:PlowException e),
    list<TaskStatsT> getTaskStats(1:common.Guid taskId) throws (1:PlowException e),
    void createTaskOnLayerDepend(1:common.Guid taskId, 2:common.Guid onLayerId) throws (1:PlowException e),
    void createTaskOnTaskDepend(1:common.Guid taskId, 2:common.Guid onTaskId) throws (1:PlowException e),

    void dropDepend(1:common.Guid dependId) throws (1:PlowException e),
    void activateDepend(1:common.Guid dependId) throws (1:PlowException e),
    DependT createDepend(1:DependSpecT dependSpec) throws (1:PlowException e),

    NodeT getNode(1:string name) throws (1:PlowException e),
    list<NodeT> getNodes(1:NodeFilterT filter) throws (1:PlowException e),
    void setNodeLocked(1:common.Guid id, 2:bool locked) throws (1:PlowException e),
    void setNodeCluster(1:common.Guid id, 2:common.Guid clusterId) throws (1:PlowException e),
    void setNodeTags(1:common.Guid id, 2:set<string> tags) throws (1:PlowException e),
    void setNodeSlotMode(1:common.Guid id, 2:SlotMode mode, 3:i32 slotCores, 4:i32 slotRam) throws (1:PlowException e),

    list<ProcT> getProcs(1:ProcFilterT filter) throws (1:PlowException e),
    ProcT getProc(1:common.Guid id) throws (1:PlowException e),

    ClusterT getCluster(1:string name) throws (1:PlowException e),
    list<ClusterT> getClustersByTag(1:string tag) throws (1:PlowException e),
    list<ClusterT> getClusters() throws (1:PlowException e),
    ClusterT createCluster(1:string name) throws (1:PlowException e),
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
