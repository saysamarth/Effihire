const { DataTypes } = require('sequelize');
const sequelize = require('../config/connection');

const BankDetails = sequelize.define('BankDetails', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    user_id: {
        type: DataTypes.UUID,
        allowNull: false,
        unique: true,
        references: {
            model: 'Users',
            key: 'id',
        },
    },
    account_number: {
        type: DataTypes.STRING(20),
        allowNull: false,
    },
    ifsc_code: {
        type: DataTypes.STRING(11),
        allowNull: false,
    },
    bank_name: {
        type: DataTypes.STRING(255),
    },
    branch_name: {
        type: DataTypes.STRING(255),
    },
}, {
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
});

module.exports = BankDetails;