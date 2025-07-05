const { DataTypes } = require('sequelize');
const sequelize = require('../config/connection');

const TaskApplication = sequelize.define('TaskApplication', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    task_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'Tasks',
            key: 'id',
        },
    },
    user_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'Users',
            key: 'id',
        },
    },
    status: {
        type: DataTypes.STRING(20),
        defaultValue: 'pending',
        validate: {
            isIn: [['pending', 'accepted', 'rejected']],
        },
    },
    applied_at: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW,
    },
}, {
    timestamps: false,
});

module.exports = TaskApplication;