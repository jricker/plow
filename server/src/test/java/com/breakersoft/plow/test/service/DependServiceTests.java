package com.breakersoft.plow.test.service;

import static org.junit.Assert.assertEquals;

import javax.annotation.Resource;

import org.junit.Test;

import com.breakersoft.plow.Depend;
import com.breakersoft.plow.Layer;
import com.breakersoft.plow.Task;
import com.breakersoft.plow.event.JobLaunchEvent;
import com.breakersoft.plow.service.DependService;
import com.breakersoft.plow.service.StateManager;
import com.breakersoft.plow.test.AbstractTest;
import com.breakersoft.plow.thrift.DependSpecT;
import com.breakersoft.plow.thrift.DependType;
import com.breakersoft.plow.thrift.JobSpecT;
import com.breakersoft.plow.thrift.TaskState;

public class DependServiceTests extends AbstractTest {

    @Resource
    DependService dependService;

    @Resource
    StateManager jobStateManager;

    @Test
    public void testSatisfyDepend() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1");
        JobSpecT spec2 = getTestJobSpec("depend_test_2");

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.JOB_ON_JOB;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();

        Depend depend = dependService.createDepend(dspec);

        assertEquals(10,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));

        dependService.satisfyDepend(depend);

        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
    }

    @Test
    public void testUnsatisfyDepend() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1");
        JobSpecT spec2 = getTestJobSpec("depend_test_2");

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.JOB_ON_JOB;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();

        Depend depend = dependService.createDepend(dspec);

        assertEquals(10,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));

        dependService.satisfyDepend(depend);

        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));

        dependService.unsatisfyDepend(depend);

        assertEquals(10,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));
    }

    @Test
    public void testJobOnJob() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1");
        JobSpecT spec2 = getTestJobSpec("depend_test_2");

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.JOB_ON_JOB;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();

        dependService.createDepend(dspec);

        assertEquals(10,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));

        jobStateManager.satisfyDependsOn(event2.getJob());

        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
    }

    @Test
    public void testLayerOnLayer() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1");
        JobSpecT spec2 = getTestJobSpec("depend_test_2");

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        Layer dependentLayer =
                jobService.getLayer(event1.getJob(), 0);
        Layer dependOnLayer =
                jobService.getLayer(event2.getJob(), 0);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.LAYER_ON_LAYER;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();
        dspec.dependentLayer = dependentLayer.getLayerId().toString();
        dspec.dependOnLayer = dependOnLayer.getLayerId().toString();

        dependService.createDepend(dspec);

        assertEquals(10,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));

        jobStateManager.satisfyDependsOn(dependOnLayer);

        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
    }

    @Test
    public void testLayerOnTask() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1");
        JobSpecT spec2 = getTestJobSpec("depend_test_2");

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        Layer dependentLayer =
                jobService.getLayer(event1.getJob(), 0);
        Layer dependOnLayer =
                jobService.getLayer(event2.getJob(), 0);
        Task dependOnTask =
                jobService.getTask(dependOnLayer, 1);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.LAYER_ON_TASK;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();
        dspec.dependentLayer = dependentLayer.getLayerId().toString();
        dspec.dependOnLayer = dependOnLayer.getLayerId().toString();
        dspec.dependOnTask = dependOnTask.getTaskId().toString();

        dependService.createDepend(dspec);

        assertEquals(10,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));

        jobStateManager.satisfyDependsOn(dependOnTask);

        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));

    }

    @Test
    public void testTaskOnLayer() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1");
        JobSpecT spec2 = getTestJobSpec("depend_test_2");

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        Layer dependentLayer =
                jobService.getLayer(event1.getJob(), 0);
        Layer dependOnLayer =
                jobService.getLayer(event2.getJob(), 0);
        Task dependentTask =
                jobService.getTask(dependentLayer, 1);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.TASK_ON_LAYER;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();
        dspec.dependentLayer = dependentLayer.getLayerId().toString();
        dspec.dependOnLayer = dependOnLayer.getLayerId().toString();
        dspec.dependentTask = dependentTask.getTaskId().toString();

        dependService.createDepend(dspec);

        assertEquals(1,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));

        jobStateManager.satisfyDependsOn(dependOnLayer);

        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
    }

    @Test
    public void testTaskOnTask() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1");
        JobSpecT spec2 = getTestJobSpec("depend_test_2");

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        Layer dependentLayer =
                jobService.getLayer(event1.getJob(), 0);
        Layer dependOnLayer =
                jobService.getLayer(event2.getJob(), 0);
        Task dependentTask =
                jobService.getTask(dependentLayer, 1);
        Task dependOnTask =
                jobService.getTask(dependOnLayer, 1);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.TASK_ON_TASK;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();
        dspec.dependentLayer = dependentLayer.getLayerId().toString();
        dspec.dependOnLayer = dependOnLayer.getLayerId().toString();
        dspec.dependentTask = dependentTask.getTaskId().toString();
        dspec.dependOnTask = dependOnTask.getTaskId().toString();

        dependService.createDepend(dspec);

        assertEquals(1,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));

        jobStateManager.satisfyDependsOn(dependOnTask);

        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));

        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT COUNT(1) FROM task WHERE int_state=?",
                TaskState.DEPEND.ordinal()));

    }

    @Test
    public void testTaskByTask() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1");
        JobSpecT spec2 = getTestJobSpec("depend_test_2");

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        Layer dependentLayer =
                jobService.getLayer(event1.getJob(), 0);
        Layer dependOnLayer =
                jobService.getLayer(event2.getJob(), 0);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.TASK_BY_TASK;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();
        dspec.dependentLayer = dependentLayer.getLayerId().toString();
        dspec.dependOnLayer = dependOnLayer.getLayerId().toString();

        dependService.createDepend(dspec);

        assertEquals(10,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));

        // Satisifed handled by satisfyDependsOn(task)

    }

    @Test
    public void testTaskByTaskChunkedOnNonChunked() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1", "1-10", 5);
        JobSpecT spec2 = getTestJobSpec("depend_test_2", "1-10", 1);

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        Layer dependentLayer =
                jobService.getLayer(event1.getJob(), 0);
        Layer dependOnLayer =
                jobService.getLayer(event2.getJob(), 0);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.TASK_BY_TASK;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();
        dspec.dependentLayer = dependentLayer.getLayerId().toString();
        dspec.dependOnLayer = dependOnLayer.getLayerId().toString();

        dependService.createDepend(dspec);

        assertEquals(10,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));
        assertEquals(10,
                simpleJdbcTemplate.queryForInt("SELECT COUNT(1) FROM plow.depend"));
    }

    @Test
    public void testTaskByTaskNonChunkedOnChunked() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1", "1-10", 1);
        JobSpecT spec2 = getTestJobSpec("depend_test_2", "1-10", 5);

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        Layer dependentLayer =
                jobService.getLayer(event1.getJob(), 0);
        Layer dependOnLayer =
                jobService.getLayer(event2.getJob(), 0);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.TASK_BY_TASK;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();
        dspec.dependentLayer = dependentLayer.getLayerId().toString();
        dspec.dependOnLayer = dependOnLayer.getLayerId().toString();

        dependService.createDepend(dspec);

        assertEquals(10,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));
        assertEquals(10,
                simpleJdbcTemplate.queryForInt("SELECT COUNT(1) FROM plow.depend"));
    }

    @Test
    public void testTaskByTaskChunkedOnChunked() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1", "1-10", 5);
        JobSpecT spec2 = getTestJobSpec("depend_test_2", "1-10", 5);

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        Layer dependentLayer =
                jobService.getLayer(event1.getJob(), 0);
        Layer dependOnLayer =
                jobService.getLayer(event2.getJob(), 0);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.TASK_BY_TASK;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();
        dspec.dependentLayer = dependentLayer.getLayerId().toString();
        dspec.dependOnLayer = dependOnLayer.getLayerId().toString();

        dependService.createDepend(dspec);

        assertEquals(2,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));
        assertEquals(2,
                simpleJdbcTemplate.queryForInt("SELECT COUNT(1) FROM plow.depend"));
    }

    @Test
    public void testTaskByTaskChunked2OnChunked5() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1", "1-10", 2);
        JobSpecT spec2 = getTestJobSpec("depend_test_2", "1-10", 5);

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        Layer dependentLayer =
                jobService.getLayer(event1.getJob(), 0);
        Layer dependOnLayer =
                jobService.getLayer(event2.getJob(), 0);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.TASK_BY_TASK;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();
        dspec.dependentLayer = dependentLayer.getLayerId().toString();
        dspec.dependOnLayer = dependOnLayer.getLayerId().toString();

        dependService.createDepend(dspec);

        assertEquals(6,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));
        assertEquals(6,
                simpleJdbcTemplate.queryForInt("SELECT COUNT(1) FROM plow.depend"));
    }

    @Test
    public void testTaskByTaskChunked5OnChunked2() {
        JobSpecT spec1 = getTestJobSpec("depend_test_1", "1-10", 2);
        JobSpecT spec2 = getTestJobSpec("depend_test_2", "1-10", 5);

        JobLaunchEvent event1 = jobService.launch(spec1);
        JobLaunchEvent event2 = jobService.launch(spec2);

        Layer dependentLayer =
                jobService.getLayer(event1.getJob(), 0);
        Layer dependOnLayer =
                jobService.getLayer(event2.getJob(), 0);

        DependSpecT dspec = new DependSpecT();
        dspec.type = DependType.TASK_BY_TASK;
        dspec.dependentJob = event1.getJob().getJobId().toString();
        dspec.dependOnJob = event2.getJob().getJobId().toString();
        dspec.dependentLayer = dependentLayer.getLayerId().toString();
        dspec.dependOnLayer = dependOnLayer.getLayerId().toString();

        dependService.createDepend(dspec);

        assertEquals(6,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event1.getJob().getJobId()));
        assertEquals(0,
                simpleJdbcTemplate.queryForInt("SELECT SUM(int_depend_count) FROM task WHERE pk_job=?",
                event2.getJob().getJobId()));
        assertEquals(6,
                simpleJdbcTemplate.queryForInt("SELECT COUNT(1) FROM plow.depend"));
    }
}
