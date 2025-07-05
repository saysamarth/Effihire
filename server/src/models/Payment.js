const { DataTypes } = require('sequelize');
const sequelize = require('../config/connection');

const Payment = sequelize.define('Payment', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    task_application_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
            model: 'TaskApplications',
            key: 'id',
        },
    },
    amount: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false,
    },
    payment_status: {
        type: DataTypes.STRING(20),
        defaultValue: 'pending',
    },
    transaction_id: {
        type: DataTypes.STRING(255),
        unique: true,
    },
    payment_method: {
        type: DataTypes.STRING(50),
    },
}, {
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
});

module.exports = Payment;
