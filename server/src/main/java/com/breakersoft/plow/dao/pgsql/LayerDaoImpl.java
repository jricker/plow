package com.breakersoft.plow.dao.pgsql;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;

import org.slf4j.Logger;
import org.springframework.jdbc.core.PreparedStatementCreator;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import com.breakersoft.plow.Job;
import com.breakersoft.plow.Layer;
import com.breakersoft.plow.LayerE;
import com.breakersoft.plow.dao.AbstractDao;
import com.breakersoft.plow.dao.LayerDao;
import com.breakersoft.plow.json.BlueprintLayer;
import com.breakersoft.plow.util.JdbcUtils;

@Repository
public class LayerDaoImpl extends AbstractDao implements LayerDao {


    @SuppressWarnings("unused")
    private static final Logger logger =
        org.slf4j.LoggerFactory.getLogger(LayerDaoImpl.class);

    public static final RowMapper<Layer> MAPPER = new RowMapper<Layer>() {

        @Override
        public Layer mapRow(ResultSet rs, int rowNum)
                throws SQLException {
            LayerE layer = new LayerE();
            layer.setLayerId(UUID.fromString(rs.getString(1)));
            layer.setJobId(UUID.fromString(rs.getString(2)));
            return layer;
        }
    };

    private static final String GET =
            "SELECT " +
                "pk_layer,"+
                "pk_job " +
            "FROM " +
                "plow.layer ";

    @Override
    public Layer get(Job job, String name) {
        return jdbc.queryForObject(
                GET + "WHERE pk_job=? AND str_name=?",
                MAPPER, job.getJobId(), name);
    }

    @Override
    public Layer get(UUID id) {
        return jdbc.queryForObject(
                GET + "WHERE pk_layer=?",
                MAPPER, id);
    }

    private static final String INSERT[] = {

        JdbcUtils.Insert("plow.layer",
                "pk_layer", "pk_job", "str_name", "str_range",
                "str_command", "str_tags", "int_chunk_size", "int_order",
                "int_min_cores", "int_max_cores", "int_min_mem")
    };

    @Override
    public Layer create(final Job job, final BlueprintLayer layer, final int order) {

        final UUID id = UUID.randomUUID();

        jdbc.update(new PreparedStatementCreator() {
            @Override
            public PreparedStatement createPreparedStatement(final Connection conn) throws SQLException {
                final PreparedStatement ret = conn.prepareStatement(INSERT[0]);
                ret.setObject(1, id);
                ret.setObject(2, job.getJobId());
                ret.setString(3, layer.getName());
                ret.setString(4, layer.getRange());
                ret.setArray(5, conn.createArrayOf("text", layer.getCommand()));
                ret.setArray(6, conn.createArrayOf("text", layer.getTags()));
                ret.setInt(7, layer.getChunk());
                ret.setInt(8, order);
                ret.setInt(9, layer.getMinCores());
                ret.setInt(10, layer.getMaxCores());
                ret.setInt(11, layer.getMinMemory());

                return ret;
            }
        });

        /*
        jdbc.update(INSERT[0],
                id, job.getJobId(), layer.getName(), layer.getRange(),
                layer.getCommandAsJson(), layer.getChunk(), order,
                layer.getMinCores(), layer.getMaxCores(),
                layer.getMinMemory());
         */
        jdbc.update("INSERT INTO plow.layer_count (pk_layer) VALUES (?)", id);

        final LayerE result = new LayerE();
        result.setLayerId(id);
        result.setJobId(job.getJobId());
        return result;
    }
}