const { DataTypes } = require('sequelize');
const sequelize = require('../config/connection');

const Task = sequelize.define('Task', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    company_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'Companies',
            key: 'id',
        },
    },
    title: {
        type: DataTypes.STRING(100),
        allowNull: false,
    },
    job_role: {
        type: DataTypes.STRING(100),
        allowNull: false,
    },
    offered_amount: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false,
    },
    location: {
        type: DataTypes.TEXT,
        allowNull: false,
    },
    location_coordinate: {
        type: DataTypes.JSONB,
        allowNull: false,
    },
    required_number_of_workers: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    status: {
        type: DataTypes.STRING(20),
        defaultValue: 'open',
    },
    expires_at: {
        type: DataTypes.DATE,
    },
}, {
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
});

module.exports = Task;
